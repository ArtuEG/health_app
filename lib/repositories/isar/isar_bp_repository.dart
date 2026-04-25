import 'package:isar/isar.dart';
import 'package:health_app/models/bp_session.dart';
import 'package:health_app/repositories/ibp_repository.dart';
import 'package:health_app/repositories/isar/isar_data_service.dart';

class IsarBPRepository implements IBPRepository {
  final IsarDataService _data = IsarDataService.instance;

  @override
  Future<int> insert(BPSession session) async {
    final isar = _data.isar;
    return await isar.writeTxn<int>(
      () async => await isar.bPSessions.put(session),
    );
  }

  @override
  Future<void> delete(int id) async {
    final isar = _data.isar;
    await isar.writeTxn(() async => await isar.bPSessions.delete(id));
  }

  @override
  Future<List<BPSession>> getAll({int offset = 0, int limit = 100}) async {
    final isar = _data.isar;
    return await isar.bPSessions.where().offset(offset).limit(limit).findAll();
  }

  @override
  Future<BPSession?> getById(int id) async {
    final isar = _data.isar;
    return await isar.bPSessions.get(id);
  }

  @override
  Future<List<BPSession>> getByRange(DateTime from, DateTime to) async {
    final isar = _data.isar;
    return await isar.bPSessions.filter().dateTimeBetween(from, to).findAll();
  }
}
