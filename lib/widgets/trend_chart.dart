import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_app/models/bp_session.dart';
import 'package:health_app/models/glucose_measurement.dart';
import 'package:intl/intl.dart';

class _Point {
  const _Point({
    required this.time,
    required this.value,
    required this.label,
    this.note,
    this.type,
  });

  final DateTime time;
  final double value;
  final String label;
  final String? note;
  final GlucoseType? type;
}

class _Series {
  const _Series({
    required this.label,
    required this.color,
    required this.points,
    this.curved = false,
    this.dashArray,
    this.showDots = true,
    this.width = 2,
  });

  final String label;
  final Color color;
  final List<_Point> points;
  final bool curved;
  final List<int>? dashArray;
  final bool showDots;
  final double width;
}

class GlucoseTrendChart extends StatelessWidget {
  const GlucoseTrendChart({
    super.key,
    required this.rows,
    required this.from,
    required this.to,
  });

  final List<GlucoseMeasurement> rows;
  final DateTime from;
  final DateTime to;

  @override
  Widget build(BuildContext context) {
    final sorted = rows.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final fasting = _glucosePoints(sorted, GlucoseType.fasting, 'Ayunas');
    final post = _glucosePoints(sorted, GlucoseType.postprandial, 'Postprandial');
    final other = _glucosePoints(sorted, GlucoseType.other, 'Otro');
    final moving = _movingAverage(sorted);
    final values = sorted.map((g) => g.mgPerDl.toDouble()).toList();

    return _ChartPanel(
      title: 'Glucosa',
      subtitle: 'Ayunas y postprandial separadas por color',
      stats: [
        _Stat('Prom.', _avg(values), 'mg/dL'),
        _Stat('Mín.', values.isEmpty ? null : _minValue(values), 'mg/dL'),
        _Stat('Máx.', values.isEmpty ? null : _maxValue(values), 'mg/dL'),
      ],
      legend: const [
        _LegendItem('Ayunas', Color(0xFF047857)),
        _LegendItem('Postprandial', Color(0xFF2563EB)),
        _LegendItem('Prom. móvil', Color(0xFF111827)),
      ],
      child: _HealthLineChart(
        from: from,
        to: to,
        minY: 50,
        maxY: 220,
        normalRanges: [
          HorizontalRangeAnnotation(
            y1: 70,
            y2: 140,
            color: const Color(0xFF22C55E).withValues(alpha: 0.10),
          ),
          HorizontalRangeAnnotation(
            y1: 140,
            y2: 180,
            color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
          ),
          HorizontalRangeAnnotation(
            y1: 180,
            y2: 220,
            color: const Color(0xFFEF4444).withValues(alpha: 0.09),
          ),
        ],
        series: [
          _Series(
            label: 'Ayunas',
            color: const Color(0xFF047857),
            points: fasting,
          ),
          _Series(
            label: 'Postprandial',
            color: const Color(0xFF2563EB),
            points: post,
          ),
          if (other.isNotEmpty)
            _Series(
              label: 'Otro',
              color: const Color(0xFF7C3AED),
              points: other,
            ),
          _Series(
            label: 'Promedio móvil',
            color: const Color(0xFF111827),
            points: moving,
            curved: true,
            dashArray: const [6, 4],
            showDots: false,
            width: 2.4,
          ),
        ],
        dotColorFor: (p) => _glucoseStatusColor(p.value, p.type),
      ),
    );
  }

  List<_Point> _glucosePoints(
    List<GlucoseMeasurement> rows,
    GlucoseType type,
    String label,
  ) {
    return rows
        .where((g) => g.type == type)
        .map(
          (g) => _Point(
            time: g.dateTime,
            value: g.mgPerDl.toDouble(),
            label: label,
            note: g.notes,
            type: g.type,
          ),
        )
        .toList();
  }

