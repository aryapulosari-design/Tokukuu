import 'store.dart';

/// Laporan profit harian.
class DailyProfitReport {
  final DateTime date;
  final int grossRevenue;
  final int totalDiscount;
  final int costOfGoodsSold;
  final int netProfit;
  final int transactionCount;

  DailyProfitReport({
    required this.date,
    required this.grossRevenue,
    required this.totalDiscount,
    required this.costOfGoodsSold,
    required this.netProfit,
    required this.transactionCount,
  });

  int get netRevenue => grossRevenue - totalDiscount;
  double get profitMargin =>
      netRevenue == 0 ? 0 : (netProfit / netRevenue * 100);
}

DailyProfitReport generateDailyReport(StoreData data, DateTime date) {
  final grossRevenue = data.grossRevenue(date);
  final totalDiscount = data.totalDiscount(date);
  final costOfGoodsSold = data.costOfGoodsSold(date);
  final netProfit = data.netProfit(date);

  final transactionCount = data.sales
      .where((sale) {
        if (sale.isVoided) return false;
        final at = DateTime.parse(sale.at);
        return at.year == date.year &&
            at.month == date.month &&
            at.day == date.day;
      })
      .length;

  return DailyProfitReport(
    date: date,
    grossRevenue: grossRevenue,
    totalDiscount: totalDiscount,
    costOfGoodsSold: costOfGoodsSold,
    netProfit: netProfit,
    transactionCount: transactionCount,
  );
}
