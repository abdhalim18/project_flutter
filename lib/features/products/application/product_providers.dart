import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import '../../../core/sync/pull_sync_service.dart';
import '../data/category_repository.dart';
import '../data/product_repository.dart';
import '../domain/category.dart';
import '../domain/product.dart';

final pullSyncServiceProvider = Provider<PullSyncService>((ref) {
  return PullSyncService(ref.watch(appDatabaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(appDatabaseProvider), ref.watch(pullSyncServiceProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(appDatabaseProvider), ref.watch(pullSyncServiceProvider));
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
});
