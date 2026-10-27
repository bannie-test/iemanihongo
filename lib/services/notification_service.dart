import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily study reminders, scheduled on the device so they work offline.
///
/// The next 7 days are scheduled one by one (instead of a repeating alarm)
/// so today's reminder can be skipped once the daily goal is done. The
/// schedule is refreshed whenever the app opens or progress changes.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _daysAhead = 7;
  static const _reminderBase = 100;
  static const _nudgeBase = 200;
  static const nudgeHour = 21;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_reminders',
      'Daily reminders',
      channelDescription: 'Reminders to keep your study streak going',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_notification',
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const _reminderLines = [
    ('今日も頑張ろう！', 'Your daily Japanese session is ready. A few minutes keeps the streak alive.'),
    ('復習の時間です', 'Some words are due for review. Catch them before you forget!'),
    ('一日一歩', 'One step a day. Open the app for today\'s cards and grammar.'),
    ('継続は力なり', 'Consistency is power. Your flashcards are waiting.'),
    ('少しずつ', 'Little by little. Just 5 minutes of review today?'),
    ('新しい言葉', 'New words are ready to learn today.'),
    ('今日の文法', 'Today\'s grammar lesson takes about 5 minutes.'),
  ];

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (e) {
      debugPrint('Timezone lookup failed, using UTC: $e');
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('Notifications init failed: $e');
    }
  }

  /// Asks the OS for permission. Returns whether notifications are allowed.
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return false;
  }

  Future<void> reschedule({
    required bool enabled,
    required int hour,
    required int minute,
    required bool nudge,
    required bool goalDoneToday,
    required int streak,
    required int dueCount,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      if (!enabled) return;
      final now = tz.TZDateTime.now(tz.local);
      for (var i = 0; i < _daysAhead; i++) {
        final day = tz.TZDateTime(tz.local, now.year, now.month, now.day + i);
        final skipToday = i == 0 && goalDoneToday;

        final at = tz.TZDateTime(tz.local, day.year, day.month, day.day, hour, minute);
        if (!skipToday && at.isAfter(now)) {
          final line = _reminderLines[(day.day + day.month) % _reminderLines.length];
          final body = i == 0 && dueCount > 0
              ? '$dueCount words are due for review. ${streak > 0 ? 'Keep your $streak-day streak going!' : 'Start a new streak today!'}'
              : line.$2;
          await _schedule(_reminderBase + i, at, line.$1, body);
        }

        final nudgeAt = tz.TZDateTime(tz.local, day.year, day.month, day.day, nudgeHour);
        final reminderIsLate = hour * 60 + minute >= nudgeHour * 60 - 30;
        if (nudge && !skipToday && !reminderIsLate && nudgeAt.isAfter(now)) {
          await _schedule(
            _nudgeBase + i,
            nudgeAt,
            'ストリークが危ない！',
            i == 0 && streak > 0
                ? 'Your $streak-day streak ends at midnight. A quick session will save it.'
                : 'You haven\'t hit today\'s goal yet. A quick session keeps your streak alive.',
          );
        }
      }
    } catch (e) {
      debugPrint('Scheduling reminders failed: $e');
    }
  }

  Future<void> _schedule(int id, tz.TZDateTime at, String title, String body) => _plugin.zonedSchedule(
    id: id,
    scheduledDate: at,
    notificationDetails: _details,
    // Inexact alarms need no special permission; a few minutes' drift is fine.
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    title: title,
    body: body,
  );
}
