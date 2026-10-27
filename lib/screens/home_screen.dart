import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../logic/streak.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'flashcard_screen.dart';
import 'grammar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _weekdaysJa = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'おはよう';
    if (h < 18) return 'こんにちは';
    return 'こんばんは';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    final now = DateTime.now();
    final due = state.dueWords.length;
    final newLeft = state.nextNewWords(state.newLeftToday).length;
    final grammar = state.todaysGrammar;
    final level = state.settings.level;
    final levelTotal = state.content.byLevel[level]!.length;
    final learned = state.learnedCount(level);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_weekdaysJa[now.weekday - 1]} · ${DateFormat('EEEE').format(now)}', style: context.text.bodySmall),
                Text(_greeting(), style: context.text.headlineSmall),
              ]),
            ),
            const SyncBadge(),
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ]),
          const SizedBox(height: 12),
          _StreakCard(state: state),
          const SizedBox(height: 12),
          LevelPicker(value: level, onChanged: (l) => state.updateSettings((s) => s.copyWith(level: l))),
          const SizedBox(height: 12),
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Vocabulary review', style: context.text.titleMedium),
                    const SizedBox(height: 2),
                    Text('$due due · $newLeft new words', style: context.text.bodySmall),
                  ]),
                ),
                Tag('~${((due + newLeft) * 0.2).ceil().clamp(1, 60)} min', accent: true),
              ]),
              const SizedBox(height: 12),
              Bar(levelTotal == 0 ? 0 : learned / levelTotal),
              const SizedBox(height: 6),
              Text('N$level · $learned / $levelTotal words learned', style: context.text.bodySmall),
            ]),
          ),
          const SizedBox(height: 12),
          if (grammar != null)
            SoftCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GrammarLessonScreen(point: grammar))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Tag("Today's grammar · Day ${state.grammarDayNumber}", accent: true),
                  const Spacer(),
                  Text('N${grammar.level} · 5 min', style: context.text.bodySmall),
                ]),
                const SizedBox(height: 10),
                Text(grammar.title, style: context.text.titleLarge?.copyWith(fontSize: 21)),
                Text(grammar.meaning, style: context.text.bodySmall),
              ]),
            )
          else
            SoftCard(
              child: Row(children: [
                Icon(Icons.emoji_events_rounded, color: c.accent),
                const SizedBox(width: 10),
                const Expanded(child: Text('You have finished every grammar lesson. すごい！')),
              ]),
            ),
          const SizedBox(height: 18),
          GradientButton(
            label: due + newLeft == 0 ? 'All caught up · study extra' : "Start today's session",
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              var words = state.buildDailySession();
              if (words.isEmpty) words = state.nextNewWords(5);
              if (words.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('You have seen every word in this level. Pick another level.')));
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FlashcardScreen(words: words, title: "Today's session"),
              ));
            },
          ),
          if (state.tts.japaneseAvailable.value == false) ...[
            const SizedBox(height: 12),
            const _VoiceMissingCard(),
          ],
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final goal = state.settings.dailyGoal;
    final progress = state.goalProgress;
    final s = state.streak;
    final left = (goal - progress).clamp(0, goal);
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final days = state.days;

    return SoftCard(
      child: Column(children: [
        Row(children: [
          Ring(
            value: goal == 0 ? 0 : progress / goal,
            child: Text('${progress.clamp(0, 999)}/$goal', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🔥 ${s.current} ${s.current == 1 ? 'day' : 'days'}',
                  style: context.text.headlineSmall?.copyWith(fontSize: 26)),
              const SizedBox(height: 2),
              Text(
                s.todayDone
                    ? 'Goal done for today. お疲れさま！'
                    : left == goal
                        ? 'Study $goal items today to ${s.current > 0 ? 'keep' : 'start'} your streak'
                        : '$left more to ${s.current > 0 ? 'keep' : 'start'} your streak',
                style: context.text.bodySmall,
              ),
              if (s.freezes > 0) ...[
                const SizedBox(height: 4),
                Tag('${s.freezes} streak freeze${s.freezes > 1 ? 's' : ''}', icon: Icons.ac_unit_rounded),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          for (var i = 0; i < 7; i++)
            Expanded(child: _dayDot(context, DateTime(monday.year, monday.month, monday.day + i), days, s, c)),
        ]),
      ]),
    );
  }

  Widget _dayDot(BuildContext context, DateTime d, Map days, StreakInfo s, AppColors c) {
    final key = dayKey(d);
    final today = dayKey(DateTime.now());
    final stat = days[key];
    final met = stat != null && stat.goal > 0 && stat.studied >= stat.goal;
    final frozen = s.frozenDays.contains(key);
    final isToday = key == today;
    return Column(children: [
      Text(DateFormat('E').format(d).substring(0, 1), style: context.text.bodySmall),
      const SizedBox(height: 4),
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: met ? c.accentSoft : c.surface2,
          shape: BoxShape.circle,
          border: isToday ? Border.all(color: c.accent, width: 2) : null,
        ),
        child: met
            ? Icon(Icons.check_rounded, size: 16, color: c.accent)
            : frozen
                ? Icon(Icons.ac_unit_rounded, size: 14, color: Colors.lightBlue.shade300)
                : null,
      ),
    ]);
  }
}

class _VoiceMissingCard extends StatelessWidget {
  const _VoiceMissingCard();

  @override
  Widget build(BuildContext context) => SoftCard(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.record_voice_over_outlined, color: context.colors.accent),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'No Japanese voice found for audio. On Android open Settings → Accessibility → Text-to-speech '
              '(or install "Speech Services by Google") and add Japanese. It then works offline.',
            ),
          ),
        ]),
      );
}
