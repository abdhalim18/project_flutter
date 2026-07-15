import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/role.dart';
import '../application/report_providers.dart';
import '../domain/sales_summary.dart';

final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final _dayFormat = DateFormat('d/M');

class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdmin = ref.watch(currentRoleProvider).value == AppRole.admin;
    final selectedRange = ref.watch(selectedReportRangeProvider);
    final summaryAsync = ref.watch(salesSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(salesSummaryProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final range in ReportRange.values) ...[
                    ChoiceChip(
                      label: Text(range.label),
                      selected: selectedRange == range,
                      onSelected: (_) => ref.read(selectedReportRangeProvider.notifier).select(range),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!isAdmin)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Menampilkan penjualan Anda sendiri dari perangkat ini.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            summaryAsync.when(
              data: (summary) => _ReportBody(summary: summary, isAdmin: isAdmin),
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    isAdmin
                        ? 'Gagal memuat laporan. Pastikan Anda online: $err'
                        : 'Gagal memuat laporan: $err',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.summary, required this.isAdmin});

  final SalesSummary summary;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    if (summary.transactionCount == 0) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: Text('Belum ada transaksi pada periode ini.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total Omzet',
                value: _currencyFormat.format(summary.totalAmount),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(label: 'Transaksi', value: '${summary.transactionCount}'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          label: 'Rata-rata per Transaksi',
          value: _currencyFormat.format(summary.averagePerTransaction),
        ),
        const SizedBox(height: 24),
        Text('Penjualan Harian', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(height: 180, child: _DailyBarChart(byDay: summary.byDay)),
        const SizedBox(height: 24),
        Text('Produk Terlaris', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (final (index, product) in summary.topProducts.indexed) ...[
                if (index > 0) const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(product.productName),
                  subtitle: Text('${product.qty} terjual'),
                  trailing: Text(_currencyFormat.format(product.total)),
                ),
              ],
            ],
          ),
        ),
        if (isAdmin && summary.byCashier.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Penjualan per Kasir', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final (index, cashier) in summary.byCashier.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(cashier.label),
                    subtitle: Text('${cashier.transactionCount} transaksi'),
                    trailing: Text(_currencyFormat.format(cashier.total)),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  const _DailyBarChart({required this.byDay});

  final List<DailySales> byDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxTotal = byDay.map((d) => d.total).fold<double>(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxTotal <= 0 ? 1 : maxTotal * 1.2,
        barTouchData: BarTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= byDay.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_dayFormat.format(byDay[index].day), style: theme.textTheme.bodySmall),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (final (index, day) in byDay.indexed)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: day.total,
                  color: theme.colorScheme.primary,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
