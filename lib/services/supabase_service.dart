import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit_model.dart';
import '../models/habit_history_model.dart';
import '../models/user_model.dart';
import '../core/services/local_storage_service.dart';

class SupabaseService {
  final LocalStorageService _localStorage = LocalStorageService();

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isSupabaseAvailable => _client != null;

  // --- HABITS CRUD ---

  Future<List<HabitModel>> getHabits(String userId) async {
    final localHabits = await _localStorage.getHabits();
    if (localHabits.isNotEmpty) {
      return localHabits;
    }

    if (_client != null) {
      try {
        final response = await _client!
            .from('habits')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final habits = (response as List)
            .map((json) => HabitModel.fromMap(Map<String, dynamic>.from(json), json['id'] ?? ''))
            .toList();

        await _localStorage.saveHabits(habits);
        return habits;
      } catch (e) {
        debugPrint('Supabase getHabits error: $e');
      }
    }

    return [];
  }

  Future<void> saveHabit(String userId, HabitModel habit) async {
    final localHabits = await _localStorage.getHabits();
    final index = localHabits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      localHabits[index] = habit;
    } else {
      localHabits.add(habit);
    }
    await _localStorage.saveHabits(localHabits);

    if (_client != null) {
      try {
        final json = habit.toMap();
        json['user_id'] = userId;
        await _client!.from('habits').upsert(json);
      } catch (e) {
        debugPrint('Supabase saveHabit error: $e');
      }
    }
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    final localHabits = await _localStorage.getHabits();
    localHabits.removeWhere((h) => h.id == habitId);
    await _localStorage.saveHabits(localHabits);

    if (_client != null) {
      try {
        await _client!.from('habits').delete().eq('id', habitId);
      } catch (e) {
        debugPrint('Supabase deleteHabit error: $e');
      }
    }
  }

  // --- HISTORY LOGS ---

  Future<List<HabitHistoryModel>> getHistory(String userId) async {
    final localHistory = await _localStorage.getHistory();
    if (localHistory.isNotEmpty) {
      return localHistory;
    }

    if (_client != null) {
      try {
        final response = await _client!
            .from('habit_history')
            .select()
            .eq('user_id', userId)
            .order('date', ascending: false);

        final history = (response as List)
            .map((json) => HabitHistoryModel.fromMap(
                Map<String, dynamic>.from(json), json['id'] ?? ''))
            .toList();

        await _localStorage.saveHistory(history);
        return history;
      } catch (e) {
        debugPrint('Supabase getHistory error: $e');
      }
    }

    return [];
  }

  Future<void> saveHistory(String userId, HabitHistoryModel history) async {
    final currentHistory = await _localStorage.getHistory();
    currentHistory.removeWhere((h) => h.id == history.id);
    currentHistory.insert(0, history);
    await _localStorage.saveHistory(currentHistory);

    if (_client != null) {
      try {
        final json = history.toMap();
        json['user_id'] = userId;
        await _client!.from('habit_history').upsert(json);
      } catch (e) {
        debugPrint('Supabase saveHistory error: $e');
      }
    }
  }

  // --- USER PROFILE ---

  Future<void> saveUserProfile(UserModel user) async {
    await _localStorage.saveUser(user);

    if (_client != null) {
      try {
        await _client!.from('profiles').upsert({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'photo_url': user.photoUrl,
          'created_at': user.createdAt.toIso8601String(),
        }).timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('Supabase saveUserProfile error: $e');
      }
    }
  }

  Future<String?> uploadProfileImage(String userId, Uint8List imageBytes) async {
    if (_client != null) {
      try {
        final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _client!.storage.from('avatars').uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const FileOptions(upsert: true),
        ).timeout(const Duration(seconds: 4));
        final publicUrl = _client!.storage.from('avatars').getPublicUrl(fileName);
        return publicUrl;
      } catch (e) {
        debugPrint('Supabase storage upload error: $e');
      }
    }
    return null;
  }
}
