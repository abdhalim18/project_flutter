import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import '../../../core/sync/connectivity_service.dart';
import '../../../core/sync/sync_engine.dart';
import '../../products/application/product_providers.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(appDatabaseProvider));
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(ref.watch(appDatabaseProvider), ref.watch(pullSyncServiceProvider));
});

/// Reactive count of transactions still waiting to reach the server (either
/// queued or still within their retry backoff window), shown as a trust
/// signal in the POS app bar so a cashier can see queued sales haven't
/// silently vanished.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.transactions)..where((t) => t.syncState.equals('pending'));
  return query.watch().map((rows) => rows.length);
});

/// Reactive count of transactions that exhausted automatic retries and need
/// a manual "Sync sekarang" tap (or investigation, if that also keeps
/// failing -- e.g. a permanently rejected row).
final failedSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.transactions)..where((t) => t.syncState.equals('failed'));
  return query.watch().map((rows) => rows.length);
});

/// Kicks off a sync attempt whenever connectivity is restored, plus a
/// periodic poll while online so rows that entered backoff (or a temporarily
/// flaky connection that connectivity_plus never reported as fully offline)
/// still get retried without waiting for another connectivity transition.
/// Reading this provider anywhere (e.g. the POS screen) arms it for the
/// lifetime of that screen.
final autoSyncOnReconnectProvider = Provider<void>((ref) {
  final syncEngine = ref.watch(syncEngineProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  final subscription = connectivity.onConnectivityChanged.listen((isOnline) {
    if (isOnline) syncEngine.syncPendingTransactions();
  });

  final timer = Timer.periodic(const Duration(seconds: 30), (_) async {
    if (await connectivity.checkIsOnline()) {
      await syncEngine.syncPendingTransactions();
    }
  });

  ref.onDispose(() {
    subscription.cancel();
    timer.cancel();
  });
});
