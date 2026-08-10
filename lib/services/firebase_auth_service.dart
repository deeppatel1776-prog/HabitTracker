import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../core/services/local_storage_service.dart';
import 'supabase_service.dart';

class FirebaseAuthService {
  final LocalStorageService _localStorage = LocalStorageService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool get _isSupabaseAvailable {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  bool get isFirebaseAvailable {
    try {
      return fb.FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  Stream<UserModel?> get authStateChanges async* {
    final localUser = await _localStorage.getUser();
    if (_isSupabaseAvailable) {
      final suUser = Supabase.instance.client.auth.currentUser;
      if (suUser != null) {
        final name = suUser.userMetadata?['name'] ?? localUser?.name ?? suUser.email?.split('@').first ?? 'User';
        final photoUrl = suUser.userMetadata?['photo_url'] ?? suUser.userMetadata?['avatar_url'] ?? localUser?.photoUrl;
        yield UserModel(
          id: suUser.id,
          name: name,
          email: suUser.email ?? localUser?.email ?? '',
          photoUrl: photoUrl,
          createdAt: localUser?.createdAt ?? DateTime.now(),
        );
        return;
      }
    }
    yield localUser;
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    if (_isSupabaseAvailable) {
      try {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final suUser = res.user;
        if (suUser != null) {
          final user = UserModel(
            id: suUser.id,
            name: suUser.userMetadata?['name'] ?? email.split('@').first,
            email: email,
            createdAt: DateTime.now(),
          );
          await _localStorage.saveUser(user);
          await SupabaseService().saveUserProfile(user);
          return user;
        }
      } catch (e) {
        debugPrint('Supabase signInWithEmail error: $e');
      }
    }

    // Mock / Offline Auth Fallback
    final user = UserModel(
      id: 'user_${email.hashCode}',
      name: email.split('@').first.toUpperCase(),
      email: email,
      createdAt: DateTime.now(),
    );
    await _localStorage.saveUser(user);
    await SupabaseService().saveUserProfile(user);
    return user;
  }

  Future<UserModel> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    if (_isSupabaseAvailable) {
      try {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        );
        final suUser = res.user;
        if (suUser != null) {
          final user = UserModel(
            id: suUser.id,
            name: name,
            email: email,
            createdAt: DateTime.now(),
          );
          await _localStorage.saveUser(user);
          await SupabaseService().saveUserProfile(user);
          return user;
        }
      } catch (e) {
        debugPrint('Supabase signUpWithEmail error: $e');
      }
    }

    // Mock / Offline Auth Fallback
    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    await _localStorage.saveUser(user);
    await SupabaseService().saveUserProfile(user);
    return user;
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        if (_isSupabaseAvailable && googleAuth.idToken != null) {
          try {
            await Supabase.instance.client.auth.signInWithIdToken(
              provider: OAuthProvider.google,
              idToken: googleAuth.idToken!,
              accessToken: googleAuth.accessToken,
            );
          } catch (e) {
            debugPrint('Supabase idToken note: $e');
          }
        }

        final user = UserModel(
          id: googleUser.id,
          name: googleUser.displayName ?? 'Google User',
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
          createdAt: DateTime.now(),
        );
        await _localStorage.saveUser(user);
        await SupabaseService().saveUserProfile(user);
        return user;
      }
    } catch (e) {
      debugPrint('Google Sign-In note: $e');
    }

    // Fallback to local demo Google user
    final fallbackUser = UserModel(
      id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User',
      email: 'user.google@gmail.com',
      createdAt: DateTime.now(),
    );
    await _localStorage.saveUser(fallbackUser);
    await SupabaseService().saveUserProfile(fallbackUser);
    return fallbackUser;
  }

  Future<void> sendPasswordReset(String email) async {
    if (_isSupabaseAvailable) {
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(email);
      } catch (e) {
        debugPrint('Supabase resetPassword error: $e');
      }
    }
  }

  Future<void> signOut() async {
    if (_isSupabaseAvailable) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await _localStorage.clearUser();
  }
}
