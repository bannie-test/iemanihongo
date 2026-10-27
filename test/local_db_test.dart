import 'package:flutter_test/flutter_test.dart';
import 'package:iemanihongo/data/local_db.dart';
import 'package:iemanihongo/logic/srs.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late LocalDb db;

  setUpAll(sqfliteFfiInit);
  setUp(() async => db = await LocalDb.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath));
  tearDown(() => db.db.close());

  test('local writes are dirty until pushed', () async {
    await db.saveCard(const CardState(wordId: 'a', updatedAt: 5));
    final dirty = await db.dirtyRows('user_cards');
    expect(dirty, hasLength(1));
    await db.markClean('user_cards', dirty);
    expect(await db.dirtyRows('user_cards'), isEmpty);
  });

  test('a row changed during push stays dirty', () async {
    await db.saveCard(const CardState(wordId: 'a', updatedAt: 5));
    final pushed = await db.dirtyRows('user_cards');
    await db.saveCard(const CardState(wordId: 'a', updatedAt: 6));
    await db.markClean('user_cards', pushed);
    expect(await db.dirtyRows('user_cards'), hasLength(1));
  });

  test('remote rows merge with last-write-wins', () async {
    await db.saveCard(const CardState(wordId: 'a', reps: 1, updatedAt: 100));
    final older = {...const CardState(wordId: 'a', reps: 9, updatedAt: 50).toRow()};
    final newer = {...const CardState(wordId: 'b', reps: 3, updatedAt: 10).toRow()};
    expect(await db.mergeRemote('user_cards', [older, newer]), 1);
    final cards = {for (final c in await db.cards()) c.wordId: c};
    expect(cards['a']!.reps, 1);
    expect(cards['b']!.reps, 3);
    expect(await db.dirtyRows('user_cards'), hasLength(1)); // only the local edit
  });

  test('deck words toggle and soft-delete', () async {
    await db.setDeckWord('starred', 'x', true, 1);
    await db.setDeckWord('starred', 'y', true, 1);
    await db.setDeckWord('starred', 'x', false, 2);
    expect(await db.deckWords(), {'starred': {'y'}});
  });
}
