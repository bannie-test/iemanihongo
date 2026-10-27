import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../data/stroke_repository.dart';
import '../../logic/handwriting.dart';
import '../../theme.dart';

/// Square practice sheet: 米-shaped guide lines, the character's strokes as
/// faint dashed outlines, and the learner's ink on top.
class WritingCanvas extends StatefulWidget {
  const WritingCanvas({
    super.key,
    required this.strokes,
    required this.ink,
    required this.showGuide,
    required this.showNumbers,
    required this.onInkChanged,
    this.result,
    this.animation,
    this.enabled = true,
  });

  final CharStrokes strokes;

  /// The learner's strokes in 109×109 space.
  final List<List<Offset>> ink;
  final bool showGuide;
  final bool showNumbers;
  final ValueChanged<List<List<Offset>>> onInkChanged;

  /// When set, strokes are coloured by whether they matched.
  final HandwritingResult? result;

  /// 0 … strokeCount while the stroke-order demo plays.
  final Animation<double>? animation;
  final bool enabled;

  @override
  State<WritingCanvas> createState() => _WritingCanvasState();
}

class _WritingCanvasState extends State<WritingCanvas> {
  List<Offset>? _current;
  int? _pointer;

  Offset _toBox(Offset local, double size) => local * (CharStrokes.box / size);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, box) {
        final size = math.min(box.maxWidth, box.maxHeight);
        return SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: c.border, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              // Raw pointer events: drawing never competes with scrolling or
              // other gestures for the touch. Only the first finger draws.
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  if (!widget.enabled || _pointer != null) return;
                  _pointer = e.pointer;
                  setState(() => _current = [_toBox(e.localPosition, size)]);
                },
                onPointerMove: (e) {
                  if (e.pointer != _pointer || _current == null) return;
                  setState(() => _current!.add(_toBox(e.localPosition, size)));
                },
                onPointerUp: (e) {
                  if (e.pointer != _pointer) return;
                  _pointer = null;
                  final s = _current;
                  setState(() => _current = null);
                  if (s != null && s.length > 1) widget.onInkChanged([...widget.ink, s]);
                },
                onPointerCancel: (e) {
                  if (e.pointer != _pointer) return;
                  _pointer = null;
                  setState(() => _current = null);
                },
                child: AnimatedBuilder(
                  animation: widget.animation ?? const AlwaysStoppedAnimation(0),
                  builder: (context, _) => CustomPaint(
                    size: Size.square(size),
                    painter: _SheetPainter(
                      strokes: widget.strokes,
                      ink: [...widget.ink, ?_current],
                      showGuide: widget.showGuide,
                      showNumbers: widget.showNumbers,
                      result: widget.result,
                      demo: widget.animation?.value,
                      guideColor: dark ? Colors.white : Colors.black,
                      gridColor: c.accent.withValues(alpha: 0.18),
                      inkColor: Theme.of(context).colorScheme.onSurface,
                      accent: c.accent,
                      good: c.good,
                      bad: c.bad,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetPainter extends CustomPainter {
  _SheetPainter({
    required this.strokes,
    required this.ink,
    required this.showGuide,
    required this.showNumbers,
    required this.result,
    required this.demo,
    required this.guideColor,
    required this.gridColor,
    required this.inkColor,
    required this.accent,
    required this.good,
    required this.bad,
  });

  final CharStrokes strokes;
  final List<List<Offset>> ink;
  final bool showGuide;
  final bool showNumbers;
  final HandwritingResult? result;
  final double? demo;
  final Color guideColor;
  final Color gridColor;
  final Color inkColor;
  final Color accent;
  final Color good;
  final Color bad;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / CharStrokes.box;

    // 米 grid: centre cross and diagonals, dashed.
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final dashes = CircularIntervalList<double>([7, 6]);
    final w = size.width;
    for (final line in [
      Path()
        ..moveTo(w / 2, 0)
        ..lineTo(w / 2, w),
      Path()
        ..moveTo(0, w / 2)
        ..lineTo(w, w / 2),
      Path()
        ..moveTo(0, 0)
        ..lineTo(w, w),
      Path()
        ..moveTo(w, 0)
        ..lineTo(0, w),
    ]) {
      canvas.drawPath(dashPath(line, dashArray: dashes), grid);
    }

    canvas.save();
    canvas.scale(k);

    // Faint dashed outline of every stroke.
    if (showGuide || demo != null || result != null) {
      // A very faint body shows the character's shape; a dashed centre
      // line along each stroke shows where to trace.
      final body = Paint()
        ..color = guideColor.withValues(alpha: 0.07)
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final dashed = Paint()
        ..color = guideColor.withValues(alpha: 0.42)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final guideDash = CircularIntervalList<double>([4, 3]);
      for (final p in strokes.paths) {
        canvas.drawPath(p, body);
        canvas.drawPath(dashPath(p, dashArray: guideDash), dashed);
      }
    }

    // Stroke-order demo: strokes drawn in progressively.
    final d = demo;
    if (d != null && d > 0) {
      final demoPaint = Paint()
        ..color = accent
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < strokes.paths.length && i < d; i++) {
        final t = (d - i).clamp(0.0, 1.0);
        for (final m in strokes.paths[i].computeMetrics()) {
          canvas.drawPath(m.extractPath(0, m.length * t), demoPaint);
        }
      }
    }

    // Stroke numbers next to each stroke's start.
    if (showNumbers || d != null) {
      for (var i = 0; i < strokes.labels.length; i++) {
        if (d != null && i >= d.ceil()) break;
        final tp = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: accent.withValues(alpha: 0.9)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, strokes.labels[i] - Offset(tp.width / 2, tp.height * 0.8));
      }
    }

    // Learner's ink, coloured after checking.
    for (var i = 0; i < ink.length; i++) {
      final s = ink[i];
      if (s.length < 2) continue;
      var color = inkColor;
      final r = result;
      if (r != null) {
        color = i < r.strokes.length && r.strokes[i].matched && !r.strokes[i].reversed ? good : bad;
      }
      final paint = Paint()
        ..color = color
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPoints(ui.PointMode.polygon, s, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SheetPainter old) => true;
}
