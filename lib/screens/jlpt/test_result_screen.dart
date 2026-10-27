import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/jlpt.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/jlpt_widgets.dart';
import 'test_runner_screen.dart';

/// Score, per-section breakdown and the areas to work on for one attempt.
class TestResultScreen extends StatelessWidget {
  const TestResultScreen({super.key, required this.attemptId});

  final String attemptId;

  static const passMark = 0.6;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    final a = state.attempts[attemptId]!;
    final qs = [for (final id in a.questionIds) state.content.questionById[id]!];
    final wrong = [
      for (final q in qs)
        if (a.answers[q.id] != q.answer) q,
    ];
    final pct = a.percent;
    final pass = pct >= passMark;

    final perSection = <JlptSection, (int, int)>{};
    for (final q in qs) {
      final (ok, n) = perSection[q.section] ?? (0, 0);
      perSection[q.section] = (ok + (a.answers[q.id] == q.answer ? 1 : 0), n + 1);
    }
    final weakTags = <String, int>{};
    for (final q in wrong) {
      weakTags[q.tag] = (weakTags[q.tag] ?? 0) + 1;
    }
    final sortedTags = weakTags.entries.toList()..sort((x, y) => y.value.compareTo(x.value));

    return Scaffold(
      appBar: AppBar(title: Text(a.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          SoftCard(
            child: Row(
              children: [
                Ring(
                  value: pct,
                  size: 96,
                  stroke: 10,
                  child: Text('${(pct * 100).round()}%', style: context.text.titleLarge),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${a.score}/${a.total} câu đúng', style: context.text.titleLarge),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(AppIcons.clock, size: 15, color: c.muted),
                          const SizedBox(width: 4),
                          Text(
                            a.timed
                                ? 'Thời gian: ${formatClock(a.elapsedSec)} / ${formatClock(a.timeLimitSec)}'
                                : 'Thời gian: ${formatClock(a.elapsedSec)}',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Tag(
                        pass ? 'Đạt (≥ 60%)' : 'Chưa đạt (cần ≥ 60%)',
                        accent: pass,
                        icon: pass ? AppIcons.trophy : AppIcons.target,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kết quả theo dạng bài', style: context.text.titleMedium),
                for (final e in perSection.entries) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(e.key.vi, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Text('${e.value.$1}/${e.value.$2}', style: context.text.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Bar(e.value.$1 / e.value.$2, color: e.value.$1 / e.value.$2 >= passMark ? c.good : c.bad),
                ],
              ],
            ),
          ),
          if (sortedTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.target, color: c.accent, size: 20),
                      const SizedBox(width: 6),
                      Text('Điểm cần cải thiện', style: context.text.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final t in sortedTags.take(8)) Tag('${t.key} · sai ${t.value}')],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          GradientButton(
            label: 'Xem lại đáp án & giải thích',
            icon: AppIcons.eye,
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => TestReviewScreen(attemptId: a.id))),
          ),
          const SizedBox(height: 10),
          if (wrong.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () {
                final p = state.startPractice(
                  level: a.level,
                  key: 'n${a.level}-retry',
                  title: 'N${a.level} · Luyện lại câu sai',
                  questionIds: [for (final q in wrong) q.id],
                );
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) => TestRunnerScreen(attemptId: p.id)));
              },
              icon: const Icon(AppIcons.retry),
              label: Text('Luyện lại ${wrong.length} câu sai'),
            ),
        ],
      ),
    );
  }
}

enum _Filter { all, wrong, correct, flagged }

/// Answer review. The switch shows or hides every answer at once; each
/// question can also be revealed on its own, so it doubles as self-testing.
class TestReviewScreen extends StatefulWidget {
  const TestReviewScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  State<TestReviewScreen> createState() => _TestReviewScreenState();
}

