import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/vi_format.dart';

import '../logic/streak.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/app_icons.dart';
import '../widgets/botanical.dart';
import 'database_setup_screen.dart';
import 'flashcard_screen.dart';
import 'grammar_screen.dart';
import 'listening/listening_screens.dart';
import 'settings_screen.dart';
import 'shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _weekdaysJa = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];

  (String, String, String) _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return ('おはよう', 'Chào buổi sáng,', 'một trang mới.');
    if (h < 18) return ('こんにちは', 'Chào buổi chiều,', 'thêm chút nữa hôm nay.');
    return ('こんばんは', 'Chào buổi tối,', 'một buổi ôn nhẹ nhàng.');
  }

  void _startSession(BuildContext context, AppState state) {
    var words = state.buildDailySession();
    if (words.isEmpty) words = state.nextNewWords(5);
    if (words.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Bạn đã học hết từ của cấp độ này. Hãy chọn cấp độ khác.')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(words: words, title: 'Buổi học hôm nay'),
      ),
    );
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
    final (jpGreeting, line1, line2) = _greeting();
    final word = state.wordOfTheDay;
    final running = state.attempts.values.where((a) => a.inProgress && a.timed).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
            child: Row(
              children: [
                Expanded(child: Eyebrow('${_weekdaysJa[now.weekday - 1]} · ${viWeekdayLong(now)}')),
                const SyncBadge(),
                IconButton(
                  tooltip: 'Cài đặt',
                  icon: const Icon(AppIcons.settings),
                  onPressed: () => push(const SettingsScreen()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DatabaseSetupBanner(onOpen: () => push(const DatabaseSetupScreen())),
                // Hero: large serif copy on the left, arched "portrait" of
                // today's word on the right with the streak circle at its base.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(jpGreeting, style: AppTheme.jp(20, color: c.muted)),
                            const SizedBox(height: 6),
                            Text(line1, style: context.text.headlineLarge),
                            Text(line2, style: displayItalic(context, 40)),
                            const SizedBox(height: 14),
                            Text('N$level · đã thuộc $learned/$levelTotal từ', style: context.text.bodySmall),
                            const SizedBox(height: 8),
                            Bar(levelTotal == 0 ? 0 : learned / levelTotal, height: 4),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      height: 238,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Semantics(
                              button: true,
                              label: word == null
                                  ? 'Từ của ngày'
                                  : 'Từ của ngày: ${word.word}, ${word.meaning}. Chạm để nghe.',
                              child: GestureDetector(
                                onTap: word == null ? null : () => state.tts.speak(word.speakText),
                                child: ArchPanel(
                                  width: 126,
                                  height: 196,
                                  child: word == null
                                      ? const SizedBox.shrink()
                                      : Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 40, 8, 18),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              FittedBox(child: Eyebrow('Từ của ngày', color: c.muted)),
                                              const SizedBox(height: 10),
                                              Flexible(
                                                flex: 3,
                                                child: FittedBox(child: Text(word.word, style: AppTheme.jp(40))),
                                              ),
                                              if (word.showReading)
                                                Flexible(
                                                  child: FittedBox(
                                                    child: Text(word.reading, style: context.text.bodySmall),
                                                  ),
                                                ),
                                              const SizedBox(height: 4),
                                              Flexible(
                                                flex: 2,
                                                child: Text(
                                                  word.shortMeaning,
                                                  style: context.text.bodySmall,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 4,
                            child: Semantics(
                              label: 'Chuỗi ${state.streak.current} ngày',
                              child: OrnamentCircle(
                                size: 68,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${state.streak.current}',
                                      style: context.text.titleLarge?.copyWith(height: 1, color: c.clay),
                                    ),
                                    Text(
                                      'ngày',
                                      style: context.text.bodySmall?.copyWith(fontSize: 9.5, height: 1.1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Positioned(right: -6, bottom: -6, child: Sprig(size: 58, leaves: 4)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _StreakCard(state: state),
                const SizedBox(height: 14),
                LevelPicker(
                  value: level,
                  onChanged: (l) => state.updateSettings((s) => s.copyWith(level: l)),
                ),
                if (state.tts.japaneseAvailable.value == false) ...[
                  const SizedBox(height: 12),
                  const _VoiceMissingCard(),
                ],
                const SizedBox(height: 22),
              ],
            ),
          ),
          // Today's path: numbered steps on a forest field with a curved top.
          CurvedForestField(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Eyebrow('Lộ trình hôm nay', color: c.onForest.withValues(alpha: 0.75)),
                const SizedBox(height: 6),
                Text('Bốn bước nhỏ', style: context.text.headlineMedium?.copyWith(color: c.onForest)),
                const SizedBox(height: 14),
                _Step(
                  n: 1,
                  title: 'Từ vựng',
                  body: due + newLeft == 0
                      ? 'Đã ôn xong · học thêm từ mới'
                      : '$due từ cần ôn · $newLeft từ mới',
                  onTap: () => _startSession(context, state),
                ),
                _Step(
                  n: 2,
                  title: grammar == null ? 'Ngữ pháp · đã học hết bài' : 'Ngữ pháp · ${grammar.title}',
                  body: grammar == null ? 'すごい！ Hãy ôn lại bài bất kỳ trong mục Luyện tập.' : grammar.meaning,
                  onTap: grammar == null ? null : () => push(GrammarLessonScreen(point: grammar)),
                ),
                _Step(
                  n: 3,
                  title: 'Nghe hiểu',
                  body: 'Hội thoại ngắn và câu được đọc to',
                  onTap: () => push(const ListeningHubScreen()),
                ),
                _Step(
                  n: 4,
                  title: 'Luyện thi JLPT',
                  body: running.isEmpty
                      ? 'Đề thi thử có tính giờ · giải thích tiếng Việt'
                      : '${running.first.title} · đang làm ${running.first.answers.length}/${running.first.total}',
                  onTap: () => Shell.goToTab(context, Shell.jlptTab),
                  last: true,
                ),
                const SizedBox(height: 20),
                GradientButton(
                  inverse: true,
                  label: 'Bắt đầu buổi học hôm nay',
                  icon: AppIcons.play,
                  onPressed: () => _startSession(context, state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.title, required this.body, this.onTap, this.last = false});

  final int n;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: c.fieldLine),
              bottom: last ? BorderSide(color: c.fieldLine) : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 46,
                child: Text(
                  n.toString().padLeft(2, '0'),
                  style: displayItalic(context, 26).copyWith(color: c.warmField),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium?.copyWith(color: c.onForest)),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: context.text.bodySmall?.copyWith(color: c.onForest.withValues(alpha: 0.78)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null) Icon(AppIcons.next, color: c.onForest.withValues(alpha: 0.8), size: 20),
            ],
          ),
        ),
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
      tone: PanelTone.sage,
      radius: AppTheme.radiusWide,
      child: Column(
        children: [
          Row(
            children: [
              Ring(
                value: goal == 0 ? 0 : progress / goal,
                child: Text(
                  '${progress.clamp(0, 999)}/$goal',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.fire,
                          color: s.current > 0 ? context.colors.clay : context.colors.muted,
                          size: 26,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${s.current} ngày',
                          style: context.text.headlineSmall?.copyWith(fontSize: 26),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.todayDone
                          ? 'Đã đạt mục tiêu hôm nay. お疲れさま！'
                          : left == goal
                          ? 'Học $goal mục hôm nay để ${s.current > 0 ? 'giữ' : 'bắt đầu'} chuỗi ngày'
                          : 'Còn $left mục để ${s.current > 0 ? 'giữ' : 'bắt đầu'} chuỗi ngày',
                      style: context.text.bodySmall,
                    ),
                    if (s.freezes > 0) ...[
                      const SizedBox(height: 4),
                      Tag('${s.freezes} lượt đóng băng chuỗi', icon: AppIcons.freeze),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(child: _dayDot(context, DateTime(monday.year, monday.month, monday.day + i), days, s, c)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayDot(BuildContext context, DateTime d, Map days, StreakInfo s, AppColors c) {
    final key = dayKey(d);
    final today = dayKey(DateTime.now());
    final stat = days[key];
    final met = stat != null && stat.goal > 0 && stat.studied >= stat.goal;
    final frozen = s.frozenDays.contains(key);
    final isToday = key == today;
    return Column(
      children: [
        Text(viWeekdayShort(d), style: context.text.bodySmall),
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
              ? Icon(AppIcons.check, size: 16, color: c.accent)
              : frozen
              ? Icon(AppIcons.freeze, size: 14, color: c.fieldLine)
              : null,
        ),
      ],
    );
  }
}

class _VoiceMissingCard extends StatelessWidget {
  const _VoiceMissingCard();

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.voice, color: context.colors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            Platform.isIOS
                ? 'Không tìm thấy giọng đọc tiếng Nhật. Trên iPhone, mở Cài đặt → Trợ năng → Nội dung được đọc → '
                      'Giọng nói → Tiếng Nhật và tải một giọng. Sau đó dùng được cả khi không có mạng.'
                : 'Không tìm thấy giọng đọc tiếng Nhật. Trên Android, mở Cài đặt → Hỗ trợ tiếp cận → Chuyển văn bản thành giọng nói '
                      '(hoặc cài "Dịch vụ lời nói của Google") rồi thêm tiếng Nhật. Sau đó dùng được cả khi không có mạng.',
          ),
        ),
      ],
    ),
  );
}
