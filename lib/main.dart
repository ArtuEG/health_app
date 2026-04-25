import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/repositories/isar/isar_data_service.dart';
import 'package:health_app/repositories/isar/isar_bp_repository.dart';
import 'package:health_app/repositories/isar/isar_glucose_repository.dart';
import 'package:health_app/repositories/isar/isar_reminder_repository.dart';
import 'package:health_app/repositories/isar/isar_user_repository.dart';
import 'package:health_app/screens/root_screen.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const RootScreen(),
    );
  }
}
