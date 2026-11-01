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
      'Nhắc học hằng ngày',
      channelDescription: 'Nhắc bạn giữ chuỗi ngày học',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_notification',
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const _reminderLines = [
    ('今日も頑張ろう！', 'Buổi học tiếng Nhật hôm nay đã sẵn sàng. Vài phút thôi là giữ được chuỗi ngày học.'),
    ('復習の時間です', 'Có từ đến hạn ôn tập. Ôn ngay trước khi quên nhé!'),
    ('一日一歩', 'Mỗi ngày một bước. Mở app để học thẻ từ và ngữ pháp hôm nay.'),
    ('継続は力なり', 'Kiên trì là sức mạnh. Thẻ từ đang chờ bạn.'),
    ('少しずつ', 'Từng chút một. Hôm nay ôn 5 phút nhé?'),
    ('新しい言葉', 'Có từ mới để học hôm nay.'),
    ('今日の文法', 'Bài ngữ pháp hôm nay chỉ mất khoảng 5 phút.'),
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
              ? 'Có $dueCount từ cần ôn. ${streak > 0 ? 'Giữ chuỗi $streak ngày học nhé!' : 'Bắt đầu chuỗi ngày học mới hôm nay!'}'
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
                ? 'Chuỗi $streak ngày học sẽ mất lúc nửa đêm. Học nhanh một chút để giữ chuỗi nhé.'
                : 'Bạn chưa đạt mục tiêu hôm nay. Học nhanh một chút để giữ chuỗi nhé.',
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
