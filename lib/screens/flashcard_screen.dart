import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/srs.dart';
import '../models/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'word_sheet.dart';
import '../widgets/app_icons.dart';

/// Spaced-repetition flashcard session. Cards still in a learning step come
/// back a few cards later in the same session.
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.words, required this.title});

  final List<Word> words;
  final String title;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late final List<Word> _queue = List.of(widget.words);
  late final int _total = widget.words.length;
  final _finished = <String>{};
  final _watch = Stopwatch()..start();
  late final AppState _state;
  bool _flipped = false;
  int _answered = 0;
  int _correct = 0;

  static const _requeueGap = 3;

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

  void _flip() {
    setState(() => _flipped = true);
    if (_state.settings.autoplayAudio) _state.tts.speak(_queue.first.speakText);
  }

  void _rate(Rating r) {
    final word = _queue.removeAt(0);
    final card = _state.rate(word.id, r);
    _answered++;
    if (r != Rating.again) _correct++;
    final stillLearning = card.phase == CardPhase.learning || card.phase == CardPhase.relearning;
    if (stillLearning) {
      _queue.insert(_queue.length < _requeueGap ? _queue.length : _requeueGap, word);
    } else {
      _finished.add(word.id);
    }
    setState(() => _flipped = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.close),
          tooltip: 'End session',
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(child: Bar(_total == 0 ? 1 : _finished.length / _total)),
            const SizedBox(width: 12),
            Text('${_finished.length}/$_total', style: context.text.bodySmall),
            const SizedBox(width: 16),
          ],
        ),
      ),
      body: SafeArea(child: _queue.isEmpty ? _summary(context) : _card(context, c, _queue.first)),
    );
  }

  Widget _card(BuildContext context, AppColors c, Word w) {
    final state = context.watch<AppState>();
    final card = state.cardFor(w.id);
    final isNew = card.phase == CardPhase.fresh;
    final now = state.nowMs;
    final kanji = state.content.kanjiIn(w);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _flipped ? null : _flip,
              child: SoftCard(
                padding: const EdgeInsets.fromLTRB(18, 14, 8, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Tag('N${w.level}${isNew ? ' · New' : ''}', accent: true),
                        const Spacer(),
                        IconButton(
                          tooltip: state.isStarred(w.id) ? 'Remove star' : 'Star word',
                          icon: Icon(state.isStarred(w.id) ? AppIcons.starOn : AppIcons.star, color: c.accent),
                          onPressed: () => state.toggleStar(w.id),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            SizedBox(height: _flipped ? 8 : 70),
                            if (_flipped && w.showReading)
                              Text(
                                w.reading,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, color: c.muted, letterSpacing: 2),
                              ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                w.word,
                                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w700, height: 1.25),
                              ),
                            ),
                            if (!_flipped) ...[
                              const SizedBox(height: 40),
                              Text('Tap to reveal', style: context.text.bodySmall),
                            ] else ...[
                              const SizedBox(height: 8),
                              SpeakButton(w.speakText, size: 46),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: c.border),
                              ),
                              Text(w.meaning, textAlign: TextAlign.center, style: context.text.titleLarge),
                              if (kanji.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final k in kanji)
                                      ActionChip(
                                        label: Text('${k.char}  ${k.meanings.take(2).join(', ')}'),
                                        onPressed: () => showKanjiSheet(context, k),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!_flipped)
            GradientButton(label: 'Show answer', onPressed: _flip)
          else ...[
            Text('How well did you remember?', style: context.text.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final r in Rating.values) ...[
                  Expanded(child: _rateButton(context, c, r, Srs.previewLabel(card, r, now))),
                  if (r != Rating.easy) const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _rateButton(BuildContext context, AppColors c, Rating r, String label) {
    final (name, color) = switch (r) {
      Rating.again => ('Again', c.bad),
      Rating.hard => ('Hard', Theme.of(context).colorScheme.onSurface),
      Rating.good => ('Good', c.good),
      Rating.easy => ('Easy', c.accent),
    };
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.border, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _rate(r),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15),
              ),
              Text(label, style: context.text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    final pct = _answered == 0 ? 0 : (_correct * 100 / _answered).round();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Text('🎉', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text('お疲れさまでした！', style: context.text.headlineSmall),
          const SizedBox(height: 4),
          Text('Session complete', style: context.text.bodySmall),
          const SizedBox(height: 24),
          Row(
            children: [
              _stat(context, '$_total', 'cards'),
              _stat(context, '$pct%', 'remembered'),
              _stat(context, '${state.streak.current}', 'day streak'),
            ],
          ),
          const SizedBox(height: 16),
          if (!state.goalDone)
            Text(
              '${(state.settings.dailyGoal - state.goalProgress).clamp(0, 999)} more items to reach today\'s goal.',
              style: TextStyle(color: c.muted),
            )
          else
            Text(
              "Today's goal is done. Your streak is safe!",
              style: TextStyle(color: c.good, fontWeight: FontWeight.w700),
            ),
          const Spacer(),
          if (state.nextNewWords(5).isNotEmpty)
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => FlashcardScreen(words: state.nextNewWords(5), title: 'Extra words'),
                ),
              ),
              child: const Text('Learn 5 more words'),
            ),
          const SizedBox(height: 10),
          GradientButton(label: 'Done', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) => Expanded(
    child: Column(
      children: [
        Text(value, style: context.text.titleLarge),
        Text(label, style: context.text.bodySmall),
      ],
    ),
  );
}
