/// نموذج سجل المسح بـ QR
class QrScanModel {
  final String id;
  final String studentId;
  final String studentName;
  final String actionType; // attendance | payment
  final double? amount; // فقط في حالة الدفع
  final String groupId;
  final String groupName;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm:ss
  final String createdDate;

  const QrScanModel({
    required this.id,
    required this.studentId,
    this.studentName = '',
    required this.actionType,
    this.amount,
    this.groupId = '',
    this.groupName = '',
    required this.date,
    required this.time,
    required this.createdDate,
  });

  factory QrScanModel.fromMap(Map<String, dynamic> map) {
    return QrScanModel(
      id: map['id'] as String,
      studentId: map['student_id'] as String? ?? '',
      studentName: map['student_name'] as String? ?? '',
      actionType: map['action_type'] as String? ?? 'attendance',
      amount: (map['amount'] as num?)?.toDouble(),
      groupId: map['group_id'] as String? ?? '',
      groupName: map['group_name'] as String? ?? '',
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      createdDate: map['created_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'action_type': actionType,
      'amount': amount,
      'group_id': groupId,
      'group_name': groupName,
      'date': date,
      'time': time,
      'created_date': createdDate,
    };
  }
}
