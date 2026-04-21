class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;
  final String? groupId; // Optional binding to a group
  final String? type;
  final String? time;
  final String? repeat;
  final String? notes;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.isCompleted = false,
    this.groupId,
    this.type,
    this.time,
    this.repeat,
    this.notes,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: DateTime.parse(map['date'] as String? ?? DateTime.now().toIso8601String()),
      isCompleted: map['is_completed'] as bool? ?? false,
      groupId: map['group_id'] as String?,
      type: map['type'] as String?,
      time: map['time'] as String?,
      repeat: map['repeat'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'is_completed': isCompleted,
      'group_id': groupId,
      'type': type,
      'time': time,
      'repeat': repeat,
      'notes': notes,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isCompleted,
    String? groupId,
    String? type,
    String? time,
    String? repeat,
    String? notes,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      notes: notes ?? this.notes,
    );
  }
}
