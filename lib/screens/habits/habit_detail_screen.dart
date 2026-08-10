import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../models/habit_category.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/habit_timer_dialog.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitProvider);
    final habit = habitState.habits.firstWhere(
      (h) => h.id == widget.habitId,
      orElse: () => habitState.habits.first,
    );

    final categoryObj = HabitCategory.getById(habit.category);
    final habitColor = Color(habit.colorValue);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isCompletedToday = habit.completedDates.contains(todayStr);

    final totalCompleted = habit.completedDates.length;
    final totalSkipped = habit.skippedDates.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined, color: AppColors.primary),
            tooltip: 'Set Timer ⏱️',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => HabitTimerDialog(habit: habit),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/habit/edit/${habit.id}'),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'archive') {
                if (habit.isArchived) {
                  ref.read(habitProvider.notifier).restoreHabit(habit.id);
                } else {
                  ref.read(habitProvider.notifier).archiveHabit(habit.id);
                }
                context.pop();
              } else if (val == 'delete') {
                ref.read(habitProvider.notifier).deleteHabit(habit.id);
                context.pop();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'archive',
                child: Text(habit.isArchived ? 'Restore Habit' : 'Archive Habit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Habit', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: habitColor.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: habitColor.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: habitColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(categoryObj.icon, color: habitColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: habitColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            habit.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: habitColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          habit.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (habit.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            habit.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Today Toggle Action Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isCompletedToday
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCompletedToday ? AppColors.success : AppColors.primary,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompletedToday ? "Today's Status: Done! 🎉" : "Today's Status: Pending",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompletedToday ? AppColors.success : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompletedToday
                            ? "Keep up the momentum tomorrow!"
                            : "Tap button to mark complete for today.",
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompletedToday ? AppColors.success : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(habitProvider.notifier).toggleHabitCompletion(habit.id);
                    },
                    icon: Icon(isCompletedToday ? Icons.check_rounded : Icons.add_rounded),
                    label: Text(isCompletedToday ? 'Completed' : 'Mark Done'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Key Stats Grid
            Row(
              children: [
                Expanded(
                  child: StreakBadge(
                    streakCount: habit.currentStreak,
                    label: 'Current Streak',
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreakBadge(
                    streakCount: habit.longestStreak,
                    label: 'Best Streak',
                    icon: Icons.workspace_premium_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: StreakBadge(
                    streakCount: totalCompleted,
                    label: 'Total Completed',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreakBadge(
                    streakCount: totalSkipped,
                    label: 'Total Skipped',
                    icon: Icons.forward_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Completion Calendar History
            const Text(
              'Completion Calendar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final dayStr = DateFormat('yyyy-MM-dd').format(day);
                    final isDone = habit.completedDates.contains(dayStr);
                    final isSkip = habit.skippedDates.contains(dayStr);

                    if (isDone) {
                      return Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    if (isSkip) {
                      return Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),

            if (habit.notes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Notes & Motivation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.textMuted.withOpacity(0.15)),
                ),
                child: Text(
                  habit.notes,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
