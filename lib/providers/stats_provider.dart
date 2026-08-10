import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'habit_provider.dart';

class HabitStats {
  final double dailyCompletionPercentage;
  final int completedTodayCount;
  final int totalActiveHabits;
  final int currentMaxStreak;
  final int longestOverallStreak;
  final int totalCompletedSessions;
  final double consistencyPercentage;
  final List<double> weeklyData;   // 7 values (Mon - Sun)
  final List<double> monthlyData;  // 30 values
  final List<double> yearlyData;   // 12 values (Jan - Dec)

  HabitStats({
    required this.dailyCompletionPercentage,
    required this.completedTodayCount,
    required this.totalActiveHabits,
    required this.currentMaxStreak,
    required this.longestOverallStreak,
    required this.totalCompletedSessions,
    required this.consistencyPercentage,
    required this.weeklyData,
    required this.monthlyData,
    required this.yearlyData,
  });
}

final statsProvider = Provider<HabitStats>((ref) {
  final habitState = ref.watch(habitProvider);
  final activeHabits = habitState.habits.where((h) => !h.isArchived).toList();

  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  int completedToday = 0;
  int maxCurrentStreak = 0;
  int maxLongestStreak = 0;
  int totalCompletedSessions = 0;

  for (var h in activeHabits) {
    if (h.completedDates.contains(today)) {
      completedToday++;
    }
    if (h.currentStreak > maxCurrentStreak) maxCurrentStreak = h.currentStreak;
    if (h.longestStreak > maxLongestStreak) maxLongestStreak = h.longestStreak;
    totalCompletedSessions += h.completedDates.length;
  }

  final double dailyPercentage = activeHabits.isNotEmpty
      ? (completedToday / activeHabits.length) * 100
      : 0.0;

  // Weekly data (last 7 days Mon - Sun)
  final now = DateTime.now();
  final List<double> weeklyData = List.filled(7, 0.0);
  final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
  final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

  for (int i = 0; i < 7; i++) {
    final dayDate = startOfWeek.add(Duration(days: i));
    final dateStr = DateFormat('yyyy-MM-dd').format(dayDate);
    int dayCount = 0;
    for (var h in activeHabits) {
      if (h.completedDates.contains(dateStr)) {
        dayCount++;
      }
    }
    weeklyData[i] = dayCount.toDouble();
  }

  // Monthly data (last 30 days)
  final List<double> monthlyData = List.filled(30, 0.0);
  for (int i = 0; i < 30; i++) {
    final dayDate = now.subtract(Duration(days: 29 - i));
    final dateStr = DateFormat('yyyy-MM-dd').format(dayDate);
    int dayCount = 0;
    for (var h in activeHabits) {
      if (h.completedDates.contains(dateStr)) {
        dayCount++;
      }
    }
    monthlyData[i] = dayCount.toDouble();
  }

  // Yearly data (12 months of current year)
  final List<double> yearlyData = List.filled(12, 0.0);
  for (var h in activeHabits) {
    for (var dateStr in h.completedDates) {
      try {
        final d = DateFormat('yyyy-MM-dd').parse(dateStr);
        if (d.year == now.year && d.month >= 1 && d.month <= 12) {
          yearlyData[d.month - 1] += 1;
        }
      } catch (_) {}
    }
  }

  // Consistency calculation over last 30 days
  int possibleTotal = activeHabits.length * 30;
  int actualTotal = 0;
  for (int i = 0; i < 30; i++) {
    final dayDate = now.subtract(Duration(days: i));
    final dateStr = DateFormat('yyyy-MM-dd').format(dayDate);
    for (var h in activeHabits) {
      if (h.completedDates.contains(dateStr)) {
        actualTotal++;
      }
    }
  }
  final double consistency = possibleTotal > 0 ? (actualTotal / possibleTotal) * 100 : 0.0;

  return HabitStats(
    dailyCompletionPercentage: dailyPercentage,
    completedTodayCount: completedToday,
    totalActiveHabits: activeHabits.length,
    currentMaxStreak: maxCurrentStreak,
    longestOverallStreak: maxLongestStreak,
    totalCompletedSessions: totalCompletedSessions,
    consistencyPercentage: consistency,
    weeklyData: weeklyData,
    monthlyData: monthlyData,
    yearlyData: yearlyData,
  );
});
