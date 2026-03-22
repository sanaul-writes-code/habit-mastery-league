class HabitLog {
  final int? id;
  final int habitId;
  final DateTime completedDate;
  final bool status;
  final DateTime createdAt;

  HabitLog({
    this.id,
    required this.habitId,
    required this.completedDate,
    this.status = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'completed_date': completedDate.toIso8601String(),
      'status': status ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      completedDate: DateTime.parse(map['completed_date'] as String),
      status: (map['status'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? completedDate,
    bool? status,
    DateTime? createdAt,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedDate: completedDate ?? this.completedDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
