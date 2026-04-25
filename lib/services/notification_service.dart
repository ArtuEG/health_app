import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:health_app/models/reminder_config.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

enum NotifKind { prep, moment, followUp, test }

class _PendingPayload {
  final String type;
  final int reminderId;
  final int slotIndex;
  final NotifKind kind;
  final DateTime scheduledAt;

  _PendingPayload({
    required this.type,
    required this.reminderId,
    required this.slotIndex,
    required this.kind,
    required this.scheduledAt,
  });

  String encode() =>
      '$type|$reminderId|$slotIndex|${kind.name}|${scheduledAt.toIso8601String()}';

  static _PendingPayload? tryDecode(String? raw) {
    if (raw == null) return null;
    final parts = raw.split('|');
    if (parts.length != 5) return null;
    final kind = NotifKind.values.firstWhere(
      (k) => k.name == parts[3],
      orElse: () => NotifKind.test,
    );
    final at = DateTime.tryParse(parts[4]);
    final rid = int.tryParse(parts[1]);
    final slot = int.tryParse(parts[2]);
    if (at == null || rid == null || slot == null) return null;
    return _PendingPayload(
      type: parts[0],
      reminderId: rid,
      slotIndex: slot,
      kind: kind,
      scheduledAt: at,
    );
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelIdPrep = 'health_prep';
  static const _channelIdMoment = 'health_moment';
  static const _channelIdFollow = 'health_followup';
  static const _channelIdTest = 'health_test';

  static const int _scheduleHorizonDays = 2;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  AndroidNotificationDetails _androidDetails(NotifKind kind) {
    switch (kind) {
      case NotifKind.prep:
        return const AndroidNotificationDetails(
          _channelIdPrep,
          'Recordatorios previos',
          channelDescription: 'Aviso 30 minutos antes de la medición',
          importance: Importance.high,
          priority: Priority.high,
        );
      case NotifKind.moment:
        return const AndroidNotificationDetails(
          _channelIdMoment,
          'Recordatorios de medición',
          channelDescription: 'Aviso al momento de medir',
          importance: Importance.max,
          priority: Priority.max,
        );
      case NotifKind.followUp:
        return const AndroidNotificationDetails(
          _channelIdFollow,
          'Seguimiento',
          channelDescription: 'Recordatorio si no se registró la medición',
          importance: Importance.max,
          priority: Priority.max,
        );
      case NotifKind.test:
        return const AndroidNotificationDetails(
          _channelIdTest,
          'Prueba',
          channelDescription: 'Notificaciones de prueba',
          importance: Importance.max,
          priority: Priority.max,
        );
    }
  }

  String _titleFor(NotifKind kind, String type) {
    final what = type == 'pressure' ? 'presión arterial' : 'glucosa';
    switch (kind) {
      case NotifKind.prep:
        return 'En 30 min: medir $what';
      case NotifKind.moment:
        return 'Hora de medir $what';
      case NotifKind.followUp:
        return 'Recordatorio: medir $what';
      case NotifKind.test:
        return 'Notificación de prueba';
    }
  }

  String _bodyFor(NotifKind kind, String type) {
    switch (kind) {
      case NotifKind.prep:
        return 'Prepárate. Estamos a 30 minutos del próximo registro.';
      case NotifKind.moment:
        return 'Toca para registrar la medición ahora.';
      case NotifKind.followUp:
        return 'Aún no registras. Toca para hacerlo.';
      case NotifKind.test:
        return 'Si ves esto, las notificaciones funcionan.';
    }
  }

  /// Deterministic id layout per reminder to keep cancellation simple.
  /// Bits: reminderId(20) | dayOffset(2) | slotIndex(6) | event(7)
  int _notifId({
    required int reminderId,
    required int dayOffset,
    required int slotIndex,
    required int eventOffset,
  }) {
    return (reminderId * 100000) +
        (dayOffset * 10000) +
        (slotIndex * 100) +
        eventOffset;
  }

  Future<void> _scheduleAt({
    required int id,
    required DateTime when,
    required NotifKind kind,
    required String type,
    required _PendingPayload payload,
  }) async {
    if (when.isBefore(DateTime.now())) return;
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id,
      _titleFor(kind, type),
      _bodyFor(kind, type),
      tzWhen,
      NotificationDetails(android: _androidDetails(kind)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload.encode(),
    );
  }

  Future<void> scheduleReminder(ReminderConfig config) async {
    if (!config.enabled) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int dayOffset = 0; dayOffset < _scheduleHorizonDays; dayOffset++) {
      final dayBase = today.add(Duration(days: dayOffset));
      for (int slotIndex = 0; slotIndex < config.times.length; slotIndex++) {
        final minutes = config.times[slotIndex];
        final moment = dayBase.add(Duration(minutes: minutes));
        final prep = moment.subtract(const Duration(minutes: 30));

        await _scheduleAt(
          id: _notifId(
            reminderId: config.id,
            dayOffset: dayOffset,
            slotIndex: slotIndex,
            eventOffset: 0,
          ),
          when: prep,
          kind: NotifKind.prep,
          type: config.type,
          payload: _PendingPayload(
            type: config.type,
            reminderId: config.id,
            slotIndex: slotIndex,
            kind: NotifKind.prep,
            scheduledAt: prep,
          ),
        );

        await _scheduleAt(
          id: _notifId(
            reminderId: config.id,
            dayOffset: dayOffset,
            slotIndex: slotIndex,
            eventOffset: 1,
          ),
          when: moment,
          kind: NotifKind.moment,
          type: config.type,
          payload: _PendingPayload(
            type: config.type,
            reminderId: config.id,
            slotIndex: slotIndex,
            kind: NotifKind.moment,
            scheduledAt: moment,
          ),
        );

        for (int i = 1; i <= config.followUpCount; i++) {
          final fu = moment.add(Duration(minutes: 5 * i));
          await _scheduleAt(
            id: _notifId(
              reminderId: config.id,
              dayOffset: dayOffset,
              slotIndex: slotIndex,
              eventOffset: 1 + i,
            ),
            when: fu,
            kind: NotifKind.followUp,
            type: config.type,
            payload: _PendingPayload(
              type: config.type,
              reminderId: config.id,
              slotIndex: slotIndex,
              kind: NotifKind.followUp,
              scheduledAt: fu,
            ),
          );
        }
      }
    }
  }

