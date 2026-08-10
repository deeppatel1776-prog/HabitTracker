class HabitHistoryModel {
  final String id;
  final String habitId;
  final bool completed;
  final String status; // 'completed' or 'skipped'
  final DateTime completedAt;

  HabitHistoryModel({
    required this.id,
    required this.habitId,
    required this.completed,
    required this.status,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completed': completed,
      'status': status,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory HabitHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitHistoryModel(
      id: id,
      habitId: map['habitId'] ?? '',
      completed: map['completed'] ?? true,
      status: map['status'] ?? 'completed',
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
