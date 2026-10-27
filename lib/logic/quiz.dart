/// Builds multiple-choice vocabulary quizzes.
library;

import 'dart:math';

import '../models/content.dart';

enum QuizMode {
  meaning('Meaning', 'Japanese → English', '意味'),
  reverse('Reverse', 'English → Japanese', '逆'),
  reading('Reading', 'Kanji → kana reading', '読み'),
  listening('Listening', 'Hear it, pick the word', '聴');

  const QuizMode(this.title, this.subtitle, this.glyph);
  final String title;
  final String subtitle;
  final String glyph;
}

class QuizQuestion {
  QuizQuestion({required this.word, required this.mode, required this.options, required this.answer});
  final Word word;
  final QuizMode mode;
  final List<String> options;
  final int answer;
}

class QuizBuilder {
  QuizBuilder(this.allWords, {Random? random}) : _rng = random ?? Random();

  final List<Word> allWords;
  final Random _rng;

  /// [pool] are the words to be asked about; distractors come from words of
  /// the same JLPT level. Returns at most [count] questions.
  List<QuizQuestion> build(List<Word> pool, QuizMode mode, int count) {
    final eligible = mode == QuizMode.reading ? pool.where((w) => w.hasKanji).toList() : List.of(pool);
    eligible.shuffle(_rng);
    final byLevel = <int, List<Word>>{};
    for (final w in allWords) {
      byLevel.putIfAbsent(w.level, () => []).add(w);
    }
    return [for (final w in eligible.take(count)) _question(w, mode, byLevel[w.level] ?? allWords)];
  }

  String display(Word w, QuizMode mode) => switch (mode) {
    QuizMode.meaning => w.shortMeaning,
    QuizMode.reverse || QuizMode.listening => w.word,
    QuizMode.reading => w.reading,
  };

  QuizQuestion _question(Word w, QuizMode mode, List<Word> sameLevel) {
    final correct = display(w, mode);
    final seen = {correct, w.shortMeaning, w.word, w.reading};
    final options = <String>[correct];
    var guard = 0;
    while (options.length < 4 && guard++ < 200) {
      final d = sameLevel[_rng.nextInt(sameLevel.length)];
      if (d.id == w.id) continue;
      if (mode == QuizMode.reading && !d.hasKanji) continue;
      // Avoid synonyms/homophones that would also be "right".
      if (d.shortMeaning == w.shortMeaning || d.reading == w.reading || d.word == w.word) continue;
      final text = display(d, mode);
      if (seen.add(text)) options.add(text);
    }
    options.shuffle(_rng);
    return QuizQuestion(word: w, mode: mode, options: options, answer: options.indexOf(correct));
  }
}
