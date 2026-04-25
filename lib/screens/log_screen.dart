import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/models/bp_session.dart';
import 'package:health_app/models/glucose_measurement.dart';
import 'package:health_app/screens/report_preview_screen.dart';
import 'package:health_app/widgets/trend_chart.dart';
import 'package:intl/intl.dart';

enum QuickRange { today, week, month, custom }

class _DateRange {
  _DateRange(this.from, this.to);
  final DateTime from;
  final DateTime to;
}

_DateRange _rangeFor(QuickRange q, [DateTimeRange? custom]) {
  final now = DateTime.now();
  switch (q) {
    case QuickRange.today:
      final start = DateTime(now.year, now.month, now.day);
      return _DateRange(
        start,
        start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
      );
    case QuickRange.week:
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return _DateRange(end.subtract(const Duration(days: 7)), end);
    case QuickRange.month:
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return _DateRange(end.subtract(const Duration(days: 30)), end);
    case QuickRange.custom:
      if (custom == null) {
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return _DateRange(end.subtract(const Duration(days: 30)), end);
      }
      return _DateRange(
        DateTime(custom.start.year, custom.start.month, custom.start.day),
        DateTime(
          custom.end.year,
          custom.end.month,
          custom.end.day,
          23,
          59,
          59,
        ),
      );
  }
}

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  QuickRange _range = QuickRange.month;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final res = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (res != null) {
      setState(() {
        _customRange = res;
        _range = QuickRange.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _rangeFor(_range, _customRange);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Presión', icon: Icon(Icons.monitor_heart)),
            Tab(text: 'Glucosa', icon: Icon(Icons.bloodtype)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reporte PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ReportPreviewScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _filterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _BPTab(range: r),
                _GlucoseTab(range: r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    final fmt = DateFormat('yyyy-MM-dd');
    final r = _rangeFor(_range, _customRange);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Hoy'),
                selected: _range == QuickRange.today,
                onSelected: (_) => setState(() => _range = QuickRange.today),
              ),
              ChoiceChip(
                label: const Text('Semana'),
                selected: _range == QuickRange.week,
                onSelected: (_) => setState(() => _range = QuickRange.week),
              ),
              ChoiceChip(
                label: const Text('Mes'),
                selected: _range == QuickRange.month,
                onSelected: (_) => setState(() => _range = QuickRange.month),
              ),
              ChoiceChip(
                label: const Text('Personalizado'),
                selected: _range == QuickRange.custom,
                onSelected: (_) => _pickCustom(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${fmt.format(r.from)} → ${fmt.format(r.to)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _BPTab extends ConsumerStatefulWidget {
  const _BPTab({required this.range});
  final _DateRange range;

  @override
  ConsumerState<_BPTab> createState() => _BPTabState();
}

class _BPTabState extends ConsumerState<_BPTab> {
  late Future<List<BPSession>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _BPTab old) {
    super.didUpdateWidget(old);
    if (old.range.from != widget.range.from ||
        old.range.to != widget.range.to) {
      _load();
    }
  }

  void _load() {
    _future = ref
        .read(bpRepositoryProvider)
        .getByRange(widget.range.from, widget.range.to)
        .then(
          (l) => l..sort((a, b) => b.dateTime.compareTo(a.dateTime)),
        );
  }

  Future<void> _delete(BPSession s) async {
    await ref.read(bpRepositoryProvider).delete(s.id);
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    return FutureBuilder<List<BPSession>>(
      future: _future,
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snap.data!;
        final asc = rows.reversed.toList();
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TrendChart(
              from: widget.range.from,
              to: widget.range.to,
              series: [
                TrendSeries(
                  label: 'Sys derecho',
                  color: Colors.red.shade700,
                  points: asc
                      .map((s) => TrendPoint(s.dateTime, s.rightArm.sys.toDouble()))
                      .toList(),
                ),
                TrendSeries(
                  label: 'Sys izquierdo',
                  color: Colors.red.shade300,
                  points: asc
                      .map((s) => TrendPoint(s.dateTime, s.leftArm.sys.toDouble()))
                      .toList(),
                ),
                TrendSeries(
                  label: 'Dia derecho',
                  color: Colors.blue.shade700,
                  points: asc
                      .map((s) => TrendPoint(s.dateTime, s.rightArm.dia.toDouble()))
                      .toList(),
                ),
                TrendSeries(
                  label: 'Dia izquierdo',
                  color: Colors.blue.shade300,
                  points: asc
                      .map((s) => TrendPoint(s.dateTime, s.leftArm.dia.toDouble()))
                      .toList(),
                ),
              ],
            ),
            const Divider(),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Sin registros en el rango.')),
              )
            else
              ...rows.map(
                (s) => Dismissible(
                  key: ValueKey('bp-${s.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async => await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Eliminar registro'),
                          content: const Text('¿Confirmar eliminación?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      ) ??
                      false,
                  onDismissed: (_) => _delete(s),
                  child: Card(
                    child: ListTile(
                      title: Text(dateFmt.format(s.dateTime)),
                      subtitle: Text(
                        'D: ${s.rightArm.sys}/${s.rightArm.dia} '
                        '· ${s.rightArm.pulse} bpm\n'
                        'I: ${s.leftArm.sys}/${s.leftArm.dia} '
                        '· ${s.leftArm.pulse} bpm'
                        '${s.note != null && s.note!.isNotEmpty ? "\nNota: ${s.note}" : ""}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GlucoseTab extends ConsumerStatefulWidget {
  const _GlucoseTab({required this.range});
  final _DateRange range;

  @override
  ConsumerState<_GlucoseTab> createState() => _GlucoseTabState();
}

class _GlucoseTabState extends ConsumerState<_GlucoseTab> {
  late Future<List<GlucoseMeasurement>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _GlucoseTab old) {
    super.didUpdateWidget(old);
    if (old.range.from != widget.range.from ||
        old.range.to != widget.range.to) {
      _load();
    }
  }

  void _load() {
    _future = ref
        .read(glucoseRepositoryProvider)
        .getByRange(widget.range.from, widget.range.to)
        .then(
          (l) => l..sort((a, b) => b.dateTime.compareTo(a.dateTime)),
        );
  }

  Future<void> _delete(GlucoseMeasurement g) async {
    await ref.read(glucoseRepositoryProvider).delete(g.id);
    setState(_load);
  }

  String _typeLabel(GlucoseType t) {
    switch (t) {
      case GlucoseType.fasting:
        return 'Ayunas';
      case GlucoseType.postprandial:
        return 'Postprandial';
      case GlucoseType.other:
        return 'Otro';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    return FutureBuilder<List<GlucoseMeasurement>>(
      future: _future,
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snap.data!;
        final asc = rows.reversed.toList();
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TrendChart(
              from: widget.range.from,
              to: widget.range.to,
              series: [
                TrendSeries(
                  label: 'Glucosa (mg/dL)',
                  color: Colors.green.shade700,
                  points: asc
                      .map((g) => TrendPoint(g.dateTime, g.mgPerDl.toDouble()))
                      .toList(),
                ),
              ],
            ),
            const Divider(),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Sin registros en el rango.')),
              )
            else
              ...rows.map(
                (g) => Dismissible(
                  key: ValueKey('glu-${g.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async => await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Eliminar registro'),
                          content: const Text('¿Confirmar eliminación?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      ) ??
                      false,
                  onDismissed: (_) => _delete(g),
                  child: Card(
                    child: ListTile(
                      title: Text('${g.mgPerDl} mg/dL · ${_typeLabel(g.type)}'),
                      subtitle: Text(
                        '${dateFmt.format(g.dateTime)}'
                        '${g.notes != null && g.notes!.isNotEmpty ? "\n${g.notes}" : ""}',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
