import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iemanihongo/data/stroke_repository.dart';
import 'package:iemanihongo/logic/handwriting.dart';
import 'package:iemanihongo/logic/kana.dart';

void main() {
  final repo = StrokeRepository.fromJson(
    jsonDecode(File('assets/data/strokes.json').readAsStringSync()) as Map<String, dynamic>,
  );

  test('stroke data covers kana and kanji', () {
    expect(repo['あ']!.strokeCount, 3);
    expect(repo['ア']!.strokeCount, 2);
    expect(repo['勉']!.strokeCount, 10);
    expect(repo['あ']!.labels, hasLength(3));
  });

  test('a faithful trace scores high', () {
    final ref = repo['木']!.samples;
    final r = HandwritingScorer.score(ref, [
      for (final s in ref) [s.first, ...s.skip(3)],
    ]);
    expect(r.score, greaterThanOrEqualTo(90));
    expect(r.inOrder, 4);
    expect(r.strokeCountOk, isTrue);
  });

  test('reversed strokes and wrong order lose points', () {
    final ref = repo['木']!.samples;
    final good = HandwritingScorer.score(ref, ref).score;
    final reversed = HandwritingScorer.score(ref, [for (final s in ref) s.reversed.toList()]);
    expect(reversed.strokes.every((s) => s.reversed), isTrue);
    expect(reversed.score, lessThan(good));
    final shuffled = HandwritingScorer.score(ref, [ref[1], ref[0], ref[3], ref[2]]);
    expect(shuffled.inOrder, lessThan(4));
    expect(shuffled.score, lessThan(good));
  });

  test('a different character scores low; nothing drawn scores 0', () {
    final r = HandwritingScorer.score(repo['木']!.samples, repo['口']!.samples);
    expect(r.score, lessThan(50));
    expect(HandwritingScorer.score(repo['木']!.samples, []).score, 0);
  });

  test('resample spaces points evenly', () {
    final pts = HandwritingScorer.resample([Offset.zero, const Offset(10, 0)], step: 2);
    expect(pts, hasLength(6));
    expect(pts[1].dx, closeTo(2, 1e-9));
    expect(pts.last, const Offset(10, 0));
  });

  test('kana helpers', () {
    expect(romajiOf('し'), 'shi');
    expect(romajiOf('ツ'), 'tsu');
    expect(romajiOf('ん'), 'n');
    expect(toKatakana('あいう'), 'アイウ');
    expect(isKana('ア'), isTrue);
    expect(isKana('木'), isFalse);
  });
}
