import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/models/reminder_config.dart';

class ReminderEditScreen extends ConsumerStatefulWidget {
  const ReminderEditScreen({super.key, this.existing});
  final ReminderConfig? existing;

  @override
  ConsumerState<ReminderEditScreen> createState() =>
      _ReminderEditScreenState();
}

class _ReminderEditScreenState extends ConsumerState<ReminderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _label;
  late String _type;
  late bool _enabled;
  late int _followUpCount;
  late List<int> _times; // minutes from midnight, sorted

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _label = TextEditingController(text: r?.label ?? '');
    _type = r?.type ?? 'pressure';
    _enabled = r?.enabled ?? true;
    _followUpCount = r?.followUpCount ?? 6;
    _times = List<int>.from(r?.times ?? const <int>[]);
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  String _fmtMinutes(int m) {
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    if (_times.contains(minutes)) return;
    setState(() {
      _times.add(minutes);
      _times.sort();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una hora')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final config = widget.existing ?? ReminderConfig();
      config
        ..type = _type
        ..label = _label.text.trim().isEmpty ? null : _label.text.trim()
        ..enabled = _enabled
        ..followUpCount = _followUpCount
        ..times = _times;

      final repo = ref.read(reminderRepositoryProvider);
      final notifs = ref.read(notificationServiceProvider);

      await repo.upsert(config);
      await notifs.cancelReminder(config.id);
      if (config.enabled) await notifs.scheduleReminder(config);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Nuevo recordatorio' : 'Editar recordatorio',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'pressure',
                    label: Text('Presión'),
                    icon: Icon(Icons.monitor_heart),
                  ),
                  ButtonSegment(
                    value: 'glucose',
                    label: Text('Glucosa'),
                    icon: Icon(Icons.bloodtype),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _label,
                decoration: const InputDecoration(
                  labelText: 'Etiqueta (opcional)',
                  hintText: 'Ej: Presión matutina',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                subtitle: const Text(
                  'Si se desactiva, no se programan notificaciones',
                ),
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Horarios',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton.icon(
                    onPressed: _addTime,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar hora'),
                  ),
                ],
              ),
              if (_times.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Aún no agregas horarios.'),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final m in _times)
                      InputChip(
                        label: Text(_fmtMinutes(m)),
                        onDeleted: () => setState(() => _times.remove(m)),
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              Text(
                'Recordatorios de seguimiento',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Si no registras la medición, te recordaremos cada 5 min '
                'hasta $_followUpCount veces.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
              Slider(
                value: _followUpCount.toDouble(),
                min: 0,
                max: 12,
                divisions: 12,
                label: '$_followUpCount',
                onChanged: (v) => setState(() => _followUpCount = v.round()),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'También recibirás un aviso 30 min antes de cada '
                        'horario para prepararte.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
