// Checkout while the backend is unreachable must leave the sale queued
// locally, and the count the POS sync bar shows must include it.
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/db/app_database.dart';
import 'package:pos_app/core/db/database_provider.dart';
import 'package:pos_app/features/pos/application/pos_providers.dart';
import 'package:pos_app/features/pos/domain/cart_item.dart';

void main() {
  test('offline checkout stays pending and is counted by the sync bar', () async {
    // Port 9 on localhost refuses connections immediately, like having no network.
    dotenv.loadFromString(envString: 'API_BASE_URL=http://127.0.0.1:9');

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.products).insert(
      ProductsCompanion.insert(id: 'p1', name: 'Croissant', price: 20000, stockQty: 10),
    );

    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final counts = <int>[];
    container.listen(
      pendingSyncCountProvider,
      (_, next) => next.whenData(counts.add),
      fireImmediately: true,
    );
    expect(await container.read(pendingSyncCountProvider.future), 0);

    await container.read(transactionRepositoryProvider).checkout(
      cashierId: 'kasir-1',
      items: const [CartItem(productId: 'p1', name: 'Croissant', price: 20000, qty: 1)],
      discountAmount: 0,
      paymentMethod: 'cash',
      paymentReceived: 20000,
    );
    // Same call the cart screen makes right after checkout: it must report
    // "not sent" so the cashier sees the offline message.
    final txId = (await db.select(db.transactions).getSingle()).id;
    expect(await container.read(syncEngineProvider).trySyncNow(txId), isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final tx = await db.select(db.transactions).getSingle();
    expect(tx.syncState, 'pending');
    expect(tx.syncAttemptCount, 1);
    expect(tx.lastSyncError, isNotNull);
    expect(counts.last, 1);

    final product = await (db.select(db.products)..where((p) => p.id.equals('p1'))).getSingle();
    expect(product.stockQty, 9);
  });
}
