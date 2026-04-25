import 'package:isar/isar.dart';
import 'package:health_app/models/user_profile.dart';
import 'package:health_app/repositories/iuser_repository.dart';
import 'package:health_app/repositories/isar/isar_data_service.dart';

class IsarUserRepository implements IUserRepository {
  final IsarDataService _data = IsarDataService.instance;

  @override
  Future<int> insert(UserProfile profile) async {
    final isar = _data.isar;
    return await isar.writeTxn<int>(
      () async => await isar.userProfiles.put(profile),
    );
  }

  @override
  Future<void> update(UserProfile profile) async {
    final isar = _data.isar;
    await isar.writeTxn(() async => await isar.userProfiles.put(profile));
  }

  @override
  Future<void> delete(int id) async {
    final isar = _data.isar;
    await isar.writeTxn(() async => await isar.userProfiles.delete(id));
  }

  @override
  Future<List<UserProfile>> getAll({int offset = 0, int limit = 100}) async {
    final isar = _data.isar;
    return await isar.userProfiles
        .where()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  @override
  Future<UserProfile?> getById(int id) async {
    final isar = _data.isar;
    return await isar.userProfiles.get(id);
  }
}
