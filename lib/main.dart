import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/repositories/isar/isar_data_service.dart';
import 'package:health_app/repositories/isar/isar_bp_repository.dart';
import 'package:health_app/repositories/isar/isar_glucose_repository.dart';
import 'package:health_app/repositories/isar/isar_reminder_repository.dart';
import 'package:health_app/repositories/isar/isar_user_repository.dart';
import 'package:health_app/screens/record_bp_screen.dart';
import 'package:health_app/screens/record_glucose_screen.dart';
import 'package:health_app/services/notification_service.dart';

final bpRepositoryProvider = Provider<IsarBPRepository>(
  (ref) => IsarBPRepository(),
);
final glucoseRepositoryProvider = Provider<IsarGlucoseRepository>(
  (ref) => IsarGlucoseRepository(),
);
final userRepositoryProvider = Provider<IsarUserRepository>(
  (ref) => IsarUserRepository(),
);
final reminderRepositoryProvider = Provider<IsarReminderRepository>(
  (ref) => IsarReminderRepository(),
);
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarDataService.instance.init();
  await NotificationService.instance.init();
  await _rescheduleAllReminders();
  runApp(const ProviderScope(child: MainApp()));
}

Future<void> _rescheduleAllReminders() async {
  final repo = IsarReminderRepository();
  final notifs = NotificationService.instance;
  final enabled = await repo.getEnabled();
  for (final r in enabled) {
    await notifs.cancelReminder(r.id);
    await notifs.scheduleReminder(r);
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Health Tracker',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Tracker')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RecordBPScreen(),
                  ),
                ),
                icon: const Icon(Icons.monitor_heart),
                label: const Text('Registrar presión arterial'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RecordGlucoseScreen(),
                  ),
                ),
                icon: const Icon(Icons.bloodtype),
                label: const Text('Registrar glucosa'),
              ),
              const Spacer(),
              const Divider(),
              Text(
                'Pruebas de notificación',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(notificationServiceProvider)
                      .scheduleTest();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificación de prueba en 10 s'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('Probar notificación (10 s)'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(notificationServiceProvider).cancelAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificaciones canceladas'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_off),
                label: const Text('Cancelar todas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
