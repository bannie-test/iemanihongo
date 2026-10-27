import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/content_repository.dart';
import '../data/local_db.dart';
import '../logic/srs.dart';
import '../logic/streak.dart';
import '../models/content.dart';
import '../models/settings.dart';
import '../models/user_data.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../services/tts_service.dart';

enum AuthPhase { signedOut, guest, signedIn }

/// Everything the UI reads and every change it makes goes through here.
/// Changes are written to the local database first (so the app works
/// offline) and then synced in the background.
class AppState extends ChangeNotifier with WidgetsBindingObserver {
  AppState({
    required this.content,
    required this.db,
    required this.prefs,
    required this.tts,
    required this.notifications,
    this.supabase,
  });

  final ContentRepository content;
  final LocalDb db;
  final SharedPreferences prefs;
  final TtsService tts;
  final NotificationService notifications;
  final SupabaseClient? supabase;
  SyncService? sync;

  late AppSettings settings;
  late String deviceId;
  final Map<String, CardState> cards = {};
  final List<DailyStat> _stats = [];
  final Map<String, Deck> decks = {};
  Map<String, Set<String>> deckWords = {};
  Map<String, int> grammarDone = {};
  StreakInfo streak = StreakInfo.empty;
  StreamSubscription<AuthState>? _authSub;
  Timer? _reminderDebounce;
  final Set<Future<void>> _pendingWrites = {};

  /// Local writes run in the background so the UI never waits on disk.
  void _write(Future<void> f) {
    _pendingWrites.add(f);
    f.whenComplete(() => _pendingWrites.remove(f));
  }

  /// Waits for queued local writes (before sync, sign-out and in tests).
  Future<void> flushWrites() => Future.wait(List.of(_pendingWrites));

  // ---------------------------------------------------------------- setup

  Future<void> init() async {
    deviceId = prefs.getString('device_id') ?? const Uuid().v4();
    await prefs.setString('device_id', deviceId);
    final raw = prefs.getString('settings');
    settings = raw == null ? const AppSettings() : AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    await _loadFromDb();
    await tts.init(settings.speechRate);

    final client = supabase;
    if (client != null) {
      sync = SyncService(
        client: client,
        db: db,
        prefs: prefs,
        localSettings: () => settings.toJson(),
        onRemoteSettings: (j) => _applySettings(AppSettings.fromJson(j), touch: false),
        onRemoteData: () async {
          await _loadFromDb();
          notifyListeners();
          _queueReminders();
        },
      );
      _authSub = client.auth.onAuthStateChange.listen((s) {
        if (s.event == AuthChangeEvent.signedIn || s.event == AuthChangeEvent.signedOut) {
          sync?.onAuthChanged();
          notifyListeners();
        }
      });
      unawaited(sync!.start());
    }
    WidgetsBinding.instance.addObserver(this);
    _queueReminders();
  }

  Future<void> _loadFromDb() async {
    cards
      ..clear()
      ..addEntries((await db.cards()).map((c) => MapEntry(c.wordId, c)));
    _stats
      ..clear()
      ..addAll(await db.dailyStats());
    decks
      ..clear()
      ..addEntries((await db.decks()).map((d) => MapEntry(d.id, d)));
    deckWords = await db.deckWords();
    grammarDone = await db.grammarDone();
    _recomputeStreak();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recomputeStreak();
      notifyListeners();
      sync?.schedule(immediate: true);
      _queueReminders();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    _reminderDebounce?.cancel();
    sync?.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------- auth

  User? get user => supabase?.auth.currentUser;

  AuthPhase get authPhase {
    if (user != null) return AuthPhase.signedIn;
    if (prefs.getBool('guest') ?? false) return AuthPhase.guest;
    return AuthPhase.signedOut;
  }

  bool get onboarded => prefs.getBool('onboarded') ?? false;

  Future<void> finishOnboarding() async {
    await prefs.setBool('onboarded', true);
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    await prefs.setBool('guest', true);
    notifyListeners();
  }

  /// Returns a message for the user when something needs their attention
  /// (e.g. confirm email), or null on success.
  Future<String?> signUp(String email, String password) async {
    final res = await supabase!.auth.signUp(email: email.trim(), password: password);
    if (res.session == null) {
      return 'Check your inbox to confirm your email, then sign in.';
    }
    await _afterSignIn();
    return null;
  }

  Future<void> signIn(String email, String password) async {
    await supabase!.auth.signInWithPassword(email: email.trim(), password: password);
    await _afterSignIn();
  }

  Future<void> _afterSignIn() async {
    // Anything studied as a guest is uploaded to the account.
    await prefs.setBool('guest', false);
    await sync?.resetCursors();
    await db.markAllDirty();
    await sync?.sync();
    // Settings pulled from an existing account mean setup was done before.
    if (settings.updatedAt > 0 && !onboarded) await prefs.setBool('onboarded', true);
    notifyListeners();
  }

  /// Uploads pending changes, then removes this account's data from the device.
  Future<void> signOut() async {
    await flushWrites();
    try {
      await sync?.sync();
    } catch (_) {}
    await supabase?.auth.signOut();
    await db.clearAll();
    await sync?.resetCursors();
    await prefs.remove('guest');
    await prefs.remove('onboarded');
    await _loadFromDb();
    notifyListeners();
  }

  // ------------------------------------------------------------- settings

  void updateSettings(AppSettings Function(AppSettings) change) {
    _applySettings(change(settings), touch: true);
  }

  void _applySettings(AppSettings next, {required bool touch}) {
    final prev = settings;
    settings = touch ? next.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch) : next;
    prefs.setString('settings', jsonEncode(settings.toJson()));
    if (prev.speechRate != settings.speechRate) tts.setRate(settings.speechRate);
    if (prev.dailyGoal != settings.dailyGoal) {
      _todayRow().goal = settings.dailyGoal;
      _saveToday();
    }
    _recomputeStreak();
    notifyListeners();
    _queueReminders();
    if (touch) sync?.schedule();
  }

