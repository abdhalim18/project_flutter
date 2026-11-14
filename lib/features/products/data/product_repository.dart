import 'package:image_picker/image_picker.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/pull_sync_service.dart';
import '../domain/product.dart';

class ProductRepository {
  ProductRepository(this._db, this._pullSyncService);

  static const _imageTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
    'heic': 'image/heic',
  };

  final AppDatabase _db;
  final PullSyncService _pullSyncService;

  ApiClient get _api => ApiClient.instance;

  Stream<List<Product>> watchProducts() {
    return _db
        .select(_db.products)
        .watch()
        .map((rows) => rows.map(Product.fromRow).toList());
  }

  Future<void> create(Product product) async {
    await _api.post('/api/products', product.toInsertMap());
    await _pullSyncService.pullAll();
  }

  Future<void> update(String id, Product product) async {
    await _api.patch('/api/products/$id', product.toInsertMap());
    await _pullSyncService.pullAll();
  }

  /// Hard-deletes the product where possible. Products that were ever sold
  /// have rows in `stock_movements` referencing them (the stock ledger is
  /// intentionally immutable/append-only), so the server deactivates those
  /// instead, which already hides them from the kasir POS grid while
  /// preserving sales history. Returns true if hard-deleted, false if
  /// soft-deleted, so the caller can tell the admin which happened.
  Future<bool> delete(String id) async {
    final json = await _api.delete('/api/products/$id') as Map<String, dynamic>;
    await _pullSyncService.pullAll();
    return json['deleted'] as bool;
  }

  Future<void> setActive(String id, bool isActive) async {
    await _api.patch('/api/products/$id', {'is_active': isActive});
    await _pullSyncService.pullAll();
  }

  /// Clears the negative-stock review flag once an admin has looked into it
  /// (e.g. restocked or accepted the oversell). Requires connectivity: this
  /// is a deliberate admin decision, not something to queue offline.
  Future<void> acknowledgeStockReview(String id) async {
    await _api.patch('/api/products/$id', {'needs_review': false});
    await _pullSyncService.pullAll();
  }

  /// Uploads the photo bytes to the backend (stored in the database) and
  /// returns the public URL to save as the product's photo_url.
  Future<String> uploadPhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    final extension = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : 'jpg';
    final contentType = file.mimeType ?? _imageTypes[extension] ?? 'image/jpeg';

    final json =
        await _api.postBytes('/api/photos', bytes, contentType)
            as Map<String, dynamic>;
    return json['url'] as String;
  }
}
