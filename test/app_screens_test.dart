// Drives the real UI with sample progress. Doubles as a smoke test for
// every main screen. Set SCREENSHOT_DIR to also save PNG screenshots:
//   SCREENSHOT_DIR=build/screens flutter test test/app_screens_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iemanihongo/data/content_repository.dart';
import 'package:iemanihongo/data/local_db.dart';
import 'package:iemanihongo/data/stroke_repository.dart';
import 'package:iemanihongo/logic/srs.dart';
import 'package:iemanihongo/logic/streak.dart';
import 'package:iemanihongo/main.dart';
import 'package:iemanihongo/models/jlpt.dart';
import 'package:iemanihongo/models/settings.dart';
import 'package:iemanihongo/models/user_data.dart';
import 'package:iemanihongo/screens/jlpt/jlpt_hub_screen.dart';
import 'package:iemanihongo/screens/writing/writing_canvas.dart';
import 'package:iemanihongo/services/notification_service.dart';
import 'package:iemanihongo/services/tts_service.dart';
import 'package:iemanihongo/state/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final _outDir = Platform.environment['SCREENSHOT_DIR'];

/// Serves assets from the project folder (real IO, outside fake async).
class _FileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(File(key).readAsBytesSync());
}

Finder _nav(String label) => find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Finder _hubList() => find.descendant(of: find.byType(JlptHubScreen), matching: find.byType(Scrollable)).first;

