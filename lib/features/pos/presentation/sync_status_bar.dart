import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/pos_providers.dart';

class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;
    final failedCount = ref.watch(failedSyncCountProvider).value ?? 0;
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final hasFailed = failedCount > 0;
    final hasPending = pendingCount > 0;

    final (Color background, Color foreground, IconData icon, String label) = switch (()) {
      _ when hasFailed => (
        Colors.red.shade100,
        Colors.red.shade800,
        Icons.error_outline,
        '${isOnline ? '' : 'Offline · '}$failedCount transaksi gagal sync, $pendingCount menunggu',
      ),
      _ when !isOnline && hasPending => (
        Colors.orange.shade100,
        Colors.orange.shade900,
        Icons.cloud_off_outlined,
        'Offline · $pendingCount transaksi menunggu sinkron',
      ),
      _ when !isOnline => (
        Colors.blueGrey.shade100,
        Colors.blueGrey.shade800,
        Icons.cloud_off_outlined,
        'Offline · transaksi tetap bisa disimpan',
      ),
      _ when hasPending => (
        Colors.orange.shade100,
        Colors.orange.shade800,
        Icons.cloud_upload_outlined,
        '$pendingCount transaksi menunggu sinkron',
      ),
      _ => (
        Colors.green.shade50,
        Colors.green.shade800,
        Icons.cloud_done_outlined,
        'Semua transaksi tersinkron',
      ),
    };

    return Container(
      height: 32,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: foreground),
            ),
          ),
          // Sending can't succeed while offline; auto-sync takes over once back online.
          if (isOnline && (hasPending || hasFailed)) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () => ref.read(syncEngineProvider).syncPendingTransactions(force: true),
              child: Text(
                'Sync sekarang',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: foreground,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
