import 'package:flutter/material.dart';

/// Tombol jumlah di kartu produk: hanya "+" saat produk belum ada di keranjang, lalu berubah
/// menjadi "− qty +" setelah ditambahkan. [onAdd]/[onRemove] null = tombolnya nonaktif
/// (mis. jumlah sudah sama dengan stok).
class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.qty, required this.onAdd, required this.onRemove});

  final int qty;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (qty <= 0) {
      return _StepButton(icon: Icons.add, tooltip: 'Tambah', onPressed: onAdd, filled: true);
    }

    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      shape: const StadiumBorder(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, tooltip: 'Kurangi', onPressed: onRemove),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 22),
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(icon: Icons.add, tooltip: 'Tambah', onPressed: onAdd, filled: true),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon);
    return SizedBox(
      width: 36,
      height: 36,
      child: filled
          ? IconButton.filled(
              padding: EdgeInsets.zero,
              iconSize: 20,
              tooltip: tooltip,
              onPressed: onPressed,
              icon: iconWidget,
            )
          : IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              tooltip: tooltip,
              onPressed: onPressed,
              icon: iconWidget,
            ),
    );
  }
}
