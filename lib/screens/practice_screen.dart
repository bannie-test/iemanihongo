import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import 'grammar_screen.dart';
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
      appBar: AppBar(title: const Text('Practice')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _PracticeCard(
            icon: AppIcons.quiz,
            title: 'Vocabulary quiz',
            subtitle: 'Meaning, reverse, reading and listening',
            badge: '${state.cards.length} words studied',
            onTap: () => _push(context, const QuizHubScreen()),
          ),
          const SizedBox(height: 12),
          _PracticeCard(
            icon: AppIcons.writing,
            title: 'Writing practice',
            subtitle: 'Trace kana and kanji stroke by stroke',
            badge: practised == 0 ? 'New' : '$practised characters practised',
            onTap: () => _push(context, const WritingHubScreen()),
          ),
          const SizedBox(height: 12),
          _PracticeCard(
            icon: AppIcons.grammar,
            title: 'Grammar lessons',
            subtitle: today == null ? 'All lessons completed' : "Today: ${today.title} · ${today.meaning}",
            badge: '${state.grammarDone.length}/${state.content.grammar.length} done',
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
            decoration: BoxDecoration(gradient: c.gradient, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: Colors.white, size: 30),
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
