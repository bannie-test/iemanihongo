import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/content.dart';
import '../models/jlpt.dart';

/// Vocabulary, kanji and grammar bundled with the app, so everything works
/// offline from the first launch.
class ContentRepository {
  ContentRepository._(this.words, this.kanji, this.grammar, this.tests)
    : byId = {for (final w in words) w.id: w},
      byLevel = _groupByLevel(words),
      questionById = {
        for (final t in tests)
          for (final q in t.questions) q.id: q,
      };

  final List<Word> words;
  final Map<String, Word> byId;
  final Map<int, List<Word>> byLevel;
  final Map<String, KanjiInfo> kanji;
  final List<GrammarPoint> grammar;

  /// JLPT N3–N1 mock tests.
  final List<JlptTest> tests;
  final Map<String, JlptQuestion> questionById;

  static const testLevels = [3, 2, 1];

  List<JlptTest> testsFor(int level) => tests.where((t) => t.level == level).toList();

  List<JlptQuestion> questionsFor(int level, {JlptSection? section}) => [
    for (final t in testsFor(level))
      for (final q in t.questions)
        if (section == null || q.section == section) q,
  ];

  static Future<ContentRepository> load([AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    final vocab = jsonDecode(await b.loadString('assets/data/vocab.json')) as List;
    final kanji = jsonDecode(await b.loadString('assets/data/kanji.json')) as Map<String, dynamic>;
    final grammar = jsonDecode(await b.loadString('assets/data/grammar.json')) as List;
    final tests = jsonDecode(await b.loadString('assets/data/jlpt_tests.json')) as List;
    return ContentRepository.fromJson(vocab, kanji, grammar, tests);
  }

  factory ContentRepository.fromJson(List vocab, Map<String, dynamic> kanji, List grammar, [List tests = const []]) =>
      ContentRepository._(
        [for (final j in vocab) Word.fromJson(j as Map<String, dynamic>)],
        {for (final e in kanji.entries) e.key: KanjiInfo.fromJson(e.key, e.value as Map<String, dynamic>)},
        [for (final j in grammar) GrammarPoint.fromJson(j as Map<String, dynamic>)],
        [for (final j in tests) JlptTest.fromJson(j as Map<String, dynamic>)],
      );

  static Map<int, List<Word>> _groupByLevel(List<Word> words) {
    final m = <int, List<Word>>{for (var l = 1; l <= 5; l++) l: []};
    for (final w in words) {
      m[w.level]!.add(w);
    }
    for (final l in m.values) {
      l.sort((a, b) => a.order.compareTo(b.order));
    }
    return m;
  }

  List<KanjiInfo> kanjiIn(Word w) => [for (final r in w.word.runes.toSet()) ?kanji[String.fromCharCode(r)]];

  List<Word> wordsWithKanji(String char, {int limit = 12}) =>
      words.where((w) => w.word.contains(char)).take(limit).toList();

  List<Word> search(String query, {int limit = 60}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final exact = <Word>[], partial = <Word>[];
    for (final w in words) {
      if (w.word == q || w.reading == q || w.meaning.toLowerCase() == q) {
        exact.add(w);
      } else if (w.word.contains(q) || w.reading.contains(q) || w.meaning.toLowerCase().contains(q)) {
        partial.add(w);
      }
      if (exact.length + partial.length >= limit * 3) break;
    }
    return [...exact, ...partial].take(limit).toList();
  }
}
