import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../network/api_client.dart';
import 'pull_sync_service.dart';

/// Pushes locally-created transactions (and their items/stock movements) to
/// the backend. Insert-by-UUID makes retries idempotent: whether a row is sent
/// once or five times after connection blips, the same primary key means no
/// duplicate rows land server-side.
class SyncEngine {
  SyncEngine(this._db, this._pullSyncService);

  final AppDatabase _db;
  final PullSyncService _pullSyncService;

  /// After this many failed attempts a transaction stops being retried by
  /// the automatic (connectivity/polling) triggers and is marked 'failed' --
  /// it still shows up in the sync bar and can be retried with [force].
  static const _maxAutoAttempts = 5;
  static const _baseBackoff = Duration(seconds: 5);
  static const _maxBackoff = Duration(minutes: 5);

  Duration _backoffFor(int attemptCount) {
    final scaled = _baseBackoff * (1 << attemptCount.clamp(0, 10));
    return scaled > _maxBackoff ? _maxBackoff : scaled;
  }

  /// Pushes every transaction with `syncState` in `pending`/`failed`.
  /// Automatic callers (connectivity change, polling timer) leave [force]
  /// false so rows still inside their backoff window are skipped; the
  /// manual "Sync sekarang" button passes `force: true` to retry immediately
  /// regardless of backoff.
  Future<void> syncPendingTransactions({bool force = false}) async {
    final now = DateTime.now();
    final candidates =
        await (_db.select(_db.transactions)
              ..where(
                (t) =>
                    t.syncState.equals('pending') |
                    t.syncState.equals('failed'),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.clientCreatedAt)]))
            .get();

    final due = force
        ? candidates
        : candidates.where((tx) {
            final lastAttempt = tx.lastAttemptAt;
            if (lastAttempt == null) return true;
            return now.difference(lastAttempt) >=
                _backoffFor(tx.syncAttemptCount);
          }).toList();

    if (due.isEmpty) return;

    var anySucceeded = false;

    for (final tx in due) {
      try {
        await _pushTransaction(tx);
        await (_db.update(
          _db.transactions,
        )..where((t) => t.id.equals(tx.id))).write(
          TransactionsCompanion(
            syncState: const Value('synced'),
            lastSyncError: const Value(null),
            lastAttemptAt: Value(now),
          ),
        );
        anySucceeded = true;
      } catch (e) {
        final attempts = tx.syncAttemptCount + 1;
        await (_db.update(
          _db.transactions,
        )..where((t) => t.id.equals(tx.id))).write(
          TransactionsCompanion(
            syncState: Value(
              attempts >= _maxAutoAttempts ? 'failed' : 'pending',
            ),
            syncAttemptCount: Value(attempts),
            lastSyncError: Value(e.toString()),
            lastAttemptAt: Value(now),
          ),
        );
      }
    }

    // Reconcile local stock cache with the server-authoritative values now
    // that the stock_movements trigger has run for whatever synced.
    if (anySucceeded) {
      try {
        await _pullSyncService.pullAll();
      } catch (_) {
        // Reconciliation is best-effort; the next successful sync retries it.
      }
    }
  }

  /// Tries to send [transactionId] right away (along with anything else that
  /// is due) and reports whether it reached the server. Used right after
  /// checkout so the cashier is told whether the sale was sent or is queued.
  Future<bool> trySyncNow(String transactionId) async {
    await syncPendingTransactions();
    final row = await (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(transactionId))).getSingleOrNull();
    return row?.syncState == 'synced';
  }

  /// Sends one transaction with its items and stock movements in a single
  /// request; the server writes them in one database transaction. Every row
  /// uses its client-generated UUID with ON CONFLICT DO NOTHING server-side,
  /// so a retry after a partial failure or a lost response never duplicates
  /// rows or deducts stock twice.
  Future<void> _pushTransaction(TransactionRow tx) async {
    final items = await (_db.select(
      _db.transactionItems,
    )..where((i) => i.transactionId.equals(tx.id))).get();
    final movements = await (_db.select(
      _db.stockMovements,
    )..where((m) => m.referenceId.equals(tx.id))).get();

    await ApiClient.instance.post('/api/sync/transactions', {
      'transaction': {
        'id': tx.id,
        'cashier_id': tx.cashierId,
        'total_amount': tx.totalAmount,
        'discount_amount': tx.discountAmount,
        'payment_method': tx.paymentMethod,
        'payment_received': tx.paymentReceived,
        'change_amount': tx.changeAmount,
        'status': tx.status,
        'client_created_at': tx.clientCreatedAt.toUtc().toIso8601String(),
      },
      'items': items
          .map(
            (i) => {
              'id': i.id,
              'transaction_id': i.transactionId,
              'product_id': i.productId,
              'product_name_snapshot': i.productNameSnapshot,
              'unit_price': i.unitPrice,
              'qty': i.qty,
              'subtotal': i.subtotal,
            },
          )
          .toList(),
      'movements': movements
          .map(
            (m) => {
              'id': m.id,
              'product_id': m.productId,
              'change_qty': m.changeQty,
              'reason': m.reason,
              'reference_id': m.referenceId,
              'created_at': m.createdAt.toUtc().toIso8601String(),
            },
          )
          .toList(),
    });
  }
}
