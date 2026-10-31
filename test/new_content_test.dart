import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iemanihongo/data/content_repository.dart';
import 'package:iemanihongo/screens/listening/listening_screens.dart';
import 'package:iemanihongo/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late ContentRepository content;

  setUpAll(() {
    content = ContentRepository.fromJson(
      jsonDecode(File('assets/data/vocab.json').readAsStringSync()) as List,
      jsonDecode(File('assets/data/kanji.json').readAsStringSync()) as Map<String, dynamic>,
      jsonDecode(File('assets/data/grammar.json').readAsStringSync()) as List,
      jsonDecode(File('assets/data/jlpt_tests.json').readAsStringSync()) as Map<String, dynamic>,
      jsonDecode(File('assets/data/listening.json').readAsStringSync()) as List,
    );
  });

  test('every grammar lesson has a reference and a tip', () {
    expect(content.grammar.length, greaterThanOrEqualTo(160));
    for (final g in content.grammar) {
      expect(g.reference, isNotNull, reason: g.id);
      expect(g.tip, isNotNull, reason: g.id);
    }
  });

  test('JLPT section tips exist for every section', () {
    expect(content.sectionTips.length, 6);
  });

  test('listening items: 6 per level, answer points at the authored option', () {
    final raw = jsonDecode(File('assets/data/listening.json').readAsStringSync()) as List;
    for (final l in [5, 4, 3, 2, 1]) {
      expect(content.listening.where((i) => i.level == l).length, 6);
    }
    for (var i = 0; i < raw.length; i++) {
      final item = content.listening[i];
      expect(item.options[item.answer], (raw[i]['o'] as List)[0]);
      expect(item.lines, isNotEmpty);
    }
  });

  test('sentence listening fills blanks and offers 4 distinct meanings', () {
    final qs = buildSentenceQuestions(content.questionsFor(3), Random(1));
    expect(qs, hasLength(10));
    for (final q in qs) {
      expect(q.jp.contains('（　）'), isFalse);
      expect(q.jp.contains('['), isFalse);
      expect(q.options.toSet(), hasLength(4));
    }
  });

  test('missing Supabase tables are recognised (the "schema cache" error)', () {
    expect(
      SyncService.isMissingSchema(
        const PostgrestException(
          message: "Could not find the table 'public.profiles' in the schema cache",
          code: 'PGRST205',
        ),
      ),
      isTrue,
    );
    expect(SyncService.isMissingSchema(const PostgrestException(message: 'JWT expired', code: 'PGRST301')), isFalse);
    expect(SyncService.isMissingSchema(Exception('SocketException')), isFalse);
  });
}
