import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/models/user_profile.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, this.existing});
  final UserProfile? existing;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.fullName ?? '');
    _age = TextEditingController(text: p?.age.toString() ?? '');
    _height = TextEditingController(
      text: p?.heightCm.toStringAsFixed(0) ?? '',
    );
    _weight = TextEditingController(
      text: p?.weightKg.toStringAsFixed(1) ?? '',
    );
    _notes = TextEditingController(text: p?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requerido' : null;

  String? _intInRange(String? v, int min, int max, String label) {
    final base = _required(v);
    if (base != null) return base;
    final n = int.tryParse(v!.trim());
    if (n == null) return '$label inválido';
    if (n < min || n > max) return '$label debe estar entre $min y $max';
    return null;
  }

  String? _doubleInRange(String? v, double min, double max, String label) {
    final base = _required(v);
    if (base != null) return base;
    final n = double.tryParse(v!.trim().replaceAll(',', '.'));
    if (n == null) return '$label inválido';
    if (n < min || n > max) return '$label debe estar entre $min y $max';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final profile = widget.existing ?? UserProfile();
      profile
        ..fullName = _name.text.trim()
        ..age = int.parse(_age.text.trim())
        ..heightCm = double.parse(_height.text.trim().replaceAll(',', '.'))
        ..weightKg = double.parse(_weight.text.trim().replaceAll(',', '.'))
        ..notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      final repo = ref.read(userRepositoryProvider);
      if (widget.existing == null) {
        await repo.insert(profile);
      } else {
        await repo.update(profile);
      }
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
          widget.existing == null ? 'Crear expediente' : 'Editar expediente',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: _required,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _age,
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        suffixText: 'años',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (v) => _intInRange(v, 0, 130, 'Edad'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _height,
                      decoration: const InputDecoration(
                        labelText: 'Estatura',
                        suffixText: 'cm',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          _doubleInRange(v, 50, 250, 'Estatura'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weight,
                decoration: const InputDecoration(
                  labelText: 'Peso',
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => _doubleInRange(v, 10, 400, 'Peso'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