  // ---------------------------------------------------------------- stats

  String get todayKey => dayKey(DateTime.now());

  DailyStat _todayRow() {
    final key = todayKey;
    for (final s in _stats) {
      if (s.day == key && s.deviceId == deviceId) return s;
    }
    final s = DailyStat(day: key, deviceId: deviceId, goal: settings.dailyGoal);
    _stats.add(s);
    return s;
  }

  void _saveToday() {
    final row = _todayRow()..updatedAt = DateTime.now().millisecondsSinceEpoch;
    _write(db.saveStat(row));
  }

  /// Per-day totals across all devices.
  Map<String, DailyStat> get days {
    final m = <String, DailyStat>{};
    for (final s in _stats) {
      final t = m.putIfAbsent(s.day, () => DailyStat(day: s.day, deviceId: '*', goal: s.goal));
      t
        ..reviews += s.reviews
        ..correct += s.correct
        ..newWords += s.newWords
        ..quizTotal += s.quizTotal
        ..quizCorrect += s.quizCorrect
        ..seconds += s.seconds;
      if (s.updatedAt >= t.updatedAt) {
        t
          ..goal = s.goal
          ..updatedAt = s.updatedAt;
      }
    }
    return m;
  }

  DailyStat get today => days[todayKey] ?? DailyStat(day: todayKey, deviceId: '*', goal: settings.dailyGoal);

  int get goalProgress => today.studied;
  bool get goalDone => streak.todayDone;

  void _recomputeStreak() {
    streak = StreakCalculator.compute(
      {for (final e in days.entries) e.key: DayTotal(e.value.studied, e.value.goal)},
      todayKey,
      settings.dailyGoal,
    );
  }

  void addStudyTime(Duration d) {
    if (d.inSeconds <= 0) return;
    _todayRow().seconds += d.inSeconds.clamp(0, 3 * 3600);
    _saveToday();
    sync?.schedule();
  }

  // ---------------------------------------------------------------- cards

  int get nowMs => DateTime.now().millisecondsSinceEpoch;

  List<Word> get dueWords {
    final now = nowMs;
    final due = cards.values.where((c) => c.isDue(now)).toList()..sort((a, b) => a.due.compareTo(b.due));
    return [for (final c in due) ?content.byId[c.wordId]];
  }

  int get newLeftToday => max(0, settings.newPerDay - today.newWords);

  /// Next unseen words from the chosen level, in frequency order.
  List<Word> nextNewWords(int count, {int? level}) {
    if (count <= 0) return const [];
    return content.byLevel[level ?? settings.level]!.where((w) => !cards.containsKey(w.id)).take(count).toList();
  }

  /// Due reviews first, then today's new words.
  List<Word> buildDailySession({int maxReviews = 100}) {
    final due = dueWords.take(maxReviews).toList();
    return [...due, ...nextNewWords(newLeftToday)];
  }

  CardState cardFor(String wordId) => cards[wordId] ?? CardState(wordId: wordId);

  int learnedCount(int level) =>
      content.byLevel[level]!.where((w) => cards[w.id]?.isLearned ?? false).length;

