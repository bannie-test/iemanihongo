import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../logic/streak.dart';
import '../models/user_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _range = 7;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final days = state.days;
    final now = DateTime.now();
    final rangeDays = [for (var i = _range - 1; i >= 0; i--) DateTime(now.year, now.month, now.day - i)];
    final inRange = [for (final d in rangeDays) days[dayKey(d)]];
    int sum(int Function(DailyStat) f) => inRange.fold(0, (a, s) => a + (s == null ? 0 : f(s)));
    final answered = sum((s) => s.answered);
    final accuracy = answered == 0 ? null : (sum((s) => s.answeredCorrect) * 100 / answered).round();
    final minutes = (sum((s) => s.seconds) / 60).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(value: 7, label: Text('7d')),
                ButtonSegment(value: 30, label: Text('30d')),
                ButtonSegment(value: 90, label: Text('90d')),
              ],
              selected: {_range},
              onSelectionChanged: (s) => setState(() => _range = s.first),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(
            children: [
              _Stat(label: 'Words learned', value: '${state.totalLearned}', delta: '+${sum((s) => s.newWords)} new'),
              const SizedBox(width: 8),
              _Stat(label: 'Accuracy', value: accuracy == null ? '–' : '$accuracy%', delta: '$answered answers'),
              const SizedBox(width: 8),
              _Stat(label: 'Streak', value: '${state.streak.current} d', delta: 'best ${state.streak.best}'),
            ],
          ),
          const SizedBox(height: 10),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Items studied', style: context.text.titleMedium),
                    const Spacer(),
                    Text('$minutes min studied', style: context.text.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                _BarChart(range: _range, days: days, goal: state.settings.dailyGoal),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JLPT vocabulary coverage', style: context.text.titleMedium),
                const SizedBox(height: 6),
                for (final l in [5, 4, 3, 2, 1]) _LevelRow(level: l),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Study calendar', style: context.text.titleMedium),
                    const Spacer(),
                    Text('${state.grammarDone.length} grammar lessons', style: context.text.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                _Heatmap(days: days, frozen: state.streak.frozenDays),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.delta});
  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) => Expanded(
    child: SoftCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          FittedBox(child: Text(value, style: context.text.headlineSmall)),
          Text(
            delta,
            style: context.text.bodySmall?.copyWith(color: context.colors.good),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total = state.content.byLevel[level]!.length;
    final learned = state.learnedCount(level);
    final pct = total == 0 ? 0.0 : learned / total;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('N$level', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Bar(pct)),
          SizedBox(
            width: 86,
            child: Text('$learned/$total', textAlign: TextAlign.right, style: context.text.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.range, required this.days, required this.goal});
  final int range;
  final Map<String, DailyStat> days;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    // 90 days are grouped by week; shorter ranges show each day.
    final weekly = range > 30;
    final buckets = <(String, int)>[];
    if (weekly) {
      for (var w = 12; w >= 0; w--) {
        var total = 0;
        for (var d = 0; d < 7; d++) {
          total += days[dayKey(DateTime(now.year, now.month, now.day - w * 7 - d))]?.studied ?? 0;
        }
        final start = DateTime(now.year, now.month, now.day - w * 7 - 6);
        buckets.add((w % 3 == 0 ? DateFormat('M/d').format(start) : '', total));
      }
    } else {
      for (var i = range - 1; i >= 0; i--) {
        final d = DateTime(now.year, now.month, now.day - i);
        final label = range == 7 ? DateFormat('E').format(d).substring(0, 1) : (i % 5 == 0 ? '${d.day}' : '');
        buckets.add((label, days[dayKey(d)]?.studied ?? 0));
      }
    }
    final maxV = math.max(buckets.fold(0, (a, b) => math.max(a, b.$2)), weekly ? goal * 7 : goal).toDouble();
    const h = 120.0;
    final goalY = (weekly ? goal * 7 : goal) / maxV * h;

    return SizedBox(
      height: h + 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 22 + goalY,
            child: Row(
              children: [
                Expanded(child: Container(height: 1.5, color: c.accent.withValues(alpha: 0.35))),
                Text(' goal', style: context.text.bodySmall?.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (label, v) in buckets)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: range == 30 ? 1.5 : 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: '$v items',
                          child: Container(
                            height: math.max(3, v / maxV * h),
                            decoration: BoxDecoration(
                              color: v == 0 ? c.surface2 : c.accent,
                              borderRadius: BorderRadius.circular(range == 30 ? 3 : 7),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                          child: Center(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                              style: context.text.bodySmall?.copyWith(fontSize: 10.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.days, required this.frozen});
  final Map<String, DailyStat> days;
  final Set<String> frozen;

  static const weeks = 18;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastMonday = today.subtract(Duration(days: today.weekday - 1));
    final first = lastMonday.subtract(const Duration(days: (weeks - 1) * 7));

    Color colorFor(DateTime d) {
      if (d.isAfter(today)) return Colors.transparent;
      final key = dayKey(d);
      if (frozen.contains(key)) return Colors.lightBlue.withValues(alpha: 0.45);
      final s = days[key];
      if (s == null || s.studied == 0) return c.heat[0];
      final ratio = s.goal == 0 ? 1 : s.studied / s.goal;
      return ratio >= 1.5
          ? c.heat[3]
          : ratio >= 1
          ? c.heat[2]
          : c.heat[1];
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final size = (box.maxWidth - (weeks - 1) * 3) / weeks;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var w = 0; w < weeks; w++) ...[
                  Column(
                    children: [
                      for (var d = 0; d < 7; d++) ...[
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: colorFor(first.add(Duration(days: w * 7 + d))),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (d < 6) const SizedBox(height: 3),
                      ],
                    ],
                  ),
                  if (w < weeks - 1) const SizedBox(width: 3),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Less ', style: context.text.bodySmall),
            for (final col in c.heat) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: col, shape: BoxShape.circle),
              ),
              const SizedBox(width: 3),
            ],
            Text(' More  ', style: context.text.bodySmall),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: Colors.lightBlue.withValues(alpha: 0.45), shape: BoxShape.circle),
            ),
            Text(' freeze', style: context.text.bodySmall),
          ],
        ),
      ],
    );
  }
}
