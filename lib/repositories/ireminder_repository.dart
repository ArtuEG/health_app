import 'package:health_app/models/reminder_config.dart';

abstract class IReminderRepository {
  Future<int> upsert(ReminderConfig config);
  Future<ReminderConfig?> getById(int id);
  Future<List<ReminderConfig>> getAll();
  Future<List<ReminderConfig>> getEnabled();
  Future<List<ReminderConfig>> getByType(String type);
  Future<void> delete(int id);
}
