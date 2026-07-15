import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/sales_summary.dart';

typedef _SaleRecord = ({
  String cashierId,
  String cashierLabel,
  double totalAmount,
  DateTime createdAt,
  List<({String name, int qty, double subtotal})> items,
});

/// Kasir reports read Drift only -- exactly the sales that cashier made on
/// this device, which is what makes the report offline-ready. Admin reports
/// need every cashier's numbers, which only Supabase (source of truth for
/// synced data) can answer, so that path requires connectivity.
class ReportRepository {
  ReportRepository(this._db);

  final AppDatabase _db;

  Future<SalesSummary> kasirSummary({
    required String cashierId,
    required DateTime from,
    required DateTime to,
  }) async {
    final txRows = await (_db.select(_db.transactions)..where(
          (t) =>
              t.cashierId.equals(cashierId) &
              t.clientCreatedAt.isBiggerOrEqualValue(from) &
              t.clientCreatedAt.isSmallerThanValue(to),
        ))
        .get();

    if (txRows.isEmpty) return SalesSummary.empty;

    final txIds = txRows.map((t) => t.id).toList();
    final itemRows = await (_db.select(
      _db.transactionItems,
    )..where((i) => i.transactionId.isIn(txIds))).get();
    final itemsByTx = <String, List<TransactionItemRow>>{};
    for (final item in itemRows) {
      itemsByTx.putIfAbsent(item.transactionId, () => []).add(item);
    }

    return _aggregate(
      txRows.map(
        (t) => (
          cashierId: t.cashierId,
          cashierLabel: 'Saya',
          totalAmount: t.totalAmount,
          createdAt: t.clientCreatedAt,
          items: (itemsByTx[t.id] ?? const <TransactionItemRow>[])
              .map((i) => (name: i.productNameSnapshot, qty: i.qty, subtotal: i.subtotal))
              .toList(),
        ),
      ),
      includeCashierBreakdown: false,
    );
  }

  Future<SalesSummary> adminSummary({required DateTime from, required DateTime to}) async {
    final rows = await AppSupabase.client
        .from('transactions')
        .select(
          'cashier_id, total_amount, client_created_at, '
          'cashier:profiles(full_name), '
          'transaction_items(product_name_snapshot, qty, subtotal)',
        )
        .gte('client_created_at', from.toIso8601String())
        .lt('client_created_at', to.toIso8601String());

    if (rows.isEmpty) return SalesSummary.empty;

    return _aggregate(
      rows.map((row) {
        final cashierId = row['cashier_id'] as String;
        final cashier = row['cashier'] as Map<String, dynamic>?;
        final items = (row['transaction_items'] as List).cast<Map<String, dynamic>>();
        return (
          cashierId: cashierId,
          cashierLabel: (cashier?['full_name'] as String?) ?? cashierId.substring(0, 8),
          totalAmount: (row['total_amount'] as num).toDouble(),
          createdAt: DateTime.parse(row['client_created_at'] as String).toLocal(),
          items: items
              .map(
                (i) => (
                  name: i['product_name_snapshot'] as String,
                  qty: i['qty'] as int,
                  subtotal: (i['subtotal'] as num).toDouble(),
                ),
              )
              .toList(),
        );
      }),
      includeCashierBreakdown: true,
    );
  }

  SalesSummary _aggregate(Iterable<_SaleRecord> transactions, {required bool includeCashierBreakdown}) {
    var totalAmount = 0.0;
    var transactionCount = 0;
    final dayTotals = <DateTime, ({double total, int count})>{};
    final productTotals = <String, ({int qty, double total})>{};
    final cashierTotals = <String, ({String label, double total, int count})>{};

    for (final tx in transactions) {
      totalAmount += tx.totalAmount;
      transactionCount++;

      final day = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
      final existingDay = dayTotals[day];
      dayTotals[day] = (
        total: (existingDay?.total ?? 0) + tx.totalAmount,
        count: (existingDay?.count ?? 0) + 1,
      );

      if (includeCashierBreakdown) {
        final existingCashier = cashierTotals[tx.cashierId];
        cashierTotals[tx.cashierId] = (
          label: tx.cashierLabel,
          total: (existingCashier?.total ?? 0) + tx.totalAmount,
          count: (existingCashier?.count ?? 0) + 1,
        );
      }

      for (final item in tx.items) {
        final existingProduct = productTotals[item.name];
        productTotals[item.name] = (
          qty: (existingProduct?.qty ?? 0) + item.qty,
          total: (existingProduct?.total ?? 0) + item.subtotal,
        );
      }
    }

    final byDay = dayTotals.entries
        .map((e) => DailySales(day: e.key, total: e.value.total, transactionCount: e.value.count))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    final topProducts =
        productTotals.entries
            .map((e) => ProductSales(productName: e.key, qty: e.value.qty, total: e.value.total))
            .toList()
          ..sort((a, b) => b.qty.compareTo(a.qty));

    final byCashier =
        cashierTotals.entries
            .map(
              (e) => CashierSales(
                cashierId: e.key,
                label: e.value.label,
                total: e.value.total,
                transactionCount: e.value.count,
              ),
            )
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));

    return SalesSummary(
      totalAmount: totalAmount,
      transactionCount: transactionCount,
      byDay: byDay,
      topProducts: topProducts.take(5).toList(),
      byCashier: byCashier,
    );
  }
}
