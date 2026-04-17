class GradeModel {
  final String id;
  final String studentId;
  final String groupId;
  final String examName;
  final double score;
  final double maxScore;
  final String examDate;
  final String notes;

  GradeModel({
    required this.id,
    required this.studentId,
    required this.groupId,
    required this.examName,
    required this.score,
    required this.maxScore,
    required this.examDate,
    this.notes = '',
  });

  factory GradeModel.fromMap(Map<String, dynamic> map) {
    return GradeModel(
      id: map['id'] as String,
      studentId: map['student_id'] as String? ?? '',
      groupId: map['group_id'] as String? ?? '',
      examName: map['exam_name'] as String? ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (map['max_score'] as num?)?.toDouble() ?? 100.0,
      examDate: map['exam_date'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'group_id': groupId,
      'exam_name': examName,
      'score': score,
      'max_score': maxScore,
      'exam_date': examDate,
      'notes': notes,
    };
  }
}