  List<_Point> _movingAverage(List<GlucoseMeasurement> rows) {
    if (rows.length < 3) return const [];
    final result = <_Point>[];
    for (var i = 0; i < rows.length; i++) {
      final current = rows[i];
      final start = current.dateTime.subtract(const Duration(days: 7));
      final window = rows
          .where(
            (g) =>
                !g.dateTime.isBefore(start) &&
                !g.dateTime.isAfter(current.dateTime),
          )
          .toList();
      if (window.length < 2) continue;
      final avg =
          window.map((g) => g.mgPerDl).reduce((a, b) => a + b) / window.length;
      result.add(
        _Point(time: current.dateTime, value: avg, label: 'Promedio móvil 7d'),
      );
    }
    return result;
  }
}

class BloodPressureTrendChart extends StatelessWidget {
  const BloodPressureTrendChart({
    super.key,
    required this.rows,
    required this.from,
    required this.to,
    required this.showArms,
  });

  final List<BPSession> rows;
  final DateTime from;
  final DateTime to;
  final bool showArms;

  @override
  Widget build(BuildContext context) {
    final sorted = rows.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final daily = _dailyBpAverages(sorted);
    final avgSys = daily.sys;
    final avgDia = daily.dia;
    final pulse = daily.pulse;
    final allPressureValues = [
      ...avgSys.map((p) => p.value),
      ...avgDia.map((p) => p.value),
    ];

    final series = showArms
        ? [
            _bpPoints(sorted, 'Sys D', (s) => s.rightArm.sys.toDouble()),
            _bpPoints(sorted, 'Sys I', (s) => s.leftArm.sys.toDouble()),
            _bpPoints(sorted, 'Dia D', (s) => s.rightArm.dia.toDouble()),
            _bpPoints(sorted, 'Dia I', (s) => s.leftArm.dia.toDouble()),
          ]
        : [avgSys, avgDia, pulse];

    return _ChartPanel(
      title: 'Presión arterial',
      subtitle: showArms
          ? 'Comparativa por brazo'
          : 'Promedio de ambos brazos con banda sistólica-diastólica',
      stats: [
        _Stat('Sys prom.', _avg(avgSys.map((p) => p.value).toList()), 'mmHg'),
        _Stat('Dia prom.', _avg(avgDia.map((p) => p.value).toList()), 'mmHg'),
        _Stat('Pulso', _avg(pulse.map((p) => p.value).toList()), 'bpm'),
      ],
      legend: [
        if (showArms) ...const [
          _LegendItem('Sys D/I', Color(0xFFB91C1C)),
          _LegendItem('Dia D/I', Color(0xFF1D4ED8)),
        ] else ...const [
          _LegendItem('Banda presión', Color(0xFFDC2626)),
          _LegendItem('Pulso', Color(0xFF374151)),
        ],
      ],
      child: _HealthLineChart(
        from: from,
        to: to,
        minY: 45,
        maxY: max(
          180,
          allPressureValues.isEmpty ? 160 : _maxValue(allPressureValues) + 15,
        ).toDouble(),
        normalRanges: [
          HorizontalRangeAnnotation(
            y1: 90,
            y2: 120,
            color: const Color(0xFF22C55E).withValues(alpha: 0.10),
          ),
          HorizontalRangeAnnotation(
            y1: 120,
            y2: 140,
            color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
          ),
          HorizontalRangeAnnotation(
            y1: 140,
            y2: 190,
            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
          ),
        ],
        betweenBars: showArms
            ? const []
            : [
                BetweenBarsData(
                  fromIndex: 0,
                  toIndex: 1,
                  color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                ),
              ],
        series: showArms
            ? [
                _Series(
                  label: 'Sys D',
                  color: const Color(0xFFB91C1C),
                  points: series[0],
                  width: 1.7,
                ),
                _Series(
                  label: 'Sys I',
                  color: const Color(0xFFF87171),
                  points: series[1],
                  width: 1.7,
                ),
                _Series(
                  label: 'Dia D',
                  color: const Color(0xFF1D4ED8),
                  points: series[2],
                  width: 1.7,
                ),
                _Series(
                  label: 'Dia I',
                  color: const Color(0xFF60A5FA),
                  points: series[3],
                  width: 1.7,
                ),
              ]
            : [
                _Series(
                  label: 'Sistólica',
                  color: const Color(0xFFB91C1C),
                  points: avgSys,
                ),
                _Series(
                  label: 'Diastólica',
                  color: const Color(0xFF1D4ED8),
                  points: avgDia,
                ),
                _Series(
                  label: 'Pulso',
                  color: const Color(0xFF374151),
                  points: pulse,
                  dashArray: const [5, 5],
                  width: 1.8,
                ),
              ],
        dotColorFor: (p) => _bpStatusColor(p.value, p.label),
      ),
    );
  }

