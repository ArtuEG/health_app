import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/models/bp_session.dart';
import 'package:health_app/models/glucose_measurement.dart';
import 'package:health_app/models/user_profile.dart';
import 'package:health_app/screens/record_bp_screen.dart';
import 'package:health_app/screens/record_glucose_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<_DashboardData> _load() async {
    final user = await ref.read(userRepositoryProvider).getAll(limit: 1);
    final since = DateTime.now().subtract(const Duration(days: 60));
    final bp = await ref
        .read(bpRepositoryProvider)
        .getByRange(since, DateTime.now().add(const Duration(days: 1)));
    final glu = await ref
        .read(glucoseRepositoryProvider)
        .getByRange(since, DateTime.now().add(const Duration(days: 1)));
    bp.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    glu.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return _DashboardData(
      profile: user.isEmpty ? null : user.first,
      lastBp: bp.isEmpty ? null : bp.first,
      lastGlucose: glu.isEmpty ? null : glu.first,
      bpCount30d: bp.where((s) => s.dateTime.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          )).length,
      glucoseCount30d: glu.where((g) => g.dateTime.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          )).length,
    );
  }

  Future<void> _openRecordBp() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecordBPScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openRecordGlucose() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecordGlucoseScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: SafeArea(
        child: FutureBuilder<_DashboardData>(
          future: _load(),
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final d = snap.data!;
            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Greeting(profile: d.profile),
                  const SizedBox(height: 16),
                  _LastBpCard(session: d.lastBp),
                  const SizedBox(height: 12),
                  _LastGlucoseCard(measurement: d.lastGlucose),
                  const SizedBox(height: 16),
                  _StatsRow(
                    bp30d: d.bpCount30d,
                    glucose30d: d.glucoseCount30d,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Registrar ahora',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          onPressed: _openRecordBp,
                          icon: const Icon(Icons.monitor_heart),
                          label: const Text('Presión'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Colors.green.shade700,
                          ),
                          onPressed: _openRecordGlucose,
                          icon: const Icon(Icons.bloodtype),
                          label: const Text('Glucosa'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardData {
  _DashboardData({
    required this.profile,
    required this.lastBp,
    required this.lastGlucose,
    required this.bpCount30d,
    required this.glucoseCount30d,
  });
  final UserProfile? profile;
  final BPSession? lastBp;
  final GlucoseMeasurement? lastGlucose;
  final int bpCount30d;
  final int glucoseCount30d;
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.profile});
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName.split(' ').first ?? 'Hola';
    final hour = DateTime.now().hour;
    final salute = hour < 12
        ? 'Buenos días'
        : hour < 19
            ? 'Buenas tardes'
            : 'Buenas noches';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$salute,',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}

class _LastBpCard extends StatelessWidget {
  const _LastBpCard({required this.session});
  final BPSession? session;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: Colors.red.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Última presión',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (session == null)
              const Text('Aún no hay registros.')
            else
              DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'D: ${session!.rightArm.sys}/${session!.rightArm.dia}'
                      ' · ${session!.rightArm.pulse} bpm',
                    ),
                    Text(
                      'I: ${session!.leftArm.sys}/${session!.leftArm.dia}'
                      ' · ${session!.leftArm.pulse} bpm',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(session!.dateTime),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LastGlucoseCard extends StatelessWidget {
  const _LastGlucoseCard({required this.measurement});
  final GlucoseMeasurement? measurement;

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
    final fmt = DateFormat('dd MMM, HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bloodtype, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Última glucosa',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (measurement == null)
              const Text('Aún no hay registros.')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${measurement!.mgPerDl} mg/dL · '
                    '${_typeLabel(measurement!.type)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmt.format(measurement!.dateTime),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.bp30d, required this.glucose30d});
  final int bp30d;
  final int glucose30d;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Presión (30 d)',
            value: bp30d.toString(),
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Glucosa (30 d)',
            value: glucose30d.toString(),
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
