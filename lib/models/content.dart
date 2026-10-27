/// Bundled, read-only learning content (assets/data/*.json).
library;

class Word {
  const Word({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
    required this.level,
    required this.order,
    this.spoken,
  });

  final String id;

  /// Written form, e.g. 勉強. Kana-only words have [word] == [reading].
  final String word;
  final String reading;
  final String meaning;

  /// JLPT level, 5 (N5) … 1 (N1).
  final int level;

  /// Position within its level (approximate frequency order).
  final int order;

  /// Clean kana reading for text-to-speech when [reading] has notes.
  final String? spoken;

  String get speakText => spoken ?? reading;
  bool get hasKanji => word.runes.any((r) => isKanji(String.fromCharCode(r)));
  bool get showReading => word != reading;

  /// First one or two senses, short enough for quiz options.
  String get shortMeaning {
    final parts = meaning.split(RegExp(r'[,;]\s*'));
    final short = parts.take(2).join(', ');
    return short.length > 42 ? '${short.substring(0, 40)}…' : short;
  }

  factory Word.fromJson(Map<String, dynamic> j) => Word(
        id: j['id'] as String,
        word: j['w'] as String,
        reading: j['r'] as String,
        meaning: j['m'] as String,
        level: j['l'] as int,
        order: j['o'] as int,
        spoken: j['s'] as String?,
      );
}

bool isKanji(String ch) {
  final c = ch.codeUnitAt(0);
  return (c >= 0x4e00 && c <= 0x9fff) || c == 0x3005;
}

class KanjiInfo {
  const KanjiInfo({
    required this.char,
    required this.strokes,
    required this.meanings,
    required this.onReadings,
    required this.kunReadings,
    this.level,
  });

  final String char;
  final int? strokes;
  final List<String> meanings;
  final List<String> onReadings;
  final List<String> kunReadings;
  final int? level;

  factory KanjiInfo.fromJson(String char, Map<String, dynamic> j) => KanjiInfo(
        char: char,
        strokes: j['s'] as int?,
        meanings: List<String>.from(j['m'] as List),
        onReadings: List<String>.from(j['on'] as List),
        kunReadings: List<String>.from(j['kun'] as List),
        level: j['l'] as int?,
      );
}

class GrammarExample {
  const GrammarExample(this.jp, this.en);
  final String jp; // ** marks the highlighted grammar
  final String en;
  String get plain => jp.replaceAll('**', '');
}

class GrammarQuiz {
  const GrammarQuiz(this.sentence, this.options, this.answer, this.translation);
  final String sentence; // contains ＿＿
  final List<String> options;
  final int answer;
  final String translation;
}

class GrammarPoint {
  const GrammarPoint({
    required this.id,
    required this.level,
    required this.title,
    required this.meaning,
    required this.formation,
    required this.explanation,
    required this.examples,
    required this.quiz,
  });

  final String id;
  final int level;
  final String title;
  final String meaning;
  final String formation;
  final String explanation;
  final List<GrammarExample> examples;
  final GrammarQuiz quiz;

  factory GrammarPoint.fromJson(Map<String, dynamic> j) {
    final q = j['q'] as Map<String, dynamic>;
    return GrammarPoint(
      id: j['id'] as String,
      level: j['l'] as int,
      title: j['t'] as String,
      meaning: j['m'] as String,
      formation: j['f'] as String,
      explanation: j['e'] as String,
      examples: [
        for (final x in j['x'] as List) GrammarExample(x['jp'] as String, x['en'] as String),
      ],
      quiz: GrammarQuiz(
        q['s'] as String,
        List<String>.from(q['o'] as List),
        q['a'] as int,
        q['en'] as String,
      ),
    );
  }
}
