import 'dart:math';

import 'package:health_app/models/bp_session.dart';
import 'package:health_app/models/glucose_measurement.dart';
import 'package:health_app/models/user_profile.dart';
import 'package:health_app/repositories/ibp_repository.dart';
import 'package:health_app/repositories/iglucose_repository.dart';
import 'package:health_app/repositories/iuser_repository.dart';

class MockSeedResult {
  const MockSeedResult({
    required this.bpCount,
    required this.glucoseCount,
    required this.profileCreated,
  });

  final int bpCount;
  final int glucoseCount;
  final bool profileCreated;
}

class MockDataService {
  MockDataService({
    required this.bpRepo,
    required this.glucoseRepo,
    required this.userRepo,
  });

  final IBPRepository bpRepo;
  final IGlucoseRepository glucoseRepo;
  final IUserRepository userRepo;

  Future<MockSeedResult> seedLastTenMonths() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 10, now.day);
    final random = Random(20260425);
    var bpCount = 0;
    var glucoseCount = 0;

    await _deleteExistingMockData(start, now);
    final profileCreated = await _ensureProfile();

    for (
      var day = DateTime(start.year, start.month, start.day);
      !day.isAfter(now);
      day = day.add(const Duration(days: 1))
    ) {
      final dayIndex = day.difference(start).inDays;
      final seasonal = sin(dayIndex / 18);

      final fasting = GlucoseMeasurement()
        ..dateTime = DateTime(day.year, day.month, day.day, 7, 30)
        ..mgPerDl = _clampInt(
          95 + seasonal * 10 + random.nextInt(19) - 9,
          72,
          145,
        )
        ..type = GlucoseType.fasting
        ..notes = '[mock] Ayunas';
      await glucoseRepo.insert(fasting);
      glucoseCount++;

      if (dayIndex.isEven) {
        final postprandial = GlucoseMeasurement()
          ..dateTime = DateTime(day.year, day.month, day.day, 14, 15)
          ..mgPerDl = _clampInt(
            125 + seasonal * 14 + random.nextInt(31) - 12,
            90,
            190,
          )
          ..type = GlucoseType.postprandial
          ..notes = '[mock] Postprandial';
        await glucoseRepo.insert(postprandial);
        glucoseCount++;
      }

      if (dayIndex % 3 == 0) {
        final baseSys = 124 + seasonal * 7 + random.nextInt(13) - 6;
        final baseDia = 78 + seasonal * 4 + random.nextInt(9) - 4;
        final session = BPSession()
          ..dateTime = DateTime(day.year, day.month, day.day, 8, 10)
          ..rightArm = _armReading(
            sys: baseSys.round(),
            dia: baseDia.round(),
            pulse: 70 + random.nextInt(13) - 5,
          )
          ..leftArm = _armReading(
            sys: (baseSys + random.nextInt(7) - 3).round(),
            dia: (baseDia + random.nextInt(5) - 2).round(),
            pulse: 70 + random.nextInt(13) - 5,
          )
          ..note = '[mock] Lectura de prueba';
        await bpRepo.insert(session);
        bpCount++;
      }
    }

    return MockSeedResult(
      bpCount: bpCount,
      glucoseCount: glucoseCount,
      profileCreated: profileCreated,
    );
  }

  Future<void> _deleteExistingMockData(DateTime from, DateTime to) async {
    final bpRows = await bpRepo.getByRange(from, to);
    for (final row in bpRows.where((row) => _isMockText(row.note))) {
      await bpRepo.delete(row.id);
    }

    final glucoseRows = await glucoseRepo.getByRange(from, to);
    for (final row in glucoseRows.where((row) => _isMockText(row.notes))) {
      await glucoseRepo.delete(row.id);
    }
  }

  bool _isMockText(String? value) => value?.startsWith('[mock]') ?? false;

  Future<bool> _ensureProfile() async {
    final existing = await userRepo.getAll(limit: 1);
    if (existing.isNotEmpty) return false;

    final profile = UserProfile()
      ..fullName = 'Paciente Demo'
      ..age = 42
      ..heightCm = 170
      ..weightKg = 76
      ..notes = '[mock] Perfil generado para pruebas locales.';

    await userRepo.insert(profile);
    return true;
  }

  ArmReading _armReading({
    required int sys,
    required int dia,
    required int pulse,
  }) {
    return ArmReading()
      ..sys = _clampInt(sys, 95, 165)
      ..dia = _clampInt(dia, 58, 105)
      ..pulse = _clampInt(pulse, 55, 105);
  }

  int _clampInt(num value, int min, int max) {
    return value.round().clamp(min, max).toInt();
  }
}
