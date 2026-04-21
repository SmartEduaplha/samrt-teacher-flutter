/// نموذج المجموعة (Group)
class GroupModel {
  final String id;
  final String name;
  final String type; // center | privateGroup | privateLesson | online
  final String subject;
  final String academicYear;
  final double defaultMonthlyPrice;
  final double groupMonthlyDiscount;
  final List<ScheduleSlot> schedule;
  final String location;
  final String onlineLink;
  final String notes;
  final bool isActive;
  final double? quizGrade;
  final double? monthlyExamGrade;
  final String createdDate;
  final String updatedDate;

  const GroupModel({
    required this.id,
    required this.name,
    this.type = 'center',
    this.subject = '',
    this.academicYear = '',
    required this.defaultMonthlyPrice,
    this.groupMonthlyDiscount = 0,
    this.schedule = const [],
    this.location = '',
    this.onlineLink = '',
    this.notes = '',
    this.isActive = true,
    this.quizGrade,
    this.monthlyExamGrade,
    required this.createdDate,
    required this.updatedDate,
  });

  /// السعر الفعلي بعد خصم المجموعة
  double get effectivePrice => defaultMonthlyPrice - groupMonthlyDiscount;

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'center',
      subject: map['subject'] as String? ?? '',
      academicYear: map['academic_year'] as String? ?? '',
      defaultMonthlyPrice: (map['default_monthly_price'] as num?)?.toDouble() ?? 0.0,
      groupMonthlyDiscount: (map['group_monthly_discount'] as num?)?.toDouble() ?? 0.0,
      schedule: (map['schedule'] as List<dynamic>?)
              ?.map((s) => ScheduleSlot.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      location: map['location'] as String? ?? '',
      onlineLink: map['online_link'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? true,
      quizGrade: (map['quiz_grade'] as num?)?.toDouble(),
      monthlyExamGrade: (map['monthly_exam_grade'] as num?)?.toDouble(),
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'subject': subject,
      'academic_year': academicYear,
      'default_monthly_price': defaultMonthlyPrice,
      'group_monthly_discount': groupMonthlyDiscount,
      'schedule': schedule.map((s) => s.toMap()).toList(),
      'location': location,
      'online_link': onlineLink,
      'notes': notes,
      'is_active': isActive,
      'quiz_grade': quizGrade,
      'monthly_exam_grade': monthlyExamGrade,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? type,
    String? subject,
    String? academicYear,
    double? defaultMonthlyPrice,
    double? groupMonthlyDiscount,
    List<ScheduleSlot>? schedule,
    String? location,
    String? onlineLink,
    String? notes,
    bool? isActive,
    double? quizGrade,
    double? monthlyExamGrade,
    String? createdDate,
    String? updatedDate,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      academicYear: academicYear ?? this.academicYear,
      defaultMonthlyPrice: defaultMonthlyPrice ?? this.defaultMonthlyPrice,
      groupMonthlyDiscount: groupMonthlyDiscount ?? this.groupMonthlyDiscount,
      schedule: schedule ?? this.schedule,
      location: location ?? this.location,
      onlineLink: onlineLink ?? this.onlineLink,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      quizGrade: quizGrade ?? this.quizGrade,
      monthlyExamGrade: monthlyExamGrade ?? this.monthlyExamGrade,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}

/// موعد واحد في جدول المجموعة
class ScheduleSlot {
  final String day; // saturday | sunday | monday | tuesday | wednesday | thursday | friday
  final String startTime; // HH:mm
  final String endTime; // HH:mm

  const ScheduleSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleSlot.fromMap(Map<String, dynamic> map) {
    return ScheduleSlot(
      day: map['day'] as String? ?? 'saturday',
      startTime: map['start_time'] as String? ?? '16:00',
      endTime: map['end_time'] as String? ?? '18:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

/// أنواع المجموعات
enum GroupType {
  center('center', 'سنتر'),
  privateGroup('privateGroup', 'مجموعة خاصة'),
  privateLesson('privateLesson', 'درس خاص'),
  online('online', 'أونلاين');

  final String value;
  final String label;
  const GroupType(this.value, this.label);

  static GroupType fromValue(String value) {
    return GroupType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GroupType.center,
    );
  }
}
