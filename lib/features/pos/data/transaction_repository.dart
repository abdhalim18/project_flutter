import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/cart_item.dart';

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  /// Writes the transaction, its items, and the resulting stock movements
  /// atomically to the local Drift DB, decrementing local stock optimistically
  /// in the same transaction. Never touches Supabase directly — the sync
  /// engine picks up rows with `syncState = 'pending'` and pushes them once
  /// online. This is what makes checkout work with zero connectivity.
  Future<String> checkout({
    required String cashierId,
    required List<CartItem> items,
    required double discountAmount,
    required String paymentMethod,
    required double paymentReceived,
  }) async {
    final transactionId = _uuid.v4();
    final now = DateTime.now();
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final totalAmount = subtotal - discountAmount;
    final changeAmount = paymentReceived - totalAmount;

    await _db.transaction(() async {
      await _db.into(_db.transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          cashierId: cashierId,
          totalAmount: totalAmount,
          discountAmount: Value(discountAmount),
          paymentMethod: paymentMethod,
          paymentReceived: Value(paymentReceived),
          changeAmount: Value(changeAmount),
          clientCreatedAt: now,
        ),
      );

      for (final item in items) {
        await _db.into(_db.transactionItems).insert(
          TransactionItemsCompanion.insert(
            id: _uuid.v4(),
            transactionId: transactionId,
            productId: Value(item.productId),
            productNameSnapshot: item.name,
            unitPrice: item.price,
            qty: item.qty,
            subtotal: item.subtotal,
          ),
        );

        await _db.into(_db.stockMovements).insert(
          StockMovementsCompanion.insert(
            id: _uuid.v4(),
            productId: item.productId,
            changeQty: -item.qty,
            reason: 'sale',
            referenceId: Value(transactionId),
            createdAt: now,
          ),
        );

        final product = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(item.productId))).getSingleOrNull();
        if (product != null) {
          await (_db.update(_db.products)..where((p) => p.id.equals(item.productId))).write(
            ProductsCompanion(stockQty: Value(product.stockQty - item.qty)),
          );
        }
      }
    });

    return transactionId;
  }
}
