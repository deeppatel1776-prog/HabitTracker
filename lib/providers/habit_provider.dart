import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import '../models/habit_history_model.dart';
import '../models/achievement_model.dart';
import '../services/firestore_service.dart';
import '../core/services/notification_service.dart';
import 'auth_provider.dart';
import 'filter_provider.dart';

class HabitState {
  final List<HabitModel> habits;
  final List<AchievementModel> achievements;
  final bool isLoading;
  final String? errorMessage;
  final AchievementModel? newlyUnlockedAchievement;

  HabitState({
    this.habits = const [],
    this.achievements = const [],
    this.isLoading = false,
    this.errorMessage,
    this.newlyUnlockedAchievement,
  });

  HabitState copyWith({
    List<HabitModel>? habits,
    List<AchievementModel>? achievements,
    bool? isLoading,
    String? errorMessage,
    AchievementModel? newlyUnlockedAchievement,
    bool clearUnlocked = false,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      newlyUnlockedAchievement: clearUnlocked
          ? null
          : (newlyUnlockedAchievement ?? this.newlyUnlockedAchievement),
    );
  }
}

class HabitNotifier extends StateNotifier<HabitState> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _userId;
  final Uuid _uuid = const Uuid();

  HabitNotifier(this._userId) : super(HabitState()) {
    loadData();
  }

  String get _todayDateStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      var habits = await _firestoreService.getHabits(_userId);
      var achievements = await _firestoreService.getAchievements(_userId);

      if (habits.isEmpty) {
        habits = _getInitialDefaultHabits();
        for (var h in habits) {
          await _firestoreService.saveHabit(_userId, h);
        }
      }

      state = state.copyWith(
        habits: habits,
        achievements: achievements,
        isLoading: false,
      );

      _syncNotifications(habits);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  List<HabitModel> _getInitialDefaultHabits() {
    final now = DateTime.now();
    return [
      HabitModel(
        id: _uuid.v4(),
        title: 'Morning Meditation',
        description: '10 minutes of mindfulness & breathing',
        category: 'Meditation',
        icon: 'self_improvement',
        colorValue: 0xFFA88BEB,
        frequency: 'Daily',
        reminderTime: '07:30 AM',
        targetCount: 1,
        completedToday: true,
        currentStreak: 5,
        longestStreak: 12,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
        notes: 'Feel calm and centered afterwards.',
        completedDates: [_todayDateStr],
      ),
      HabitModel(
        id: _uuid.v4(),
        title: 'Read 20 Pages',
        description: 'Read non-fiction book or tech articles',
        category: 'Reading',
        icon: 'menu_book',
        colorValue: 0xFF4ECDC4,
        frequency: 'Daily',
        reminderTime: '09:00 PM',
        targetCount: 1,
        completedToday: false,
        currentStreak: 8,
        longestStreak: 14,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
        notes: 'Currently reading Atomic Habits.',
        completedDates: [],
      ),
      HabitModel(
        id: _uuid.v4(),
        title: 'Hydrate 2.5 Liters',
        description: 'Drink water throughout the day',
        category: 'Water Intake',
        icon: 'water_drop',
        colorValue: 0xFF3A86FF,
        frequency: 'Daily',
        reminderTime: '10:00 AM',
        targetCount: 8,
        completedToday: true,
        currentStreak: 3,
        longestStreak: 7,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
        notes: 'Track glass by glass.',
        completedDates: [_todayDateStr],
      ),
      HabitModel(
        id: _uuid.v4(),
        title: '30-Minute Workout',
        description: 'Gym, cardio, or HIIT session',
        category: 'Fitness',
        icon: 'fitness_center',
        colorValue: 0xFFFF6B6B,
        frequency: 'Daily',
        reminderTime: '06:00 PM',
        targetCount: 1,
        completedToday: false,
        currentStreak: 2,
        longestStreak: 10,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        notes: 'Focus on strength training.',
        completedDates: [],
      ),
    ];
  }

  Future<void> addHabit({
    required String title,
    required String description,
    required String category,
    required String icon,
    required int colorValue,
    required String frequency,
    String? reminderTime,
    int targetCount = 1,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final newHabit = HabitModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      icon: icon,
      colorValue: colorValue,
      frequency: frequency,
      reminderTime: reminderTime,
      targetCount: targetCount,
      createdAt: now,
      updatedAt: now,
      notes: notes,
    );

    final updatedHabits = [...state.habits, newHabit];
    state = state.copyWith(habits: updatedHabits);
    await _firestoreService.saveHabit(_userId, newHabit);

    if (newHabit.reminderTime != null) {
      final notificationService = NotificationService();
      final parsedTime = notificationService.parseReminderTime(newHabit.reminderTime);
      if (parsedTime != null) {
        await notificationService.scheduleHabitReminder(
          habitId: newHabit.id,
          habitTitle: newHabit.title,
          time: parsedTime,
        );
      }
    }
    NotificationService().syncUncompletedTasksReminder(updatedHabits);

    _checkAchievements();
  }

  Future<void> updateHabit(HabitModel updatedHabit) async {
    final updatedHabits = state.habits.map((h) {
      return h.id == updatedHabit.id ? updatedHabit : h;
    }).toList();

    state = state.copyWith(habits: updatedHabits);
    await _firestoreService.saveHabit(_userId, updatedHabit);

    final notificationService = NotificationService();
    if (updatedHabit.reminderTime != null) {
      final parsedTime = notificationService.parseReminderTime(updatedHabit.reminderTime);
      if (parsedTime != null) {
        await notificationService.scheduleHabitReminder(
          habitId: updatedHabit.id,
          habitTitle: updatedHabit.title,
          time: parsedTime,
        );
      }
    } else {
      await notificationService.cancelHabitReminder(updatedHabit.id);
    }
    notificationService.syncUncompletedTasksReminder(updatedHabits);
  }

  Future<void> deleteHabit(String habitId) async {
    final updatedHabits = state.habits.where((h) => h.id != habitId).toList();
    state = state.copyWith(habits: updatedHabits);
    await _firestoreService.deleteHabit(_userId, habitId);

    NotificationService().cancelHabitReminder(habitId);
    NotificationService().syncUncompletedTasksReminder(updatedHabits);
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    final today = _todayDateStr;
    final now = DateTime.now();

    final habitIndex = state.habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = state.habits[habitIndex];
    final isCurrentlyCompleted = habit.completedDates.contains(today);

    List<String> newCompletedDates = List.from(habit.completedDates);
    int newStreak = habit.currentStreak;
    int newLongest = habit.longestStreak;

    if (isCurrentlyCompleted) {
      newCompletedDates.remove(today);
      newStreak = (newStreak - 1).clamp(0, 9999);
    } else {
      newCompletedDates.add(today);
      newStreak += 1;
      if (newStreak > newLongest) {
        newLongest = newStreak;
      }
    }

    final updatedHabit = habit.copyWith(
      completedToday: !isCurrentlyCompleted,
      currentStreak: newStreak,
      longestStreak: newLongest,
      completedDates: newCompletedDates,
      updatedAt: now,
    );

    final updatedHabits = List<HabitModel>.from(state.habits);
    updatedHabits[habitIndex] = updatedHabit;
    state = state.copyWith(habits: updatedHabits);

    await _firestoreService.saveHabit(_userId, updatedHabit);

    final history = HabitHistoryModel(
      id: _uuid.v4(),
      habitId: habitId,
      completed: !isCurrentlyCompleted,
      status: !isCurrentlyCompleted ? 'completed' : 'uncompleted',
      completedAt: now,
    );
    await _firestoreService.logHabitHistory(_userId, history);

    if (!isCurrentlyCompleted) {
      NotificationService().showCompletionNotification(updatedHabit.title, newStreak);
    }
    NotificationService().syncUncompletedTasksReminder(updatedHabits);

    _checkAchievements();
  }

  void _syncNotifications(List<HabitModel> habits) async {
    final notificationService = NotificationService();
    for (var h in habits) {
      if (h.reminderTime != null && !h.isArchived) {
        final parsedTime = notificationService.parseReminderTime(h.reminderTime);
        if (parsedTime != null) {
          await notificationService.scheduleHabitReminder(
            habitId: h.id,
            habitTitle: h.title,
            time: parsedTime,
          );
        }
      }
    }
    await notificationService.syncUncompletedTasksReminder(habits);
  }

  Future<void> skipHabit(String habitId) async {
    final today = _todayDateStr;
    final habitIndex = state.habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = state.habits[habitIndex];
    List<String> newSkipped = List.from(habit.skippedDates);
    if (!newSkipped.contains(today)) {
      newSkipped.add(today);
    }

    final updatedHabit = habit.copyWith(
      skippedDates: newSkipped,
      updatedAt: DateTime.now(),
    );

    final updatedHabits = List<HabitModel>.from(state.habits);
    updatedHabits[habitIndex] = updatedHabit;
    state = state.copyWith(habits: updatedHabits);

    await _firestoreService.saveHabit(_userId, updatedHabit);
  }

  Future<void> archiveHabit(String habitId) async {
    final habitIndex = state.habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final updatedHabit = state.habits[habitIndex].copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );

    final updatedHabits = List<HabitModel>.from(state.habits);
    updatedHabits[habitIndex] = updatedHabit;
    state = state.copyWith(habits: updatedHabits);

    await _firestoreService.saveHabit(_userId, updatedHabit);
  }

  Future<void> restoreHabit(String habitId) async {
    final habitIndex = state.habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final updatedHabit = state.habits[habitIndex].copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    );

    final updatedHabits = List<HabitModel>.from(state.habits);
    updatedHabits[habitIndex] = updatedHabit;
    state = state.copyWith(habits: updatedHabits);

    await _firestoreService.saveHabit(_userId, updatedHabit);
  }

  void dismissUnlockedAchievement() {
    state = state.copyWith(clearUnlocked: true);
  }

  void _checkAchievements() {
    if (state.habits.isEmpty) return;

    final totalCompleted = state.habits.fold<int>(
      0,
      (sum, h) => sum + h.completedDates.length,
    );

    final maxStreak = state.habits.fold<int>(
      0,
      (maxS, h) => h.currentStreak > maxS ? h.currentStreak : maxS,
    );

    final nowHour = DateTime.now().hour;
    AchievementModel? newlyUnlocked;

    final updatedAchievements = state.achievements.map((a) {
      if (a.isUnlocked) return a;

      bool shouldUnlock = false;
      if (a.id == 'first_habit' && state.habits.isNotEmpty) shouldUnlock = true;
      if (a.id == 'streak_7' && maxStreak >= 7) shouldUnlock = true;
      if (a.id == 'streak_30' && maxStreak >= 30) shouldUnlock = true;
      if (a.id == 'streak_100' && maxStreak >= 100) shouldUnlock = true;
      if (a.id == 'streak_365' && maxStreak >= 365) shouldUnlock = true;
      if (a.id == 'completed_100' && totalCompleted >= 100) shouldUnlock = true;
      if (a.id == 'early_bird' && nowHour < 8 && totalCompleted > 0) shouldUnlock = true;
      if (a.id == 'night_owl' && nowHour >= 21 && totalCompleted > 0) shouldUnlock = true;

      if (shouldUnlock) {
        final unlocked = a.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
        newlyUnlocked = unlocked;
        _firestoreService.saveAchievement(_userId, unlocked);
        return unlocked;
      }
      return a;
    }).toList();

    state = state.copyWith(
      achievements: updatedAchievements,
      newlyUnlockedAchievement: newlyUnlocked,
    );
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id ?? 'guest_user';
  return HabitNotifier(userId);
});

