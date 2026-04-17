import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_db_service.dart';
import '../services/auth_service.dart';
import '../../features/groups/data/models/group_model.dart';
import '../../features/students/data/models/student_model.dart';
import '../../features/payments/data/models/payment_model.dart';
import '../../features/attendance/data/models/attendance_model.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/quizzes/data/models/quiz_model.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/grades/data/models/grade_model.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/store/data/models/store_item_model.dart';
import '../../features/announcements/data/models/announcement_model.dart';



// ─── Auth Provider ────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// حالة المستخدم الحالي (تحديث مباشر مع Firebase)
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final auth = ref.read(authServiceProvider);
  return auth.me();
});

/// بث حالة تسجيل الدخول ليسمعها التطبيق مباشرة للتوجيه التلقائي
final authStateProvider = StreamProvider((ref) {
  return ref.read(authServiceProvider).authStateChanges();
});

/// هل المستخدم مسجل الدخول؟ (سواء معلم أو طالب مجهول)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user != null;
});

/// هل المستخدم الحالي هو معلم؟ (لديه بريد إلكتروني)
final isTeacherAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user != null && user.email != null && user.email!.isNotEmpty;
});

// ─── Entity Providers ─────────────────────────────────────────────────────────

/// قاعدة بيانات المجموعات
final groupDbProvider = Provider<FirebaseDbService<GroupModel>>((ref) {
  return FirebaseDbService<GroupModel>(
    collectionName: 'groups',
    fromMap: GroupModel.fromMap,
    toMap: (g) => g.toMap(),
  );
});

/// قائمة كل المجموعات
final groupsProvider = StreamProvider<List<GroupModel>>((ref) {
  return ref.read(groupDbProvider).snapshots();
});

/// المجموعات النشطة فقط
final activeGroupsProvider = StreamProvider<List<GroupModel>>((ref) {
  final groupsAsync = ref.watch(groupsProvider);
  return groupsAsync.when(
    data: (groups) => Stream.value(groups.where((g) => g.isActive).toList()),
    loading: () => const Stream.empty(),
    error: (e, st) => Stream.error(e, st),
  );
});

// ─── Students ─────────────────────────────────────────────────────────────────

/// قاعدة بيانات الطلاب
final studentDbProvider = Provider<FirebaseDbService<StudentModel>>((ref) {
  return FirebaseDbService<StudentModel>(
    collectionName: 'students',
    fromMap: StudentModel.fromMap,
    toMap: (s) => s.toMap(),
  );
});

/// قائمة كل الطلاب
final studentsProvider = StreamProvider<List<StudentModel>>((ref) {
  return ref.read(studentDbProvider).snapshots();
});

/// الطلاب النشطون فقط
final activeStudentsProvider = StreamProvider<List<StudentModel>>((ref) {
  final studentsAsync = ref.watch(studentsProvider);
  return studentsAsync.when(
    data: (students) => Stream.value(students.where((s) => s.isActive).toList()),
    loading: () => const Stream.empty(),
    error: (e, st) => Stream.error(e, st),
  );
});

/// طلاب مجموعة بعينها
final studentsByGroupProvider =
    StreamProvider.family<List<StudentModel>, String>((ref, groupId) {
  final db = ref.read(studentDbProvider);
  return db.snapshotsFilter({'group_id': groupId, 'is_active': true});
});

// ─── Payments ─────────────────────────────────────────────────────────────────

/// قاعدة بيانات الدفعات
final paymentDbProvider = Provider<FirebaseDbService<PaymentModel>>((ref) {
  return FirebaseDbService<PaymentModel>(
    collectionName: 'payments',
    fromMap: PaymentModel.fromMap,
    toMap: (p) => p.toMap(),
  );
});

/// قائمة كل الدفعات
final paymentsProvider = StreamProvider<List<PaymentModel>>((ref) {
  return ref.read(paymentDbProvider).snapshots();
});

/// دفعات طالب بعينه
final paymentsByStudentProvider =
    StreamProvider.family<List<PaymentModel>, String>((ref, studentId) {
  return ref.read(paymentDbProvider).snapshotsFilter({'student_id': studentId});
});

// ─── Attendance ───────────────────────────────────────────────────────────────

/// قاعدة بيانات الحضور
final attendanceDbProvider = Provider<FirebaseDbService<AttendanceRecord>>((ref) {
  return FirebaseDbService<AttendanceRecord>(
    collectionName: 'attendance',
    fromMap: AttendanceRecord.fromMap,
    toMap: (a) => a.toMap(),
  );
});

/// قائمة كل سجلات الحضور
final attendanceProvider = StreamProvider<List<AttendanceRecord>>((ref) {
  return ref.read(attendanceDbProvider).snapshots();
});

/// سجل حضور طالب بعينه
final attendanceByStudentProvider =
    StreamProvider.family<List<AttendanceRecord>, String>((ref, studentId) {
  return ref.read(attendanceDbProvider).snapshotsFilter({'student_id': studentId});
});

/// سجلات حضور مجموعة في يوم بعينه
final attendanceByGroupDateProvider =
    StreamProvider.family<List<AttendanceRecord>, ({String groupId, String date})>(
  (ref, args) {
    return ref
        .read(attendanceDbProvider)
        .snapshotsFilter({'group_id': args.groupId, 'date': args.date});
  },
);

// ─── Expenses ─────────────────────────────────────────────────────────────────

