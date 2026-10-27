import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/quiz.dart';
import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'word_sheet.dart';
import '../widgets/app_icons.dart';

/// Quiz tab: choose a mode and which words to be quizzed on.
class QuizHubScreen extends StatefulWidget {
  const QuizHubScreen({super.key});

  @override
  State<QuizHubScreen> createState() => _QuizHubScreenState();
}

enum _Source { studied, level, starred }

class _QuizHubScreenState extends State<QuizHubScreen> {
  _Source _source = _Source.studied;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final studied = [for (final id in state.cards.keys) ?state.content.byId[id]];
    final starred = state.wordsIn('starred');
    final level = state.settings.level;
    final (pool, label) = switch (_source) {
      _Source.studied => (studied, 'Words you have studied'),
      _Source.level => (state.content.byLevel[level]!, 'All N$level words'),
      _Source.starred => (starred, 'Starred words'),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text('Quiz on', style: context.text.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text('Studied · ${studied.length}'),
                selected: _source == _Source.studied,
                onSelected: (_) => setState(() => _source = _Source.studied),
              ),
              ChoiceChip(
                label: Text('All N$level'),
                selected: _source == _Source.level,
                onSelected: (_) => setState(() => _source = _Source.level),
              ),
              ChoiceChip(
                label: Text('Starred · ${starred.length}'),
                selected: _source == _Source.starred,
                onSelected: (_) => setState(() => _source = _Source.starred),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (pool.length < 4)
            SoftCard(
              child: Text(
                _source == _Source.starred
                    ? 'Star at least 4 words to quiz yourself on them.'
                    : 'Study a few flashcards first, or quiz yourself on all N$level words.',
              ),
            )
          else
            for (final m in QuizMode.values) ...[
              _ModeCard(mode: m, onTap: () => startQuiz(context, pool, m, label)),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

void startQuiz(BuildContext context, List<Word> pool, QuizMode mode, String label, {int count = 10}) {
  final state = context.read<AppState>();
  final questions = QuizBuilder(state.content.words).build(pool, mode, count);
  if (questions.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No words with kanji here yet. Try another mode.')));
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => QuizScreen(questions: questions, label: label),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onTap});
  final QuizMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text(
                mode.glyph,
                style: TextStyle(fontSize: 24, color: c.accent, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mode.title, style: context.text.titleMedium),
                Text(mode.subtitle, style: context.text.bodySmall),
              ],
            ),
          ),
          Icon(AppIcons.playCircle, color: c.accent, size: 32),
        ],
      ),
    );
  }
}

