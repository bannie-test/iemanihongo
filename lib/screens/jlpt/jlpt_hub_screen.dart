import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/content_repository.dart';
import '../../logic/weakness.dart';
import '../../models/jlpt.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/jlpt_widgets.dart';
import '../auth_screen.dart';
import 'test_result_screen.dart';
import 'test_runner_screen.dart';

/// "Luyện thi JLPT": timed mock tests, practice by question type, weak-area
/// tracking and history for N3–N1. Results are stored in the user's
/// Supabase account.
class JlptHubScreen extends StatefulWidget {
  const JlptHubScreen({super.key});

  @override
  State<JlptHubScreen> createState() => _JlptHubScreenState();
}

class _JlptHubScreenState extends State<JlptHubScreen> {
  int? _level;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final level = _level ?? (state.settings.level <= 3 ? state.settings.level : 3);
    final report = state.weakness(level);
    final signedIn = state.canSaveTests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Luyện thi JLPT'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: [for (final l in ContentRepository.testLevels) ButtonSegment(value: l, label: Text('N$l'))],
              selected: {level},
              onSelectionChanged: (s) => setState(() => _level = s.first),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (!signedIn) ...[const _SignInCard(), const SizedBox(height: 14)],
          _section(context, 'Đề thi thử', 'Mô phỏng phần 文字・語彙・文法, có tính giờ'),
          for (final t in state.content.testsFor(level)) ...[
            _TestCard(test: t, enabled: signedIn),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          _section(context, 'Điểm yếu cần cải thiện', 'Tính từ các câu bạn đã làm ở N$level'),
          _WeaknessCard(level: level, report: report, enabled: signedIn),
          const SizedBox(height: 20),
          _section(context, 'Luyện theo dạng bài', 'Không tính giờ, xem đáp án ngay sau mỗi câu'),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final sec in JlptSection.values)
                  _SectionTile(level: level, section: sec, stat: report.sections[sec]!, enabled: signedIn),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _History(level: level),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String sub) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleLarge),
        Text(sub, style: context.text.bodySmall),
      ],
    ),
  );
}

void _requireSignIn(BuildContext context) => showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Cần đăng nhập'),
    content: const Text(
      'Kết quả luyện thi, tiến độ và điểm yếu được lưu vào tài khoản Supabase của bạn. '
      'Hãy đăng nhập hoặc tạo tài khoản để bắt đầu.',
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Để sau')),
      FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen(linking: true)));
        },
        child: const Text('Đăng nhập'),
      ),
    ],
  ),
);

void _open(BuildContext context, TestAttempt a) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TestRunnerScreen(attemptId: a.id)));

class _SignInCard extends StatelessWidget {
  const _SignInCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      color: c.accentSoft,
      borderColor: c.accentSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.cloudUpload, color: c.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Đăng nhập để luyện thi', style: context.text.titleMedium?.copyWith(color: c.accent)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Bài làm, thời gian còn lại và thống kê điểm yếu được lưu trên tài khoản, '
            'nên bạn có thể làm tiếp trên thiết bị khác.',
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Đăng nhập / Tạo tài khoản',
            height: 46,
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen(linking: true))),
          ),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({required this.test, required this.enabled});

  final JlptTest test;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    final running = state.inProgress(test.id);
    final best = state.bestScore(test.id);
    final tries = state.attemptsFor(test.id).where((a) => a.finished).length;

    void start() {
      if (!enabled) return _requireSignIn(context);
      _open(context, state.startExam(test));
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(gradient: c.gradient, borderRadius: BorderRadius.circular(16)),
                child: const Icon(AppIcons.examOn, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('N${test.level} · ${test.title}', style: context.text.titleMedium),
                    Text('${test.questions.length} câu · ${test.minutes} phút', style: context.text.bodySmall),
                  ],
                ),
              ),
              if (best != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$best%', style: context.text.titleLarge?.copyWith(color: best >= 60 ? c.good : c.bad)),
                    Text('cao nhất · $tries lần', style: context.text.bodySmall),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (running != null) ...[
            Row(
              children: [
                Icon(AppIcons.timer, size: 16, color: c.accent),
                const SizedBox(width: 6),
                Text(
                  'Đang làm ${running.answers.length}/${running.total} · còn ${formatClock(running.remainingSec)}',
                  style: TextStyle(color: c.accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: start, child: const Text('Làm lại từ đầu')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(label: 'Làm tiếp', height: 48, onPressed: () => _open(context, running)),
                ),
              ],
            ),
          ] else
            GradientButton(
              label: best == null ? 'Bắt đầu làm bài' : 'Làm lại',
              height: 48,
              icon: AppIcons.play,
              onPressed: start,
            ),
        ],
      ),
    );
  }
}

