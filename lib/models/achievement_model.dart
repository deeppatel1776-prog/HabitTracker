import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  AchievementModel copyWith({
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  static List<AchievementModel> defaultAchievements = [
    AchievementModel(
      id: 'first_habit',
      title: 'First Habit',
      description: 'Create your very first habit',
      icon: Icons.star_rounded,
    ),
    AchievementModel(
      id: 'streak_7',
      title: '7-Day Streak',
      description: 'Maintain a habit for 7 consecutive days',
      icon: Icons.local_fire_department_rounded,
    ),
    AchievementModel(
      id: 'streak_30',
      title: '30-Day Streak',
      description: 'Maintain a habit for 30 consecutive days',
      icon: Icons.bolt_rounded,
    ),
    AchievementModel(
      id: 'streak_100',
      title: '100-Day Streak',
      description: 'Maintain a habit for 100 consecutive days',
      icon: Icons.workspace_premium_rounded,
    ),
    AchievementModel(
      id: 'streak_365',
      title: 'One-Year Streak',
      description: 'Maintain a habit for an entire year!',
      icon: Icons.military_tech_rounded,
    ),
    AchievementModel(
      id: 'completed_100',
      title: '100 Habits Completed',
      description: 'Complete 100 total habit sessions',
      icon: Icons.emoji_events_rounded,
    ),
    AchievementModel(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete a habit before 8:00 AM',
      icon: Icons.wb_sunny_rounded,
    ),
    AchievementModel(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Complete a habit after 9:00 PM',
      icon: Icons.nightlight_round,
    ),
  ];
}
