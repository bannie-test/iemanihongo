/// User progress records stored locally and synced to Supabase.
library;

class DailyStat {
  DailyStat({
    required this.day,
    required this.deviceId,
    this.reviews = 0,
    this.correct = 0,
    this.newWords = 0,
    this.quizTotal = 0,
    this.quizCorrect = 0,
    this.seconds = 0,
    this.goal = 20,
    this.updatedAt = 0,
  });

  final String day;
  final String deviceId;
  int reviews;
  int correct;
  int newWords;
  int quizTotal;
  int quizCorrect;
  int seconds;
  int goal;
  int updatedAt;

  /// Items that count toward the daily goal.
  int get studied => reviews + quizTotal;
  int get answered => reviews + quizTotal;
  int get answeredCorrect => correct + quizCorrect;

  Map<String, Object?> toRow() => {
        'day': day,
        'device_id': deviceId,
        'reviews': reviews,
        'correct': correct,
        'new_words': newWords,
        'quiz_total': quizTotal,
        'quiz_correct': quizCorrect,
        'seconds': seconds,
        'goal': goal,
        'updated_at': updatedAt,
      };

  factory DailyStat.fromRow(Map<String, Object?> r) => DailyStat(
        day: r['day'] as String,
        deviceId: r['device_id'] as String,
        reviews: (r['reviews'] as num).toInt(),
        correct: (r['correct'] as num).toInt(),
        newWords: (r['new_words'] as num).toInt(),
        quizTotal: (r['quiz_total'] as num).toInt(),
        quizCorrect: (r['quiz_correct'] as num).toInt(),
        seconds: (r['seconds'] as num).toInt(),
        goal: (r['goal'] as num).toInt(),
        updatedAt: (r['updated_at'] as num).toInt(),
      );
}

class Deck {
  Deck({required this.id, required this.name, this.deleted = false, this.updatedAt = 0});

  static const starredId = 'starred';

  final String id;
  String name;
  bool deleted;
  int updatedAt;

  bool get isStarred => id == starredId;

  Map<String, Object?> toRow() => {'id': id, 'name': name, 'deleted': deleted ? 1 : 0, 'updated_at': updatedAt};

  factory Deck.fromRow(Map<String, Object?> r) => Deck(
        id: r['id'] as String,
        name: r['name'] as String,
        deleted: r['deleted'] == 1 || r['deleted'] == true,
        updatedAt: (r['updated_at'] as num).toInt(),
      );
}
