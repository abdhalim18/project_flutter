class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
    this.photoUrl,
  });

  final String productId;
  final String name;
  final double price;
  final int qty;
  final String? photoUrl;

  double get subtotal => price * qty;

  CartItem copyWith({int? qty}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      qty: qty ?? this.qty,
      photoUrl: photoUrl,
    );
  }
}
