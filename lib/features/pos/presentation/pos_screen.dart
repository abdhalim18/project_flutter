import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../products/application/product_providers.dart';
import '../../products/domain/product.dart';
import '../application/cart_provider.dart';
import '../application/pos_providers.dart';
import 'qty_stepper.dart';
import 'sync_status_bar.dart';

final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

/// Selected category filter on the POS grid; null means "show everything".
class _SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

final _selectedCategoryProvider = NotifierProvider<_SelectedCategoryNotifier, String?>(
  _SelectedCategoryNotifier.new,
);

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pullSyncServiceProvider).pullAll().catchError((_) {});
      ref.read(syncEngineProvider).syncPendingTransactions().catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(autoSyncOnReconnectProvider);

    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final cart = ref.watch(cartProvider);
    final cartCount = cart.fold<int>(0, (sum, item) => sum + item.qty);
    final cartQtyByProduct = {for (final item in cart) item.productId: item.qty};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            onPressed: cart.isEmpty ? null : () => context.push('/pos/cart'),
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cart.isNotEmpty,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(32),
          child: SyncStatusBar(),
        ),
      ),
      body: productsAsync.when(
        data: (products) {
          final active = products.where((p) => p.isActive).toList();
          if (active.isEmpty) {
            return const Center(child: Text('Belum ada produk aktif.'));
          }

          final categories = categoriesAsync.value ?? const [];
          final visible = selectedCategory == null
              ? active
              : active.where((p) => p.categoryId == selectedCategory).toList();

          return Column(
            children: [
              if (categories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ChoiceChip(
                          label: const Text('Semua'),
                          selected: selectedCategory == null,
                          onSelected: (_) => ref.read(_selectedCategoryProvider.notifier).select(null),
                        ),
                        for (final category in categories) ...[
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(category.name),
                            selected: selectedCategory == category.id,
                            onSelected: (_) =>
                                ref.read(_selectedCategoryProvider.notifier).select(category.id),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('Tidak ada produk di kategori ini.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final product = visible[index];
                          final qty = cartQtyByProduct[product.id] ?? 0;
                          final cartNotifier = ref.read(cartProvider.notifier);
                          // Tidak bisa menambah melebihi stok yang tercatat.
                          final canAdd = qty < product.stockQty;
                          return _ProductTile(
                            product: product,
                            qtyInCart: qty,
                            onAdd: canAdd ? () => cartNotifier.addProduct(product) : null,
                            onRemove: qty > 0
                                ? () => cartNotifier.updateQty(product.id, qty - 1)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat produk: $err')),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: () => context.push('/pos/cart'),
                  child: Text('Lihat Keranjang ($cartCount item)'),
                ),
              ),
            ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.qtyInCart,
    required this.onAdd,
    required this.onRemove,
  });

  final Product product;
  final int qtyInCart;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outOfStock = product.stockQty <= 0;
    final placeholderColor = theme.colorScheme.surfaceContainerHighest;

    return Card(
      // Kartu yang sudah ada di keranjang diberi garis tepi warna utama
      // (sudut 16 sama dengan cardTheme di AppTheme).
      shape: qtyInCart > 0
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
            )
          : null,
      child: InkWell(
        // Mengetuk kartu tetap menambah satu, sama seperti tombol +.
        onTap: onAdd,
        child: Opacity(
          opacity: outOfStock ? 0.55 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.photoUrl == null || product.photoUrl!.isEmpty
                        ? Container(
                            color: placeholderColor,
                            child: Icon(
                              Icons.local_cafe_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 32,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: product.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, _) => Container(color: placeholderColor),
                            errorWidget: (context, _, _) => Container(
                              color: placeholderColor,
                              child: Icon(Icons.broken_image_outlined, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: QtyStepper(qty: qtyInCart, onAdd: onAdd, onRemove: onRemove),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFormat.format(product.price),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      outOfStock ? 'Stok habis' : 'Stok: ${product.stockQty}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: outOfStock ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
