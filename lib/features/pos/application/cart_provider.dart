import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/domain/product.dart';
import '../domain/cart_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addProduct(Product product) {
    final index = state.indexWhere((item) => item.productId == product.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(qty: updated[index].qty + 1);
      state = updated;
    } else {
      state = [
        ...state,
        CartItem(
          productId: product.id,
          name: product.name,
          price: product.price.toDouble(),
          qty: 1,
          photoUrl: product.photoUrl,
        ),
      ];
    }
  }

  void updateQty(String productId, int qty) {
    if (qty <= 0) {
      removeProduct(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId) item.copyWith(qty: qty) else item,
    ];
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clear() => state = [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<double>(0, (sum, item) => sum + item.subtotal);
});