  Future<void> cancelReminder(int reminderId) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      final payload = _PendingPayload.tryDecode(p.payload);
      if (payload != null && payload.reminderId == reminderId) {
        await _plugin.cancel(p.id);
      }
    }
  }

  /// Cancel pending follow-ups for a given type whose moment is within the
  /// last hour or upcoming hour. Called when the user records a measurement.
  Future<void> cancelActiveFollowUpsForType(String type) async {
    final pending = await _plugin.pendingNotificationRequests();
    final now = DateTime.now();
    final from = now.subtract(const Duration(hours: 1));
    final to = now.add(const Duration(hours: 1));
    for (final p in pending) {
      final payload = _PendingPayload.tryDecode(p.payload);
      if (payload == null) continue;
      if (payload.type != type) continue;
      if (payload.kind != NotifKind.followUp) continue;
      if (payload.scheduledAt.isAfter(from) &&
          payload.scheduledAt.isBefore(to)) {
        await _plugin.cancel(p.id);
      }
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  /// Quick smoke test: fires a notification after [delay].
  Future<void> scheduleTest({Duration delay = const Duration(seconds: 10)}) {
    final when = DateTime.now().add(delay);
    return _scheduleAt(
      id: 999999,
      when: when,
      kind: NotifKind.test,
      type: 'test',
      payload: _PendingPayload(
        type: 'test',
        reminderId: 0,
        slotIndex: 0,
        kind: NotifKind.test,
        scheduledAt: when,
      ),
    );
  }
}
