import '../../../core/db/app_database.dart' show ProductRow;

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQty,
    required this.isActive,
    this.categoryId,
    this.sku,
    this.photoUrl,
    this.needsReview = false,
  });

  final String id;
  final String name;
  final num price;
  final int stockQty;
  final bool isActive;
  final String? categoryId;
  final String? sku;
  final String? photoUrl;
  // True when a stock movement drove stock_qty negative (e.g. two offline
  // cashiers selling the last unit before either synced) and an admin
  // hasn't acknowledged it yet.
  final bool needsReview;

  factory Product.fromRow(ProductRow row) {
    return Product(
      id: row.id,
      name: row.name,
      price: row.price,
      stockQty: row.stockQty,
      isActive: row.isActive,
      categoryId: row.categoryId,
      sku: row.sku,
      photoUrl: row.photoUrl,
      needsReview: row.needsReview,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'price': price,
      'stock_qty': stockQty,
      'is_active': isActive,
      'category_id': categoryId,
      'sku': sku,
      'photo_url': photoUrl,
    };
  }
}