/// Mode picker for a specific set of words (used by decks).
class QuizSetupScreen extends StatelessWidget {
  const QuizSetupScreen({super.key, required this.pool, required this.sourceLabel});
  final List<Word> pool;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Quiz · $sourceLabel')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final m in QuizMode.values) ...[
          _ModeCard(mode: m, onTap: () => startQuiz(context, pool, m, sourceLabel)),
          const SizedBox(height: 10),
        ],
      ],
    ),
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.questions, required this.label});
  final List<QuizQuestion> questions;
  final String label;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _picked;
  int _score = 0;
  int _combo = 0;
  final _missed = <Word>[];
  final _watch = Stopwatch()..start();
  late final AppState _state;

  QuizQuestion get _q => widget.questions[_index];
  bool get _done => _index >= widget.questions.length;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _autoplay();
  }

  @override
  void dispose() {
    _state.addStudyTime(_watch.elapsed);
    _state.tts.stop();
    super.dispose();
  }

  void _autoplay() {
    if (!_done && _q.mode == QuizMode.listening) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _state.tts.speak(_q.word.speakText));
    }
  }

  void _pick(int i) {
    if (_picked != null) return;
    final correct = i == _q.answer;
    _state.recordQuizAnswer(_q.word.id, correct);
    setState(() {
      _picked = i;
      if (correct) {
        _score++;
        _combo++;
      } else {
        _combo = 0;
        _missed.add(_q.word);
      }
    });
    if (_q.mode != QuizMode.listening && _state.settings.autoplayAudio) _state.tts.speak(_q.word.speakText);
  }

  void _next() {
    setState(() {
      _index++;
      _picked = null;
    });
    _autoplay();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.close),
          tooltip: 'End quiz',
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(child: Bar(_index / total)),
            const SizedBox(width: 12),
            Text('${_index.clamp(0, total)}/$total', style: context.text.bodySmall),
            const SizedBox(width: 16),
          ],
        ),
      ),
      body: SafeArea(child: _done ? _summary(context) : _question(context)),
    );
  }

  Widget _question(BuildContext context) {
    final c = context.colors;
    final q = _q;
    final w = q.word;
    final prompt = switch (q.mode) {
      QuizMode.meaning => 'What does this word mean?',
      QuizMode.reverse => 'Which word means…',
      QuizMode.reading => 'How is this word read?',
      QuizMode.listening => 'Which word do you hear?',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Align(alignment: Alignment.centerLeft, child: Tag('${q.mode.title} quiz · N${w.level}')),
        const SizedBox(height: 12),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
          child: Column(
            children: [
              Text(prompt, style: context.text.bodySmall),
              const SizedBox(height: 10),
              switch (q.mode) {
                QuizMode.meaning || QuizMode.reading => FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(w.word, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w700)),
                ),
                QuizMode.reverse => Text(w.meaning, textAlign: TextAlign.center, style: context.text.headlineSmall),
                QuizMode.listening => SpeakButton(w.speakText, size: 84),
              },
              if (q.mode == QuizMode.meaning) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpeakButton(w.speakText, size: 36),
                    if (w.showReading) ...[
                      const SizedBox(width: 8),
                      Text(w.reading, style: TextStyle(color: c.muted, fontSize: 16)),
                    ],
                  ],
                ),
              ],
              if (q.mode == QuizMode.listening && _picked == null) ...[
                const SizedBox(height: 10),
                Text('Tap to listen again', style: context.text.bodySmall),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++) ...[_option(context, i), const SizedBox(height: 10)],
        if (_picked != null) _feedback(context),
      ],
    );
  }

  Widget _option(BuildContext context, int i) {
    final c = context.colors;
    final picked = _picked;
    final isAnswer = i == _q.answer;
    final showGood = picked != null && isAnswer;
    final showBad = picked == i && !isAnswer;
    final border = showGood
        ? c.good
        : showBad
        ? c.bad
        : c.border;
    final fg = showGood
        ? c.good
        : showBad
        ? c.bad
        : Theme.of(context).colorScheme.onSurface;
    final jp = _q.mode == QuizMode.reverse || _q.mode == QuizMode.listening || _q.mode == QuizMode.reading;
    return Material(
      color: showGood
          ? Color.alphaBlend(c.good.withValues(alpha: 0.12), Theme.of(context).colorScheme.surface)
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: border, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: picked == null ? () => _pick(i) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _q.options[i],
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: jp ? 19 : 15.5, color: fg),
                ),
              ),
              if (showGood) Icon(AppIcons.check, color: c.good),
              if (showBad) Icon(AppIcons.close, color: c.bad),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedback(BuildContext context) {
    final c = context.colors;
    final right = _picked == _q.answer;
    final w = _q.word;
    return SoftCard(
      borderColor: right ? c.good : c.bad,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  right ? (_combo >= 3 ? 'Correct! $_combo in a row 🔥' : 'Correct!') : 'Not quite',
                  style: TextStyle(color: right ? c.good : c.bad, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  '${w.word}${w.showReading ? '（${w.reading}）' : ''} · ${w.shortMeaning}',
                  style: context.text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            onPressed: _next,
            child: Text(_index == widget.questions.length - 1 ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final total = widget.questions.length;
    final pct = (_score * 100 / total).round();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Text(
            pct >= 80
                ? '🌸'
                : pct >= 50
                ? '👍'
                : '💪',
            style: const TextStyle(fontSize: 64),
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text('$_score / $total correct', style: context.text.headlineSmall)),
        Center(child: Text(widget.label, style: context.text.bodySmall)),
        const SizedBox(height: 24),
        if (_missed.isNotEmpty) ...[
          Text('Review these', style: context.text.titleMedium),
          const SizedBox(height: 4),
          Text('Missed words you have already learned come back in your next review.', style: context.text.bodySmall),
          const SizedBox(height: 8),
          for (final w in _missed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(w.word, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              subtitle: Text('${w.showReading ? '${w.reading} · ' : ''}${w.shortMeaning}'),
              trailing: SpeakButton(w.speakText, size: 34),
              onTap: () => showWordSheet(context, w),
            ),
        ],
        const SizedBox(height: 24),
        GradientButton(label: 'Done', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
