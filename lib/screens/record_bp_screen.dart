import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/models/bp_session.dart';
import 'package:health_app/widgets/arm_reading_widget.dart';
import 'package:health_app/widgets/date_time_picker_field.dart';

class RecordBPScreen extends ConsumerStatefulWidget {
  const RecordBPScreen({super.key});

  @override
  ConsumerState<RecordBPScreen> createState() => _RecordBPScreenState();
}

class _RecordBPScreenState extends ConsumerState<RecordBPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rightArm = ArmReadingController();
  final _leftArm = ArmReadingController();
  final _noteController = TextEditingController();
  DateTime _dateTime = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _rightArm.dispose();
    _leftArm.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final right = _rightArm.toModel();
    final left = _leftArm.toModel();
    if (right == null || left == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes completar las lecturas de ambos brazos'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final session = BPSession()
        ..dateTime = _dateTime
        ..rightArm = right
        ..leftArm = left
        ..note = _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim();

      await ref.read(bpRepositoryProvider).insert(session);
      await ref
          .read(notificationServiceProvider)
          .cancelActiveFollowUpsForType('pressure');

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
      appBar: AppBar(title: const Text('Registrar presión arterial')),
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
              const SizedBox(height: 8),
              ArmReadingWidget(
                title: 'Brazo derecho',
                controller: _rightArm,
              ),
              ArmReadingWidget(
                title: 'Brazo izquierdo',
                controller: _leftArm,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
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
