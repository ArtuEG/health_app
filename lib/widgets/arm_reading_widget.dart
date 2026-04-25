import 'package:flutter/material.dart';
import 'package:health_app/models/bp_session.dart';
import 'package:health_app/utils/validators.dart';
import 'package:health_app/widgets/number_field.dart';

class ArmReadingController {
  final TextEditingController sys = TextEditingController();
  final TextEditingController dia = TextEditingController();
  final TextEditingController pulse = TextEditingController();

  ArmReading? toModel() {
    final s = int.tryParse(sys.text.trim());
    final d = int.tryParse(dia.text.trim());
    final p = int.tryParse(pulse.text.trim());
    if (s == null || d == null || p == null) return null;
    return ArmReading()
      ..sys = s
      ..dia = d
      ..pulse = p;
  }

  void dispose() {
    sys.dispose();
    dia.dispose();
    pulse.dispose();
  }
}

class ArmReadingWidget extends StatelessWidget {
  const ArmReadingWidget({
    super.key,
    required this.title,
    required this.controller,
  });

  final String title;
  final ArmReadingController controller;

  String? _crossValidate(String? _) {
    final s = int.tryParse(controller.sys.text.trim());
    final d = int.tryParse(controller.dia.text.trim());
    return Validators.sysGreaterThanDia(s, d);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: controller.sys,
                    label: 'Sistólica',
                    suffix: 'mmHg',
                    validator: (v) {
                      final base = Validators.sys(v);
                      if (base != null) return base;
                      return _crossValidate(v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumberField(
                    controller: controller.dia,
                    label: 'Diastólica',
                    suffix: 'mmHg',
                    validator: Validators.dia,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            NumberField(
              controller: controller.pulse,
              label: 'Pulso',
              suffix: 'bpm',
              validator: Validators.pulse,
            ),
          ],
        ),
      ),
    );
  }
}
