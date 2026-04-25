import 'package:health_app/models/bp_session.dart';

abstract class IBPRepository {
  Future<int> insert(BPSession session);
  Future<BPSession?> getById(int id);
  Future<List<BPSession>> getAll({int offset = 0, int limit = 100});
  Future<List<BPSession>> getByRange(DateTime from, DateTime to);
  Future<void> delete(int id);
}
