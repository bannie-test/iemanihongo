import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sync_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'app_icons.dart';

/// Rounded card with the Sakura border.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppTheme.radius);
    return Material(
      color: color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor ?? c.border, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Pill-shaped primary button with the pink → peach gradient.
class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 54});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        height: height,
        decoration: ShapeDecoration(shape: const StadiumBorder(), gradient: c.gradient),
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: AppTheme.font,
                      fontFamilyFallback: AppTheme.fallback,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.accent = false, this.icon});

  final String label;
  final bool accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = accent ? c.accent : c.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: accent ? c.accentSoft : c.surface2, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Round speaker button that reads Japanese text aloud.
class SpeakButton extends StatelessWidget {
  const SpeakButton(this.text, {super.key, this.size = 40});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: 'Play pronunciation',
      child: Material(
        color: c.accentSoft,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.read<AppState>().tts.speak(text),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(AppIcons.speaker, color: c.accent, size: size * 0.52),
          ),
        ),
      ),
    );
  }
}

class Bar extends StatelessWidget {
  const Bar(this.value, {super.key, this.height = 8, this.color});

  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1).toDouble(),
        minHeight: height,
        backgroundColor: c.surface2,
        valueColor: AlwaysStoppedAnimation(color ?? c.accent),
      ),
    );
  }
}

class Ring extends StatelessWidget {
  const Ring({super.key, required this.value, required this.child, this.size = 72, this.stroke = 8});

  final double value;
  final Widget child;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value.clamp(0, 1).toDouble(), c.surface2, c.accent, stroke),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.track, this.fill, this.stroke);
  final double value;
  final Color track;
  final Color fill;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (value > 0) canvas.drawArc(r, -math.pi / 2, math.pi * 2 * value, false, p..color = fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.fill != fill || old.track != track;
}

/// Japanese text where **…** segments are highlighted in the accent colour.
class HighlightText extends StatelessWidget {
  const HighlightText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd ? base.copyWith(color: context.colors.accent, fontWeight: FontWeight.w700) : base,
            ),
        ],
      ),
    );
  }
}

/// Small "Synced / Offline / Guest" indicator.
class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.read<AppState>().sync;
    final c = context.colors;
    if (sync == null) return _badge(context, c.muted, 'Offline mode');
    return ValueListenableBuilder(
      valueListenable: sync.status,
      builder: (context, s, _) => switch (s) {
        SyncStatus.guest => _badge(context, c.muted, 'Guest'),
        SyncStatus.idle => _badge(context, c.good, 'Synced'),
        SyncStatus.syncing => _badge(context, Colors.amber, 'Syncing'),
        SyncStatus.offline => _badge(context, c.muted, 'Offline'),
        SyncStatus.error => _badge(context, Theme.of(context).colorScheme.error, 'Sync issue'),
      },
    );
  }

  Widget _badge(BuildContext context, Color dot, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: context.text.bodySmall),
    ],
  );
}

String levelName(int level) => 'N$level';

class LevelPicker extends StatelessWidget {
  const LevelPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        for (final l in [5, 4, 3, 2, 1]) ...[
          Expanded(
            child: Material(
              color: l == value ? c.accent : Theme.of(context).colorScheme.surface,
              shape: StadiumBorder(side: BorderSide(color: l == value ? c.accent : c.border, width: 2)),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onChanged(l),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Center(
                    child: Text(
                      levelName(l),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: l == value ? c.onAccent : c.muted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (l != 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.action});

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: context.colors.accent),
          const SizedBox(height: 14),
          Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            body,
            style: context.text.bodyMedium?.copyWith(color: context.colors.muted),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}
