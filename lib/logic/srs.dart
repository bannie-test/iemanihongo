/// Spaced-repetition scheduling (an SM-2 variant with Anki-style learning
/// steps). Pure Dart so it can be unit tested.
library;

import 'dart:math' as math;

enum Rating { again, hard, good, easy }

enum CardPhase { fresh, learning, review, relearning }

class CardState {
  const CardState({
    required this.wordId,
    this.phase = CardPhase.fresh,
    this.step = 0,
    this.ease = 2.5,
    this.interval = 0,
    this.due = 0,
    this.reps = 0,
    this.lapses = 0,
    this.updatedAt = 0,
  });

  final String wordId;
  final CardPhase phase;
  final int step;
  final double ease;

  /// Current review interval in days (meaningful once graduated).
  final double interval;

  /// Next due time, epoch milliseconds.
  final int due;
  final int reps;
  final int lapses;
  final int updatedAt;

  /// A word counts as "learned" once it has graduated to review.
  bool get isLearned => phase == CardPhase.review || phase == CardPhase.relearning;
  bool isDue(int nowMs) => phase != CardPhase.fresh && due <= nowMs;

  CardState copyWith({
    CardPhase? phase,
    int? step,
    double? ease,
    double? interval,
    int? due,
    int? reps,
    int? lapses,
    int? updatedAt,
  }) =>
      CardState(
        wordId: wordId,
        phase: phase ?? this.phase,
        step: step ?? this.step,
        ease: ease ?? this.ease,
        interval: interval ?? this.interval,
        due: due ?? this.due,
        reps: reps ?? this.reps,
        lapses: lapses ?? this.lapses,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toRow() => {
        'word_id': wordId,
        'state': phase.index,
        'step': step,
        'ease': ease,
        'interval_days': interval,
        'due': due,
        'reps': reps,
        'lapses': lapses,
        'updated_at': updatedAt,
      };

  factory CardState.fromRow(Map<String, Object?> r) => CardState(
        wordId: r['word_id'] as String,
        phase: CardPhase.values[(r['state'] as num).toInt().clamp(0, 3)],
        step: (r['step'] as num).toInt(),
        ease: (r['ease'] as num).toDouble(),
        interval: (r['interval_days'] as num).toDouble(),
        due: (r['due'] as num).toInt(),
        reps: (r['reps'] as num).toInt(),
        lapses: (r['lapses'] as num).toInt(),
        updatedAt: (r['updated_at'] as num).toInt(),
      );
}

class Srs {
  static const learningSteps = [Duration(minutes: 1), Duration(minutes: 10)];
  static const relearnStep = Duration(minutes: 10);
  static const graduatingDays = 1.0;
  static const easyDays = 4.0;
  static const minEase = 1.3;
  static const maxDays = 3650.0;
  static const _dayMs = 86400000;

  static CardState schedule(CardState c, Rating r, int nowMs) {
    final next = switch (c.phase) {
      CardPhase.fresh || CardPhase.learning => _learning(c, r, nowMs),
      CardPhase.review => _review(c, r, nowMs),
      CardPhase.relearning => _relearning(c, r, nowMs),
    };
    return next.copyWith(reps: c.reps + 1, updatedAt: nowMs);
  }

  static CardState _learning(CardState c, Rating r, int now) {
    switch (r) {
      case Rating.again:
        return c.copyWith(phase: CardPhase.learning, step: 0, due: now + learningSteps[0].inMilliseconds);
      case Rating.hard:
        final d = c.step == 0
            ? (learningSteps[0].inMilliseconds + learningSteps[1].inMilliseconds) ~/ 2
            : learningSteps[c.step.clamp(0, learningSteps.length - 1)].inMilliseconds;
        return c.copyWith(phase: CardPhase.learning, due: now + d);
      case Rating.good:
        final nextStep = c.phase == CardPhase.fresh ? 1 : c.step + 1;
        if (nextStep < learningSteps.length) {
          return c.copyWith(phase: CardPhase.learning, step: nextStep, due: now + learningSteps[nextStep].inMilliseconds);
        }
        return _graduate(c, graduatingDays, now);
      case Rating.easy:
        return _graduate(c, easyDays, now);
    }
  }

  static CardState _graduate(CardState c, double days, int now) =>
      c.copyWith(phase: CardPhase.review, step: 0, interval: days, due: now + (days * _dayMs).round());

  static CardState _review(CardState c, Rating r, int now) {
    final ivl = math.max(c.interval, 1.0);
    switch (r) {
      case Rating.again:
        return c.copyWith(
          phase: CardPhase.relearning,
          lapses: c.lapses + 1,
          ease: math.max(minEase, c.ease - 0.2),
          interval: math.max(1.0, (ivl * 0.5).roundToDouble()),
          due: now + relearnStep.inMilliseconds,
        );
      case Rating.hard:
        return _reviewDue(c.copyWith(ease: math.max(minEase, c.ease - 0.15)), math.max(ivl + 1, ivl * 1.2), now);
      case Rating.good:
        return _reviewDue(c, math.max(ivl + 1, ivl * c.ease), now);
      case Rating.easy:
        final e = c.ease + 0.15;
        return _reviewDue(c.copyWith(ease: e), math.max(ivl + 2, ivl * e * 1.3), now);
    }
  }

  static CardState _reviewDue(CardState c, double days, int now) {
    final d = math.min(maxDays, days.roundToDouble());
    return c.copyWith(phase: CardPhase.review, interval: d, due: now + (d * _dayMs).round());
  }

  static CardState _relearning(CardState c, Rating r, int now) {
    switch (r) {
      case Rating.again:
      case Rating.hard:
        return c.copyWith(due: now + relearnStep.inMilliseconds);
      case Rating.good:
        return _reviewDue(c, c.interval, now);
      case Rating.easy:
        return _reviewDue(c, c.interval + 1, now);
    }
  }

  /// Human-friendly label of the interval a rating would produce.
  static String previewLabel(CardState c, Rating r, int nowMs) =>
      formatInterval(schedule(c, r, nowMs).due - nowMs);

  static String formatInterval(int ms) {
    final m = ms / 60000;
    if (m < 60) return '${math.max(1, m.round())}m';
    final h = m / 60;
    if (h < 24) return '${h.round()}h';
    final d = h / 24;
    if (d < 30) return '${d.round()}d';
    if (d < 365) return '${(d / 30).round()}mo';
    return '${(d / 365).toStringAsFixed(1)}y';
  }
}
