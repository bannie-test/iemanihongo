import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import 'grammar_screen.dart';
import 'listening/listening_screens.dart';
import 'quiz_screen.dart';
import 'writing/writing_screens.dart';

/// Practice tab: vocabulary quizzes, handwriting and grammar lessons.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final today = state.todaysGrammar;
    final practised = state.writing.values.where((w) => w.attempts > 0).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _PracticeCard(
            icon: AppIcons.quiz,
            title: 'Trắc nghiệm từ vựng',
            subtitle: 'Nghĩa, ngược, cách đọc và nghe',
            badge: 'Đã học ${state.cards.length} từ',
            onTap: () => _push(context, const QuizHubScreen()),
          ),
          const SizedBox(height: 12),
          _PracticeCard(
            icon: AppIcons.voice,
            title: 'Nghe hiểu · 聴解',
            subtitle: 'Hội thoại kiểu JLPT và nghe câu',
            badge: '${state.content.listening.length} bài nghe · N5–N1',
            onTap: () => _push(context, const ListeningHubScreen()),
          ),
          const SizedBox(height: 12),
          _PracticeCard(
            icon: AppIcons.writing,
            title: 'Luyện viết',
            subtitle: 'Tô kana và kanji theo từng nét',
            badge: practised == 0 ? 'Mới' : 'Đã luyện $practised chữ',
            onTap: () => _push(context, const WritingHubScreen()),
          ),
          const SizedBox(height: 12),
          _PracticeCard(
            icon: AppIcons.grammar,
            title: 'Bài ngữ pháp',
            subtitle: today == null ? 'Đã hoàn thành mọi bài' : "Today: ${today.title} · ${today.meaning}",
            badge: 'Đã xong ${state.grammarDone.length}/${state.content.grammar.length}',
            onTap: () => _push(context, const GrammarScreen()),
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: context.text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Tag(badge, accent: true),
              ],
            ),
          ),
          Icon(AppIcons.next, color: c.muted),
        ],
      ),
    );
  }
}
