import 'package:flutter/material.dart';

class HabitCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const HabitCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  static const List<HabitCategory> defaultCategories = [
    HabitCategory(
      id: 'fitness',
      name: 'Fitness',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFFF6B6B),
      description: 'Exercise, workouts & physical activity',
    ),
    HabitCategory(
      id: 'reading',
      name: 'Reading',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF4ECDC4),
      description: 'Books, articles & learning materials',
    ),
    HabitCategory(
      id: 'meditation',
      name: 'Meditation',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFFA88BEB),
      description: 'Mindfulness, breathing & mental peace',
    ),
    HabitCategory(
      id: 'study',
      name: 'Study',
      icon: Icons.school_rounded,
      color: Color(0xFFFFBE0B),
      description: 'Academics, courses & skill building',
    ),
    HabitCategory(
      id: 'water',
      name: 'Water Intake',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF3A86FF),
      description: 'Daily hydration & water tracking',
    ),
    HabitCategory(
      id: 'sleep',
      name: 'Sleep',
      icon: Icons.bedtime_rounded,
      color: Color(0xFF8338EC),
      description: 'Restful sleep & night routine',
    ),
    HabitCategory(
      id: 'coding',
      name: 'Coding',
      icon: Icons.code_rounded,
      color: Color(0xFF00F5D4),
      description: 'Programming, projects & problem solving',
    ),
    HabitCategory(
      id: 'finance',
      name: 'Finance',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF06D6A0),
      description: 'Budgeting, saving & financial discipline',
    ),
    HabitCategory(
      id: 'diet',
      name: 'Diet',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFB5607),
      description: 'Healthy meals & nutrition habits',
    ),
    HabitCategory(
      id: 'work',
      name: 'Work',
      icon: Icons.work_rounded,
      color: Color(0xFF4361EE),
      description: 'Productivity, career & deep work',
    ),
    HabitCategory(
      id: 'personal',
      name: 'Personal',
      icon: Icons.person_rounded,
      color: Color(0xFFFF006E),
      description: 'Self-care, hobbies & personal goals',
    ),
  ];

  static HabitCategory getById(String id) {
    return defaultCategories.firstWhere(
      (c) => c.id.toLowerCase() == id.toLowerCase(),
      orElse: () => defaultCategories.last,
    );
  }
}
