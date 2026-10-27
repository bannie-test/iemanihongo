import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_db.dart';

enum SyncStatus { guest, idle, syncing, offline, error }

/// Two-way sync between the local database and Supabase.
///
/// Push: rows marked dirty are upserted. Pull: rows changed on the server
/// since the last pull (by `synced_at`) are merged with last-write-wins on
/// `updated_at`. Realtime change events from other devices trigger a pull.
class SyncService {
  SyncService({
    required this.client,
    required this.db,
    required this.prefs,
    required this.localSettings,
    required this.onRemoteSettings,
    required this.onRemoteData,
  });

  final SupabaseClient client;
  final LocalDb db;
  final SharedPreferences prefs;

  /// Current settings JSON (with `updatedAt`), and a callback for newer
  /// settings arriving from the server.
  final Map<String, Object?> Function() localSettings;
  final void Function(Map<String, dynamic>) onRemoteSettings;
  final VoidCallback onRemoteData;

  final status = ValueNotifier<SyncStatus>(SyncStatus.guest);
  final lastSynced = ValueNotifier<DateTime?>(null);
  final lastError = ValueNotifier<String?>(null);

  RealtimeChannel? _channel;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _debounce;
  bool _running = false;
  bool _again = false;
  bool _online = true;

  String? get _uid => client.auth.currentUser?.id;

  Future<void> start() async {
    final initial = await Connectivity().checkConnectivity();
    _online = !initial.contains(ConnectivityResult.none) || initial.isEmpty;
    _connectivitySub = Connectivity().onConnectivityChanged.listen((r) {
      final online = !r.contains(ConnectivityResult.none);
      final cameBack = online && !_online;
      _online = online;
      if (_uid == null) return;
      if (!online) {
        status.value = SyncStatus.offline;
      } else if (cameBack) {
        schedule(immediate: true);
      }
    });
    final saved = prefs.getInt('last_synced_${_uid ?? ''}');
    if (saved != null) lastSynced.value = DateTime.fromMillisecondsSinceEpoch(saved);
    await onAuthChanged();
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _unsubscribe();
    _debounce?.cancel();
  }

  /// Call after sign-in / sign-out.
  Future<void> onAuthChanged() async {
    await _unsubscribe();
    if (_uid == null) {
      status.value = SyncStatus.guest;
      return;
    }
    final saved = prefs.getInt('last_synced_$_uid');
    lastSynced.value = saved == null ? null : DateTime.fromMillisecondsSinceEpoch(saved);
    _subscribe();
    await sync();
  }

  /// Queue a sync soon (coalesces bursts of local changes).
  void schedule({bool immediate = false}) {
    if (_uid == null) return;
    _debounce?.cancel();
    _debounce = Timer(immediate ? Duration.zero : const Duration(seconds: 4), sync);
  }

  Future<void> sync() async {
    if (_uid == null) {
      status.value = SyncStatus.guest;
      return;
    }
    if (!_online) {
      status.value = SyncStatus.offline;
      return;
    }
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    status.value = SyncStatus.syncing;
    try {
      do {
        _again = false;
        await _pushSettings();
        for (final t in LocalDb.syncTables.keys) {
          await _push(t);
        }
        var changed = await _pullSettings();
        for (final t in LocalDb.syncTables.keys) {
          changed = await _pull(t) || changed;
        }
        if (changed) onRemoteData();
      } while (_again);
      final now = DateTime.now();
      lastSynced.value = now;
      await prefs.setInt('last_synced_$_uid', now.millisecondsSinceEpoch);
      lastError.value = null;
      status.value = SyncStatus.idle;
    } catch (e) {
      debugPrint('Sync failed: $e');
      lastError.value = _describe(e);
      status.value = _isNetwork(e) ? SyncStatus.offline : SyncStatus.error;
    } finally {
      _running = false;
    }
  }

  // ---- push ----

  static const _boolColumns = {'deleted'};

