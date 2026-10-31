/// JLPT-style listening (聴解) items, read aloud with text-to-speech.
library;

import 'dart:math';

import 'jlpt.dart';

enum ListeningKind {
  kadai('課題理解', 'Hiểu nhiệm vụ'),
  point('ポイント理解', 'Hiểu điểm chính'),
  gaiyou('概要理解', 'Hiểu khái quát'),
  hatsuwa('発話表現', 'Diễn đạt bằng lời'),
  sokuji('即時応答', 'Phản hồi nhanh');

  const ListeningKind(this.jp, this.vi);
  final String jp;
  final String vi;
}

/// M = male, F = female, N = narrator.
class ListeningLine {
  const ListeningLine(this.speaker, this.text);
  final String speaker;
  final String text;

  /// Pitch used to tell the voices apart with a single TTS voice.
  double get pitch => switch (speaker) {
    'M' => 0.78,
    'F' => 1.28,
    _ => 1.0,
  };

  String get label => switch (speaker) {
    'M' => '男',
    'F' => '女',
    _ => '',
  };
}

class ListeningItem {
  ListeningItem({
    required this.id,
    required this.level,
    required this.kind,
    required this.title,
    required this.question,
    required this.lines,
    required this.options,
    required this.answer,
    required this.translation,
    required this.explanation,
    this.tip,
  });

  final String id;
  final int level;
  final ListeningKind kind;

  /// Short Vietnamese title.
  final String title;
  final String question;
  final List<ListeningLine> lines;
  final List<String> options;
  final int answer;
  final String translation;
  final String explanation;
  final String? tip;

  factory ListeningItem.fromJson(Map<String, dynamic> j) {
    final id = j['id'] as String;
    final authored = List<String>.from(j['o'] as List);
    final correct = authored[j['a'] as int];
    final shuffled = List.of(authored)..shuffle(Random(stableHash(id)));
    return ListeningItem(
      id: id,
      level: j['l'] as int,
      kind: ListeningKind.values.byName(j['k'] as String),
      title: j['t'] as String,
      question: j['q'] as String,
      lines: [for (final l in j['lines'] as List) ListeningLine(l['s'] as String, l['jp'] as String)],
      options: shuffled,
      answer: shuffled.indexOf(correct),
      translation: j['vi'] as String,
      explanation: j['ex'] as String,
      tip: j['tip'] as String?,
    );
  }
}
