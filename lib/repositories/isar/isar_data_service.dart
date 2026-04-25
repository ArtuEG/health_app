import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:health_app/models/bp_session.dart';
import 'package:health_app/models/glucose_measurement.dart';
import 'package:health_app/models/reminder_config.dart';
import 'package:health_app/models/user_profile.dart';

class IsarDataService {
  IsarDataService._private();
  static final IsarDataService instance = IsarDataService._private();

  Isar? _isar;

  Future<Isar> init() async {
    if (_isar != null) return _isar!;

    final docs = await getApplicationDocumentsDirectory();
    final path = docs.path;

    _isar = await Isar.open([
      UserProfileSchema,
      BPSessionSchema,
      GlucoseMeasurementSchema,
      ReminderConfigSchema,
    ], directory: path);

    return _isar!;
  }

  Isar get isar {
    if (_isar == null) {
      throw StateError('Isar not initialized. Call init() first.');
    }
    return _isar!;
  }
}
