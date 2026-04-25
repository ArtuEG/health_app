import 'package:isar/isar.dart';

part 'glucose_measurement.g.dart';

enum GlucoseType { fasting, postprandial, other }

@Collection()
class GlucoseMeasurement {
  Id id = Isar.autoIncrement;

  late DateTime dateTime;

  late int mgPerDl;

  String? notes;

  @Enumerated(EnumType.ordinal)
  GlucoseType type = GlucoseType.other;
}
