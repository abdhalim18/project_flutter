import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/pos_providers.dart';

class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;
    final failedCount = ref.watch(failedSyncCountProvider).value ?? 0;
    final hasFailed = failedCount > 0;
    final hasPending = pendingCount > 0;

    final backgroundColor = hasFailed
        ? Colors.red.shade100
        : hasPending
        ? Colors.orange.shade100
        : Colors.green.shade50;
    final foregroundColor = hasFailed
        ? Colors.red.shade800
        : hasPending
        ? Colors.orange.shade800
        : Colors.green.shade800;

    final label = hasFailed
        ? '$failedCount transaksi gagal sync, $pendingCount menunggu'
        : hasPending
        ? '$pendingCount transaksi menunggu sinkron'
        : 'Semua transaksi tersinkron';

    return Container(
      height: 32,
      alignment: Alignment.center,
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFailed
                ? Icons.error_outline
                : hasPending
                ? Icons.cloud_upload_outlined
                : Icons.cloud_done_outlined,
            size: 16,
            color: foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: foregroundColor)),
          if (hasPending || hasFailed) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () => ref.read(syncEngineProvider).syncPendingTransactions(force: true),
              child: Text(
                'Sync sekarang',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
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
