import 'package:isar/isar.dart';

part 'reminder_config.g.dart';

@Collection()
class ReminderConfig {
  Id id = Isar.autoIncrement;

  /// type: 'pressure' or 'glucose'
  late String type;

  /// times stored as minutes from midnight (0-1439)
  List<int> times = [];

  bool enabled = true;

  /// number of follow-up notifications (every 5 minutes)
  int followUpCount = 6;

  /// optional user-readable name
  String? label;
}
