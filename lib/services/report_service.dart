import 'dart:typed_data';

import 'package:health_app/models/bp_session.dart';
import 'package:health_app/models/glucose_measurement.dart';
import 'package:health_app/models/user_profile.dart';
import 'package:health_app/repositories/ibp_repository.dart';
import 'package:health_app/repositories/iglucose_repository.dart';
import 'package:health_app/repositories/iuser_repository.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportData {
  final UserProfile? profile;
  final List<BPSession> bpSessions;
  final List<GlucoseMeasurement> glucose;
  final DateTime from;
  final DateTime to;

  ReportData({
    required this.profile,
    required this.bpSessions,
    required this.glucose,
    required this.from,
    required this.to,
  });
}

class ReportService {
  ReportService({
    required this.userRepo,
    required this.bpRepo,
    required this.glucoseRepo,
  });

  final IUserRepository userRepo;
  final IBPRepository bpRepo;
  final IGlucoseRepository glucoseRepo;

  Future<ReportData> loadData({
    required DateTime from,
    required DateTime to,
  }) async {
    final profiles = await userRepo.getAll(limit: 1);
    final bp = await bpRepo.getByRange(from, to);
    final glu = await glucoseRepo.getByRange(from, to);
    bp.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    glu.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return ReportData(
      profile: profiles.isEmpty ? null : profiles.first,
      bpSessions: bp,
      glucose: glu,
      from: from,
      to: to,
    );
  }

