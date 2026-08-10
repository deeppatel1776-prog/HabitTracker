import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/habit_model.dart';
import '../../models/user_model.dart';
import '../../models/achievement_model.dart';
import '../../models/habit_history_model.dart';

class LocalStorageService {
  static const String _userKey = 'cached_user_profile';
  static const String _habitsKey = 'cached_habits_list';
  static const String _achievementsKey = 'cached_achievements_list';
  static const String _historyKey = 'cached_history_list';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return UserModel.fromMap(map, map['id'] ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final list = habits.map((h) => h.toMap()).toList();
    await prefs.setString(_habitsKey, jsonEncode(list));
  }

  Future<List<HabitModel>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_habitsKey);
    if (data == null) return [];
    try {
      final List rawList = jsonDecode(data);
      return rawList.map((item) {
        final map = Map<String, dynamic>.from(item);
        return HabitModel.fromMap(map, map['id'] ?? '');
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAchievements(List<AchievementModel> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final list = achievements.map((a) => a.toMap()).toList();
    await prefs.setString(_achievementsKey, jsonEncode(list));
  }

  Future<List<AchievementModel>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_achievementsKey);
    if (data == null) return AchievementModel.defaultAchievements;
    try {
      final List rawList = jsonDecode(data);
      final Map<String, Map<String, dynamic>> mapById = {};
      for (var item in rawList) {
        final m = Map<String, dynamic>.from(item);
        mapById[m['id']] = m;
      }
      return AchievementModel.defaultAchievements.map((def) {
        if (mapById.containsKey(def.id)) {
          final m = mapById[def.id]!;
          return def.copyWith(
            isUnlocked: m['isUnlocked'] ?? false,
            unlockedAt: m['unlockedAt'] != null
                ? DateTime.tryParse(m['unlockedAt'].toString())
                : null,
          );
        }
        return def;
      }).toList();
    } catch (_) {
      return AchievementModel.defaultAchievements;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setThemeModeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme_mode_index', index);
  }

  Future<int> getThemeModeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('app_theme_mode_index') ?? 0; // 0: light, 1: dark, 2: system
  }

  Future<void> saveHistory(List<HabitHistoryModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final list = history.map((h) => h.toMap()).toList();
    await prefs.setString(_historyKey, jsonEncode(list));
  }

  Future<List<HabitHistoryModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_historyKey);
    if (data == null) return [];
    try {
      final List rawList = jsonDecode(data);
      return rawList.map((item) {
        final map = Map<String, dynamic>.from(item);
        return HabitHistoryModel.fromMap(map, map['id'] ?? '');
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
