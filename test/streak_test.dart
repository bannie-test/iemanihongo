import 'package:flutter_test/flutter_test.dart';
import 'package:iemanihongo/logic/streak.dart';

Map<String, DayTotal> run(String start, List<int> studied, {int goal = 10}) {
  final d0 = parseDay(start);
  return {
    for (var i = 0; i < studied.length; i++) dayKey(DateTime(d0.year, d0.month, d0.day + i)): DayTotal(studied[i], goal),
  };
}

void main() {
  test('no activity → empty streak', () {
    expect(StreakCalculator.compute({}, '2026-10-27', 10).current, 0);
  });

  test('consecutive goal days build the streak; today in progress does not break it', () {
    final days = run('2026-10-24', [10, 12, 15, 3]); // 24..27, today = 27 not done yet
    final s = StreakCalculator.compute(days, '2026-10-27', 10);
    expect(s.current, 3);
    expect(s.todayDone, isFalse);
  });

  test('meeting the goal today counts', () {
    final s = StreakCalculator.compute(run('2026-10-26', [10, 10]), '2026-10-27', 10);
    expect(s.current, 2);
    expect(s.todayDone, isTrue);
  });

  test('a missed day without freezes resets the streak', () {
    final s = StreakCalculator.compute(run('2026-10-20', [10, 10, 0, 10]), '2026-10-23', 10);
    expect(s.current, 1);
    expect(s.best, 2);
  });

  test('7-day streak earns a freeze that covers one missed day', () {
    final s = StreakCalculator.compute(run('2026-10-01', [10, 10, 10, 10, 10, 10, 10, 0, 10]), '2026-10-09', 10);
    expect(s.current, 8);
    expect(s.freezes, 0);
    expect(s.frozenDays, {'2026-10-08'});
  });

  test('freezes are capped at 2 and run out over a long break', () {
    final s = StreakCalculator.compute(run('2026-09-01', [...List.filled(21, 10), 0, 0, 0, 10]), '2026-09-25', 10);
    expect(s.best, 21);
    expect(s.current, 1);
  });

  test('day keys are zero padded and parse back', () {
    expect(dayKey(DateTime(2026, 3, 7)), '2026-03-07');
    expect(parseDay('2026-03-07'), DateTime(2026, 3, 7));
  });
}
