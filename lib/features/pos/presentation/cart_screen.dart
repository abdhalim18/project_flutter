import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/format/rupiah_input.dart';
import '../application/cart_provider.dart';
import '../application/pos_providers.dart';

final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

const _paymentMethods = ['cash', 'qris', 'debit'];

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _discountController = TextEditingController(text: '0');
  final _paymentReceivedController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _discountController.dispose();
    _paymentReceivedController.dispose();
    super.dispose();
  }

  // Isian memakai titik pemisah ribuan ("50.000"), jadi dibaca lewat parseRupiah.
  double get _discount => parseRupiah(_discountController.text).toDouble();
  double get _paymentReceived => parseRupiah(_paymentReceivedController.text).toDouble();

  Future<void> _checkout(double total) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final cashierId = ref.read(authRepositoryProvider).currentSession!.user.id;
      final items = ref.read(cartProvider);

      final transactionId = await ref
          .read(transactionRepositoryProvider)
          .checkout(
            cashierId: cashierId,
            items: items,
            discountAmount: _discount,
            paymentMethod: _paymentMethod,
            paymentReceived: _paymentMethod == 'cash' ? _paymentReceived : total,
          );

      ref.read(cartProvider.notifier).clear();
      // Best-effort immediate push; if offline this just leaves the
      // transaction queued and the connectivity listener retries later.
      unawaited(ref.read(syncEngineProvider).syncPendingTransactions());

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi tersimpan (${transactionId.substring(0, 8)})')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal checkout: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final total = (subtotal - _discount).clamp(0, double.infinity);
    final change = _paymentMethod == 'cash' ? (_paymentReceived - total) : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: items.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: item.photoUrl == null || item.photoUrl!.isEmpty
                            ? Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.local_cafe_outlined,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              )
                            : CachedNetworkImage(imageUrl: item.photoUrl!, fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(_currencyFormat.format(item.price)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => ref
                              .read(cartProvider.notifier)
                              .updateQty(item.productId, item.qty - 1),
                        ),
                        Text('${item.qty}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => ref
                              .read(cartProvider.notifier)
                              .updateQty(item.productId, item.qty + 1),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 32),
                TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [RupiahInputFormatter()],
                  decoration: const InputDecoration(labelText: 'Diskon', prefixText: 'Rp '),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final method in _paymentMethods)
                      ChoiceChip(
                        label: Text(method.toUpperCase()),
                        selected: _paymentMethod == method,
                        onSelected: (_) => setState(() => _paymentMethod = method),
                      ),
                  ],
                ),
                if (_paymentMethod == 'cash') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _paymentReceivedController,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [RupiahInputFormatter()],
                    decoration: const InputDecoration(labelText: 'Uang Diterima', prefixText: 'Rp '),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Subtotal: ${_currencyFormat.format(subtotal)}'),
                Text('Total: ${_currencyFormat.format(total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_paymentMethod == 'cash') Text('Kembalian: ${_currencyFormat.format(change)}'),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: (_isSubmitting || (_paymentMethod == 'cash' && _paymentReceived < total))
                      ? null
                      : () => _checkout(total.toDouble()),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Selesaikan Transaksi'),
                ),
              ),
            ),
    );
  }
}