  Future<void> _push(String table) async {
    final keys = LocalDb.syncTables[table]!;
    while (true) {
      final rows = await db.dirtyRows(table);
      if (rows.isEmpty) return;
      final payload = [
        for (final r in rows)
          {
            for (final e in r.entries)
              if (e.key != 'dirty') e.key: _boolColumns.contains(e.key) ? e.value == 1 : e.value,
            'user_id': _uid,
          },
      ];
      await client.from(table).upsert(payload, onConflict: ['user_id', ...keys].join(','));
      await db.markClean(table, rows);
      if (rows.length < 500) return;
    }
  }

  Future<void> _pushSettings() async {
    final s = localSettings();
    final at = (s['updatedAt'] as num?)?.toInt() ?? 0;
    final key = 'settings_pushed_$_uid';
    if (at == 0 || at <= (prefs.getInt(key) ?? 0)) return;
    await client.from('profiles').upsert({'user_id': _uid, 'settings': s, 'updated_at': at}, onConflict: 'user_id');
    await prefs.setInt(key, at);
  }

  // ---- pull ----

  Future<bool> _pull(String table) async {
    final cursorKey = 'cursor_${_uid}_$table';
    final cursor = prefs.getString(cursorKey) ?? '1970-01-01T00:00:00Z';
    var offset = 0, changed = false;
    String? maxSeen;
    const page = 1000;
    while (true) {
      final rows = await client
          .from(table)
          .select()
          .eq('user_id', _uid!)
          .gt('synced_at', cursor)
          .order('synced_at')
          .range(offset, offset + page - 1);
      if (rows.isEmpty) break;
      final local = [
        for (final r in rows)
          {
            for (final e in r.entries)
              if (e.key != 'user_id' && e.key != 'synced_at')
                e.key: _boolColumns.contains(e.key) ? ((e.value == true) ? 1 : 0) : e.value,
          },
      ];
      if (await db.mergeRemote(table, local) > 0) changed = true;
      maxSeen = rows.last['synced_at'] as String;
      if (rows.length < page) break;
      offset += page;
    }
    if (maxSeen != null) await prefs.setString(cursorKey, maxSeen);
    return changed;
  }

  Future<bool> _pullSettings() async {
    final row = await client.from('profiles').select().eq('user_id', _uid!).maybeSingle();
    if (row == null) return false;
    final remoteAt = (row['updated_at'] as num?)?.toInt() ?? 0;
    final localAt = (localSettings()['updatedAt'] as num?)?.toInt() ?? 0;
    if (remoteAt <= localAt) return false;
    onRemoteSettings(Map<String, dynamic>.from(row['settings'] as Map));
    await prefs.setInt('settings_pushed_$_uid', remoteAt);
    return true;
  }

  // ---- realtime ----

  void _subscribe() {
    final uid = _uid;
    if (uid == null) return;
    var channel = client.channel('sync-$uid');
    for (final table in ['profiles', ...LocalDb.syncTables.keys]) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: uid),
        callback: (_) => schedule(),
      );
    }
    _channel = channel..subscribe();
  }

  Future<void> _unsubscribe() async {
    final c = _channel;
    _channel = null;
    if (c != null) await client.removeChannel(c);
  }

  /// Forget pull cursors so the next sync downloads everything again.
  Future<void> resetCursors() async {
    for (final k in prefs.getKeys().where((k) => k.startsWith('cursor_') || k.startsWith('settings_pushed_'))) {
      await prefs.remove(k);
    }
  }

  static bool _isNetwork(Object e) {
    final s = e.toString();
    return s.contains('SocketException') || s.contains('ClientException') || s.contains('Failed host lookup');
  }

  static String _describe(Object e) {
    if (e is PostgrestException) {
      if (e.code == '42P01' || e.message.contains('does not exist')) {
        return 'Database tables are missing. Run supabase/schema.sql in your Supabase project.';
      }
      return e.message;
    }
    if (_isNetwork(e)) return 'No connection. Your progress is saved on this device.';
    return e.toString();
  }
}
