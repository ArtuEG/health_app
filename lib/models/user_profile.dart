import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@Collection()
class UserProfile {
  Id id = Isar.autoIncrement;

  late String fullName;
  late int age;
  late double heightCm;
  late double weightKg;
  String? notes;
}
