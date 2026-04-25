import 'package:health_app/models/user_profile.dart';

abstract class IUserRepository {
  Future<int> insert(UserProfile profile);
  Future<UserProfile?> getById(int id);
  Future<List<UserProfile>> getAll({int offset = 0, int limit = 100});
  Future<void> update(UserProfile profile);
  Future<void> delete(int id);
}
