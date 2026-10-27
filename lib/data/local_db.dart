import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../logic/srs.dart';
import '../models/user_data.dart';

/// Local SQLite store. It is the source of truth for the UI; rows with
/// `dirty = 1` are waiting to be pushed to Supabase.
class LocalDb {
  LocalDb(this.db);

  final Database db;

  /// Tables that sync, with their primary-key columns.
  static const syncTables = {
    'user_cards': ['word_id'],
    'daily_stats': ['day', 'device_id'],
    'decks': ['id'],
    'deck_words': ['deck_id', 'word_id'],
    'grammar_progress': ['grammar_id'],
  };

  static Future<LocalDb> open({DatabaseFactory? factory, String? path}) async {
    final f = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await f.getDatabasesPath(), 'iemanihongo.db');
    final db = await f.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: 1, onCreate: (db, _) => _create(db)),
    );
    return LocalDb(db);
  }

  static Future<void> _create(Database db) async {
    final b = db.batch();
    b.execute('''CREATE TABLE user_cards(
      word_id TEXT PRIMARY KEY, state INTEGER NOT NULL, step INTEGER NOT NULL, ease REAL NOT NULL,
      interval_days REAL NOT NULL, due INTEGER NOT NULL, reps INTEGER NOT NULL, lapses INTEGER NOT NULL,
      updated_at INTEGER NOT NULL, dirty INTEGER NOT NULL DEFAULT 1)''');
    b.execute('''CREATE TABLE daily_stats(
      day TEXT NOT NULL, device_id TEXT NOT NULL, reviews INTEGER NOT NULL, correct INTEGER NOT NULL,
      new_words INTEGER NOT NULL, quiz_total INTEGER NOT NULL, quiz_correct INTEGER NOT NULL,
      seconds INTEGER NOT NULL, goal INTEGER NOT NULL, updated_at INTEGER NOT NULL,
      dirty INTEGER NOT NULL DEFAULT 1, PRIMARY KEY(day, device_id))''');
    b.execute('''CREATE TABLE decks(
      id TEXT PRIMARY KEY, name TEXT NOT NULL, deleted INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER NOT NULL, dirty INTEGER NOT NULL DEFAULT 1)''');
    b.execute('''CREATE TABLE deck_words(
      deck_id TEXT NOT NULL, word_id TEXT NOT NULL, deleted INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER NOT NULL, dirty INTEGER NOT NULL DEFAULT 1, PRIMARY KEY(deck_id, word_id))''');
    b.execute('''CREATE TABLE grammar_progress(
      grammar_id TEXT PRIMARY KEY, completed_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
      dirty INTEGER NOT NULL DEFAULT 1)''');
    await b.commit(noResult: true);
  }

  // ---- reads ----

  Future<List<CardState>> cards() async => [for (final r in await db.query('user_cards')) CardState.fromRow(r)];

  Future<List<DailyStat>> dailyStats() async => [for (final r in await db.query('daily_stats')) DailyStat.fromRow(r)];

  Future<List<Deck>> decks() async => [for (final r in await db.query('decks')) Deck.fromRow(r)];

  Future<Map<String, Set<String>>> deckWords() async {
    final m = <String, Set<String>>{};
    for (final r in await db.query('deck_words', where: 'deleted = 0')) {
      m.putIfAbsent(r['deck_id'] as String, () => {}).add(r['word_id'] as String);
    }
    return m;
  }

  Future<Map<String, int>> grammarDone() async => {
        for (final r in await db.query('grammar_progress'))
          r['grammar_id'] as String: (r['completed_at'] as num).toInt(),
      };

  // ---- local writes (marked dirty) ----

  Future<void> saveCard(CardState c) =>
      db.insert('user_cards', {...c.toRow(), 'dirty': 1}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> saveStat(DailyStat s) =>
      db.insert('daily_stats', {...s.toRow(), 'dirty': 1}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> saveDeck(Deck d) =>
      db.insert('decks', {...d.toRow(), 'dirty': 1}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> setDeckWord(String deckId, String wordId, bool present, int now) => db.insert(
        'deck_words',
        {'deck_id': deckId, 'word_id': wordId, 'deleted': present ? 0 : 1, 'updated_at': now, 'dirty': 1},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> saveGrammarDone(String id, int at) => db.insert(
        'grammar_progress',
        {'grammar_id': id, 'completed_at': at, 'updated_at': at, 'dirty': 1},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  // ---- sync support ----

  Future<List<Map<String, Object?>>> dirtyRows(String table) => db.query(table, where: 'dirty = 1', limit: 500);

  /// Clears the dirty flag unless the row changed again while pushing.
  Future<void> markClean(String table, List<Map<String, Object?>> rows) async {
    final keys = syncTables[table]!;
    final b = db.batch();
    for (final r in rows) {
      b.update(
        table,
        {'dirty': 0},
        where: '${keys.map((k) => '$k = ?').join(' AND ')} AND updated_at = ?',
        whereArgs: [for (final k in keys) r[k], r['updated_at']],
      );
    }
    await b.commit(noResult: true);
  }

  /// Applies remote rows using last-write-wins on `updated_at`.
  /// Returns how many local rows changed.
  Future<int> mergeRemote(String table, List<Map<String, Object?>> rows) async {
    final keys = syncTables[table]!;
    var changed = 0;
    await db.transaction((txn) async {
      for (final r in rows) {
        final where = keys.map((k) => '$k = ?').join(' AND ');
        final args = [for (final k in keys) r[k]];
        final local = await txn.query(table, columns: ['updated_at'], where: where, whereArgs: args);
        final remoteAt = (r['updated_at'] as num).toInt();
        if (local.isNotEmpty && (local.first['updated_at'] as num).toInt() >= remoteAt) continue;
        await txn.insert(table, {...r, 'dirty': 0}, conflictAlgorithm: ConflictAlgorithm.replace);
        changed++;
      }
    });
    return changed;
  }

  Future<void> markAllDirty() async {
    for (final t in syncTables.keys) {
      await db.update(t, {'dirty': 1});
    }
  }

  Future<void> clearAll() async {
    for (final t in syncTables.keys) {
      await db.delete(t);
    }
  }
}
