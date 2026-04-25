import 'package:isar/isar.dart';

part 'bp_session.g.dart';

@Collection()
class BPSession {
  Id id = Isar.autoIncrement;

  late DateTime dateTime;

  @Embedded()
  late ArmReading rightArm;

  @Embedded()
  late ArmReading leftArm;

  String? note;
}

@Embedded()
class ArmReading {
  int sys = 0;
  int dia = 0;
  int pulse = 0;
}
