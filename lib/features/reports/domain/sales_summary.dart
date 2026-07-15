class DailySales {
  const DailySales({required this.day, required this.total, required this.transactionCount});

  final DateTime day;
  final double total;
  final int transactionCount;
}

class ProductSales {
  const ProductSales({required this.productName, required this.qty, required this.total});

  final String productName;
  final int qty;
  final double total;
}

class CashierSales {
  const CashierSales({required this.cashierId, required this.label, required this.total, required this.transactionCount});

  final String cashierId;
  final String label;
  final double total;
  final int transactionCount;
}

class SalesSummary {
  const SalesSummary({
    required this.totalAmount,
    required this.transactionCount,
    required this.byDay,
    required this.topProducts,
    required this.byCashier,
  });

  final double totalAmount;
  final int transactionCount;
  final List<DailySales> byDay;
  final List<ProductSales> topProducts;
  final List<CashierSales> byCashier;

  static const empty = SalesSummary(
    totalAmount: 0,
    transactionCount: 0,
    byDay: [],
    topProducts: [],
    byCashier: [],
  );

  double get averagePerTransaction => transactionCount == 0 ? 0 : totalAmount / transactionCount;
}

/// Preset date ranges shown as chips on the report screen.
enum ReportRange {
  today('Hari ini'),
  last7Days('7 Hari'),
  thisMonth('Bulan ini');

  const ReportRange(this.label);
  final String label;

  DateTime startOf(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case ReportRange.today:
        return today;
      case ReportRange.last7Days:
        return today.subtract(const Duration(days: 6));
      case ReportRange.thisMonth:
        return DateTime(now.year, now.month, 1);
    }
  }
}
