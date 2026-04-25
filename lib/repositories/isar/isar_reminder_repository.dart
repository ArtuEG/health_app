import 'package:isar/isar.dart';
import 'package:health_app/models/reminder_config.dart';
import 'package:health_app/repositories/ireminder_repository.dart';
import 'package:health_app/repositories/isar/isar_data_service.dart';

class IsarReminderRepository implements IReminderRepository {
  final IsarDataService _data = IsarDataService.instance;

  @override
  Future<int> upsert(ReminderConfig config) async {
    final isar = _data.isar;
    return await isar.writeTxn<int>(
      () async => await isar.reminderConfigs.put(config),
    );
  }

  @override
  Future<ReminderConfig?> getById(int id) async {
    final isar = _data.isar;
    return await isar.reminderConfigs.get(id);
  }

  @override
  Future<List<ReminderConfig>> getAll() async {
    final isar = _data.isar;
    return await isar.reminderConfigs.where().findAll();
  }

  @override
  Future<List<ReminderConfig>> getEnabled() async {
    final isar = _data.isar;
    return await isar.reminderConfigs
        .filter()
        .enabledEqualTo(true)
        .findAll();
  }

  @override
  Future<List<ReminderConfig>> getByType(String type) async {
    final isar = _data.isar;
    return await isar.reminderConfigs.filter().typeEqualTo(type).findAll();
  }

  @override
  Future<void> delete(int id) async {
    final isar = _data.isar;
    await isar.writeTxn(() async => await isar.reminderConfigs.delete(id));
  }
}