  List<_Point> _bpPoints(
    List<BPSession> rows,
    String label,
    double Function(BPSession session) value, {
    String? Function(BPSession session)? note,
  }) {
    return rows
        .map(
          (s) => _Point(
            time: s.dateTime,
            value: value(s),
            label: label,
            note: note?.call(s) ?? s.note,
          ),
        )
        .toList();
  }

  double _avgArms(BPSession s, bool systolic) {
    if (systolic) return (s.rightArm.sys + s.leftArm.sys) / 2;
    return (s.rightArm.dia + s.leftArm.dia) / 2;
  }

  _DailyBpSeries _dailyBpAverages(List<BPSession> rows) {
    final buckets = <DateTime, List<BPSession>>{};
    for (final row in rows) {
      final day = DateTime(
        row.dateTime.year,
        row.dateTime.month,
        row.dateTime.day,
      );
      buckets.putIfAbsent(day, () => []).add(row);
    }

    final days = buckets.keys.toList()..sort();
    final sys = <_Point>[];
    final dia = <_Point>[];
    final pulse = <_Point>[];

    for (final day in days) {
      final items = buckets[day]!;
      final time = DateTime(day.year, day.month, day.day, 12);
      final note = '${items.length} registro${items.length == 1 ? '' : 's'}';
      sys.add(
        _Point(
          time: time,
          value: _avg(items.map((s) => _avgArms(s, true)).toList())!,
          label: 'Sistólica prom. diaria',
          note: note,
        ),
      );
      dia.add(
        _Point(
          time: time,
          value: _avg(items.map((s) => _avgArms(s, false)).toList())!,
          label: 'Diastólica prom. diaria',
          note: note,
        ),
      );
      pulse.add(
        _Point(
          time: time,
          value: _avg(
            items.map((s) => (s.rightArm.pulse + s.leftArm.pulse) / 2).toList(),
          )!,
          label: 'Pulso prom. diario',
          note: note,
        ),
      );
    }

    return _DailyBpSeries(sys: sys, dia: dia, pulse: pulse);
  }
}

class _DailyBpSeries {
  const _DailyBpSeries({
    required this.sys,
    required this.dia,
    required this.pulse,
  });

  final List<_Point> sys;
  final List<_Point> dia;
  final List<_Point> pulse;
}

class _HealthLineChart extends StatelessWidget {
  const _HealthLineChart({
    required this.series,
    required this.from,
    required this.to,
    required this.minY,
    required this.maxY,
    this.normalRanges = const [],
    this.betweenBars = const [],
    this.dotColorFor,
  });

  final List<_Series> series;
  final DateTime from;
  final DateTime to;
  final double minY;
  final double maxY;
  final List<HorizontalRangeAnnotation> normalRanges;
  final List<BetweenBarsData> betweenBars;
  final Color Function(_Point point)? dotColorFor;

