import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/currency_controller.dart';
import '../models/currency_rate.dart';

class ChartScreen extends StatefulWidget {
  final String base;
  final String target;

  const ChartScreen({super.key, required this.base, required this.target});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final CurrencyController controller = CurrencyController();
  List<HistoricalRate> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    try {
      final data = await controller.fetchHistorical(widget.base, widget.target, days: 30);
      setState(() {
        history = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chart: ${widget.base} → ${widget.target}'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text('No data available'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: isDark ? Colors.black : Colors.white,
              ),
            ),
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.1,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: (history.length - 1).toDouble(),
            minY: (history.map((e) => e.rate).reduce((a, b) => a < b ? a : b) - 0.1).clamp(0.0, double.infinity),
            maxY: history.map((e) => e.rate).reduce((a, b) => a > b ? a : b) + 0.1,
            lineBarsData: [
              LineChartBarData(
                spots: history
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.rate))
                    .toList(),
                isCurved: true,
                color: Colors.indigo,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.withOpacity(0.4),
                      Colors.indigo.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
