import '../../../core/db/app_database.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/sync/pull_sync_service.dart';
import '../domain/category.dart';

class CategoryRepository {
  CategoryRepository(this._db, this._pullSyncService);

  final AppDatabase _db;
  final PullSyncService _pullSyncService;

  Stream<List<Category>> watchCategories() {
    return _db.select(_db.categories).watch().map(
      (rows) => rows.map(Category.fromRow).toList(),
    );
  }

  Future<void> create(String name) async {
    await AppSupabase.client.from('categories').insert({'name': name});
    await _pullSyncService.pullAll();
  }

  Future<void> delete(String id) async {
    await AppSupabase.client.from('categories').delete().eq('id', id);
    await _pullSyncService.pullAll();
  }
}
