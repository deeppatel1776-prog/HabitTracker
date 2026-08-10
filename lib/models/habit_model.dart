class HabitModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final int colorValue;
  final String frequency; // 'Daily', 'Weekly', 'Monthly'
  final String? reminderTime;
  final int targetCount;
  final bool completedToday;
  final int currentStreak;
  final int longestStreak;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;
  final List<String> completedDates; // Format: YYYY-MM-DD
  final List<String> skippedDates;   // Format: YYYY-MM-DD

  HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.colorValue,
    required this.frequency,
    this.reminderTime,
    this.targetCount = 1,
    this.completedToday = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
    this.completedDates = const [],
    this.skippedDates = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'colorValue': colorValue,
      'frequency': frequency,
      'reminderTime': reminderTime,
      'targetCount': targetCount,
      'completedToday': completedToday,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'completedDates': completedDates,
      'skippedDates': skippedDates,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Personal',
      icon: map['icon'] ?? 'star',
      colorValue: map['colorValue'] ?? 0xFF6C63FF,
      frequency: map['frequency'] ?? 'Daily',
      reminderTime: map['reminderTime'],
      targetCount: map['targetCount'] ?? 1,
      completedToday: map['completedToday'] ?? false,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      isArchived: map['isArchived'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      notes: map['notes'] ?? '',
      completedDates: List<String>.from(map['completedDates'] ?? []),
      skippedDates: List<String>.from(map['skippedDates'] ?? []),
    );
  }

  HabitModel copyWith({
    String? title,
    String? description,
    String? category,
    String? icon,
    int? colorValue,
    String? frequency,
    String? reminderTime,
    int? targetCount,
    bool? completedToday,
    int? currentStreak,
    int? longestStreak,
    bool? isArchived,
    DateTime? updatedAt,
    String? notes,
    List<String>? completedDates,
    List<String>? skippedDates,
  }) {
    return HabitModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      targetCount: targetCount ?? this.targetCount,
      completedToday: completedToday ?? this.completedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
      completedDates: completedDates ?? this.completedDates,
      skippedDates: skippedDates ?? this.skippedDates,
    );
  }
}
