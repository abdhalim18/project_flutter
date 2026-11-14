import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/features/pos/application/pos_providers.dart';
import 'package:pos_app/features/pos/presentation/sync_status_bar.dart';

Future<void> _pumpBar(
  WidgetTester tester, {
  required bool online,
  int pending = 0,
  int failed = 0,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        isOnlineProvider.overrideWith((ref) => Stream.value(online)),
        pendingSyncCountProvider.overrideWith((ref) => Stream.value(pending)),
        failedSyncCountProvider.overrideWith((ref) => Stream.value(failed)),
      ],
      child: const MaterialApp(home: Scaffold(body: SyncStatusBar())),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('online, nothing queued', (tester) async {
    await _pumpBar(tester, online: true);
    expect(find.text('Semua transaksi tersinkron'), findsOneWidget);
    expect(find.text('Sync sekarang'), findsNothing);
  });

  testWidgets('online with queued sales offers manual sync', (tester) async {
    await _pumpBar(tester, online: true, pending: 2);
    expect(find.text('2 transaksi menunggu sinkron'), findsOneWidget);
    expect(find.text('Sync sekarang'), findsOneWidget);
  });

  testWidgets('offline, nothing queued', (tester) async {
    await _pumpBar(tester, online: false);
    expect(find.text('Offline · transaksi tetap bisa disimpan'), findsOneWidget);
    expect(find.text('Sync sekarang'), findsNothing);
  });

  testWidgets('offline with queued sales', (tester) async {
    await _pumpBar(tester, online: false, pending: 1);
    expect(find.text('Offline · 1 transaksi menunggu sinkron'), findsOneWidget);
    expect(find.text('Sync sekarang'), findsNothing);
  });

  testWidgets('failed sales take priority', (tester) async {
    await _pumpBar(tester, online: true, pending: 1, failed: 2);
    expect(find.text('2 transaksi gagal sync, 1 menunggu'), findsOneWidget);
    expect(find.text('Sync sekarang'), findsOneWidget);
  });
}
