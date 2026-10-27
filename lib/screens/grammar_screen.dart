import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/app_icons.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final today = state.todaysGrammar;
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (today != null)
            SoftCard(
              color: c.accentSoft,
              borderColor: c.accentSoft,
              onTap: () => _open(context, today),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's lesson · Day ${state.grammarDayNumber}",
                          style: TextStyle(color: c.accent, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(today.title, style: context.text.headlineSmall),
                        Text(today.meaning, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  Icon(AppIcons.playCircle, color: c.accent, size: 40),
                ],
              ),
            ),
          const SizedBox(height: 16),
          for (final l in [5, 4, 3, 2, 1]) _LevelSection(level: l, initiallyExpanded: l == state.settings.level),
        ],
      ),
    );
  }

  static void _open(BuildContext context, GrammarPoint g) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => GrammarLessonScreen(point: g)));
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({required this.level, required this.initiallyExpanded});
  final int level;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    final points = state.grammarFor(level);
    final done = points.where((g) => state.grammarDone.containsKey(g.id)).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            shape: const Border(),
            title: Text('N$level grammar', style: context.text.titleMedium),
            subtitle: Text('$done / ${points.length} lessons done', style: context.text.bodySmall),
            children: [
              for (final g in points)
                ListTile(
                  onTap: () => GrammarScreen._open(context, g),
                  leading: Icon(
                    state.grammarDone.containsKey(g.id) ? AppIcons.checkCircle : AppIcons.circle,
                    color: state.grammarDone.containsKey(g.id) ? c.good : c.border,
                  ),
                  title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(g.meaning),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GrammarLessonScreen extends StatefulWidget {
  const GrammarLessonScreen({super.key, required this.point});
  final GrammarPoint point;

  @override
  State<GrammarLessonScreen> createState() => _GrammarLessonScreenState();
}

class _GrammarLessonScreenState extends State<GrammarLessonScreen> {
  late final List<int> _order = List.generate(widget.point.quiz.options.length, (i) => i)..shuffle();
  int? _picked;
  final _watch = Stopwatch()..start();
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
  }

  @override
  void dispose() {
    _state.addStudyTime(_watch.elapsed);
    _state.tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.point;
    final c = context.colors;
    final state = context.watch<AppState>();
    final done = state.grammarDone.containsKey(g.id);
    final answered = _picked != null;
    final correct = _picked == g.quiz.answer;

    return Scaffold(
      appBar: AppBar(title: Text('N${g.level} · Grammar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          children: [
            Text(g.title, style: context.text.headlineMedium?.copyWith(fontSize: 30)),
            const SizedBox(height: 2),
            Text(
              g.meaning,
              style: context.text.titleMedium?.copyWith(color: c.muted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(18)),
              child: Text(
                g.formation,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.accent, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            const SizedBox(height: 14),
            Text(g.explanation, style: context.text.bodyMedium),
            const SizedBox(height: 16),
            Text('Examples', style: context.text.titleMedium),
            for (final x in g.examples) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HighlightText(x.jp, style: const TextStyle(fontSize: 17, height: 1.5)),
                          Text(x.en, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SpeakButton(x.plain, size: 38),
                  ],
                ),
              ),
              const Divider(),
            ],
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick check', style: context.text.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    answered
                        ? g.quiz.sentence.replaceFirst('＿＿', '【${g.quiz.options[g.quiz.answer]}】')
                        : g.quiz.sentence,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                  if (answered) Text(g.quiz.translation, style: context.text.bodySmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final i in _order)
                        ChoiceChip(
                          label: Text(g.quiz.options[i], style: const TextStyle(fontSize: 16)),
                          selected: _picked == i,
                          selectedColor: i == g.quiz.answer ? c.good : c.bad,
                          backgroundColor: answered && i == g.quiz.answer ? c.good.withValues(alpha: 0.2) : null,
                          onSelected: answered ? null : (_) => setState(() => _picked = i),
                        ),
                    ],
                  ),
                  if (answered) ...[
                    const SizedBox(height: 10),
                    Text(
                      correct ? 'Correct! よくできました。' : 'Not quite. The answer is ${g.quiz.options[g.quiz.answer]}.',
                      style: TextStyle(color: correct ? c.good : c.bad, fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (done)
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(AppIcons.checkCircle, color: c.good),
                label: const Text('Lesson completed'),
              )
            else
              GradientButton(
                label: answered ? 'Complete lesson' : 'Answer the quick check to finish',
                onPressed: answered
                    ? () {
                        state.completeGrammar(g.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('${g.title} completed. また明日！')));
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
