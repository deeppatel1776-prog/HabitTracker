import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.user, this.isLoading = false, this.errorMessage});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthNotifier() : super(AuthState()) {
    _init();
  }

  void _init() async {
    state = state.copyWith(isLoading: true);
    try {
      _authService.authStateChanges.listen((user) {
        if (user != null) {
          state = AuthState(user: user, isLoading: false);
        } else {
          state = AuthState(user: null, isLoading: false);
        }
      });
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.signInWithEmail(email, password);
      await _firestoreService.saveUserProfile(user);
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.signUpWithEmail(name, email, password);
      await _firestoreService.saveUserProfile(user);
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.signInWithGoogle();
      await _firestoreService.saveUserProfile(user);
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<String?> uploadProfileImage(
    String userId,
    Uint8List imageBytes, {
    String? localFilePath,
  }) async {
    return await _firestoreService.uploadProfileImage(
      userId,
      imageBytes,
      localFilePath: localFilePath,
    );
  }

  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    if (state.user == null) {
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedUser = state.user!.copyWith(name: name, photoUrl: photoUrl);

      if (_authService.isFirebaseAvailable) {
        try {
          final fbUser = fb.FirebaseAuth.instance.currentUser;
          if (fbUser != null) {
            if (name != null) {
              await fbUser.updateDisplayName(name);
            }
            if (photoUrl != null && photoUrl.startsWith('http')) {
              await fbUser.updatePhotoURL(photoUrl);
            }
          }
        } catch (e) {
          // Ignore uninitialized Firebase errors
        }
      }

      try {
        final client = Supabase.instance.client;
        if (client.auth.currentUser != null) {
          final data = <String, dynamic>{};
          if (name != null) data['name'] = name;
          if (photoUrl != null) {
            data['photo_url'] = photoUrl;
            data['avatar_url'] = photoUrl;
          }
          await client.auth
              .updateUser(UserAttributes(data: data))
              .timeout(const Duration(seconds: 4));
        }
      } catch (_) {}

      await _firestoreService.saveUserProfile(updatedUser);
      state = AuthState(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.sendPasswordReset(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = AuthState(user: null, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
