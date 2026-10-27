/// JLPT practice tests (bundled questions) and the user's attempts/answers
/// (synced to Supabase).
library;

import 'dart:convert';
import 'dart:math';

enum JlptSection {
  kanji('問題1 漢字読み', 'Đọc Kanji', 'Chọn cách đọc đúng của từ được gạch chân.'),
  hyoki('問題2 表記', 'Viết Kanji', 'Chọn cách viết Kanji đúng của từ được gạch chân.'),
  bunmyaku('問題3 文脈規定', 'Từ vựng theo ngữ cảnh', 'Chọn từ thích hợp nhất để điền vào （　）.'),
  iikae('問題4 言い換え類義', 'Từ đồng nghĩa', 'Chọn cách nói có nghĩa gần nhất với từ được gạch chân.'),
  bunpou('問題5 文法形式の判断', 'Ngữ pháp', 'Chọn mẫu ngữ pháp thích hợp nhất để điền vào （　）.'),
  narabe('問題6 文の組み立て', 'Sắp xếp câu', 'Sắp xếp các vế thành câu đúng và chọn vế ở vị trí ★.');

  const JlptSection(this.jp, this.vi, this.instruction);
  final String jp;
  final String vi;
  final String instruction;
}

class JlptQuestion {
  JlptQuestion({
    required this.id,
    required this.level,
    required this.testNo,
    required this.section,
    required this.tag,
    required this.sentence,
    required this.options,
    required this.answer,
    required this.translation,
    required this.explanation,
  });

  final String id;
  final int level;
  final int testNo;
  final JlptSection section;

  /// Weak-area label (Vietnamese), e.g. "Ngữ pháp: ～わけだ".
  final String tag;

  /// [x] = underlined word, （　） = blank, ★ = asked slot.
  final String sentence;
  final List<String> options;
  final int answer;
  final String translation;

  /// Vietnamese explanation; lines starting with ✓ / ✗ explain each option.
  final String explanation;

  /// Options are authored with the answer first; shuffle them with a seed
  /// from the id so the order is the same on every device and every visit.
  factory JlptQuestion.fromJson(Map<String, dynamic> j, int level, int testNo) {
    final id = j['id'] as String;
    final authored = List<String>.from(j['o'] as List);
    final correct = authored[j['a'] as int];
    final shuffled = List.of(authored)..shuffle(Random(_stableHash(id)));
    return JlptQuestion(
      id: id,
      level: level,
      testNo: testNo,
      section: JlptSection.values.byName(j['sec'] as String),
      tag: j['tag'] as String,
      sentence: j['s'] as String,
      options: shuffled,
      answer: shuffled.indexOf(correct),
      translation: j['vi'] as String,
      explanation: j['ex'] as String,
    );
  }
}

int _stableHash(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0x7fffffff;
  }
  return h;
}

class JlptTest {
  const JlptTest({
    required this.id,
    required this.level,
    required this.no,
    required this.minutes,
    required this.questions,
  });

  final String id;
  final int level;
  final int no;
  final int minutes;
  final List<JlptQuestion> questions;

  String get title => 'Đề thi thử $no';

  factory JlptTest.fromJson(Map<String, dynamic> j) {
    final level = j['level'] as int;
    final no = j['no'] as int;
    return JlptTest(
      id: j['id'] as String,
      level: level,
      no: no,
      minutes: j['minutes'] as int,
      questions: [for (final q in j['questions'] as List) JlptQuestion.fromJson(q as Map<String, dynamic>, level, no)],
    );
  }
}

enum AttemptMode { exam, practice }

/// One sitting of a mock test or a practice set. Saved while in progress so
/// it can be resumed (also from another device).
class TestAttempt {
  TestAttempt({
    required this.id,
    required this.testId,
    required this.title,
    required this.level,
    required this.mode,
    required this.questionIds,
    Map<String, int>? answers,
    Set<String>? flagged,
    this.currentIndex = 0,
    required this.startedAt,
    this.finishedAt = 0,
    this.timeLimitSec = 0,
    this.elapsedSec = 0,
    this.score = 0,
    this.updatedAt = 0,
  }) : answers = answers ?? {},
       flagged = flagged ?? {};

