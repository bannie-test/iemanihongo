import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/stroke_repository.dart';
import '../../logic/handwriting.dart';
import '../../logic/kana.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import 'writing_canvas.dart';

/// Pick kana or kanji to practise writing.
class WritingHubScreen extends StatefulWidget {
  const WritingHubScreen({super.key});

  @override
  State<WritingHubScreen> createState() => _WritingHubScreenState();
}

class _WritingHubScreenState extends State<WritingHubScreen> {
  late final Future<StrokeRepository> _strokes = StrokeRepository.load();
  int _kanjiLevel = 5;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Writing practice'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hiragana'),
              Tab(text: 'Katakana'),
              Tab(text: 'Kanji'),
            ],
          ),
        ),
        body: FutureBuilder(
          future: _strokes,
          initialData: StrokeRepository.loaded,
          builder: (context, snap) {
            final repo = snap.data;
            if (repo == null) return const Center(child: CircularProgressIndicator());
            final hira = [
              for (final ch in hiraganaOrder.split(''))
                if (repo.has(ch)) ch,
            ];
            final kata = [
              for (final ch in hira.map(toKatakana))
                if (repo.has(ch)) ch,
            ];
            final kanji = [
              for (final k in state.content.kanji.values)
                if (k.level == _kanjiLevel && repo.has(k.char)) k.char,
            ];
            return TabBarView(
              children: [
                _CharGrid(chars: hira, repo: repo),
                _CharGrid(chars: kata, repo: repo),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: LevelPicker(value: _kanjiLevel, onChanged: (l) => setState(() => _kanjiLevel = l)),
                    ),
                    Expanded(
                      child: _CharGrid(chars: kanji, repo: repo),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CharGrid extends StatelessWidget {
  const _CharGrid({required this.chars, required this.repo});

  final List<String> chars;
  final StrokeRepository repo;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final c = context.colors;
    final practised = chars.where((ch) => state.writingScore(ch).attempts > 0).length;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(child: Text('$practised / ${chars.length} practised', style: context.text.bodySmall)),
                TextButton.icon(
                  onPressed: chars.isEmpty
                      ? null
                      : () {
                          final next = chars.indexWhere((ch) => state.writingScore(ch).best < 75);
                          _openPractice(context, chars, next < 0 ? 0 : next);
                        },
                  icon: const Icon(AppIcons.play, size: 16),
                  label: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 76,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: chars.length,
            itemBuilder: (context, i) {
              final ch = chars[i];
              final s = state.writingScore(ch);
              final color = s.attempts == 0
                  ? c.border
                  : s.best >= 75
                  ? c.good
                  : s.best >= 50
                  ? Colors.amber
                  : c.bad;
              return Material(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: color, width: s.attempts == 0 ? 2 : 2.5),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openPractice(context, chars, i),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(ch, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                      ),
                      if (s.attempts > 0)
                        Positioned(
                          right: 6,
                          bottom: 4,
                          child: Text(
                            '${s.best}',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openPractice(BuildContext context, List<String> chars, int index) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => WritingPracticeScreen(chars: chars, initialIndex: index, repo: repo),
    ),
  );
}

/// Trace or write a character over a dashed guide, then check it.
class WritingPracticeScreen extends StatefulWidget {
  const WritingPracticeScreen({super.key, required this.chars, required this.initialIndex, required this.repo});

  final List<String> chars;
  final int initialIndex;
  final StrokeRepository repo;

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> with SingleTickerProviderStateMixin {
  late int _index = widget.initialIndex;
  List<List<Offset>> _ink = [];
  HandwritingResult? _result;
  bool _guide = true;
  bool _numbers = false;
  late final AnimationController _demo = AnimationController(vsync: this);
  bool _playing = false;

  String get _ch => widget.chars[_index];
  CharStrokes get _strokes => widget.repo[_ch]!;

  @override
  void dispose() {
    _demo.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    if (i < 0 || i >= widget.chars.length) return;
    _demo.stop();
    setState(() {
      _index = i;
      _ink = [];
      _result = null;
      _playing = false;
    });
  }

  Future<void> _playDemo() async {
    final n = _strokes.strokeCount.toDouble();
    setState(() {
      _playing = true;
      _ink = [];
      _result = null;
    });
    _demo
      ..duration = Duration(milliseconds: (700 * n).round())
      ..value = 0;
    await _demo.animateTo(1, curve: Curves.linear).orCancel.catchError((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _playing = false);
  }

  void _check() {
    final r = HandwritingScorer.score(_strokes.samples, _ink);
    setState(() => _result = r);
    context.read<AppState>().recordWriting(_ch, r.score);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = context.watch<AppState>();
    final best = state.writingScore(_ch);
    final info = state.content.kanji[_ch];
    final romaji = isKana(_ch) ? romajiOf(_ch) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / ${widget.chars.length}'),
        actions: [
          if (best.attempts > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Tag('Best ${best.best}', accent: true)),
            ),
        ],
      ),
      // Not scrollable: the whole page is the drawing surface's frame.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_ch, style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w700, height: 1.1)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (romaji != null) Text(romaji, style: context.text.titleLarge),
                        if (info != null) ...[
                          Text(info.meanings.take(3).join(', '), style: context.text.titleMedium),
                          if (info.onReadings.isNotEmpty)
                            Text('On: ${info.onReadings.join('、')}', style: context.text.bodySmall),
                          if (info.kunReadings.isNotEmpty)
                            Text(
                              'Kun: ${info.kunReadings.map((r) => r.replaceAll('.', '')).join('、')}',
                              style: context.text.bodySmall,
                            ),
                        ],
                        const SizedBox(height: 4),
                        Tag('${_strokes.strokeCount} strokes'),
                      ],
                    ),
                  ),
                  SpeakButton(
                    romaji != null
                        ? _ch
                        : (info?.kunReadings.isNotEmpty ?? false)
                        ? info!.kunReadings.first.replaceAll(RegExp(r'[.\-]'), '')
                        : _ch,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: WritingCanvas(
                    strokes: _strokes,
                    ink: _ink,
                    showGuide: _guide,
                    showNumbers: _numbers,
                    result: _result,
                    animation: _playing ? _demo.drive(Tween(begin: 0.0, end: _strokes.strokeCount.toDouble())) : null,
                    enabled: !_playing && _result == null,
                    onInkChanged: (ink) => setState(() => _ink = ink),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tool(context, AppIcons.playCircle, 'Stroke order', _playing ? null : _playDemo),
                  _tool(
                    context,
                    _guide ? AppIcons.eye : AppIcons.eyeOff,
                    _guide ? 'Guide on' : 'From memory',
                    () => setState(() => _guide = !_guide),
                  ),
                  _tool(
                    context,
                    AppIcons.grid,
                    _numbers ? 'Numbers on' : 'Numbers',
                    () => setState(() => _numbers = !_numbers),
                  ),
                  _tool(
                    context,
                    AppIcons.undo,
                    'Undo',
                    _ink.isEmpty || _result != null
                        ? null
                        : () => setState(() => _ink = _ink.sublist(0, _ink.length - 1)),
                  ),
                  _tool(
                    context,
                    AppIcons.eraser,
                    'Clear',
                    _ink.isEmpty
                        ? null
                        : () => setState(() {
                            _ink = [];
                            _result = null;
                          }),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_result != null) _ResultPanel(result: _result!) else const SizedBox.shrink(),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton.outlined(
                    tooltip: 'Previous',
                    onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                    icon: const Icon(AppIcons.back),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _result == null
                        ? GradientButton(
                            label: 'Check',
                            icon: AppIcons.check,
                            height: 50,
                            onPressed: _ink.isEmpty ? null : _check,
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() {
                                    _ink = [];
                                    _result = null;
                                  }),
                                  child: const Text('Try again'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GradientButton(
                                  label: 'Next',
                                  height: 50,
                                  onPressed: _index == widget.chars.length - 1 ? null : () => _goTo(_index + 1),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.outlined(
                    tooltip: 'Next',
                    onPressed: _index == widget.chars.length - 1 ? null : () => _goTo(_index + 1),
                    icon: const Icon(AppIcons.next),
                  ),
                ],
              ),
              if (_result == null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _guide
                        ? 'Trace over the dashed strokes in order. Tap "Stroke order" to watch first.'
                        : 'Write it from memory, then check.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.muted, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tool(BuildContext context, IconData icon, String label, VoidCallback? onTap) {
    final c = context.colors;
    final color = onTap == null ? c.muted.withValues(alpha: 0.5) : c.accent;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result});
  final HandwritingResult result;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = result;
    final color = r.score >= 75
        ? c.good
        : r.score >= 50
        ? Colors.amber.shade700
        : c.bad;
    final tips = <String>[
      if (!r.strokeCountOk) 'You drew ${r.drawnStrokes} strokes; this character has ${r.expectedStrokes}.',
      if (r.strokes.any((s) => s.reversed)) 'Some strokes were drawn in the wrong direction (red).',
      if (r.inOrder < r.expectedStrokes && r.strokeCountOk)
        'Check the stroke order: ${r.inOrder}/${r.expectedStrokes} in the right place.',
      if (r.coverage < 0.7) 'Parts of the character are missing. Follow the whole outline.',
      if (r.precision < 0.7) 'Try to stay on the guide lines.',
    ];
    return SoftCard(
      borderColor: color,
      child: Row(
        children: [
          Ring(
            value: r.score / 100,
            size: 64,
            stroke: 7,
            child: Text(
              '${r.score}',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.grade, style: context.text.titleMedium?.copyWith(color: color)),
                Text(
                  'Order ${r.inOrder}/${r.expectedStrokes} · shape ${(r.coverage * 100).round()}%',
                  style: context.text.bodySmall,
                ),
                for (final t in tips.take(2)) Text('• $t', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
