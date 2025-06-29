import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';
import '../models/forecast.dart';

class CurrencyController {
  // Список фиатных валют
  static const List<String> fiatCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK', 'NZD'
  ];

  // Список криптовалют
  static const List<String> cryptoCurrencies = [
    'BTC', 'ETH', 'LTC', 'XRP', 'DOGE'
  ];

  /// Определяет, крипта или нет
  bool isCrypto(String symbol) => cryptoCurrencies.contains(symbol);

  /// Курс фиат-фиат через Frankfurter
  Future<CurrencyRate> fetchFiatRate(String base, String target) async {
    final url = Uri.parse('https://api.frankfurter.app/latest?from=$base&to=$target');
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    final rate = data['rates'][target];
    return CurrencyRate(base: base, target: target, rate: (rate as num).toDouble());
  }

  /// Курс крипта-фиат через CoinGecko
  Future<CurrencyRate> fetchCryptoRate(String cryptoSymbol, String fiatSymbol) async {
    final id = _mapCryptoId(cryptoSymbol); // BTC -> bitcoin
    final url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=$id&vs_currencies=$fiatSymbol');
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('CoinGecko Error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    final rate = data[id][fiatSymbol.toLowerCase()];
    return CurrencyRate(base: cryptoSymbol, target: fiatSymbol, rate: (rate as num).toDouble());
  }

  /// Определяем ID CoinGecko
  String _mapCryptoId(String symbol) {
    switch (symbol) {
      case 'BTC':
        return 'bitcoin';
      case 'ETH':
        return 'ethereum';
      case 'LTC':
        return 'litecoin';
      case 'XRP':
        return 'ripple';
      case 'DOGE':
        return 'dogecoin';
      default:
        throw Exception('Unsupported crypto: $symbol');
    }
  }

  /// История курсов — пока только для фиатов (Frankfurter)
  Future<List<HistoricalRate>> fetchHistorical(
      String base,
      String target, {
        int days = 30,
      }) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final start = "${startDate.toIso8601String().substring(0, 10)}";
    final end = "${now.toIso8601String().substring(0, 10)}";

    final url = Uri.parse('https://api.frankfurter.app/$start..$end?from=$base&to=$target');
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body)['rates'] as Map<String, dynamic>;
    final List<HistoricalRate> rates = [];
    data.forEach((date, value) {
      rates.add(HistoricalRate(
        date: DateTime.parse(date),
        rate: (value[target] as num).toDouble(),
      ));
    });

    rates.sort((a, b) => a.date.compareTo(b.date));
    return rates;
  }

  /// Прогноз
  List<Forecast> generateForecast(List<HistoricalRate> history) {
    final lastRate = history.isNotEmpty ? history.last.rate : 1.0;
    final List<Forecast> forecast = [];
    for (int i = 1; i <= 7; i++) {
      final predicted =
          lastRate * (1 + (0.01 * ([-1, 1]..shuffle()).first));
      forecast.add(Forecast(predictedRate: predicted));
    }
    return forecast;
  }
}
