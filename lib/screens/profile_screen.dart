import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/main.dart';
import 'package:health_app/models/user_profile.dart';
import 'package:health_app/screens/profile_edit_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<UserProfile?> _load() async {
    final list = await ref.read(userRepositoryProvider).getAll(limit: 1);
    return list.isEmpty ? null : list.first;
  }

  Future<void> _openEdit(UserProfile? existing) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileEditScreen(existing: existing),
      ),
    );
    if (saved == true && mounted) setState(() {});
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Image.asset(
          'assets/images/app_logo.png',
          width: 88,
          height: 88,
        ),
        title: const Text('Health Tracker'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App local de seguimiento de presión arterial y glucosa. '
              'Tus datos se almacenan únicamente en este dispositivo.',
            ),
            SizedBox(height: 16),
            Text('Creada por Arturo Elizalde.'),
            SizedBox(height: 12),
            Text(
              'GitHub',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SelectableText('https://github.com/ArtuEG'),
            SizedBox(height: 12),
            Text(
              'Contacto',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SelectableText('artudev365@gmail.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: FutureBuilder<UserProfile?>(
          future: _load(),
          builder: (ctx, snap) {
            if (!snap.hasData && snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final p = snap.data;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (p == null)
                  _EmptyProfile(onCreate: () => _openEdit(null))
                else
                  _ProfileCard(profile: p, onEdit: () => _openEdit(p)),
                const SizedBox(height: 24),
                Text(
                  'Privacidad y datos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Datos 100% locales'),
                    subtitle: const Text(
                      'Toda tu información se guarda en este dispositivo. '
                      'Nada se envía a la nube.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Acerca de la app'),
                    onTap: _showAbout,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onEdit});
  final UserProfile profile;
  final VoidCallback onEdit;

  double? get _bmi {
    final h = profile.heightCm / 100.0;
    if (h <= 0) return null;
    return profile.weightKg / (h * h);
  }

  String _bmiCategory(double v) {
    if (v < 18.5) return 'Bajo peso';
    if (v < 25) return 'Normal';
    if (v < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${profile.age} años',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _InfoCell(
                    label: 'Estatura',
                    value: '${profile.heightCm.toStringAsFixed(0)} cm',
                  ),
                ),
                Expanded(
                  child: _InfoCell(
                    label: 'Peso',
                    value: '${profile.weightKg.toStringAsFixed(1)} kg',
                  ),
                ),
                Expanded(
                  child: _InfoCell(
                    label: 'IMC',
                    value: bmi == null
                        ? '—'
                        : '${bmi.toStringAsFixed(1)}\n${_bmiCategory(bmi)}',
                  ),
                ),
              ],
            ),
            if (profile.notes != null && profile.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notas',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(profile.notes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  const _EmptyProfile({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person_add_alt, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Crea tu expediente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tu nombre, edad y datos básicos aparecerán en los reportes PDF.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear ahora'),
            ),
          ],
        ),
      ),
    );
  }
}
