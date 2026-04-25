import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/services/report_service.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class ReportPreviewScreen extends ConsumerStatefulWidget {
  const ReportPreviewScreen({super.key});

  @override
  ConsumerState<ReportPreviewScreen> createState() =>
      _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends ConsumerState<ReportPreviewScreen> {
  late DateTime _from;
  late DateTime _to;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _from = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 30));
  }

  Future<void> _pickRange() async {
    final res = await showDateRangePicker(
      context: context,
      firstDate: DateTime(_to.year - 5),
      lastDate: DateTime(_to.year + 1),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (res == null) return;
    setState(() {
      _from = DateTime(res.start.year, res.start.month, res.start.day);
      _to = DateTime(res.end.year, res.end.month, res.end.day, 23, 59, 59);
      _refreshKey++;
    });
  }

  ReportService _service() {
    return ReportService(
      userRepo: ref.read(userRepositoryProvider),
      bpRepo: ref.read(bpRepositoryProvider),
      glucoseRepo: ref.read(glucoseRepositoryProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte PDF'),
        actions: [
          IconButton(
            tooltip: 'Cambiar rango',
            icon: const Icon(Icons.date_range),
            onPressed: _pickRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.event_note, size: 18),
                const SizedBox(width: 6),
                Text('${fmt.format(_from)} → ${fmt.format(_to)}'),
              ],
            ),
          ),
          Expanded(
            child: PdfPreview(
              key: ValueKey(_refreshKey),
              build: (_) => _service().generate(from: _from, to: _to),
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              pdfFileName:
                  'reporte_salud_${fmt.format(_from)}_${fmt.format(_to)}.pdf',
            ),
          ),
        ],
      ),
    );
  }
}
