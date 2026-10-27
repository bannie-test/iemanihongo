/// Finds weak areas from the history of JLPT answers. Pure Dart.
library;

import '../models/jlpt.dart';

class AreaStat {
  AreaStat(this.label);
  final String label;
  int answered = 0;
  int correct = 0;
  double get accuracy => answered == 0 ? 0 : correct / answered;
}

class WeaknessReport {
  WeaknessReport({required this.sections, required this.weakTags, required this.mistakes});

  /// Accuracy per section, every section present (answered may be 0).
  final Map<JlptSection, AreaStat> sections;

  /// Tags below the threshold, weakest first.
  final List<AreaStat> weakTags;

  /// Questions whose most recent answer was wrong, most recent first.
  final List<String> mistakes;

  int get answered => sections.values.fold(0, (a, s) => a + s.answered);
  double get accuracy {
    final c = sections.values.fold(0, (a, s) => a + s.correct);
    return answered == 0 ? 0 : c / answered;
  }

  JlptSection? get weakestSection {
    final tried = sections.entries.where((e) => e.value.answered >= 2).toList()
      ..sort((a, b) => a.value.accuracy.compareTo(b.value.accuracy));
    return tried.isEmpty || tried.first.value.accuracy >= Weakness.threshold ? null : tried.first.key;
  }
}

class Weakness {
  static const threshold = 0.7;
  static const minAnswers = 2;

  /// Uses each question's latest [recent] answers so old mistakes that have
  /// since been fixed stop counting against an area.
  static WeaknessReport analyze(Iterable<TestAnswer> answers, {int? level, int recent = 3}) {
    final byQuestion = <String, List<TestAnswer>>{};
    for (final a in answers) {
      if (level != null && a.level != level) continue;
      byQuestion.putIfAbsent(a.questionId, () => []).add(a);
    }
    final sections = {for (final s in JlptSection.values) s: AreaStat(s.vi)};
    final tags = <String, AreaStat>{};
    final mistakes = <(String, int)>[];

    for (final entry in byQuestion.entries) {
      final list = entry.value..sort((a, b) => b.answeredAt.compareTo(a.answeredAt));
      final latest = list.first;
      if (!latest.isCorrect) mistakes.add((entry.key, latest.answeredAt));
      for (final a in list.take(recent)) {
        final sec = JlptSection.values.asNameMap()[a.section];
        if (sec != null) {
          sections[sec]!
            ..answered += 1
            ..correct += a.isCorrect ? 1 : 0;
        }
        tags.putIfAbsent(a.tag, () => AreaStat(a.tag))
          ..answered += 1
          ..correct += a.isCorrect ? 1 : 0;
      }
    }

    final weakTags = tags.values.where((t) => t.answered >= minAnswers && t.accuracy < threshold).toList()
      ..sort((a, b) {
        final c = a.accuracy.compareTo(b.accuracy);
        return c != 0 ? c : b.answered.compareTo(a.answered);
      });
    mistakes.sort((a, b) => b.$2.compareTo(a.$2));
    return WeaknessReport(sections: sections, weakTags: weakTags, mistakes: [for (final m in mistakes) m.$1]);
  }
}
