import 'package:flutter/material.dart';

import '../models/jlpt.dart';
import '../theme.dart';
import 'app_icons.dart';

/// Renders a JLPT sentence: [word] is underlined, （　） is a blank and ★
/// marks the asked slot in sentence-building questions.
class JlptSentence extends StatelessWidget {
  const JlptSentence(this.question, {super.key, this.fontSize = 19});

  final JlptQuestion question;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = TextStyle(fontSize: fontSize, height: 1.75, color: Theme.of(context).colorScheme.onSurface);
    final spans = <InlineSpan>[];
    final re = RegExp(r'\[([^\]]+)\]|（　）|★|＿＿');
    var last = 0;
    for (final m in re.allMatches(question.sentence)) {
      if (m.start > last) spans.add(TextSpan(text: question.sentence.substring(last, m.start)));
      final t = m.group(0)!;
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: c.accent,
              decorationThickness: 2.5,
            ),
          ),
        );
      } else if (t == '（　）') {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              width: fontSize * 3.2,
              height: fontSize * 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.accent.withValues(alpha: 0.5), width: 1.5),
              ),
            ),
          ),
        );
      } else if (t == '★') {
        spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: _slot(context, star: true)));
      } else {
        spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: _slot(context)));
      }
      last = m.end;
    }
    if (last < question.sentence.length) spans.add(TextSpan(text: question.sentence.substring(last)));
    return Text.rich(TextSpan(style: base, children: spans));
  }

  Widget _slot(BuildContext context, {bool star = false}) {
    final c = context.colors;
    return Container(
      width: fontSize * 2.6,
      height: fontSize * 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: star ? c.accent : c.muted, width: 2)),
      ),
      child: star
          ? Text(
              '★',
              style: TextStyle(color: c.accent, fontSize: fontSize * 0.8),
            )
          : null,
    );
  }
}

enum OptionState { idle, selected, correct, wrong, dimmed }

class JlptOption extends StatelessWidget {
  const JlptOption({super.key, required this.index, required this.text, required this.state, this.onTap, this.note});

  final int index;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  /// Small label under the option, e.g. "Bạn chọn".
  final String? note;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final surface = Theme.of(context).colorScheme.surface;
    final (border, fill, fg) = switch (state) {
      OptionState.idle => (c.border, surface, Theme.of(context).colorScheme.onSurface),
      OptionState.selected => (c.accent, c.accentSoft, c.accent),
      OptionState.correct => (c.good, Color.alphaBlend(c.good.withValues(alpha: 0.12), surface), c.good),
      OptionState.wrong => (c.bad, Color.alphaBlend(c.bad.withValues(alpha: 0.10), surface), c.bad),
      OptionState.dimmed => (c.border, surface, c.muted),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: state == OptionState.idle || state == OptionState.dimmed ? c.surface2 : border,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: state == OptionState.idle || state == OptionState.dimmed ? c.muted : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: fg),
                      ),
                      if (note != null) Text(note!, style: TextStyle(fontSize: 11.5, color: fg.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
                if (state == OptionState.correct) Icon(AppIcons.check, color: c.good, size: 20),
                if (state == OptionState.wrong) Icon(AppIcons.cross, color: c.bad, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Vietnamese translation + explanation; ✓/✗ lines are coloured.
class ExplanationBox extends StatelessWidget {
  const ExplanationBox(this.question, {super.key});

  final JlptQuestion question;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lines = question.explanation.split('\n');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.translate, size: 16, color: c.accent),
              const SizedBox(width: 6),
              Text(
                'Dịch nghĩa',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.accent, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(question.translation, style: const TextStyle(fontSize: 14.5, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(AppIcons.bulb, size: 16, color: c.accent),
              const SizedBox(width: 6),
              Text(
                'Giải thích',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.accent, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final line in lines) _line(context, c, line),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, AppColors c, String line) {
    final good = line.startsWith('✓');
    final bad = line.startsWith('✗');
    final text = good || bad ? line.substring(1).trim() : line;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (good || bad)
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 6),
              child: Icon(good ? AppIcons.check : AppIcons.cross, size: 14, color: good ? c.good : c.bad),
            ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: good ? FontWeight.w700 : FontWeight.w500,
                color: good ? c.good : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatClock(int seconds) {
  final m = seconds ~/ 60, s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