  final String id;

  /// Test id (n3-t1) or practice key (n3-sec-kanji, n3-weak).
  final String testId;
  final String title;
  final int level;
  final AttemptMode mode;
  final List<String> questionIds;
  final Map<String, int> answers;
  final Set<String> flagged;
  int currentIndex;
  final int startedAt;

  /// 0 while in progress, [discarded] if abandoned, else the finish time.
  int finishedAt;

  /// 0 = untimed.
  final int timeLimitSec;
  int elapsedSec;
  int score;
  int updatedAt;

  /// finishedAt value of an abandoned sitting.
  static const discarded = -1;

  bool get finished => finishedAt > 0;
  bool get inProgress => finishedAt == 0;
  bool get timed => timeLimitSec > 0;
  int get total => questionIds.length;
  int get remainingSec => max(0, timeLimitSec - elapsedSec);
  double get percent => total == 0 ? 0 : score / total;

  Map<String, Object?> toRow() => {
    'id': id,
    'test_id': testId,
    'title': title,
    'level': level,
    'mode': mode.name,
    'question_ids': jsonEncode(questionIds),
    'answers': jsonEncode(answers),
    'flagged': jsonEncode(flagged.toList()),
    'current_index': currentIndex,
    'started_at': startedAt,
    'finished_at': finishedAt,
    'time_limit_sec': timeLimitSec,
    'elapsed_sec': elapsedSec,
    'score': score,
    'total': total,
    'updated_at': updatedAt,
  };

  factory TestAttempt.fromRow(Map<String, Object?> r) => TestAttempt(
    id: r['id'] as String,
    testId: r['test_id'] as String,
    title: r['title'] as String,
    level: (r['level'] as num).toInt(),
    mode: AttemptMode.values.byName(r['mode'] as String),
    questionIds: List<String>.from(jsonDecode(r['question_ids'] as String) as List),
    answers: (jsonDecode(r['answers'] as String) as Map).map((k, v) => MapEntry(k as String, (v as num).toInt())),
    flagged: Set<String>.from(jsonDecode(r['flagged'] as String) as List),
    currentIndex: (r['current_index'] as num).toInt(),
    startedAt: (r['started_at'] as num).toInt(),
    finishedAt: (r['finished_at'] as num).toInt(),
    timeLimitSec: (r['time_limit_sec'] as num).toInt(),
    elapsedSec: (r['elapsed_sec'] as num).toInt(),
    score: (r['score'] as num).toInt(),
    updatedAt: (r['updated_at'] as num).toInt(),
  );
}

/// One answered question; the history behind weak-area tracking.
class TestAnswer {
  const TestAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.level,
    required this.section,
    required this.tag,
    required this.chosen,
    required this.isCorrect,
    required this.answeredAt,
  });

  final String id;
  final String attemptId;
  final String questionId;
  final int level;
  final String section;
  final String tag;
  final int chosen;
  final bool isCorrect;
  final int answeredAt;

  Map<String, Object?> toRow() => {
    'id': id,
    'attempt_id': attemptId,
    'question_id': questionId,
    'level': level,
    'section': section,
    'tag': tag,
    'chosen': chosen,
    'is_correct': isCorrect ? 1 : 0,
    'answered_at': answeredAt,
    'updated_at': answeredAt,
  };

  factory TestAnswer.fromRow(Map<String, Object?> r) => TestAnswer(
    id: r['id'] as String,
    attemptId: r['attempt_id'] as String,
    questionId: r['question_id'] as String,
    level: (r['level'] as num).toInt(),
    section: r['section'] as String,
    tag: r['tag'] as String,
    chosen: (r['chosen'] as num).toInt(),
    isCorrect: r['is_correct'] == 1 || r['is_correct'] == true,
    answeredAt: (r['answered_at'] as num).toInt(),
  );
}
