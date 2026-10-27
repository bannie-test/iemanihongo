/// Supabase project settings. Override at build time with
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
///
/// The anon key is designed to ship inside client apps; user data is
/// protected by the row-level security policies in supabase/schema.sql.
class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pvhksnqqpqilkqvwywaw.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2aGtzbnFxcHFpbGtxdnd5d2F3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMxMTUyNTUsImV4cCI6MjEwODY5MTI1NX0.AGX9m7iaCzSdg5-dc3oNTFMxghivmGo8QWwJ5PJgWcc',
  );
}