/// Traces the reference strokes of [ch] on the writing canvas.
Future<void> _trace(WidgetTester tester, String ch) async {
  final strokes = StrokeRepository.loaded![ch]!;
  final box = tester.getRect(find.byType(WritingCanvas));
  final k = box.width / CharStrokes.box;
  for (final s in strokes.samples) {
    final g = await tester.startGesture(box.topLeft + s.first * k);
    for (final p in s.skip(1)) {
      await g.moveTo(box.topLeft + p * k);
    }
    await g.up();
    await tester.pump();
  }
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final p in paths) {
      if (File(p).existsSync()) loader.addFont(Future.value(ByteData.sublistView(File(p).readAsBytesSync())));
    }
    await loader.load();
  }

  await load('Nunito', [
    'assets/fonts/Nunito-Medium.ttf',
    'assets/fonts/Nunito-Bold.ttf',
    'assets/fonts/Nunito-ExtraBold.ttf',
  ]);
  await load('ZenMaruGothic', ['assets/fonts/ZenMaruGothic-Medium.ttf', 'assets/fonts/ZenMaruGothic-Bold.ttf']);
  final flutterRoot = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  await load('MaterialIcons', ['$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  final pubCache = Platform.environment['PUB_CACHE'] ?? '${Platform.environment['HOME']}/.pub-cache';
  final lucide = '$pubCache/hosted/pub.dev/lucide_icons_flutter-4.0.1/assets';
  await load('packages/lucide_icons_flutter/Lucide', ['$lucide/lucide.ttf']);
  await load('packages/lucide_icons_flutter/Lucide600', ['$lucide/build_font/LucideVariable-w600.ttf']);
}

Future<AppState> _seededState(ThemeMode mode) async {
  SharedPreferences.setMockInitialValues({
    'guest': true,
    'onboarded': true,
    'device_id': 'test-device',
    'settings': jsonEncode(const AppSettings(dailyGoal: 20).copyWith(themeMode: mode).toJson()),
  });
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository.fromJson(
    jsonDecode(File('assets/data/vocab.json').readAsStringSync()) as List,
    jsonDecode(File('assets/data/kanji.json').readAsStringSync()) as Map<String, dynamic>,
    jsonDecode(File('assets/data/grammar.json').readAsStringSync()) as List,
    jsonDecode(File('assets/data/jlpt_tests.json').readAsStringSync()) as List,
  );
  final db = await LocalDb.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
  final now = DateTime.now().millisecondsSinceEpoch;

  // ~3 weeks of history: learned N5 words, some due today, a few N4.
  final n5 = content.byLevel[5]!;
  for (var i = 0; i < 420; i++) {
    final dueSoon = i % 17 == 0;
    await db.saveCard(
      CardState(
        wordId: n5[i].id,
        phase: CardPhase.review,
        interval: 6,
        due: dueSoon ? now - 3600000 : now + (i % 9 + 1) * 86400000,
        reps: 4,
        updatedAt: now,
      ),
    );
  }
  for (final w in content.byLevel[4]!.take(160)) {
    await db.saveCard(
      CardState(wordId: w.id, phase: CardPhase.review, interval: 3, due: now + 86400000, updatedAt: now),
    );
  }
  final today = DateTime.now();
  for (var i = 1; i <= 75; i++) {
    if (i > 12 && i % 6 == 0) continue;
    final d = DateTime(today.year, today.month, today.day - i);
    final n = 18 + (i * 7) % 26;
    await db.saveStat(
      DailyStat(
        day: dayKey(d),
        deviceId: 'test-device',
        reviews: n,
        correct: (n * 0.86).round(),
        newWords: 8,
        quizTotal: i % 3 == 0 ? 10 : 0,
        quizCorrect: i % 3 == 0 ? 8 : 0,
        seconds: 600 + i * 13,
        goal: 20,
      ),
    );
  }
  await db.saveStat(
    DailyStat(day: dayKey(today), deviceId: 'test-device', reviews: 15, correct: 13, newWords: 5, goal: 20),
  );
  for (final w in content.byLevel[5]!.skip(30).take(6)) {
    await db.setDeckWord(Deck.starredId, w.id, true, now);
  }
  for (final g in content.grammar.where((g) => g.level == 5).take(11)) {
    await db.saveGrammarDone(g.id, now);
  }

  // JLPT N3: one finished mock test (with mistakes) and one in progress.
  final t1 = content.testsFor(3)[0], t2 = content.testsFor(3)[1];
  final done = TestAttempt(
    id: 'done-1',
    testId: t1.id,
    title: 'N3 · ${t1.title}',
    level: 3,
    mode: AttemptMode.exam,
    questionIds: [for (final q in t1.questions) q.id],
    startedAt: now - 7200000,
    finishedAt: now - 5400000,
    timeLimitSec: t1.minutes * 60,
    elapsedSec: 1534,
    updatedAt: now,
  );
  final answers = <TestAnswer>[];
  for (var i = 0; i < t1.questions.length; i++) {
    final q = t1.questions[i];
    final chosen = i % 4 == 1 || q.section == JlptSection.bunpou && i.isEven ? (q.answer + 1) % 4 : q.answer;
    done.answers[q.id] = chosen;
    answers.add(
      TestAnswer(
        id: 'ans-$i',
        attemptId: done.id,
        questionId: q.id,
        level: 3,
        section: q.section.name,
        tag: q.tag,
        chosen: chosen,
        isCorrect: chosen == q.answer,
        answeredAt: now - 5400000 + i,
      ),
    );
  }
  done.score = answers.where((a) => a.isCorrect).length;
  done.flagged.add(t1.questions[3].id);
  await db.saveAttempt(done);
  await db.saveAnswers(answers);
  final running = TestAttempt(
    id: 'run-1',
    testId: t2.id,
    title: 'N3 · ${t2.title}',
    level: 3,
    mode: AttemptMode.exam,
    questionIds: [for (final q in t2.questions) q.id],
    answers: {for (final q in t2.questions.take(12)) q.id: q.answer},
    currentIndex: 12,
    startedAt: now - 600000,
    timeLimitSec: t2.minutes * 60,
    elapsedSec: 742,
    updatedAt: now,
  );
  await db.saveAttempt(running);
  for (final ch in ['あ', 'い', 'う', 'か', 'き']) {
    await db.saveWriting(ch, const WritingScore().record(ch == 'き' ? 58 : 86, now));
  }

  final state = AppState(
    content: content,
    db: db,
    prefs: prefs,
    tts: TtsService(),
    notifications: NotificationService(),
  );
  await state.init();
  state.tts.japaneseAvailable.value = true; // no TTS engine in tests
  state.allowTestsWithoutAccount = true;
  await StrokeRepository.load(_FileBundle());
  return state;
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
  final dir = _outDir;
  if (dir == null) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(dir).createSync(recursive: true);
    File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    await _loadFonts();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('main screens render (${mode.name})', (tester) async {
      tester.view.physicalSize = const Size(412 * 2, 892 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final state = (await tester.runAsync(() => _seededState(mode)))!;
      await tester.pumpWidget(
        RepaintBoundary(
          key: const ValueKey('shot'),
          child: ChangeNotifierProvider.value(value: state, child: const IemanihongoApp()),
        ),
      );
      final m = mode.name;

      await _shot(tester, '01-home-$m');
      expect(find.textContaining('days'), findsWidgets);

      await tester.tap(find.text("Start today's session"));
      await _shot(tester, '02-flashcard-front-$m');
      await tester.tap(find.text('Show answer'));
      await _shot(tester, '03-flashcard-back-$m');
      expect(find.text('Good'), findsOneWidget);
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('End session'));
      await tester.pumpAndSettle();

      await tester.tap(_nav('Practice'));
      await _shot(tester, '04-practice-$m');
      await tester.tap(find.text('Vocabulary quiz'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Meaning'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(InkWell).at(3));
      await _shot(tester, '05-quiz-answered-$m');
      await tester.tap(find.byTooltip('End quiz'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Writing practice'));
      await tester.pumpAndSettle();
      await _shot(tester, '06-writing-hub-$m');
      await tester.tap(find.text('あ').first);
      await tester.pumpAndSettle();
      await _shot(tester, '07-writing-guide-$m');
      await _trace(tester, 'あ');
      await tester.tap(find.text('Check'));
      await _shot(tester, '08-writing-checked-$m');
      expect(find.textContaining('Order 3/3'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Grammar lessons'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining("Today's lesson"));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(ChoiceChip).first, 200);
      await tester.tap(find.byType(ChoiceChip).first);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
      await _shot(tester, '09-grammar-lesson-$m');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      // JLPT: hub, resume a timed test, practice with explanation, review.
      await tester.tap(_nav('JLPT'));
      await _shot(tester, '10-jlpt-hub-$m');
      expect(find.textContaining('Đang làm 12/30'), findsOneWidget);
      await tester.tap(find.text('Làm tiếp').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(InkWell).at(4));
      await _shot(tester, '11-jlpt-exam-$m');
      expect(find.textContaining('Câu 13/30'), findsOneWidget);
      await tester.tap(find.byTooltip('Tạm dừng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu & thoát'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Ngữ pháp'), 300, scrollable: _hubList());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ngữ pháp'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(InkWell).at(4));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -260));
      await _shot(tester, '12-jlpt-practice-explained-$m');
      expect(find.text('Giải thích'), findsOneWidget);
      await tester.tap(find.byTooltip('Tạm dừng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu & thoát'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.widgetWithText(ListTile, 'N3 · Đề thi thử 1'), 300, scrollable: _hubList());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'N3 · Đề thi thử 1'));
      await tester.pumpAndSettle();
      await _shot(tester, '13-jlpt-result-$m');
      await tester.tap(find.text('Xem lại đáp án & giải thích'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Sai '));
      await _shot(tester, '14-jlpt-review-$m');
      await tester.tap(find.byType(Switch));
      await _shot(tester, '15-jlpt-review-hidden-$m');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Điểm yếu cần cải thiện'), -300, scrollable: _hubList());
      await tester.pumpAndSettle();
      await _shot(tester, '16-jlpt-weak-$m');

      await tester.tap(_nav('Progress'));
      await _shot(tester, '17-progress-$m');

      await tester.tap(_nav('Words'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '勉強');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, '勉強').first);
      await _shot(tester, '18-word-kanji-$m');

      // Let debounced timers finish before the test ends.
      await tester.pump(const Duration(seconds: 5));
      await tester.runAsync(() async {
        await state.flushWrites();
        await state.db.db.close();
      });
    });
  }
}
