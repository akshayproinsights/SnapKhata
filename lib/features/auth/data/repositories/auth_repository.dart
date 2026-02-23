// lib/features/auth/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart';

/// Wraps Supabase auth calls. Returns [AppUser] or throws typed errors.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Returns current logged-in user or null.
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _toAppUser(user);
  }

  /// Listen to auth state changes.
  Stream<AppUser?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        return user != null ? _toAppUser(user) : null;
      });

  /// Sign in with email + password.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Sign-in failed');
    return _toAppUser(response.user!);
  }

  /// Register a new user.
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Sign-up failed');
    return _toAppUser(response.user!);
  }

  /// Sign out and clear local session.
  Future<void> signOut() => _client.auth.signOut();

  AppUser _toAppUser(User user) => AppUser(
        id: user.id,
        email: user.email ?? '',
        phone: user.phone,
      );
}
