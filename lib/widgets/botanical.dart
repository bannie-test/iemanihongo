import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Fine botanical sprig in the ornament line colour. Decorative only, so it
/// is hidden from assistive technology.
class Sprig extends StatelessWidget {
  const Sprig({super.key, this.size = 72, this.flip = false, this.leaves = 5, this.color});

  final double size;
  final bool flip;
  final int leaves;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Transform.flip(
      flipX: flip,
      child: CustomPaint(
        size: Size(size * 0.62, size),
        painter: _SprigPainter(color ?? context.colors.ornament, leaves),
      ),
    ),
  );
}

class _SprigPainter extends CustomPainter {
  _SprigPainter(this.color, this.leaves);
  final Color color;
  final int leaves;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, h / 90)
      ..strokeCap = StrokeCap.round;
    final stem = Path()
      ..moveTo(w * 0.28, h)
      ..cubicTo(w * 0.36, h * 0.66, w * 0.30, h * 0.36, w * 0.62, h * 0.04);
    canvas.drawPath(stem, line);
    final metric = stem.computeMetrics().first;
    for (var i = 0; i < leaves; i++) {
      final t = 0.18 + 0.72 * i / math.max(1, leaves - 1);
      final tan = metric.getTangentForOffset(metric.length * t)!;
      final side = i.isEven ? 1.0 : -1.0;
      final dir = tan.vector;
      final normal = Offset(-dir.dy, dir.dx) * side;
      final len = h * (0.20 - 0.07 * t);
      final base = tan.position;
      final tip = base + (normal * 0.85 + dir * 0.55) * len;
      final mid = (base + tip) / 2;
      final bulge = Offset(-(tip - base).dy, (tip - base).dx) * 0.28;
      final leaf = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(mid.dx + bulge.dx, mid.dy + bulge.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(mid.dx - bulge.dx, mid.dy - bulge.dy, base.dx, base.dy);
      canvas.drawPath(leaf, line);
      // Midrib.
      canvas.drawLine(base, Offset.lerp(base, tip, 0.8)!, line..strokeWidth = math.max(0.6, h / 160));
      line.strokeWidth = math.max(1, h / 90);
    }
    canvas.drawCircle(Offset(w * 0.62, h * 0.04), h / 70, line..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_SprigPainter old) => old.color != color || old.leaves != leaves;
}

/// Tall arch crop (semicircular top) for the hero image area.
class ArchClipper extends CustomClipper<Path> {
  const ArchClipper();

  @override
  Path getClip(Size size) {
    final r = size.width / 2;
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(0, r)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Arch-shaped panel with an optional fine outline arch offset behind it.
class ArchPanel extends StatelessWidget {
  const ArchPanel({
    super.key,
    required this.child,
    this.color,
    this.width = 150,
    this.height = 210,
    this.outline = true,
  });

  final Widget child;
  final Color? color;
  final double width;
  final double height;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: width + 12,
      height: height + 10,
      child: Stack(
        children: [
          if (outline)
            Positioned(
              left: 12,
              top: 0,
              width: width,
              height: height,
              child: ExcludeSemantics(child: CustomPaint(painter: _ArchLinePainter(c.ornament))),
            ),
          Positioned(
            left: 0,
            top: 10,
            width: width,
            height: height,
            child: ClipPath(
              clipper: const ArchClipper(),
              child: ColoredBox(color: color ?? c.accentSoft, child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchLinePainter extends CustomPainter {
  _ArchLinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      const ArchClipper().getClip(size),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_ArchLinePainter old) => old.color != color;
}

/// Forest-green field with a broad curved top, cream text inside.
class CurvedForestField extends StatelessWidget {
  const CurvedForestField({super.key, required this.child, this.curve = 46, this.padding});

  final Widget child;
  final double curve;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipPath(
      clipper: _CurvedTopClipper(curve),
      child: ColoredBox(
        color: c.forest,
        child: Padding(
          padding: padding ?? EdgeInsets.fromLTRB(22, curve + 14, 22, 26),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: c.onForest),
            child: IconTheme.merge(
              data: IconThemeData(color: c.onForest),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _CurvedTopClipper extends CustomClipper<Path> {
  const _CurvedTopClipper(this.curve);
  final double curve;

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, curve)
    ..quadraticBezierTo(size.width / 2, -curve * 0.9, size.width, curve)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_CurvedTopClipper old) => old.curve != curve;
}

/// Faint paper grain over the whole app. It never takes input and is
/// excluded from semantics.
class PaperGrain extends StatelessWidget {
  const PaperGrain({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/grain.png'),
                    repeat: ImageRepeat.repeat,
                    scale: 2,
                    opacity: dark ? 0.05 : 0.07,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Circle with a fine outline ring (the "object portrait" crop).
class OrnamentCircle extends StatelessWidget {
  const OrnamentCircle({super.key, required this.child, this.size = 76, this.color});
  final Widget child;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c.ornament),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color ?? c.warmField),
        child: Center(child: child),
      ),
    );
  }
}

TextStyle displayItalic(BuildContext context, double size) => TextStyle(
  fontFamily: AppTheme.display,
  fontFamilyFallback: AppTheme.displayFallback,
  fontStyle: FontStyle.italic,
  fontSize: size,
  height: 1.05,
  letterSpacing: -0.5,
  color: context.colors.clay,
);
