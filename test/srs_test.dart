import 'package:flutter_test/flutter_test.dart';
import 'package:iemanihongo/logic/srs.dart';

void main() {
  const day = 86400000;
  const now = 1700000000000;
  const fresh = CardState(wordId: 'w');

  test('new card: Good steps through learning, then graduates to 1 day', () {
    final s1 = Srs.schedule(fresh, Rating.good, now);
    expect(s1.phase, CardPhase.learning);
    expect(s1.due - now, const Duration(minutes: 10).inMilliseconds);
    final s2 = Srs.schedule(s1, Rating.good, now);
    expect(s2.phase, CardPhase.review);
    expect(s2.interval, 1);
    expect(s2.due, now + day);
    expect(s2.isLearned, isTrue);
  });

  test('new card: Easy graduates straight to 4 days', () {
    final s = Srs.schedule(fresh, Rating.easy, now);
    expect(s.phase, CardPhase.review);
    expect(s.due, now + 4 * day);
  });

  test('Again in review lapses, lowers ease and relearns', () {
    const review = CardState(wordId: 'w', phase: CardPhase.review, interval: 10, ease: 2.5);
    final s = Srs.schedule(review, Rating.again, now);
    expect(s.phase, CardPhase.relearning);
    expect(s.lapses, 1);
    expect(s.ease, closeTo(2.3, 1e-9));
    expect(s.interval, 5);
    final back = Srs.schedule(s, Rating.good, now);
    expect(back.phase, CardPhase.review);
    expect(back.due, now + 5 * day);
  });

  test('review intervals grow: Hard < Good < Easy', () {
    const review = CardState(wordId: 'w', phase: CardPhase.review, interval: 10, ease: 2.5);
    final hard = Srs.schedule(review, Rating.hard, now).interval;
    final good = Srs.schedule(review, Rating.good, now).interval;
    final easy = Srs.schedule(review, Rating.easy, now).interval;
    expect(hard, 12);
    expect(good, 25);
    expect(hard < good && good < easy, isTrue);
  });

  test('ease never drops below the minimum', () {
    var c = const CardState(wordId: 'w', phase: CardPhase.review, interval: 3, ease: 1.35);
    c = Srs.schedule(c, Rating.again, now);
    expect(c.ease, Srs.minEase);
  });

  test('row round-trip', () {
    final c = Srs.schedule(fresh, Rating.easy, now);
    final back = CardState.fromRow(c.toRow());
    expect(back.phase, c.phase);
    expect(back.due, c.due);
    expect(back.interval, c.interval);
    expect(back.updatedAt, now);
  });

  test('interval labels', () {
    expect(Srs.formatInterval(60000), '1m');
    expect(Srs.formatInterval(3 * 3600000), '3h');
    expect(Srs.formatInterval(4 * day), '4d');
    expect(Srs.formatInterval(90 * day), '3mo');
  });
}
