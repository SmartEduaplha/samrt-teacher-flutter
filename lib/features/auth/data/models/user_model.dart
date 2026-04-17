/// نموذج المستخدم (المعلم) - User
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? profilePicture;
  final String? phone;
  final String? subject;
  final String createdDate;
  final String updatedDate;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.profilePicture,
    this.phone,
    this.subject,
    required this.createdDate,
    required this.updatedDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      profilePicture: map['profile_picture'] as String?,
      phone: map['phone'] as String?,
      subject: map['subject'] as String?,
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'phone': phone,
      'subject': subject,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profilePicture,
    String? phone,
    String? subject,
    String? createdDate,
    String? updatedDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      phone: phone ?? this.phone,
      subject: subject ?? this.subject,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}
