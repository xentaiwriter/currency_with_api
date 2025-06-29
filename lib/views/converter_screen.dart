import 'package:flutter/material.dart';
import '../controllers/currency_controller.dart';
import 'chart_screen.dart';
import 'forecast_screen.dart';
import '../models/currency_rate.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final CurrencyController controller = CurrencyController();
  final TextEditingController amountController = TextEditingController();
  String base = 'USD';
  String target = 'EUR';
  double? result;

  void convert() async {
    try {
      final amount = double.tryParse(amountController.text.trim());
      if (amount == null || amount <= 0) {
        throw Exception("Please enter a valid amount greater than 0.");
      }

      CurrencyRate rate;
      if (controller.isCrypto(base) || controller.isCrypto(target)) {
        final crypto = controller.isCrypto(base) ? base : target;
        final fiat = controller.isCrypto(base) ? target : base;
        rate = await controller.fetchCryptoRate(crypto, fiat);
        result = controller.isCrypto(base)
            ? amount * rate.rate
            : amount / rate.rate;
      } else {
        rate = await controller.fetchFiatRate(base, target);
        result = amount * rate.rate;
      }

      setState(() {});
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyList = [
      ...CurrencyController.fiatCurrencies,
      ...CurrencyController.cryptoCurrencies,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: DropdownButtonFormField<String>(
                    value: base,
                    decoration: const InputDecoration(labelText: 'From'),
                    borderRadius: BorderRadius.circular(12),
                    items: currencyList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => base = val!),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.compare_arrows),
                ),
                Flexible(
                  child: DropdownButtonFormField<String>(
                    value: target,
                    decoration: const InputDecoration(labelText: 'To'),
                    borderRadius: BorderRadius.circular(12),
                    items: currencyList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => target = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.indigo,
                elevation: 4,
              ),
              onPressed: convert,
              child: const Text(
                'Convert',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFFFD700), // Жёлтый цвет
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (result != null)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: result != null ? 1 : 0,
                child: Text(
                  'Result: ${result!.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChartScreen(base: base, target: target),
                ),
              ),
              icon: const Icon(Icons.show_chart),
              label: const Text('View Chart'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ForecastScreen(base: base, target: target),
                ),
              ),
              icon: const Icon(Icons.trending_up),
              label: const Text('View Forecast'),
            ),
          ],
        ),
      ),
    );
  }
}
