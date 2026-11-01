import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sync_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'app_icons.dart';
import 'botanical.dart';

enum PanelTone { paper, sage, clay, forest }

/// Rounded Botanical panel: paper cards with a hairline rule, or sage /
/// pale-clay / forest fields for grouped content.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
    this.borderColor,
    this.tone = PanelTone.paper,
    this.radius = AppTheme.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final PanelTone tone;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fill, line) = switch (tone) {
      PanelTone.paper => (Theme.of(context).colorScheme.surface, c.border),
      PanelTone.sage => (c.accentSoft, c.accentSoft),
      PanelTone.clay => (c.warmField, c.warmField),
      PanelTone.forest => (c.forest, c.forest),
    };
    final content = Padding(padding: padding, child: child);
    return Material(
      color: color ?? fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor ?? line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: tone == PanelTone.forest
          ? DefaultTextStyle.merge(
              style: TextStyle(color: c.onForest),
              child: IconTheme.merge(
                data: IconThemeData(color: c.onForest),
                child: content,
              ),
            )
          : (onTap == null ? content : InkWell(onTap: onTap, child: content)),
    );
  }
}

/// Primary action: soft-rounded forest button (cream on forest). Pressing
/// lifts it slightly; the lift is skipped when reduced motion is requested.
/// (Named for its earlier gradient look; the call sites are unchanged.)
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 54,
    this.inverse = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  /// Cream button for use on forest fields.
  final bool inverse;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = widget.onPressed != null;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bg = widget.inverse ? c.onForest : c.accent;
    final fg = widget.inverse ? c.forest : c.onAccent;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.controlRadius));
    return Semantics(
      button: true,
      enabled: enabled,
      child: AnimatedContainer(
        duration: reduced ? Duration.zero : AppTheme.motion,
        curve: Curves.ease,
        transform: Matrix4.translationValues(0, _pressed && !reduced ? -2 : 0, 0),
        height: widget.height,
        child: Material(
          color: enabled
              ? (_pressed ? Color.alphaBlend(fg.withValues(alpha: 0.12), bg) : bg)
              : bg.withValues(alpha: 0.4),
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[Icon(widget.icon, color: fg, size: 19), const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: enabled ? fg : fg.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        fontFamily: AppTheme.font,
                        fontFamilyFallback: AppTheme.fallback,
                      ),
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
    final fg = accent ? Theme.of(context).colorScheme.onSurface : c.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent ? c.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent ? c.accentSoft : c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small uppercase tracked label above a section.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: AppTheme.eyebrow(context, color: color));
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
      label: 'Nghe phát âm',
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
  const Bar(this.value, {super.key, this.height = 6, this.color});

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
  const Ring({super.key, required this.value, required this.child, this.size = 72, this.stroke = 5});

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

/// Japanese text where **…** segments are highlighted in the clay accent.
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
              style: i.isOdd ? base.copyWith(color: context.colors.clay, fontWeight: FontWeight.w700) : base,
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
    if (sync == null) return _badge(context, c.muted, 'Ngoại tuyến');
    return ValueListenableBuilder(
      valueListenable: sync.status,
      builder: (context, s, _) => switch (s) {
        SyncStatus.guest => _badge(context, c.muted, 'Khách'),
        SyncStatus.idle => _badge(context, c.good, 'Đã đồng bộ'),
        SyncStatus.syncing => _badge(context, Colors.amber, 'Đang đồng bộ'),
        SyncStatus.offline => _badge(context, c.muted, 'Ngoại tuyến'),
        SyncStatus.error => _badge(context, Theme.of(context).colorScheme.error, 'Lỗi đồng bộ'),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: l == value ? c.accent : c.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onChanged(l),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Center(
                    child: Text(
                      levelName(l),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
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
          const Sprig(size: 64),
          const SizedBox(height: 8),
          Icon(icon, size: 30, color: context.colors.muted),
          const SizedBox(height: 12),
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

/// Shown while the Supabase project is missing the app's tables.
class DatabaseSetupBanner extends StatelessWidget {
  const DatabaseSetupBanner({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final sync = context.read<AppState>().sync;
    if (sync == null) return const SizedBox.shrink();
    final c = context.colors;
    return ValueListenableBuilder(
      valueListenable: sync.needsDatabaseSetup,
      builder: (context, missing, _) => !missing
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                onTap: onOpen,
                tone: PanelTone.clay,
                child: Row(
                  children: [
                    Icon(AppIcons.warning, color: c.clay),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Đồng bộ đang tạm dừng: dự án Supabase cần thiết lập một lần. Chạm để sửa.',
                        style: context.text.bodyMedium,
                      ),
                    ),
                    Icon(AppIcons.next, color: c.clay),
                  ],
                ),
              ),
            ),
    );
  }
}

/// "Mẹo" box used for tips in tests, listening and grammar.
class TipBox extends StatelessWidget {
  const TipBox(this.text, {super.key, this.label = 'Mẹo'});
  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.warmField, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.bulb, size: 18, color: c.clay),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label  ',
                    style: TextStyle(fontWeight: FontWeight.w600, color: c.clay),
                  ),
                  TextSpan(text: text),
                ],
              ),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
