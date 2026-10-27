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
- **Light and dark themes** in the Sakura style (Zen Maru Gothic font).
- **Accounts.** Sign in with email and password, or continue as a guest and link an account later to sync.

## 1. One-time Supabase setup

1. Open your Supabase project → **SQL Editor** → **New query**.
2. Paste the contents of [`supabase/schema.sql`](supabase/schema.sql) and click **Run**.
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
  screens/                  Home, Flashcards, Words & decks, Quiz, Grammar, Progress, Settings
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
```

## Content credits

- Vocabulary: JLPT lists by Jonathan Waller ([tanos.co.uk](http://www.tanos.co.uk/jlpt/), CC BY), via [open-anki-jlpt-decks](https://github.com/jamsinclair/open-anki-jlpt-decks) (MIT).
- Kanji: [KANJIDIC2](https://www.edrdg.org/wiki/index.php/KANJIDIC_Project) © EDRDG, CC BY-SA 4.0, via [kanji-data](https://github.com/davidluzgouveia/kanji-data).
- Grammar lessons: written for this app.
- Font: [Zen Maru Gothic](https://fonts.google.com/specimen/Zen+Maru+Gothic), SIL Open Font License.
