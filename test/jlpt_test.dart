import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iemanihongo/logic/weakness.dart';
import 'package:iemanihongo/models/jlpt.dart';

List<JlptTest> load() => [
  for (final j in jsonDecode(File('assets/data/jlpt_tests.json').readAsStringSync()) as List)
    JlptTest.fromJson(j as Map<String, dynamic>),
];

TestAnswer ans(String q, bool ok, int at, {String sec = 'kanji', String tag = 'T', int level = 3}) => TestAnswer(
  id: '$q-$at',
  attemptId: 'a',
  questionId: q,
  level: level,
  section: sec,
  tag: tag,
  chosen: ok ? 1 : 0,
  isCorrect: ok,
  answeredAt: at,
);

void main() {
  group('question bank', () {
    final tests = load();
    final raw = jsonDecode(File('assets/data/jlpt_tests.json').readAsStringSync()) as List;

    test('two 30-question tests for each of N3, N2, N1', () {
      for (final l in [3, 2, 1]) {
        final ts = tests.where((t) => t.level == l).toList();
        expect(ts, hasLength(2));
        for (final t in ts) {
          expect(t.questions, hasLength(30));
          expect(t.minutes, greaterThan(0));
        }
      }
    });

    test('shuffled options still point at the authored answer', () {
      for (var ti = 0; ti < tests.length; ti++) {
        final qs = (raw[ti] as Map)['questions'] as List;
        for (var qi = 0; qi < qs.length; qi++) {
          final authored = qs[qi] as Map;
          final correct = (authored['o'] as List)[authored['a'] as int];
          final q = tests[ti].questions[qi];
          expect(q.options[q.answer], correct, reason: q.id);
          expect(q.options.toSet(), hasLength(4));
        }
      }
    });

    test('option order is stable across loads and not always first', () {
      final again = load();
      for (var i = 0; i < tests.length; i++) {
        for (var j = 0; j < tests[i].questions.length; j++) {
          expect(again[i].questions[j].options, tests[i].questions[j].options);
        }
      }
      final positions = {
        for (final t in tests)
          for (final q in t.questions) q.answer,
      };
      expect(positions.length, 4);
    });

    test('every question has a Vietnamese translation and explanation per option', () {
      for (final q in tests.expand((t) => t.questions)) {
        expect(q.translation.trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.contains('✓') || q.section == JlptSection.narabe, isTrue, reason: q.id);
        if (q.section == JlptSection.narabe) expect(q.explanation, contains('★'), reason: q.id);
      }
    });
  });

  group('weak areas', () {
    test('section accuracy, weak tags and latest mistakes', () {
      final r = Weakness.analyze([
        ans('q1', false, 1, sec: 'bunpou', tag: 'わけだ'),
        ans('q1', false, 2, sec: 'bunpou', tag: 'わけだ'),
        ans('q2', true, 3, sec: 'kanji', tag: 'Trường âm'),
        ans('q2', true, 4, sec: 'kanji', tag: 'Trường âm'),
        ans('q3', false, 5, sec: 'kanji', tag: 'Âm đục'),
        ans('q3', true, 6, sec: 'kanji', tag: 'Âm đục'),
        ans('q9', false, 7, level: 2),
      ], level: 3);
      expect(r.sections[JlptSection.bunpou]!.accuracy, 0);
      expect(r.sections[JlptSection.kanji]!.answered, 4);
      expect(r.weakestSection, JlptSection.bunpou);
      expect(r.weakTags.first.label, 'わけだ');
      expect(r.mistakes, ['q1']); // q3 was fixed, q9 is another level
    });

    test('only recent answers count, so improvement shows', () {
      final r = Weakness.analyze([
        for (var i = 0; i < 5; i++) ans('q1', false, i),
        for (var i = 5; i < 8; i++) ans('q1', true, i),
      ], recent: 3);
      expect(r.sections[JlptSection.kanji]!.accuracy, 1);
      expect(r.weakTags, isEmpty);
    });
  });

  test('attempt row round trip keeps answers and flags', () {
    final a = TestAttempt(
      id: 'x',
      testId: 'n3-t1',
      title: 'N3',
      level: 3,
      mode: AttemptMode.exam,
      questionIds: ['a', 'b'],
      answers: {'a': 2},
      flagged: {'b'},
      startedAt: 1,
      timeLimitSec: 1800,
      elapsedSec: 100,
    );
    final b = TestAttempt.fromRow(a.toRow());
    expect(b.answers, {'a': 2});
    expect(b.flagged, {'b'});
    expect(b.remainingSec, 1700);
    expect(b.inProgress, isTrue);
  });
}
