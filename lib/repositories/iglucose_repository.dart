import 'package:health_app/models/glucose_measurement.dart';

abstract class IGlucoseRepository {
  Future<int> insert(GlucoseMeasurement measurement);
  Future<GlucoseMeasurement?> getById(int id);
  Future<List<GlucoseMeasurement>> getAll({int offset = 0, int limit = 100});
  Future<List<GlucoseMeasurement>> getByRange(DateTime from, DateTime to);
  Future<void> delete(int id);
}
