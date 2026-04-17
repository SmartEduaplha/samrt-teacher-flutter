/// نموذج الطالب (Student)
class StudentModel {
  final String id;
  final String fullName;
  final String groupId;
  final String groupName;
  final String phoneNumber;
  final String parentPhoneNumber;
  final String parentPhoneNumber2;
  final String landlineNumber;
  final String address;
  final String gender; // male | female
  final String academicYear;
  final String joinDate; // yyyy-MM-dd
  final double studentMonthlyDiscount;
  final bool isFreeStudent;
  final String notes;
  final bool isActive;
  final String? portalCode; // كود بوابة الطالب
  final String createdDate;
  final String updatedDate;

  const StudentModel({
    required this.id,
    required this.fullName,
    this.groupId = '',
    this.groupName = '',
    this.phoneNumber = '',
    this.parentPhoneNumber = '',
    this.parentPhoneNumber2 = '',
    this.landlineNumber = '',
    this.address = '',
    this.gender = '',
    this.academicYear = '',
    this.joinDate = '',
    this.studentMonthlyDiscount = 0,
    this.isFreeStudent = false,
    this.notes = '',
    this.isActive = true,
    this.portalCode,
    required this.createdDate,
    required this.updatedDate,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      groupId: map['group_id'] as String? ?? '',
      groupName: map['group_name'] as String? ?? '',
      phoneNumber: map['phone_number'] as String? ?? '',
      parentPhoneNumber: map['parent_phone_number'] as String? ?? '',
      parentPhoneNumber2: map['parent_phone_number_2'] as String? ?? '',
      landlineNumber: map['landline_number'] as String? ?? '',
      address: map['address'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      academicYear: map['academic_year'] as String? ?? '',
      joinDate: map['join_date'] as String? ?? '',
      studentMonthlyDiscount: (map['student_monthly_discount'] as num?)?.toDouble() ?? 0.0,
      isFreeStudent: map['is_free_student'] as bool? ?? false,
      notes: map['notes'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? true,
      portalCode: map['portal_code'] as String?,
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'group_id': groupId,
      'group_name': groupName,
      'phone_number': phoneNumber,
      'parent_phone_number': parentPhoneNumber,
      'parent_phone_number_2': parentPhoneNumber2,
      'landline_number': landlineNumber,
      'address': address,
      'gender': gender,
      'academic_year': academicYear,
      'join_date': joinDate,
      'student_monthly_discount': studentMonthlyDiscount,
      'is_free_student': isFreeStudent,
      'notes': notes,
      'is_active': isActive,
      'portal_code': portalCode,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }

  StudentModel copyWith({
    String? id,
    String? fullName,
    String? groupId,
    String? groupName,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? parentPhoneNumber2,
    String? landlineNumber,
    String? address,
    String? gender,
    String? academicYear,
    String? joinDate,
    double? studentMonthlyDiscount,
    bool? isFreeStudent,
    String? notes,
    bool? isActive,
    String? portalCode,
    String? createdDate,
    String? updatedDate,
  }) {
    return StudentModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
      parentPhoneNumber2: parentPhoneNumber2 ?? this.parentPhoneNumber2,
      landlineNumber: landlineNumber ?? this.landlineNumber,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      academicYear: academicYear ?? this.academicYear,
      joinDate: joinDate ?? this.joinDate,
      studentMonthlyDiscount: studentMonthlyDiscount ?? this.studentMonthlyDiscount,
      isFreeStudent: isFreeStudent ?? this.isFreeStudent,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      portalCode: portalCode ?? this.portalCode,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}

/// السنوات الدراسية المتاحة (Keys for localization)
const List<String> academicYears = [
  'year_1_primary', 'year_2_primary', 'year_3_primary',
  'year_4_primary', 'year_5_primary', 'year_6_primary',
  'year_1_prep', 'year_2_prep', 'year_3_prep',
  'year_1_sec', 'year_2_sec', 'year_3_sec',
  'year_university', 'year_other',
];
