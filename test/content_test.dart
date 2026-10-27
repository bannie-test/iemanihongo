import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iemanihongo/data/content_repository.dart';
import 'package:iemanihongo/logic/quiz.dart';

void main() {
  late ContentRepository content;

  setUpAll(() {
    content = ContentRepository.fromJson(
      jsonDecode(File('assets/data/vocab.json').readAsStringSync()) as List,
      jsonDecode(File('assets/data/kanji.json').readAsStringSync()) as Map<String, dynamic>,
      jsonDecode(File('assets/data/grammar.json').readAsStringSync()) as List,
      jsonDecode(File('assets/data/jlpt_tests.json').readAsStringSync()) as List,
    );
  });

  test('vocabulary covers every JLPT level with unique ids', () {
    for (final l in [5, 4, 3, 2, 1]) {
      expect(content.byLevel[l]!.length, greaterThan(500), reason: 'N$l');
    }
    expect(content.byId.length, content.words.length);
    expect(content.words.length, greaterThan(8000));
  });

  test('every word has something speakable', () {
    for (final w in content.words) {
      expect(w.speakText.trim(), isNotEmpty, reason: w.word);
      expect(w.speakText.contains('〜'), isFalse, reason: w.word);
    }
  });

  test('kanji breakdown resolves', () {
    final w = content.words.firstWhere((w) => w.word == '勉強');
    expect(content.kanjiIn(w).map((k) => k.char), ['勉', '強']);
  });

  test('grammar lessons are well formed for every level', () {
    for (final l in [5, 4, 3, 2, 1]) {
      expect(content.grammar.where((g) => g.level == l).length, greaterThanOrEqualTo(15));
    }
    for (final g in content.grammar) {
      expect(g.examples, isNotEmpty, reason: g.id);
      expect(g.quiz.sentence, contains('＿＿'), reason: g.id);
      expect(g.quiz.answer, inInclusiveRange(0, g.quiz.options.length - 1));
      for (final x in g.examples) {
        expect('**'.allMatches(x.jp).length.isEven, isTrue, reason: x.jp);
      }
    }
  });

  test('quiz questions have 4 distinct options including the answer', () {
    final builder = QuizBuilder(content.words, random: Random(1));
    for (final mode in QuizMode.values) {
      final qs = builder.build(content.byLevel[5]!.take(40).toList(), mode, 10);
      expect(qs, hasLength(10));
      for (final q in qs) {
        expect(q.options.toSet(), hasLength(4));
        expect(q.options[q.answer], builder.display(q.word, mode));
        if (mode == QuizMode.reading) expect(q.word.hasKanji, isTrue);
      }
    }
  });

  test('search finds by kanji, kana and English', () {
    expect(content.search('勉強').first.word, '勉強');
    expect(content.search('べんきょう').any((w) => w.word == '勉強'), isTrue);
    expect(content.search('library').any((w) => w.word == '図書館'), isTrue);
  });
}
