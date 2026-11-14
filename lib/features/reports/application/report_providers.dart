import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/role.dart';
import '../../../core/db/database_provider.dart';
import '../data/report_repository.dart';
import '../domain/sales_summary.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(appDatabaseProvider));
});

class _SelectedRangeNotifier extends Notifier<ReportRange> {
  @override
  ReportRange build() => ReportRange.today;

  void select(ReportRange range) => state = range;
}

final selectedReportRangeProvider = NotifierProvider<_SelectedRangeNotifier, ReportRange>(
  _SelectedRangeNotifier.new,
);

/// Kasir sees only their own sales (Drift, offline-ready); admin sees every
/// cashier's numbers (backend, requires connectivity). Both read the same
/// range selector so the UI stays a single screen.
final salesSummaryProvider = FutureProvider<SalesSummary>((ref) async {
  final range = ref.watch(selectedReportRangeProvider);
  final now = DateTime.now();
  final from = range.startOf(now);
  final to = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

  final role = await ref.watch(currentRoleProvider.future);
  final repository = ref.watch(reportRepositoryProvider);

  if (role == AppRole.admin) {
    return repository.adminSummary(from: from, to: to);
  }

  final cashierId = ref.watch(authRepositoryProvider).currentSession?.user.id;
  if (cashierId == null) return SalesSummary.empty;
  return repository.kasirSummary(cashierId: cashierId, from: from, to: to);
});
