import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

/// Stroke-order data from KanjiVG (CC BY-SA 3.0) in a 109×109 box.
class CharStrokes {
  CharStrokes(this.char, this.paths, this.labels);

  /// Size of KanjiVG's coordinate space.
  static const box = 109.0;

  final String char;

  /// One path per stroke, in the correct order.
  final List<Path> paths;

  /// Where to draw each stroke number.
  final List<Offset> labels;

  int get strokeCount => paths.length;

  /// Points every [step] units along each stroke (for scoring).
  late final List<List<Offset>> samples = [for (final p in paths) samplePath(p)];
}

List<Offset> samplePath(Path path, {double step = 2}) {
  final pts = <Offset>[];
  for (final m in path.computeMetrics()) {
    for (double d = 0; d < m.length; d += step) {
      pts.add(m.getTangentForOffset(d)!.position);
    }
    pts.add(m.getTangentForOffset(m.length)!.position);
  }
  return pts;
}

/// Loads strokes.json (~2 MB) on first use and parses characters lazily.
class StrokeRepository {
  StrokeRepository._(this._raw);

  final Map<String, dynamic> _raw;
  final Map<String, CharStrokes> _cache = {};

  static Future<StrokeRepository>? _loading;

  /// The repository once loaded, so screens can skip the loading state.
  static StrokeRepository? loaded;

  static Future<StrokeRepository> load([AssetBundle? bundle]) => _loading ??= () async {
    final text = await (bundle ?? rootBundle).loadString('assets/data/strokes.json');
    return loaded = StrokeRepository._(jsonDecode(text) as Map<String, dynamic>);
  }();

  factory StrokeRepository.fromJson(Map<String, dynamic> raw) => StrokeRepository._(raw);

  bool has(String ch) => _raw.containsKey(ch);

  CharStrokes? operator [](String ch) {
    final cached = _cache[ch];
    if (cached != null) return cached;
    final j = _raw[ch] as Map<String, dynamic>?;
    if (j == null) return null;
    final parsed = CharStrokes(
      ch,
      [for (final d in j['p'] as List) parseSvgPathData(d as String)],
      [for (final n in j['n'] as List) Offset((n[0] as num).toDouble(), (n[1] as num).toDouble())],
    );
    return _cache[ch] = parsed;
  }
}
