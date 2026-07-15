import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';
import 'profile.dart';
import 'role.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Refetched whenever auth state changes (login/logout/session refresh).
///
/// Deliberately checks `authRepository.currentSession` (updated synchronously
/// the moment sign-in resolves) rather than `authStateChangesProvider`'s
/// AsyncValue: the underlying `onAuthStateChange` stream event can arrive a
/// tick later, and reading it here raced with the router's redirect — a
/// fresh admin login could see a stale/absent stream value, fall through to
/// the `AppRole.kasir` default, and land the user on the wrong home screen.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateChangesProvider);
  final repository = ref.watch(authRepositoryProvider);
  if (repository.currentSession == null) return null;
  return repository.fetchCurrentProfile();
});

/// The role UI permission checks should use everywhere (route guards, admin
/// controls). Falls back to the cached role when the live profile fetch
/// returns null (offline) so admin controls don't silently disappear the
/// moment connectivity drops — matches the router's redirect fallback so the
/// route you land on and the controls you see never disagree.
final currentRoleProvider = FutureProvider<AppRole?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile != null) return profile.role;
  return ref.watch(authRepositoryProvider).getCachedRole();
});
