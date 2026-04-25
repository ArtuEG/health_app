import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/models/reminder_config.dart';
import 'package:health_app/screens/reminder_edit_screen.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  Future<List<ReminderConfig>> _load() {
    return ref.read(reminderRepositoryProvider).getAll();
  }

  Future<void> _openEdit([ReminderConfig? existing]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReminderEditScreen(existing: existing),
      ),
    );
    if (saved == true && mounted) setState(() {});
  }

  Future<void> _toggleEnabled(ReminderConfig r, bool value) async {
    r.enabled = value;
    final repo = ref.read(reminderRepositoryProvider);
    final notifs = ref.read(notificationServiceProvider);
    await repo.upsert(r);
    await notifs.cancelReminder(r.id);
    if (value) await notifs.scheduleReminder(r);
    setState(() {});
  }

  Future<void> _delete(ReminderConfig r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
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
    );
    if (ok != true) return;
    await ref.read(notificationServiceProvider).cancelReminder(r.id);
    await ref.read(reminderRepositoryProvider).delete(r.id);
    setState(() {});
  }

  String _typeLabel(String t) =>
      t == 'pressure' ? 'Presión arterial' : 'Glucosa';

  IconData _typeIcon(String t) =>
      t == 'pressure' ? Icons.monitor_heart : Icons.bloodtype;

  Color _typeColor(String t) =>
      t == 'pressure' ? Colors.red.shade700 : Colors.green.shade700;

  String _fmtTimes(List<int> mins) {
    if (mins.isEmpty) return 'Sin horarios';
    return mins.map((m) {
      final h = (m ~/ 60).toString().padLeft(2, '0');
      final mm = (m % 60).toString().padLeft(2, '0');
      return '$h:$mm';
    }).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ReminderConfig>>(
          future: _load(),
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snap.data!;
            if (list.isEmpty) return _empty();
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: list.length,
              separatorBuilder: (a, b) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final r = list[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _typeColor(r.type).withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(_typeIcon(r.type), color: _typeColor(r.type)),
                    ),
                    title: Text(
                      r.label?.isNotEmpty == true
                          ? r.label!
                          : _typeLabel(r.type),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_fmtTimes(r.times)),
                        Text(
                          '${r.followUpCount} recordatorios cada 5 min si '
                          'no registras',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: r.enabled,
                          onChanged: (v) => _toggleEnabled(r, v),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(r),
                        ),
                      ],
                    ),
                    onTap: () => _openEdit(r),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, size: 64),
            const SizedBox(height: 12),
            Text(
              'Sin recordatorios',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Crea uno para recibir avisos inteligentes\n'
              '(prep 30 min antes, momento, y seguimiento cada 5 min).',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openEdit(),
              icon: const Icon(Icons.add),
              label: const Text('Crear primer recordatorio'),
            ),
          ],
        ),
      ),
    );
  }
}
