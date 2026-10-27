/// Scores a hand-drawn character against its reference strokes.
/// Works on point lists in the reference's 109×109 space, so it is pure and
/// testable. No ML: it checks shape coverage, neatness, stroke count,
/// stroke order and stroke direction.
library;

import 'dart:ui';

class StrokeCheck {
  const StrokeCheck({required this.matched, required this.reversed});

  /// The user's stroke at this index lies on the reference stroke.
  final bool matched;

  /// Drawn in the opposite direction.
  final bool reversed;
}

class HandwritingResult {
  const HandwritingResult({
    required this.score,
    required this.coverage,
    required this.precision,
    required this.expectedStrokes,
    required this.drawnStrokes,
    required this.strokes,
  });

  /// 0 … 100.
  final int score;

  /// Share of the reference shape the user covered.
  final double coverage;

  /// Share of the user's ink that lies on the reference shape.
  final double precision;
  final int expectedStrokes;
  final int drawnStrokes;

  /// One entry per reference stroke.
  final List<StrokeCheck> strokes;

  int get inOrder => strokes.where((s) => s.matched && !s.reversed).length;
  bool get strokeCountOk => expectedStrokes == drawnStrokes;

  String get grade => switch (score) {
    >= 90 => 'Excellent',
    >= 75 => 'Great',
    >= 60 => 'Good',
    >= 40 => 'Keep practising',
    _ => 'Try again',
  };
}

class HandwritingScorer {
  /// Distance (in 109-unit space) that still counts as "on the stroke".
  static const tolerance = 9.0;

  static HandwritingResult score(List<List<Offset>> reference, List<List<Offset>> drawn) {
    final user = [
      for (final s in drawn)
        if (s.isNotEmpty) resample(s),
    ];
    final refAll = [for (final s in reference) ...s];
    final userAll = [for (final s in user) ...s];
    if (userAll.isEmpty || refAll.isEmpty) {
      return HandwritingResult(
        score: 0,
        coverage: 0,
        precision: 0,
        expectedStrokes: reference.length,
        drawnStrokes: user.length,
        strokes: [for (final _ in reference) const StrokeCheck(matched: false, reversed: false)],
      );
    }

    final coverage = _share(refAll, userAll);
    final precision = _share(userAll, refAll);

    final checks = <StrokeCheck>[];
    for (var i = 0; i < reference.length; i++) {
      if (i >= user.length) {
        checks.add(const StrokeCheck(matched: false, reversed: false));
        continue;
      }
      final ref = reference[i], mine = user[i];
      final onStroke = _share(mine, ref, tol: tolerance * 1.3) >= 0.7 && _share(ref, mine, tol: tolerance * 1.3) >= 0.6;
      final reversed = onStroke && (mine.first - ref.first).distance > (mine.first - ref.last).distance;
      checks.add(StrokeCheck(matched: onStroke, reversed: reversed));
    }
    final orderScore = checks.where((s) => s.matched && !s.reversed).length / reference.length;
    final countPenalty = 6 * (reference.length - user.length).abs();
    final raw = 100 * (0.45 * coverage + 0.25 * precision + 0.30 * orderScore) - countPenalty;

    return HandwritingResult(
      score: raw.round().clamp(0, 100),
      coverage: coverage,
      precision: precision,
      expectedStrokes: reference.length,
      drawnStrokes: user.length,
      strokes: checks,
    );
  }

  /// Fraction of [points] within [tol] of some point in [target].
  static double _share(List<Offset> points, List<Offset> target, {double tol = tolerance}) {
    if (points.isEmpty) return 0;
    final t2 = tol * tol;
    var hit = 0;
    for (final p in points) {
      for (final q in target) {
        final dx = p.dx - q.dx, dy = p.dy - q.dy;
        if (dx * dx + dy * dy <= t2) {
          hit++;
          break;
        }
      }
    }
    return hit / points.length;
  }

  /// Evenly spaced points every [step] units along a polyline.
  static List<Offset> resample(List<Offset> stroke, {double step = 2}) {
    if (stroke.length < 2) return List.of(stroke);
    final out = <Offset>[stroke.first];
    var travelled = 0.0; // distance since the last emitted point
    for (var i = 1; i < stroke.length; i++) {
      var a = stroke[i - 1];
      final b = stroke[i];
      var seg = (b - a).distance;
      while (travelled + seg >= step && seg > 0) {
        final p = Offset.lerp(a, b, (step - travelled) / seg)!;
        out.add(p);
        a = p;
        seg = (b - a).distance;
        travelled = 0;
      }
      travelled += seg;
    }
    if ((out.last - stroke.last).distance > 0.01) out.add(stroke.last);
    return out;
  }
}