class _WeaknessCard extends StatelessWidget {
  const _WeaknessCard({required this.level, required this.report, required this.enabled});

  final int level;
  final WeaknessReport report;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = context.read<AppState>();
    if (report.answered == 0) {
      return SoftCard(
        child: Row(
          children: [
            Icon(AppIcons.chart, color: c.accent, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Làm một đề thi thử hoặc luyện theo dạng bài để xem bạn yếu phần nào.')),
          ],
        ),
      );
    }
    final weakest = report.weakestSection;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Ring(
                value: report.accuracy,
                size: 64,
                stroke: 7,
                child: Text(
                  '${(report.accuracy * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Độ chính xác N$level', style: context.text.titleMedium),
                    Text('${report.answered} lượt trả lời', style: context.text.bodySmall),
                    if (weakest != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Yếu nhất: ${weakest.vi}',
                        style: TextStyle(color: c.bad, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (report.weakTags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Chủ điểm hay sai', style: context.text.bodySmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in report.weakTags.take(6))
                  Tag('${t.label} · ${(t.accuracy * 100).round()}%', icon: AppIcons.target),
              ],
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: report.mistakes.isEmpty
                ? null
                : () {
                    if (!enabled) return _requireSignIn(context);
                    final ids = report.mistakes.take(20).toList();
                    _open(
                      context,
                      state.startPractice(
                        level: level,
                        key: 'n$level-weak',
                        title: 'N$level · Ôn câu sai',
                        questionIds: ids,
                      ),
                    );
                  },
            icon: const Icon(AppIcons.retry),
            label: Text(
              report.mistakes.isEmpty
                  ? 'Không có câu sai cần ôn'
                  : 'Ôn lại ${report.mistakes.length.clamp(0, 20)} câu sai',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.level, required this.section, required this.stat, required this.enabled});

  final int level;
  final JlptSection section;
  final AreaStat stat;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = context.read<AppState>();
    final key = 'n$level-sec-${section.name}';
    final count = state.content.questionsFor(level, section: section).length;
    final running = context.watch<AppState>().inProgress(key);
    return ListTile(
      onTap: () {
        if (!enabled) return _requireSignIn(context);
        if (running != null) return _open(context, running);
        final ids = state.content.questionsFor(level, section: section).map((q) => q.id).toList()..shuffle();
        _open(context, state.startPractice(level: level, key: key, title: 'N$level · ${section.vi}', questionIds: ids));
      },
      title: Text(section.vi, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${section.jp} · $count câu', style: context.text.bodySmall),
          if (stat.answered > 0) ...[
            const SizedBox(height: 4),
            Bar(stat.accuracy, height: 6, color: stat.accuracy >= Weakness.threshold ? c.good : c.bad),
          ],
        ],
      ),
      trailing: running != null
          ? Tag('Làm tiếp ${running.answers.length}/${running.total}', accent: true)
          : stat.answered > 0
          ? Text(
              '${(stat.accuracy * 100).round()}%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: stat.accuracy >= Weakness.threshold ? c.good : c.bad,
              ),
            )
          : const Icon(AppIcons.next),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.finishedAttempts(level).take(8).toList();
    if (done.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Lịch sử làm bài', style: context.text.titleLarge),
        ),
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              for (final a in done)
                ListTile(
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => TestResultScreen(attemptId: a.id))),
                  leading: Icon(a.mode == AttemptMode.exam ? AppIcons.exam : AppIcons.practice, color: c.accent),
                  title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${DateFormat('dd/MM HH:mm').format(DateTime.fromMillisecondsSinceEpoch(a.finishedAt))} · ${formatClock(a.elapsedSec)}',
                  ),
                  trailing: Text(
                    '${a.score}/${a.total}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: a.percent >= 0.6 ? c.good : c.bad,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
