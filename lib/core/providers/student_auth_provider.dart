import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_providers.dart';
import '../../features/students/data/models/student_model.dart';

/// البروفايدر المسؤول عن إدارة الطالب المسجل دخوله حالياً
final currentStudentProvider = StateNotifierProvider<StudentAuthNotifier, StudentModel?>((ref) {
  return StudentAuthNotifier(ref);
});

class StudentAuthNotifier extends StateNotifier<StudentModel?> {
  final Ref _ref;
  static const _key = 'logged_in_student_id';

  StudentAuthNotifier(this._ref) : super(null) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString(_key);
    
    if (studentId != null) {
      try {
        // جلب الطالب الفردي مباشرة لتحسين الأداء والخصوصية
        final student = await _ref.read(studentDbProvider).get(studentId);
        if (student != null) {
          state = student;
        } else {
          await logout();
        }
      } catch (e) {
        // إذا فشل الجلب (ربما بسبب القواعد أو الحذف)، نقوم بمسح الجلسة
        await logout();
      }
    }
  }

  Future<void> login(StudentModel student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, student.id);
    state = student;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = null;
  }
}

/// بروفايدر يحدد نوع المستخدم المسجل حالياً (معلم أم طالب)
enum UserType { none, teacher, student }

final userTypeProvider = Provider<UserType>((ref) {
  // نستخدم المزود الجديد الذي يتأكد من وجود بريد إلكتروني (معلم)
  final isTeacher = ref.watch(isTeacherAuthenticatedProvider);
  if (isTeacher) return UserType.teacher;
  
  final student = ref.watch(currentStudentProvider);
  if (student != null) return UserType.student;
  
  return UserType.none;
});
