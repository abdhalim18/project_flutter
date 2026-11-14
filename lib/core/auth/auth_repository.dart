import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import 'profile.dart';
import 'role.dart';

/// Wraps backend login + the profile lookup, and caches the last known role
/// locally so route guards can check permissions without a live network call
/// (see plan section 5 — the cache is UX-only, the API's role checks are the
/// real security boundary).
class AuthRepository {
  AuthRepository({FlutterSecureStorage? secureStorage, ApiClient? client})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      _client = client ?? ApiClient.instance;

  static const _cachedRoleKey = 'cached_role';

  final FlutterSecureStorage _secureStorage;
  final ApiClient _client;

  Stream<AppSession?> get authStateChanges => _client.sessionChanges;

  AppSession? get currentSession => _client.session;

  /// Throws [ApiException] with a user-facing message when the credentials
  /// are rejected.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final json =
        await _client.post('/api/auth/login', {
              'email': email,
              'password': password,
            })
            as Map<String, dynamic>;
    final profile = Profile.fromMap(json['profile'] as Map<String, dynamic>);
    // Cache the role before publishing the session so the router's redirect
    // (triggered by the session change) already sees the right role.
    await _cacheRole(profile.role);
    await _client.setSession(
      AppSession(
        token: json['token'] as String,
        user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      ),
    );
  }

  Future<void> signOut() async {
    await _secureStorage.delete(key: _cachedRoleKey);
    await _client.setSession(null);
  }

  /// Fails fast (rather than hanging) when offline, so callers like the
  /// router's redirect — which must resolve before any screen can render —
  /// can fall back to the cached role instead of leaving the app stuck on a
  /// blank screen waiting for a network call that will never complete.
  Future<Profile?> fetchCurrentProfile() async {
    if (currentSession == null) return null;

    try {
      final json =
          await _client.get('/api/me').timeout(const Duration(seconds: 5))
              as Map<String, dynamic>;
      final row = json['profile'] as Map<String, dynamic>?;
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
