/// نموذج سجل الحضور (AttendanceRecord)
class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String groupId;
  final String groupName;
  final String date; // yyyy-MM-dd
  final String status; // present | absent | excused
  final String notes;
  final String createdDate;
  final String updatedDate;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    this.studentName = '',
    this.groupId = '',
    this.groupName = '',
    required this.date,
    this.status = 'present',
    this.notes = '',
    required this.createdDate,
    required this.updatedDate,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      studentId: map['student_id'] as String? ?? '',
      studentName: map['student_name'] as String? ?? '',
      groupId: map['group_id'] as String? ?? '',
      groupName: map['group_name'] as String? ?? '',
      date: map['date'] as String? ?? '',
      status: map['status'] as String? ?? 'present',
      notes: map['notes'] as String? ?? '',
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'group_id': groupId,
      'group_name': groupName,
      'date': date,
      'status': status,
      'notes': notes,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }
}

/// حالات الحضور
enum AttendanceStatus {
  present('present', 'حاضر'),
  absent('absent', 'غائب'),
  excused('excused', 'غياب بعذر');

  final String value;
  final String label;
  const AttendanceStatus(this.value, this.label);

  static AttendanceStatus fromValue(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttendanceStatus.present,
    );
  }
}
