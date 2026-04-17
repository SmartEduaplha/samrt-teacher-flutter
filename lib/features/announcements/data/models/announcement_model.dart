import 'package:cloud_firestore/cloud_firestore.dart';

enum AnnouncementPriority {
  low,
  medium,
  high,
}

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final AnnouncementPriority priority;
  final String? groupId;
  final String? groupName;
  final DateTime createdAt;
  final String? authorId;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    this.groupId,
    this.groupName,
    required this.createdAt,
    this.authorId,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      priority: _priorityFromString(map['priority'] as String? ?? 'low'),
      groupId: map['group_id'] as String?,
      groupName: map['group_name'] as String?,
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authorId: map['author_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'priority': priority.name,
      'group_id': groupId,
      'group_name': groupName,
      'created_at': Timestamp.fromDate(createdAt),
      'author_id': authorId,
    };
  }

  static AnnouncementPriority _priorityFromString(String priority) {
    return AnnouncementPriority.values.firstWhere(
      (e) => e.name == priority,
      orElse: () => AnnouncementPriority.low,
    );
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    AnnouncementPriority? priority,
    String? groupId,
    String? groupName,
    DateTime? createdAt,
    String? authorId,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
    );
  }
}
