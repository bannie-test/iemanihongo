import 'package:flutter/material.dart';

/// User preferences. Stored in SharedPreferences and synced to the
/// `profiles` table as JSON.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.level = 5,
    this.dailyGoal = 20,
    this.newPerDay = 10,
    this.remindersOn = true,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.streakNudge = true,
    this.autoplayAudio = true,
    this.speechRate = 0.45,
    this.updatedAt = 0,
  });

  final ThemeMode themeMode;

  /// Level new words are drawn from (5 = N5 … 1 = N1).
  final int level;
  final int dailyGoal;
  final int newPerDay;
  final bool remindersOn;
  final int reminderHour;
  final int reminderMinute;

  /// Evening "streak at risk" reminder if the goal isn't done yet.
  final bool streakNudge;
  final bool autoplayAudio;
  final double speechRate;
  final int updatedAt;

  static const goalOptions = [10, 20, 30, 50];
  static const newPerDayOptions = [5, 10, 15, 20, 30];

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? level,
    int? dailyGoal,
    int? newPerDay,
    bool? remindersOn,
    int? reminderHour,
    int? reminderMinute,
    bool? streakNudge,
    bool? autoplayAudio,
    double? speechRate,
    int? updatedAt,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    level: level ?? this.level,
    dailyGoal: dailyGoal ?? this.dailyGoal,
    newPerDay: newPerDay ?? this.newPerDay,
    remindersOn: remindersOn ?? this.remindersOn,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    streakNudge: streakNudge ?? this.streakNudge,
    autoplayAudio: autoplayAudio ?? this.autoplayAudio,
    speechRate: speechRate ?? this.speechRate,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'themeMode': themeMode.name,
    'level': level,
    'dailyGoal': dailyGoal,
    'newPerDay': newPerDay,
    'remindersOn': remindersOn,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'streakNudge': streakNudge,
    'autoplayAudio': autoplayAudio,
    'speechRate': speechRate,
    'updatedAt': updatedAt,
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    const d = AppSettings();
    T pick<T>(String k, T fallback) => j[k] is T ? j[k] as T : fallback;
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere((m) => m.name == j['themeMode'], orElse: () => d.themeMode),
      level: pick<num>('level', d.level).toInt().clamp(1, 5),
      dailyGoal: pick<num>('dailyGoal', d.dailyGoal).toInt(),
      newPerDay: pick<num>('newPerDay', d.newPerDay).toInt(),
      remindersOn: pick('remindersOn', d.remindersOn),
      reminderHour: pick<num>('reminderHour', d.reminderHour).toInt(),
      reminderMinute: pick<num>('reminderMinute', d.reminderMinute).toInt(),
      streakNudge: pick('streakNudge', d.streakNudge),
      autoplayAudio: pick('autoplayAudio', d.autoplayAudio),
      speechRate: pick<num>('speechRate', d.speechRate).toDouble(),
      updatedAt: pick<num>('updatedAt', 0).toInt(),
    );
  }
}
