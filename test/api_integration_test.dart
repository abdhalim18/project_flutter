// End-to-end check of the app's data layer against a running backend (pos-api).
// Skipped unless API_TEST_URL is set, e.g.:
//
//   API_TEST_URL=http://localhost:3000 \
//   API_TEST_ADMIN_EMAIL=... API_TEST_ADMIN_PASSWORD=... \
//   API_TEST_KASIR_EMAIL=... API_TEST_KASIR_PASSWORD=... \
//   flutter test test/api_integration_test.dart
//
// It writes real data (one sale, one temporary product) to that backend, so
// point it at a local or test database, not production.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_app/core/auth/auth_repository.dart';
import 'package:pos_app/core/auth/role.dart';
import 'package:pos_app/core/db/app_database.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/sync/pull_sync_service.dart';
import 'package:pos_app/core/sync/sync_engine.dart';
import 'package:pos_app/features/pos/data/transaction_repository.dart';
import 'package:pos_app/features/pos/domain/cart_item.dart';
import 'package:pos_app/features/products/data/product_repository.dart';
import 'package:pos_app/features/products/domain/product.dart';
import 'package:pos_app/features/reports/data/report_repository.dart';

final _env = Platform.environment;
final _url = _env['API_TEST_URL'];

// Smallest valid PNG (1x1 pixel).
final _png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0xF0,
  0x1F,
  0x00,
  0x05,
  0x00,
  0x01,
  0xFF,
  0x89,
  0x99,
  0x3D,
  0x1D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  group('API integration', () {
    late AppDatabase db;
    late PullSyncService pull;
    final auth = AuthRepository();

    setUpAll(() {
      // Plain `test` (no widget binding) so real HTTP is allowed.
      FlutterSecureStorage.setMockInitialValues({});
      dotenv.loadFromString(envString: 'API_BASE_URL=$_url');
    });

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      pull = PullSyncService(db);
    });

    tearDown(() async {
      await auth.signOut();
      await db.close();
    });

    test('wrong password is rejected with a readable message', () async {
      await expectLater(
        auth.signInWithPassword(email: _env['API_TEST_KASIR_EMAIL']!, password: 'salah-sekali'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
      );
      expect(auth.currentSession, isNull);
    });

    test('kasir: login, pull catalog, offline checkout, sync is idempotent', () async {
      await auth.signInWithPassword(
        email: _env['API_TEST_KASIR_EMAIL']!,
        password: _env['API_TEST_KASIR_PASSWORD']!,
      );
      final cashierId = auth.currentSession!.user.id;
      expect((await auth.fetchCurrentProfile())!.role, AppRole.kasir);

      await pull.pullAll();
      final products = await (db.select(db.products)..where((p) => p.isActive.equals(true))).get();
      expect(products, isNotEmpty);
      final product = products.first;

      final txId = await TransactionRepository(db).checkout(
        cashierId: cashierId,
        items: [CartItem(productId: product.id, name: product.name, price: product.price, qty: 1)],
        discountAmount: 0,
        paymentMethod: 'cash',
        paymentReceived: product.price,
      );

      final engine = SyncEngine(db, pull);
      await engine.syncPendingTransactions(force: true);
      final synced = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(txId))).getSingle();
      expect(synced.syncState, 'synced', reason: synced.lastSyncError ?? '');

      // Server-authoritative stock pulled back after sync: exactly one unit sold.
      final after = await (db.select(
        db.products,
      )..where((p) => p.id.equals(product.id))).getSingle();
      expect(after.stockQty, product.stockQty - 1);

      // Pushing the same transaction again must not deduct stock twice.
      await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
        const TransactionsCompanion(syncState: Value('pending')),
      );
      await engine.syncPendingTransactions(force: true);
      final again = await (db.select(
        db.products,
      )..where((p) => p.id.equals(product.id))).getSingle();
      expect(again.stockQty, product.stockQty - 1);
    });

    test('admin: photo upload, product CRUD, sales report', () async {
      await auth.signInWithPassword(
        email: _env['API_TEST_ADMIN_EMAIL']!,
        password: _env['API_TEST_ADMIN_PASSWORD']!,
      );
      final repo = ProductRepository(db, pull);

      final photoUrl = await repo.uploadPhoto(
        XFile.fromData(_png, name: 'tes.png', mimeType: 'image/png'),
      );
      expect(photoUrl, startsWith(_url!));

      const name = 'Produk Uji Integrasi';
      await repo.create(
        const Product(
          id: '',
          name: name,
          price: 12345,
          stockQty: 3,
          isActive: true,
        ).copyWithPhoto(photoUrl),
      );
      var row = await (db.select(db.products)..where((p) => p.name.equals(name))).getSingle();
      expect(row.photoUrl, photoUrl);
      expect(row.price, 12345);

      await repo.setActive(row.id, false);
      row = await (db.select(db.products)..where((p) => p.id.equals(row.id))).getSingle();
      expect(row.isActive, isFalse);

      expect(await repo.delete(row.id), isTrue);
      expect(
        await (db.select(db.products)..where((p) => p.id.equals(row.id))).getSingleOrNull(),
        isNull,
      );

      final now = DateTime.now();
      final summary = await ReportRepository(db).adminSummary(
        from: DateTime(now.year, now.month, now.day),
        to: DateTime(now.year, now.month, now.day + 1),
      );
      expect(summary.transactionCount, greaterThan(0));
      expect(summary.byCashier, isNotEmpty);
    });
  }, skip: _url == null ? 'Set API_TEST_URL to run against a backend' : false);
}

extension on Product {
  Product copyWithPhoto(String url) => Product(
    id: id,
    name: name,
    price: price,
    stockQty: stockQty,
    isActive: isActive,
    categoryId: categoryId,
    sku: sku,
    photoUrl: url,
  );
}
