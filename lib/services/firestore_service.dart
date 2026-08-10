import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../models/user_model.dart';
import '../models/habit_history_model.dart';
import '../models/achievement_model.dart';
import '../core/services/local_storage_service.dart';
import 'supabase_service.dart';

class FirestoreService {
  final LocalStorageService _localStorage = LocalStorageService();
  final SupabaseService _supabaseService = SupabaseService();

  // --- HABITS CRUD ---

  Future<List<HabitModel>> getHabits(String userId) async {
    if (_supabaseService.isSupabaseAvailable) {
      final habits = await _supabaseService.getHabits(userId);
      if (habits.isNotEmpty) {
        return habits;
      }
    }
    return await _localStorage.getHabits();
  }

  Future<void> saveHabit(String userId, HabitModel habit) async {
    if (_supabaseService.isSupabaseAvailable) {
      await _supabaseService.saveHabit(userId, habit);
    } else {
      final localHabits = await _localStorage.getHabits();
      final index = localHabits.indexWhere((h) => h.id == habit.id);
      if (index >= 0) {
        localHabits[index] = habit;
      } else {
        localHabits.add(habit);
      }
      await _localStorage.saveHabits(localHabits);
    }
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    if (_supabaseService.isSupabaseAvailable) {
      await _supabaseService.deleteHabit(userId, habitId);
    } else {
      final localHabits = await _localStorage.getHabits();
      localHabits.removeWhere((h) => h.id == habitId);
      await _localStorage.saveHabits(localHabits);
    }
  }

  // --- HISTORY LOGGING ---

  Future<void> logHabitHistory(String userId, HabitHistoryModel history) async {
    if (_supabaseService.isSupabaseAvailable) {
      await _supabaseService.saveHistory(userId, history);
    }
  }

  // --- ACHIEVEMENTS ---

  Future<List<AchievementModel>> getAchievements(String userId) async {
    return await _localStorage.getAchievements();
  }

  Future<void> saveAchievement(
    String userId,
    AchievementModel achievement,
  ) async {
    final localAchievements = await _localStorage.getAchievements();
    final index = localAchievements.indexWhere((a) => a.id == achievement.id);
    if (index >= 0) {
      localAchievements[index] = achievement;
    } else {
      localAchievements.add(achievement);
    }
    await _localStorage.saveAchievements(localAchievements);
  }

  // --- USER PROFILE ---

  Future<void> saveUserProfile(UserModel user) async {
    if (_supabaseService.isSupabaseAvailable) {
      await _supabaseService.saveUserProfile(user);
    } else {
      await _localStorage.saveUser(user);
    }
  }

  Future<String?> uploadProfileImage(
    String userId,
    Uint8List imageBytes, {
    String? localFilePath,
  }) async {
    if (_supabaseService.isSupabaseAvailable) {
      final uploadedUrl = await _supabaseService.uploadProfileImage(userId, imageBytes);
      if (uploadedUrl != null) return uploadedUrl;
    }
    return localFilePath;
  }
}