  int seenCount(int level) => content.byLevel[level]!.where((w) => cards.containsKey(w.id)).length;

  int get totalLearned => cards.values.where((c) => c.isLearned).length;

  CardState rate(String wordId, Rating rating) {
    final before = cardFor(wordId);
    final after = Srs.schedule(before, rating, nowMs);
    cards[wordId] = after;
    _write(db.saveCard(after));
    final t = _todayRow();
    t.reviews++;
    if (rating != Rating.again) t.correct++;
    if (before.phase == CardPhase.fresh) t.newWords++;
    _afterProgress();
    return after;
  }

  void recordQuizAnswer(String wordId, bool correct) {
    final t = _todayRow();
    t.quizTotal++;
    if (correct) t.quizCorrect++;
    // A missed word that is already in review comes back for review now.
    final c = cards[wordId];
    if (!correct && c != null && c.isLearned && c.due > nowMs) {
      final updated = c.copyWith(due: nowMs, updatedAt: nowMs);
      cards[wordId] = updated;
      _write(db.saveCard(updated));
    }
    _afterProgress();
  }

  void _afterProgress() {
    final wasDone = streak.todayDone;
    _saveToday();
    _recomputeStreak();
    notifyListeners();
    if (wasDone != streak.todayDone) _queueReminders();
    sync?.schedule();
  }

  // -------------------------------------------------------------- grammar

  List<GrammarPoint> grammarFor(int level) => content.grammar.where((g) => g.level == level).toList();

  /// The next unfinished lesson, starting at the chosen level.
  GrammarPoint? get todaysGrammar {
    final order = [settings.level, ...[5, 4, 3, 2, 1].where((l) => l != settings.level)];
    for (final l in order) {
      for (final g in grammarFor(l)) {
        if (!grammarDone.containsKey(g.id)) return g;
      }
    }
    return null;
  }

  int get grammarDayNumber => grammarDone.length + 1;

  void completeGrammar(String id) {
    if (grammarDone.containsKey(id)) return;
    final now = nowMs;
    grammarDone[id] = now;
    _write(db.saveGrammarDone(id, now));
    notifyListeners();
    sync?.schedule();
  }

  // ---------------------------------------------------------------- decks

  List<Deck> get visibleDecks {
    final list = decks.values.where((d) => !d.deleted && !d.isStarred).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return [starredDeck, ...list];
  }

  Deck get starredDeck => decks[Deck.starredId] ?? Deck(id: Deck.starredId, name: 'Starred');

  List<Word> wordsIn(String deckId) =>
      [for (final id in deckWords[deckId] ?? const <String>{}) ?content.byId[id]];

  bool inDeck(String deckId, String wordId) => deckWords[deckId]?.contains(wordId) ?? false;

  bool isStarred(String wordId) => inDeck(Deck.starredId, wordId);

  void setInDeck(String deckId, String wordId, bool present) {
    if (deckId == Deck.starredId && !decks.containsKey(deckId)) {
      final d = Deck(id: deckId, name: 'Starred', updatedAt: nowMs);
      decks[deckId] = d;
      _write(db.saveDeck(d));
    }
    final set = deckWords.putIfAbsent(deckId, () => {});
    present ? set.add(wordId) : set.remove(wordId);
    _write(db.setDeckWord(deckId, wordId, present, nowMs));
    notifyListeners();
    sync?.schedule();
  }

  void toggleStar(String wordId) => setInDeck(Deck.starredId, wordId, !isStarred(wordId));

  Deck createDeck(String name) {
    final d = Deck(id: const Uuid().v4(), name: name.trim(), updatedAt: nowMs);
    decks[d.id] = d;
    _write(db.saveDeck(d));
    notifyListeners();
    sync?.schedule();
    return d;
  }

  void renameDeck(Deck d, String name) {
    d
      ..name = name.trim()
      ..updatedAt = nowMs;
    _write(db.saveDeck(d));
    notifyListeners();
    sync?.schedule();
  }

  void deleteDeck(Deck d) {
    d
      ..deleted = true
      ..updatedAt = nowMs;
    _write(db.saveDeck(d));
    notifyListeners();
    sync?.schedule();
  }

  // ------------------------------------------------------------ reminders

  void _queueReminders() {
    _reminderDebounce?.cancel();
    _reminderDebounce = Timer(const Duration(milliseconds: 800), () {
      notifications.reschedule(
        enabled: settings.remindersOn,
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
        nudge: settings.streakNudge,
        goalDoneToday: streak.todayDone,
        streak: streak.current,
        dueCount: dueWords.length,
      );
    });
  }
}