class _TestReviewScreenState extends State<TestReviewScreen> {
  late bool _showAll = context.read<AppState>().prefs.getBool('jlpt_review_show') ?? true;
  final Set<String> _toggled = {};
  _Filter _filter = _Filter.all;

  bool _visible(String id) => _showAll != _toggled.contains(id);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final a = state.attempts[widget.attemptId]!;
    final all = [for (final id in a.questionIds) state.content.questionById[id]!];
    final items = [
      for (var i = 0; i < all.length; i++)
        if (switch (_filter) {
          _Filter.all => true,
          _Filter.wrong => a.answers[all[i].id] != all[i].answer,
          _Filter.correct => a.answers[all[i].id] == all[i].answer,
          _Filter.flagged => a.flagged.contains(all[i].id),
        })
          (i, all[i]),
    ];
    final wrongCount = all.where((q) => a.answers[q.id] != q.answer).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Xem lại đáp án')),
      body: Column(
        children: [
          SwitchListTile(
            value: _showAll,
            title: const Text('Hiện đáp án & giải thích', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Tắt để tự kiểm tra lại, chạm từng câu để xem'),
            secondary: Icon(_showAll ? AppIcons.eye : AppIcons.eyeOff),
            onChanged: (v) {
              setState(() {
                _showAll = v;
                _toggled.clear();
              });
              state.prefs.setBool('jlpt_review_show', v);
            },
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final f in _Filter.values) ...[
                  ChoiceChip(
                    label: Text(switch (f) {
                      _Filter.all => 'Tất cả ${all.length}',
                      _Filter.wrong => 'Sai $wrongCount',
                      _Filter.correct => 'Đúng ${all.length - wrongCount}',
                      _Filter.flagged => 'Đã đánh dấu ${a.flagged.length}',
                    }),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(icon: AppIcons.checkCircle, title: 'Không có câu nào', body: 'Thử bộ lọc khác.')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ReviewCard(
                      number: items[i].$1 + 1,
                      question: items[i].$2,
                      chosen: a.answers[items[i].$2.id],
                      flagged: a.flagged.contains(items[i].$2.id),
                      revealed: _visible(items[i].$2.id),
                      onToggle: () => setState(() {
                        final id = items[i].$2.id;
                        _toggled.contains(id) ? _toggled.remove(id) : _toggled.add(id);
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.number,
    required this.question,
    required this.chosen,
    required this.flagged,
    required this.revealed,
    required this.onToggle,
  });

  final int number;
  final JlptQuestion question;
  final int? chosen;
  final bool flagged;
  final bool revealed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final q = question;
    final correct = chosen == q.answer;

    OptionState stateFor(int i) {
      if (!revealed) return i == chosen ? OptionState.selected : OptionState.idle;
      if (i == q.answer) return OptionState.correct;
      if (i == chosen) return OptionState.wrong;
      return OptionState.dimmed;
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Tag('Câu $number', accent: true),
              const SizedBox(width: 8),
              if (revealed)
                Tag(
                  chosen == null ? 'Chưa làm' : (correct ? 'Đúng' : 'Sai'),
                  icon: chosen == null ? null : (correct ? AppIcons.check : AppIcons.cross),
                ),
              if (flagged) ...[const SizedBox(width: 6), const Icon(AppIcons.flagOn, color: Colors.orange, size: 16)],
              const Spacer(),
              Flexible(
                child: Text(q.section.vi, style: context.text.bodySmall, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          JlptSentence(q, fontSize: 17),
          const SizedBox(height: 10),
          for (var i = 0; i < q.options.length; i++)
            JlptOption(index: i, text: q.options[i], state: stateFor(i), note: i == chosen ? 'Bạn chọn' : null),
          if (revealed) ExplanationBox(q),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onToggle,
              icon: Icon(revealed ? AppIcons.eyeOff : AppIcons.eye, size: 18),
              label: Text(revealed ? 'Ẩn đáp án' : 'Hiện đáp án'),
            ),
          ),
        ],
      ),
    );
  }
}
