import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ForecastScreen extends StatelessWidget {
  final String base;
  final String target;

  const ForecastScreen({super.key, required this.base, required this.target});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Исторические данные (7 дней)
    final List<double> historyRates = [
      1.104, 1.102, 1.105, 1.107, 1.108, 1.106, 1.109
    ];

    // Простая линейная регрессия
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < historyRates.length; i++) {
      sumX += i;
      sumY += historyRates[i];
      sumXY += i * historyRates[i];
      sumX2 += i * i;
    }

    final n = historyRates.length.toDouble();
    final a = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final b = (sumY - a * sumX) / n;

    // Генерация прогноза на 7 дней
    final List<double> forecastRates = List.generate(
      7,
          (i) => a * (i + 7) + b,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Forecast: $base → $target'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: isDark ? Colors.black : Colors.white,
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    final x = spot.x.toInt();
                    final label = x < 7 ? 'Day ${x + 1}' : 'Forecast ${x - 6}';
                    return LineTooltipItem(
                      '$label\n${spot.y.toStringAsFixed(4)}',
                      const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: 0.01),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: 13,
            minY: ([
              ...historyRates,
              ...forecastRates
            ].reduce((a, b) => a < b ? a : b) - 0.01),
            maxY: ([
              ...historyRates,
              ...forecastRates
            ].reduce((a, b) => a > b ? a : b) + 0.01),
            lineBarsData: [
              LineChartBarData(
                spots: historyRates
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                    .toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.2),
                ),
              ),
              LineChartBarData(
                spots: forecastRates
                    .asMap()
                    .entries
                    .map((e) => FlSpot((e.key + 7).toDouble(), e.value))
                    .toList(),
                isCurved: true,
                color: Colors.red,
                barWidth: 2,
                dotData: FlDotData(show: true),
                dashArray: [6, 4],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