  @override
  Widget build(BuildContext context) {
    final hasData = series.any((s) => s.points.isNotEmpty);
    if (!hasData) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('Sin datos en el rango.')),
      );
    }

    final spanMs = to.difference(from).inMilliseconds.toDouble().clamp(
      1,
      double.infinity,
    );
    final useDays = to.difference(from).inHours > 36;
    final fmt = useDays ? DateFormat('MM-dd') : DateFormat('HH:mm');

    double xOf(DateTime t) {
      return (t.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / spanMs;
    }

    _Point? pointFor(int barIndex, FlSpot spot) {
      final points = series[barIndex].points;
      if (points.isEmpty) return null;
      return points.reduce((best, p) {
        final bestDelta = (xOf(best.time) - spot.x).abs();
        final delta = (xOf(p.time) - spot.x).abs();
        return delta < bestDelta ? p : best;
      });
    }

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 1,
          minY: minY,
          maxY: maxY,
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: normalRanges,
          ),
          betweenBarsData: betweenBars,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.black.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
          ),
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
                reservedSize: 24,
                interval: 0.25,
                getTitlesWidget: (value, meta) {
                  final t = from.add(
                    Duration(milliseconds: (value * spanMs).toInt()),
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
                reservedSize: 36,
                interval: 20,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black12),
          ),
          lineBarsData: [
            for (final s in series)
              LineChartBarData(
                spots: [for (final p in s.points) FlSpot(xOf(p.time), p.value)],
                isCurved: s.curved,
                color: s.color,
                barWidth: s.width,
                dashArray: s.dashArray,
                dotData: FlDotData(
                  show: s.showDots,
                  getDotPainter: (spot, percent, bar, index) {
                    final point = pointFor(series.indexOf(s), spot);
                    return FlDotCirclePainter(
                      radius: 3,
                      color: point == null
                          ? s.color
                          : dotColorFor?.call(point) ?? s.color,
                      strokeWidth: 1,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final point = pointFor(spot.barIndex, spot);
                final label = point?.label ?? series[spot.barIndex].label;
                final when = point?.time ??
                    from.add(Duration(milliseconds: (spot.x * spanMs).toInt()));
                final note = point?.note?.trim();
                return LineTooltipItem(
                  '$label\n${spot.y.toStringAsFixed(0)} · '
                  '${DateFormat('MM-dd HH:mm').format(when)}'
                  '${note == null || note.isEmpty ? '' : '\n$note'}',
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.legend,
    required this.child,
  });

  final String title;
  final String subtitle;
  final List<_Stat> stats;
  final List<_LegendItem> legend;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            _StatsRow(stats: stats),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (final item in legend)
                  _Legend(label: item.label, color: item.color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final stat in stats)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    stat.label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.value == null
                        ? '-'
                        : '${stat.value!.toStringAsFixed(0)} ${stat.unit}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _LegendItem {
  const _LegendItem(this.label, this.color);
  final String label;
  final Color color;
}

class _Stat {
  const _Stat(this.label, this.value, this.unit);
  final String label;
  final double? value;
  final String unit;
}

double? _avg(List<double> values) {
  if (values.isEmpty) return null;
  return values.reduce((a, b) => a + b) / values.length;
}

double _minValue(List<double> values) {
  return values.reduce((a, b) => a < b ? a : b);
}

double _maxValue(List<double> values) {
  return values.reduce((a, b) => a > b ? a : b);
}

Color _glucoseStatusColor(double value, GlucoseType? type) {
  final isNormal = switch (type) {
    GlucoseType.fasting => value >= 70 && value <= 99,
    GlucoseType.postprandial => value >= 70 && value <= 140,
    GlucoseType.other => value >= 70 && value <= 140,
    null => value >= 70 && value <= 140,
  };
  if (isNormal) return const Color(0xFF16A34A);
  if (value < 70 || value > 180) return const Color(0xFFDC2626);
  return const Color(0xFFF59E0B);
}

Color _bpStatusColor(double value, String label) {
  if (label.toLowerCase().contains('pulso')) return const Color(0xFF374151);
  if (label.toLowerCase().contains('dia')) {
    if (value < 60 || value >= 90) return const Color(0xFFDC2626);
    if (value >= 80) return const Color(0xFFF59E0B);
    return const Color(0xFF16A34A);
  }
  if (value >= 140 || value < 90) return const Color(0xFFDC2626);
  if (value >= 120) return const Color(0xFFF59E0B);
  return const Color(0xFF16A34A);
}