final filteredHabitsProvider = Provider<List<HabitModel>>((ref) {
  final habitState = ref.watch(habitProvider);
  final filterState = ref.watch(habitFilterProvider);

  var habits = habitState.habits;

  // Filter status
  if (filterState.filterStatus == HabitFilterStatus.active) {
    habits = habits.where((h) => !h.isArchived).toList();
  } else if (filterState.filterStatus == HabitFilterStatus.completed) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    habits = habits.where((h) => !h.isArchived && h.completedDates.contains(today)).toList();
  } else if (filterState.filterStatus == HabitFilterStatus.archived) {
    habits = habits.where((h) => h.isArchived).toList();
  }

  // Category filter
  if (filterState.selectedCategory != null) {
    habits = habits
        .where((h) =>
            h.category.toLowerCase() == filterState.selectedCategory!.toLowerCase())
        .toList();
  }

  // Search query
  if (filterState.searchQuery.isNotEmpty) {
    final query = filterState.searchQuery.toLowerCase();
    habits = habits.where((h) {
      return h.title.toLowerCase().contains(query) ||
          h.description.toLowerCase().contains(query) ||
          h.notes.toLowerCase().contains(query);
    }).toList();
  }

  // Sorting
  switch (filterState.sortOption) {
    case HabitSortOption.newest:
      habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case HabitSortOption.oldest:
      habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case HabitSortOption.streak:
      habits.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
      break;
    case HabitSortOption.name:
      habits.sort((a, b) => a.title.compareTo(b.title));
      break;
  }

  return habits;
});
