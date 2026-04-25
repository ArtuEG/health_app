import 'package:isar/isar.dart';
import 'package:health_app/models/glucose_measurement.dart';
import 'package:health_app/repositories/iglucose_repository.dart';
import 'package:health_app/repositories/isar/isar_data_service.dart';

class IsarGlucoseRepository implements IGlucoseRepository {
  final IsarDataService _data = IsarDataService.instance;

  @override
  Future<int> insert(GlucoseMeasurement measurement) async {
    final isar = _data.isar;
    return await isar.writeTxn<int>(
      () async => await isar.glucoseMeasurements.put(measurement),
    );
  }

  @override
  Future<void> delete(int id) async {
    final isar = _data.isar;
    await isar.writeTxn(() async => await isar.glucoseMeasurements.delete(id));
  }

  @override
  Future<List<GlucoseMeasurement>> getAll({
    int offset = 0,
    int limit = 100,
  }) async {
    final isar = _data.isar;
    return await isar.glucoseMeasurements
        .where()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  @override
  Future<GlucoseMeasurement?> getById(int id) async {
    final isar = _data.isar;
    return await isar.glucoseMeasurements.get(id);
  }

  @override
  Future<List<GlucoseMeasurement>> getByRange(
    DateTime from,
    DateTime to,
  ) async {
    final isar = _data.isar;
    return await isar.glucoseMeasurements
        .filter()
        .dateTimeBetween(from, to)
        .findAll();
  }
}
