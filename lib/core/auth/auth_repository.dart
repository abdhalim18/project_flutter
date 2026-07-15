import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';
import 'profile.dart';
import 'role.dart';

/// Wraps Supabase Auth + the `profiles` table lookup, and caches the last
/// known role locally so route guards can check permissions without a live
/// network call (see plan section 5 — the cache is UX-only, RLS on the
/// server is the real security boundary).
class AuthRepository {
  AuthRepository({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _cachedRoleKey = 'cached_role';

  final FlutterSecureStorage _secureStorage;

  SupabaseClient get _client => AppSupabase.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    final profile = await fetchCurrentProfile();
    if (profile != null) {
      await _cacheRole(profile.role);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await _secureStorage.delete(key: _cachedRoleKey);
  }

  /// Fails fast (rather than hanging) when offline, so callers like the
  /// router's redirect — which must resolve before any screen can render —
  /// can fall back to the cached role instead of leaving the app stuck on a
  /// blank screen waiting for a network call that will never complete.
  Future<Profile?> fetchCurrentProfile() async {
    final userId = currentSession?.user.id;
    if (userId == null) return null;

    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));
      if (row == null) return null;

      final profile = Profile.fromMap(row);
      await _cacheRole(profile.role);
      return profile;
    } on Object {
      return null;
    }
  }

  Future<AppRole?> getCachedRole() async {
    final value = await _secureStorage.read(key: _cachedRoleKey);
    return value == null ? null : AppRole.fromDb(value);
  }

  Future<void> _cacheRole(AppRole role) {
    return _secureStorage.write(key: _cachedRoleKey, value: role.name);
  }
}