  Future<Uint8List> generate({
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await loadData(from: from, to: to);
    final doc = pw.Document();
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final dayFmt = DateFormat('yyyy-MM-dd');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (ctx) => [
          _header(data, dayFmt),
          pw.SizedBox(height: 14),
          _bpSection(data, dateFmt),
          pw.SizedBox(height: 18),
          _glucoseSection(data, dateFmt),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _header(ReportData d, DateFormat dayFmt) {
    final p = d.profile;
    final genAt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 0.6),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Reporte de salud',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Periodo: ${dayFmt.format(d.from)} → ${dayFmt.format(d.to)}',
          ),
          pw.Text('Generado: $genAt'),
          pw.Divider(height: 14),
          if (p == null)
            pw.Text(
              'Sin expediente capturado.',
              style: const pw.TextStyle(color: PdfColors.grey700),
            )
          else
            pw.Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _kv('Nombre', p.fullName),
                _kv('Edad', '${p.age} años'),
                _kv('Estatura', '${p.heightCm.toStringAsFixed(1)} cm'),
                _kv('Peso', '${p.weightKg.toStringAsFixed(1)} kg'),
                if (p.notes != null && p.notes!.trim().isNotEmpty)
                  _kv('Notas', p.notes!),
              ],
            ),
        ],
      ),
    );
  }

  pw.Widget _kv(String k, String v) => pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: '$k: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.TextSpan(text: v),
      ],
    ),
  );

  pw.Widget _sectionTitle(String text) => pw.Text(
    text,
    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
  );

  pw.Widget _bpSection(ReportData d, DateFormat dateFmt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Presión arterial (${d.bpSessions.length} registros)'),
        pw.SizedBox(height: 8),
        if (d.bpSessions.isEmpty)
          pw.Text('Sin registros en el periodo.')
        else ...[
          _bpChart(d.bpSessions),
          pw.SizedBox(height: 10),
          _bpTable(d.bpSessions, dateFmt),
        ],
      ],
    );
  }

  pw.Widget _bpTable(List<BPSession> rows, DateFormat fmt) {
    final headers = [
      'Fecha',
      'D. Sys',
      'D. Dia',
      'D. Pulso',
      'I. Sys',
      'I. Dia',
      'I. Pulso',
      'Nota',
    ];
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows
          .map(
            (s) => [
              fmt.format(s.dateTime),
              s.rightArm.sys.toString(),
              s.rightArm.dia.toString(),
              s.rightArm.pulse.toString(),
              s.leftArm.sys.toString(),
              s.leftArm.dia.toString(),
              s.leftArm.pulse.toString(),
              s.note ?? '',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
      },
    );
  }

  pw.Widget _bpChart(List<BPSession> rows) {
    final firstTs = rows.first.dateTime.millisecondsSinceEpoch.toDouble();
    final rightSys = <pw.PointChartValue>[];
    final leftSys = <pw.PointChartValue>[];
    final rightDia = <pw.PointChartValue>[];
    final leftDia = <pw.PointChartValue>[];

    for (final s in rows) {
      final x =
          (s.dateTime.millisecondsSinceEpoch - firstTs) /
          (1000 * 60 * 60); // hours since first
      rightSys.add(pw.PointChartValue(x, s.rightArm.sys.toDouble()));
      leftSys.add(pw.PointChartValue(x, s.leftArm.sys.toDouble()));
      rightDia.add(pw.PointChartValue(x, s.rightArm.dia.toDouble()));
      leftDia.add(pw.PointChartValue(x, s.leftArm.dia.toDouble()));
    }

    return pw.SizedBox(
      height: 180,
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis.fromStrings(
            const ['inicio', 'fin'],
            marginStart: 20,
            marginEnd: 20,
          ),
          yAxis: pw.FixedAxis(
            const [40, 80, 120, 160, 200],
            divisions: true,
          ),
        ),
        datasets: [
          pw.LineDataSet(
            legend: 'Sys derecho',
            color: PdfColors.red700,
            data: rightSys,
            pointSize: 2,
            lineWidth: 1.2,
          ),
          pw.LineDataSet(
            legend: 'Sys izquierdo',
            color: PdfColors.red300,
            data: leftSys,
            pointSize: 2,
            lineWidth: 1.2,
          ),
          pw.LineDataSet(
            legend: 'Dia derecho',
            color: PdfColors.blue700,
            data: rightDia,
            pointSize: 2,
            lineWidth: 1.2,
          ),
          pw.LineDataSet(
            legend: 'Dia izquierdo',
            color: PdfColors.blue300,
            data: leftDia,
            pointSize: 2,
            lineWidth: 1.2,
          ),
        ],
      ),
    );
  }

  pw.Widget _glucoseSection(ReportData d, DateFormat dateFmt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Glucosa (${d.glucose.length} registros)'),
        pw.SizedBox(height: 8),
        if (d.glucose.isEmpty)
          pw.Text('Sin registros en el periodo.')
        else ...[
          _glucoseChart(d.glucose),
          pw.SizedBox(height: 10),
          _glucoseTable(d.glucose, dateFmt),
        ],
      ],
    );
  }

  pw.Widget _glucoseTable(List<GlucoseMeasurement> rows, DateFormat fmt) {
    String typeLabel(GlucoseType t) {
      switch (t) {
        case GlucoseType.fasting:
          return 'Ayunas';
        case GlucoseType.postprandial:
          return 'Postprandial';
        case GlucoseType.other:
          return 'Otro';
      }
    }

    return pw.TableHelper.fromTextArray(
      headers: const ['Fecha', 'mg/dL', 'Tipo', 'Notas'],
      data: rows
          .map(
            (g) => [
              fmt.format(g.dateTime),
              g.mgPerDl.toString(),
              typeLabel(g.type),
              g.notes ?? '',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {1: pw.Alignment.center, 2: pw.Alignment.center},
    );
  }

  pw.Widget _glucoseChart(List<GlucoseMeasurement> rows) {
    final firstTs = rows.first.dateTime.millisecondsSinceEpoch.toDouble();
    final points = <pw.PointChartValue>[];
    for (final g in rows) {
      final x =
          (g.dateTime.millisecondsSinceEpoch - firstTs) / (1000 * 60 * 60);
      points.add(pw.PointChartValue(x, g.mgPerDl.toDouble()));
    }
    return pw.SizedBox(
      height: 160,
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis.fromStrings(
            const ['inicio', 'fin'],
            marginStart: 20,
            marginEnd: 20,
          ),
          yAxis: pw.FixedAxis(
            const [40, 80, 120, 160, 200, 250, 300],
            divisions: true,
          ),
        ),
        datasets: [
          pw.LineDataSet(
            legend: 'Glucosa (mg/dL)',
            color: PdfColors.green700,
            data: points,
            pointSize: 2.5,
            lineWidth: 1.4,
          ),
        ],
      ),
    );
  }
}
