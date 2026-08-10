import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import '../models/habit_category.dart';
import '../providers/habit_provider.dart';
import '../core/constants/app_colors.dart';
import 'habit_timer_dialog.dart';

class HabitCard extends ConsumerWidget {
  final HabitModel habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isCompleted = habit.completedDates.contains(todayStr);
    final isSkipped = habit.skippedDates.contains(todayStr);

    final categoryObj = HabitCategory.getById(habit.category);
    final habitColor = Color(habit.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withOpacity(0.4)
              : AppColors.textMuted.withOpacity(0.12),
          width: isCompleted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? AppColors.success.withOpacity(0.08)
                : AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            context.push('/habit/detail/${habit.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: habitColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    categoryObj.icon,
                    color: habitColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: habitColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              habit.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: habitColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (habit.reminderTime != null) ...[
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              habit.reminderTime!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 15,
                            color: const Color(0xFFFF6B6B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${habit.currentStreak} streak",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            habit.frequency,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Complete Action Button & Menu
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(habitProvider.notifier).toggleHabitCompletion(habit.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.success
                              : isSkipped
                                  ? AppColors.textMuted.withOpacity(0.2)
                                  : AppColors.inputBackground,
                          boxShadow: isCompleted
                              ? [
                                  BoxShadow(
                                    color: AppColors.success.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : isSkipped
                                  ? Icons.forward_rounded
                                  : Icons.circle_outlined,
                          color: isCompleted
                              ? Colors.white
                              : isSkipped
                                  ? AppColors.textSecondary
                                  : AppColors.textMuted,
                          size: isCompleted ? 26 : 22,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.timer_outlined, color: AppColors.primary, size: 22),
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
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                      onSelected: (value) {
                        if (value == 'timer') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => HabitTimerDialog(habit: habit),
                          );
                        } else if (value == 'edit') {
                          context.push('/habit/edit/${habit.id}');
                        } else if (value == 'skip') {
                          ref.read(habitProvider.notifier).skipHabit(habit.id);
                        } else if (value == 'archive') {
                          if (habit.isArchived) {
                            ref.read(habitProvider.notifier).restoreHabit(habit.id);
                          } else {
                            ref.read(habitProvider.notifier).archiveHabit(habit.id);
                          }
                        } else if (value == 'delete') {
                          _confirmDelete(context, ref);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'timer',
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Set Timer ⏱️'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Habit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'skip',
                          child: Row(
                            children: [
                              const Icon(Icons.forward_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(isSkipped ? 'Unskip Today' : 'Skip Today'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(
                                habit.isArchived
                                    ? Icons.unarchive_outlined
                                    : Icons.archive_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(habit.isArchived ? 'Restore' : 'Archive'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.title}"? History will be removed.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              ref.read(habitProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