/// قاعدة بيانات المصروفات
final expenseDbProvider = Provider<FirebaseDbService<ExpenseModel>>((ref) {
  return FirebaseDbService<ExpenseModel>(
    collectionName: 'expenses',
    fromMap: ExpenseModel.fromMap,
    toMap: (e) => e.toMap(),
  );
});

/// قائمة كل المصروفات
final expensesProvider = FutureProvider<List<ExpenseModel>>((ref) async {
  return ref.read(expenseDbProvider).list();
});

/// مصروفات شهر بعينه
final expensesByMonthProvider =
    FutureProvider.family<List<ExpenseModel>, String>((ref, month) async {
  return ref.read(expenseDbProvider).filter({'for_month': month});
});

// ─── Grades ───────────────────────────────────────────────────────────────────

/// قاعدة بيانات الدرجات
final gradeDbProvider = Provider<FirebaseDbService<GradeModel>>((ref) {
  return FirebaseDbService<GradeModel>(
    collectionName: 'grades',
    fromMap: GradeModel.fromMap,
    toMap: (g) => g.toMap(),
  );
});

final gradesByStudentProvider =
    FutureProvider.family<List<GradeModel>, String>((ref, studentId) async {
  return ref.read(gradeDbProvider).filter({'student_id': studentId});
});

final gradesByGroupProvider =
    FutureProvider.family<List<GradeModel>, String>((ref, groupId) async {
  return ref.read(gradeDbProvider).filter({'group_id': groupId});
});

// ─── Quizzes ──────────────────────────────────────────────────────────────────

/// قاعدة بيانات الاختبارات
final quizDbProvider = Provider<FirebaseDbService<QuizModel>>((ref) {
  return FirebaseDbService<QuizModel>(
    collectionName: 'quizzes',
    fromMap: QuizModel.fromMap,
    toMap: (q) => q.toMap(),
  );
});

/// قاعدة بيانات نتائج الاختبارات
final quizResultDbProvider = Provider<FirebaseDbService<QuizResultModel>>((ref) {
  return FirebaseDbService<QuizResultModel>(
    collectionName: 'quiz_results',
    fromMap: QuizResultModel.fromMap,
    toMap: (r) => r.toMap(),
  );
});

/// قائمة كل الاختبارات
final quizzesProvider = FutureProvider<List<QuizModel>>((ref) async {
  return ref.read(quizDbProvider).list();
});

/// قائمة كل نتائج الاختبارات
final allQuizResultsProvider = FutureProvider<List<QuizResultModel>>((ref) async {
  return ref.read(quizResultDbProvider).list();
});

/// نتائج اختبارات طالب بعينه
final quizResultsByStudentProvider =
    FutureProvider.family<List<QuizResultModel>, String>((ref, studentId) async {
  return ref.read(quizResultDbProvider).filter({'student_id': studentId});
});

/// نتائج اختبار بعينه
final quizResultsByQuizProvider =
    FutureProvider.family<List<QuizResultModel>, String>((ref, quizId) async {
  return ref.read(quizResultDbProvider).filter({'quiz_id': quizId});
});

// ─── Tasks ────────────────────────────────────────────────────────────────────

/// قاعدة بيانات المهام
final taskDbProvider = Provider<FirebaseDbService<TaskModel>>((ref) {
  return FirebaseDbService<TaskModel>(
    collectionName: 'tasks',
    fromMap: TaskModel.fromMap,
    toMap: (t) => t.toMap(),
  );
});

/// قائمة كل المهام
final tasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  return ref.read(taskDbProvider).list();
});

// ─── Store ────────────────────────────────────────────────────────────────────

/// قاعدة بيانات المتجر
final storeDbProvider = Provider<FirebaseDbService<StoreItemModel>>((ref) {
  return FirebaseDbService<StoreItemModel>(
    collectionName: 'store',
    fromMap: StoreItemModel.fromMap,
    toMap: (s) => s.toMap(),
  );
});

/// قائمة كل منتجات المتجر
final storeProvider = StreamProvider<List<StoreItemModel>>((ref) {
  return ref.read(storeDbProvider).snapshots();
});

/// ملف تعريف المعلم (للوصول إلى رقم واتساب المتجر)
/// يجلب أول مستخدم في مجموعة users مفترضاً أنه المعلم الأساسي
final teacherProfileProvider = StreamProvider<UserModel?>((ref) {
  // نستخدم مجموعة users مباشرة عبر Firestore
  return FirebaseFirestore.instance
      .collection('users')
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromMap(snapshot.docs.first.data());
  });
});

// ─── Announcements ────────────────────────────────────────────────────────────

/// قاعدة بيانات التنبيهات
final announcementDbProvider = Provider<FirebaseDbService<AnnouncementModel>>((ref) {
  return FirebaseDbService<AnnouncementModel>(
    collectionName: 'announcements',
    fromMap: AnnouncementModel.fromMap,
    toMap: (a) => a.toMap(),
  );
});

/// قائمة كل التنبيهات (للمعلم)
final allAnnouncementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return ref.read(announcementDbProvider).snapshots();
});

/// التنبيهات الموجهة لطالب معين (تنبيهات مجموعته + التنبيهات العامة)
final studentAnnouncementsProvider = StreamProvider.family<List<AnnouncementModel>, String?>((ref, groupId) {
  final db = ref.read(announcementDbProvider);
  // نراقب كل التنبيهات ونقوم بالتصفية محلياً للسماح بالتنبيهات العامة (null) وتنبيهات المجموعة
  return db.snapshots().map((list) => list.where((a) {
    if (a.groupId == null || a.groupId!.isEmpty) return true; // عام
    return a.groupId == groupId; // للمجموعة
  }).toList());
});

