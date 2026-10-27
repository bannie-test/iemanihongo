/// Streak rules: a day counts when the daily goal is met. Every 7 days of
/// streak earns a freeze (max 2); a freeze is spent automatically on a missed
/// day so the streak survives. Today never breaks the streak while it is
/// still in progress.
library;

class DayTotal {
  const DayTotal(this.studied, this.goal);
  final int studied;
  final int goal;
  bool get met => goal > 0 && studied >= goal;
}

class StreakInfo {
  const StreakInfo({
    required this.current,
    required this.best,
    required this.freezes,
    required this.frozenDays,
    required this.todayDone,
  });

  final int current;
  final int best;
  final int freezes;
  final Set<String> frozenDays;
  final bool todayDone;

  static const empty = StreakInfo(current: 0, best: 0, freezes: 0, frozenDays: {}, todayDone: false);
}

class StreakCalculator {
  static const maxFreezes = 2;
  static const freezeEvery = 7;

  /// [days] maps yyyy-MM-dd → totals. [today] is yyyy-MM-dd in local time.
  static StreakInfo compute(Map<String, DayTotal> days, String today, int currentGoal) {
    final active = days.entries.where((e) => e.value.studied > 0).map((e) => e.key).toList()..sort();
    if (active.isEmpty) return StreakInfo.empty;

    var cur = 0, best = 0, freezes = 0;
    final frozen = <String>{};
    var d = parseDay(active.first);
    final end = parseDay(today);
    var todayDone = false;
    while (!d.isAfter(end)) {
      final key = dayKey(d);
      final total = days[key] ?? DayTotal(0, currentGoal);
      if (total.met) {
        cur++;
        if (cur > best) best = cur;
        if (cur % freezeEvery == 0 && freezes < maxFreezes) freezes++;
        if (key == today) todayDone = true;
      } else if (key != today) {
        if (cur > 0 && freezes > 0) {
          freezes--;
          frozen.add(key);
        } else {
          cur = 0;
        }
      }
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return StreakInfo(current: cur, best: best, freezes: freezes, frozenDays: frozen, todayDone: todayDone);
  }
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDay(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}
