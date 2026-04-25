import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/models/glucose_measurement.dart';
import 'package:health_app/utils/validators.dart';
import 'package:health_app/widgets/date_time_picker_field.dart';
import 'package:health_app/widgets/number_field.dart';

class RecordGlucoseScreen extends ConsumerStatefulWidget {
  const RecordGlucoseScreen({super.key});

  @override
  ConsumerState<RecordGlucoseScreen> createState() =>
      _RecordGlucoseScreenState();
}

class _RecordGlucoseScreenState extends ConsumerState<RecordGlucoseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mgController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dateTime = DateTime.now();
  GlucoseType _type = GlucoseType.fasting;
  bool _saving = false;

  @override
  void dispose() {
    _mgController.dispose();
    _notesController.dispose();
    super.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final measurement = GlucoseMeasurement()
        ..dateTime = _dateTime
        ..mgPerDl = int.parse(_mgController.text.trim())
        ..type = _type
        ..notes = _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim();

      await ref.read(glucoseRepositoryProvider).insert(measurement);
      await ref
          .read(notificationServiceProvider)
          .cancelActiveFollowUpsForType('glucose');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medición guardada')),
      );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar glucosa')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DateTimePickerField(
                value: _dateTime,
                onChanged: (v) => setState(() => _dateTime = v),
              ),
              const SizedBox(height: 16),
              NumberField(
                controller: _mgController,
                label: 'Glucosa',
                suffix: 'mg/dL',
                validator: Validators.glucose,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<GlucoseType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: GlucoseType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_typeLabel(t)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
                validator: (v) => v == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
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
