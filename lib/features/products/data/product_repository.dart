import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/sync/pull_sync_service.dart';
import '../domain/product.dart';

class ProductRepository {
  ProductRepository(this._db, this._pullSyncService);

  static const _bucket = 'product-photos';
  final _uuid = const Uuid();

  final AppDatabase _db;
  final PullSyncService _pullSyncService;

  Stream<List<Product>> watchProducts() {
    return _db.select(_db.products).watch().map(
      (rows) => rows.map(Product.fromRow).toList(),
    );
  }

  Future<void> create(Product product) async {
    await AppSupabase.client.from('products').insert(product.toInsertMap());
    await _pullSyncService.pullAll();
  }

  Future<void> update(String id, Product product) async {
    await AppSupabase.client.from('products').update(product.toInsertMap()).eq('id', id);
    await _pullSyncService.pullAll();
  }

  /// Hard-deletes the product where possible. Products that were ever sold
  /// have rows in `stock_movements` referencing them (that table's
  /// `product_id` is NOT NULL with no ON DELETE clause -- the stock ledger
  /// is intentionally immutable/append-only), so the delete is rejected by
  /// a foreign key constraint; in that case this falls back to marking the
  /// product inactive instead, which already hides it from the kasir POS
  /// grid while preserving sales history. Returns true if hard-deleted,
  /// false if soft-deleted, so the caller can tell the admin which happened.
  Future<bool> delete(String id) async {
    try {
      await AppSupabase.client.from('products').delete().eq('id', id);
      await _pullSyncService.pullAll();
      return true;
    } on PostgrestException catch (e) {
      if (e.code != '23503') rethrow;
      await AppSupabase.client.from('products').update({'is_active': false}).eq('id', id);
      await _pullSyncService.pullAll();
      return false;
    }
  }

  Future<void> setActive(String id, bool isActive) async {
    await AppSupabase.client.from('products').update({'is_active': isActive}).eq('id', id);
    await _pullSyncService.pullAll();
  }

  /// Clears the negative-stock review flag once an admin has looked into it
  /// (e.g. restocked or accepted the oversell). Requires connectivity: this
  /// is a deliberate admin decision, not something to queue offline.
  Future<void> acknowledgeStockReview(String id) async {
    await AppSupabase.client.from('products').update({'needs_review': false}).eq('id', id);
    await _pullSyncService.pullAll();
  }

  Future<String> uploadPhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    final extension = file.name.contains('.') ? file.name.split('.').last : 'jpg';
    final path = '${_uuid.v4()}.$extension';

    await AppSupabase.client.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));

    return AppSupabase.client.storage.from(_bucket).getPublicUrl(path);
  }
}
