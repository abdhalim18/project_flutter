import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/role.dart';
import '../application/product_providers.dart';
import '../domain/product.dart';

final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Best-effort refresh of the local cache from the server; if offline this
    // fails silently and the screen keeps rendering from Drift.
    Future.microtask(() => ref.read(pullSyncServiceProvider).pullAll().catchError((_) {}));
  }

  Future<void> _refresh() {
    return ref.read(pullSyncServiceProvider).pullAll().catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final isAdmin = ref.watch(currentRoleProvider).value == AppRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk & Stok'),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Kelola Kategori',
              icon: const Icon(Icons.category_outlined),
              onPressed: () => context.push('/categories'),
            ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Belum ada produk.')),
                ],
              ),
            );
          }
          final reviewCount = products.where((p) => p.needsReview).length;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                if (isAdmin && reviewCount > 0)
                  SliverToBoxAdapter(child: _ReviewBanner(count: reviewCount)),
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ProductCard(
                        product: products[index],
                        isAdmin: isAdmin,
                        onEdit: () => context.push('/products/${products[index].id}/edit', extra: products[index]),
                        onDelete: () => _confirmDelete(products[index]),
                        onAcknowledge: () => _acknowledgeReview(products[index]),
                        onToggleActive: () => _toggleActive(products[index]),
                      ),
                      childCount: products.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat produk: $err')),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => context.push('/products/new'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text(
          'Produk "${product.name}" akan dihapus. Jika produk ini pernah terjual, produk '
          'akan dinonaktifkan (disembunyikan dari kasir) alih-alih dihapus permanen, supaya '
          'riwayat penjualan lama tetap utuh.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final hardDeleted = await ref.read(productRepositoryProvider).delete(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hardDeleted
                  ? 'Produk dihapus.'
                  : 'Produk pernah terjual, jadi dinonaktifkan (bukan dihapus) agar riwayat penjualan tetap ada.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  Future<void> _toggleActive(Product product) async {
    try {
      await ref.read(productRepositoryProvider).setActive(product.id, !product.isActive);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update, coba lagi saat online: $e')));
      }
    }
  }

  Future<void> _acknowledgeReview(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai sudah direview?'),
        content: Text(
          'Stok "${product.name}" sempat negatif (kemungkinan terjual lebih dari stok saat '
          'beberapa kasir offline bersamaan). Pastikan stok fisik & sistem sudah sesuai '
          'sebelum menghapus tanda ini.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sudah direview')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(productRepositoryProvider).acknowledgeStockReview(product.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal update, coba lagi saat online: $e')));
      }
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
    required this.onAcknowledge,
    required this.onToggleActive,
  });

  final Product product;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAcknowledge;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsReview = product.needsReview;

    return Opacity(
      opacity: product.isActive ? 1 : 0.55,
      child: Card(
        shape: needsReview
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.error, width: 1.5),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(url: product.photoUrl),
                  if (needsReview)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _Badge(
                        icon: Icons.warning_amber_rounded,
                        color: theme.colorScheme.error,
                        tooltip: 'Perlu direview',
                      ),
                    ),
                  if (isAdmin)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _CardMenu(
                        needsReview: needsReview,
                        isActive: product.isActive,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onAcknowledge: onAcknowledge,
                        onToggleActive: onToggleActive,
                      ),
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
                  const SizedBox(height: 2),
                  Text(
                    [
                      'Stok: ${product.stockQty}',
                      if (!product.isActive) 'Nonaktif',
                      if (needsReview) 'Perlu direview',
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: needsReview || product.stockQty <= 0
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: needsReview ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({
    required this.needsReview,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
    required this.onAcknowledge,
    required this.onToggleActive,
  });

  final bool needsReview;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAcknowledge;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
        padding: EdgeInsets.zero,
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
            case 'delete':
              onDelete();
            case 'review':
              onAcknowledge();
            case 'toggle':
              onToggleActive();
          }
        },
        itemBuilder: (context) => [
          if (needsReview)
            const PopupMenuItem(value: 'review', child: Text('Tandai sudah direview')),
          const PopupMenuItem(value: 'edit', child: Text('Ubah')),
          PopupMenuItem(value: 'toggle', child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan')),
          const PopupMenuItem(value: 'delete', child: Text('Hapus')),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (url == null || url!.isEmpty) {
      return Container(
        color: placeholderColor,
        child: Icon(Icons.local_cafe_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 32),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (context, _) => Container(color: placeholderColor),
      errorWidget: (context, _, _) => Container(
        color: placeholderColor,
        child: Icon(Icons.broken_image_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color, required this.tooltip});

  final IconData icon;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}

class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count produk stoknya sempat negatif dan perlu direview admin.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
