# Iemanihongo

A Flutter app for learning Japanese from JLPT N5 to N1, for Android and iOS.

- **Flashcards with spaced repetition.** Again / Hard / Good / Easy ratings schedule each word (SM-2 with learning steps). You set how many new words to learn per day.
- **8,034 vocabulary words** across N5–N1. Each one has audio, its reading and meaning, and a breakdown of its kanji (meanings, on/kun readings, stroke count, other words that use it).
- **Four quiz modes:** meaning, reverse (English → Japanese), reading (kanji → kana), and listening. If you miss a word you have already learned, it comes back for review.
- **Daily grammar lessons.** 99 lessons from N5 to N1, each with the pattern's formation, an explanation, example sentences with audio, and a quick-check question.
- **Streaks.** A day counts when you reach your daily goal. Every 7-day streak earns a freeze (you can hold up to 2), which is used automatically on a day you miss.
- **Progress dashboard.** Words learned, accuracy, items studied per day, JLPT coverage, and a study calendar.
- **Starred words and custom decks.** You can study or quiz any deck.
- **Reminders.** A daily reminder at a time you choose, plus a 9 PM nudge when your streak is at risk. Both are skipped once you've reached the day's goal, and both work offline.
- **Works offline.** All content is bundled with the app and progress is saved on the device first. When you're online it syncs to Supabase, and changes from your other devices arrive in real time.
- **JLPT N3 / N2 / N1 practice tests (Luyện thi JLPT).** Two timed mock tests per level in the 文字・語彙・文法 format: kanji reading, kanji writing, vocabulary in context, synonyms, grammar, and sentence building (★). Every question has a Vietnamese translation and an explanation of why the answer is right and why each other option is wrong.
  - Countdown timer, flag questions, a question grid, and pause/resume. Progress and the remaining time are saved, so you can continue a test on another device.
  - Practice by question type (untimed), with a **Show answers** switch for instant feedback.
  - **Review mode** with a show/hide-answers switch. You can also reveal each question on its own, which lets you re-test yourself.
  - **Weak-area tracking:** accuracy per question type, the grammar points and kanji traps you miss most, and one tap to practise your mistakes.
  - Attempts and answers are stored in your Supabase account, so this feature needs you to sign in. While offline, changes queue on the device and upload when you reconnect.
- **Writing practice** for hiragana, katakana, and N5–N1 kanji (2,141 characters). Trace over faint dashed stroke guides, watch an animation of the stroke order, or hide the guide and write from memory. Your writing is scored on shape, stroke count, stroke order, and stroke direction, and the best score per character syncs to Supabase.
- **Light and dark themes** in the Sakura style: Nunito for Latin/Vietnamese text, Zen Maru Gothic for Japanese, and Lucide icons.
- **Accounts.** Sign in with email and password, or continue as a guest and link an account later to sync.

## 1. One-time Supabase setup

1. Open your Supabase project → **SQL Editor** → **New query**.
2. Paste the contents of [`supabase/schema.sql`](supabase/schema.sql) and click **Run**. It is safe to run again after updates; for example, you need to re-run it once to add the JLPT test and writing tables.
   This creates the tables, the row-level security rules (each user can only see their own rows), and turns on realtime.
3. Optional: under **Authentication → Providers → Email**, turn off **Confirm email** if you want new accounts to sign in immediately while testing.

The project URL and anon key are in `lib/config.dart`. You can override them at build time with
`--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.

## 2. Get the APK

Every push runs the **Build APK** GitHub Actions workflow (`.github/workflows/build-apk.yml`). It analyzes and tests the code, builds a release APK, and publishes it:

- **Releases** page of the repository → newest `apk-N` pre-release → download `iemanihongo-N.apk`, or
- **Actions** tab → latest *Build APK* run → **Artifacts** → `iemanihongo-apk`.

To install: open the APK on your Android device and allow "Install unknown apps" for your browser or file manager.
The APK is signed with a debug key, which is fine for test devices. Set up a proper signing key before publishing to the Play Store.

### Audio

Pronunciation uses the phone's built-in text-to-speech, so it works offline and adds nothing to the app's size.
If you hear nothing, install a Japanese voice: Android **Settings → Accessibility → Text-to-speech → Speech Services by Google → Install voice data → Japanese**.
The app shows a hint when no Japanese voice is found.

## 3. Build locally

```bash
flutter pub get
flutter test
flutter run                  # device or emulator
flutter build apk --release  # Android
flutter build ipa            # iOS (macOS + Xcode, needs an Apple signing team)
```

To render screenshots of every main screen in both themes:

```bash
SCREENSHOT_DIR=build/screens flutter test test/app_screens_test.dart
```

## Project layout

```
lib/
  main.dart                 app start-up, chooses the auth / setup / main screen
  config.dart               Supabase URL + anon key
  theme.dart                Sakura light/dark design tokens
  models/                   Word, Kanji, Grammar, settings, daily stats, decks
  logic/                    SRS scheduler, streak rules, quiz builder (pure Dart, unit tested)
  data/                     bundled content loader, local SQLite store
  services/                 Supabase sync + realtime, notifications, text-to-speech
  state/app_state.dart      single ChangeNotifier the UI reads and writes through
  screens/                  Home, Flashcards, Words & decks, Practice (quiz, writing, grammar),
                            JLPT tests, Progress, Settings
assets/data/                vocab.json, kanji.json, grammar.json (generated)
tool/                       scripts that generate assets/data
supabase/schema.sql         database schema, RLS and realtime setup
```

### How sync works

Every change is written to SQLite first and marked *dirty*. The sync service pushes dirty rows with upserts and then pulls rows whose server-side `synced_at` is newer than the last pull. Conflicts resolve by last-write-wins on `updated_at`.
Daily statistics are stored as one row per device per day and added together in the app, so two devices studying offline on the same day never overwrite each other.
A Supabase Realtime subscription starts a pull whenever another device changes something.

### Regenerating content

```bash
# download n1.csv…n5.csv from jamsinclair/open-anki-jlpt-decks (src/) and
# kanji.json from davidluzgouveia/kanji-data into some folder, then:
python3 tool/build_content.py path/to/folder
python3 tool/build_grammar.py
python3 tool/build_tests.py                    # JLPT questions: tool/jlpt_n3.py, jlpt_n2.py, jlpt_n1.py
python3 tool/build_strokes.py path/to/kanjivg  # git clone https://github.com/KanjiVG/kanjivg
```

## Content credits

- Vocabulary: JLPT lists by Jonathan Waller ([tanos.co.uk](http://www.tanos.co.uk/jlpt/), CC BY), via [open-anki-jlpt-decks](https://github.com/jamsinclair/open-anki-jlpt-decks) (MIT).
- Kanji: [KANJIDIC2](https://www.edrdg.org/wiki/index.php/KANJIDIC_Project) © EDRDG, CC BY-SA 4.0, via [kanji-data](https://github.com/davidluzgouveia/kanji-data).
- Stroke order: [KanjiVG](https://kanjivg.tagaini.net/) © Ulrich Apel, CC BY-SA 3.0.
- Grammar lessons and JLPT practice questions (with Vietnamese explanations): written for this app.
- Fonts: [Nunito](https://fonts.google.com/specimen/Nunito) and [Zen Maru Gothic](https://fonts.google.com/specimen/Zen+Maru+Gothic), SIL Open Font License.
- Icons: [Lucide](https://lucide.dev/) (ISC license).
