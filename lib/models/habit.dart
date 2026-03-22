class Habit {
  final int? id;
  final String name;
  final String description;
  final String category;
  final String targetFrequency;
  final DateTime createdAt;
  final bool isArchived;

  Habit({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.targetFrequency,
    required this.createdAt,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'target_frequency': targetFrequency,
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      targetFrequency: map['target_frequency'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? targetFrequency,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
