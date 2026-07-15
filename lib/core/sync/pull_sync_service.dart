import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../network/supabase_client.dart';

/// One-directional pull: Supabase (source of truth) -> local Drift mirror.
/// Phase 3 only reads through this cache; bidirectional sync (outbox, push)
/// lands in Phase 4/5 for the offline-first POS flow.
class PullSyncService {
  PullSyncService(this._db);

  final AppDatabase _db;

  Future<void> pullAll() async {
    final categoryRows = await AppSupabase.client.from('categories').select();
    final productRows = await AppSupabase.client.from('products').select();

    await _db.transaction(() async {
      await _db.delete(_db.categories).go();
      await _db.batch((batch) {
        batch.insertAll(
          _db.categories,
          categoryRows.map(
            (row) => CategoriesCompanion.insert(
              id: row['id'] as String,
              name: row['name'] as String,
            ),
          ),
        );
      });

      await _db.delete(_db.products).go();
      await _db.batch((batch) {
        batch.insertAll(
          _db.products,
          productRows.map(
            (row) => ProductsCompanion.insert(
              id: row['id'] as String,
              categoryId: Value(row['category_id'] as String?),
              name: row['name'] as String,
              sku: Value(row['sku'] as String?),
              price: (row['price'] as num).toDouble(),
              stockQty: row['stock_qty'] as int,
              photoUrl: Value(row['photo_url'] as String?),
              isActive: Value(row['is_active'] as bool),
              needsReview: Value(row['needs_review'] as bool? ?? false),
            ),
          ),
        );
      });

      final now = DateTime.now();
      await _db.into(_db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(entityKey: 'categories', lastPulledAt: now),
      );
      await _db.into(_db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(entityKey: 'products', lastPulledAt: now),
      );
    });
  }
}
