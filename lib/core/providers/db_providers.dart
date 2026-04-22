import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sync_db_service.dart';
import '../services/local_db_service.dart';
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
import '../../features/qr_scanner/data/models/qr_scan_model.dart';
import '../../features/honor_board/data/models/honor_point_model.dart';



// ─── Auth Provider ────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    localDb: ref.read(localUserDbProvider),
  );
});

/// قاعدة بيانات المستخدمين محلياً
final localUserDbProvider = Provider<LocalDbService<UserModel>>((ref) {
  return LocalDbService<UserModel>(
    entityName: 'users',
    fromMap: UserModel.fromMap,
    toMap: (u) => u.toMap(),
  );
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
final groupDbProvider = Provider<SyncDbService<GroupModel>>((ref) {
  return SyncDbService<GroupModel>(
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
final activeGroupsProvider = Provider<AsyncValue<List<GroupModel>>>((ref) {
  return ref.watch(groupsProvider).whenData(
    (groups) => groups.where((g) => g.isActive).toList(),
  );
});

// ─── Students ─────────────────────────────────────────────────────────────────

/// قاعدة بيانات الطلاب
final studentDbProvider = Provider<SyncDbService<StudentModel>>((ref) {
  return SyncDbService<StudentModel>(
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
final paymentDbProvider = Provider<SyncDbService<PaymentModel>>((ref) {
  return SyncDbService<PaymentModel>(
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
final attendanceDbProvider = Provider<SyncDbService<AttendanceRecord>>((ref) {
  return SyncDbService<AttendanceRecord>(
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
final expenseDbProvider = Provider<SyncDbService<ExpenseModel>>((ref) {
  return SyncDbService<ExpenseModel>(
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
final gradeDbProvider = Provider<SyncDbService<GradeModel>>((ref) {
  return SyncDbService<GradeModel>(
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
final quizDbProvider = Provider<SyncDbService<QuizModel>>((ref) {
  return SyncDbService<QuizModel>(
    collectionName: 'quizzes',
    fromMap: QuizModel.fromMap,
    toMap: (q) => q.toMap(),
  );
});

/// قاعدة بيانات نتائج الاختبارات
final quizResultDbProvider = Provider<SyncDbService<QuizResultModel>>((ref) {
  return SyncDbService<QuizResultModel>(
    collectionName: 'quiz_results',
    fromMap: QuizResultModel.fromMap,
    toMap: (r) => r.toMap(),
  );
});

/// قائمة كل الاختبارات
final quizzesProvider = StreamProvider<List<QuizModel>>((ref) {
  return ref.read(quizDbProvider).snapshots();
});

/// قائمة كل نتائج الاختبارات
final allQuizResultsProvider = StreamProvider<List<QuizResultModel>>((ref) {
  return ref.read(quizResultDbProvider).snapshots();
});

/// نتائج اختبارات طالب بعينه
final quizResultsByStudentProvider =
    StreamProvider.family<List<QuizResultModel>, String>((ref, studentId) {
  return ref.read(quizResultDbProvider).snapshotsFilter({'student_id': studentId});
});

/// نتائج اختبار بعينه
final quizResultsByQuizProvider =
    StreamProvider.family<List<QuizResultModel>, String>((ref, quizId) {
  return ref.read(quizResultDbProvider).snapshotsFilter({'quiz_id': quizId});
});

// ─── Honor Points ─────────────────────────────────────────────────────────────

/// قاعدة بيانات نقاط الشرف اليدوية
final honorPointDbProvider = Provider<SyncDbService<HonorPointModel>>((ref) {
  return SyncDbService<HonorPointModel>(
    collectionName: 'honor_points',
    fromMap: (map) => HonorPointModel.fromMap(map, map['id'] ?? ''),
    toMap: (p) => p.toMap(),
  );
});

/// قائمة كل نقاط الشرف
final honorPointsProvider = StreamProvider<List<HonorPointModel>>((ref) {
  return ref.read(honorPointDbProvider).snapshots();
});

// ─── Tasks ────────────────────────────────────────────────────────────────────

/// قاعدة بيانات المهام
final taskDbProvider = Provider<SyncDbService<TaskModel>>((ref) {
  return SyncDbService<TaskModel>(
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
final storeDbProvider = Provider<SyncDbService<StoreItemModel>>((ref) {
  return SyncDbService<StoreItemModel>(
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
final announcementDbProvider = Provider<SyncDbService<AnnouncementModel>>((ref) {
  return SyncDbService<AnnouncementModel>(
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

// ─── QR Scans ─────────────────────────────────────────────────────────────────

/// قاعدة بيانات مسح QR
final qrScanDbProvider = Provider<SyncDbService<QrScanModel>>((ref) {
  return SyncDbService<QrScanModel>(
    collectionName: 'qr_scans',
    fromMap: QrScanModel.fromMap,
    toMap: (s) => s.toMap(),
  );
});

/// قائمة كل سجلات مسح QR
final qrScansProvider = StreamProvider<List<QrScanModel>>((ref) {
  return ref.read(qrScanDbProvider).snapshots();
});
