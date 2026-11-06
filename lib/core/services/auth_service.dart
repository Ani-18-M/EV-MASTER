import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool get isReady {
    if (SupabaseConfig.publishableKey == 'PLACEHOLDER_KEY' ||
        SupabaseConfig.publishableKey.isEmpty) {
      return false;
    }
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get _client =>
      isReady ? Supabase.instance.client : null;

  User? get currentUser => _client?.auth.currentUser;
  Session? get currentSession => _client?.auth.currentSession;
  bool get isAuthenticated => currentSession != null;
  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthException(
        'Supabase is not configured yet. Please supply your API key.',
      );
    }
    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase Auth error during sign-in: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during sign-in: $e');
      rethrow;
    }
  }

  /// Sign up with email, password, and optional user profile metadata (name, phone)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthException(
        'Supabase is not configured yet. Please supply your API key.',
      );
    }
    try {
      final data = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) {
        data['full_name'] = name.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        data['phone'] = phone.trim();
      }

      final response = await client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: data.isNotEmpty ? data : null,
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase Auth error during sign-up: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during sign-up: $e');
      rethrow;
    }
  }

  /// Sign out the current user session
  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('Error signing out: $e');
        rethrow;
      }
    }
  }
}
