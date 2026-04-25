import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrendPoint {
  TrendPoint(this.time, this.value);
  final DateTime time;
  final double value;
}

class TrendSeries {
  TrendSeries({
    required this.label,
    required this.color,
    required this.points,
  });
  final String label;
  final Color color;
  final List<TrendPoint> points;
}

class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.series,
    required this.from,
    required this.to,
    this.height = 220,
    this.minY,
    this.maxY,
  });

  final List<TrendSeries> series;
  final DateTime from;
  final DateTime to;
  final double height;
  final double? minY;
  final double? maxY;

  @override
  Widget build(BuildContext context) {
    final hasData = series.any((s) => s.points.isNotEmpty);
    if (!hasData) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Sin datos en el rango.')),
      );
    }

    final spanMs = to.difference(from).inMilliseconds.toDouble().clamp(
      1,
      double.infinity,
    );
    final useDays = to.difference(from).inHours > 36;
    final fmt = useDays ? DateFormat('MM-dd') : DateFormat('HH:mm');

    double xOf(DateTime t) =>
        (t.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / spanMs;

    final allValues = [
      for (final s in series)
        for (final p in s.points) p.value,
    ];
    final autoMin = allValues.isEmpty
        ? 0.0
        : (allValues.reduce((a, b) => a < b ? a : b) - 10).floorToDouble();
    final autoMax = allValues.isEmpty
        ? 100.0
        : (allValues.reduce((a, b) => a > b ? a : b) + 10).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 1,
              minY: minY ?? autoMin,
              maxY: maxY ?? autoMax,
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 0.25,
                    getTitlesWidget: (value, meta) {
                      final t = from.add(
                        Duration(
                          milliseconds: (value * spanMs).toInt(),
                        ),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          fmt.format(t),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 20,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black26),
              ),
              lineBarsData: [
                for (final s in series)
                  LineChartBarData(
                    spots: [
                      for (final p in s.points)
                        FlSpot(xOf(p.time), p.value),
                    ],
                    isCurved: false,
                    color: s.color,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (a, b, c, d) =>
                          FlDotCirclePainter(
                            radius: 2.5,
                            color: s.color,
                            strokeWidth: 0,
                          ),
                    ),
                  ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((spot) {
                    final s = series[spot.barIndex];
                    final t = from.add(
                      Duration(
                        milliseconds: (spot.x * spanMs).toInt(),
                      ),
                    );
                    return LineTooltipItem(
                      '${s.label}\n${spot.y.toStringAsFixed(0)} · '
                      '${DateFormat('MM-dd HH:mm').format(t)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final s in series)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 3, color: s.color),
                  const SizedBox(width: 4),
                  Text(s.label, style: const TextStyle(fontSize: 11)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
