class CurrencyRate {
  final String base;
  final String target;
  final double rate;

  CurrencyRate({required this.base, required this.target, required this.rate});
}

class HistoricalRate {
  final DateTime date;
  final double rate;

  HistoricalRate({required this.date, required this.rate});
}