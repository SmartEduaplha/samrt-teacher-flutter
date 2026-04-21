import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../students/data/models/student_model.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../payments/presentation/screens/outstanding_payments_screen.dart';
import '../../../quizzes/data/models/quiz_model.dart';
import '../../../students/presentation/screens/students_screen.dart';
import '../../../honor_board/presentation/screens/honor_board_screen.dart';
import '../../../quizzes/presentation/screens/quiz_results_screen.dart';
import '../../../students/presentation/screens/student_profile_screen.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../../announcements/presentation/screens/announcements_screen.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../shared/presentation/widgets/quick_actions_bar.dart';
import '../../../grades/presentation/screens/grades_dashboard_screen.dart';
// Removed unused import

const List<Color> sessionColors = [
  Color(0xFF6366F1), // Indigo
  Color(0xFF10B981), // Emerald
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF8B5CF6), // Violet
  Color(0xFFEC4899), // Pink
  Color(0xFF0EA5E9), // Sky
];


// --- Dashboard Data Bundle ---
class DashboardData {
  final List<GroupModel> groups;
  final List<StudentModel> students;
  final List<PaymentModel> allPayments;
  final List<AttendanceRecord> todayAttendance;
  final List<AttendanceRecord> allAttendance;
  final List<dynamic> quizzes;
  final List<dynamic> allResults;
  final List<dynamic> allGrades;

  DashboardData({
    required this.groups,
    required this.students,
    required this.allPayments,
    required this.todayAttendance,
    required this.allAttendance,
    required this.quizzes,
    required this.allResults,
    required this.allGrades,
  });
}

class ActivityModel {
  final String id;
  final String action; // 'create', 'update', 'delete', 'attendance', 'payment'
  final String details;
  final DateTime timestamp;

  ActivityModel({
    required this.id,
    required this.action,
    required this.details,
    required this.timestamp,
  });
}

final dashboardDataProvider = StreamProvider<DashboardData>((ref) {
  final List<GroupModel> groups = ref.watch(groupsProvider).value ?? [];
  final List<StudentModel> students = ref.watch(studentsProvider).value ?? [];
  final List<PaymentModel> allPayments = ref.watch(paymentsProvider).value ?? [];
  final List<AttendanceRecord> allAttendance = ref.watch(attendanceProvider).value ?? [];
  final List<QuizModel> quizzes = ref.watch(quizzesProvider).value ?? [];
  final List<QuizResultModel> allResults = ref.watch(allQuizResultsProvider).value ?? [];
  
  // Custom filter for today's attendance
  final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final todayAttendance = allAttendance.where((a) => a.date == todayStr).toList();

  return Stream.value(DashboardData(
    groups: groups,
    students: students,
    allPayments: allPayments,
    todayAttendance: todayAttendance,
    allAttendance: allAttendance,
    quizzes: quizzes,
    allResults: allResults,
    allGrades: [],
  ));
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showAllOutstanding = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncData = ref.watch(dashboardDataProvider);
    final userAsync = ref.watch(currentUserProvider);

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final thisMonthStr = DateFormat('yyyy-MM').format(DateTime.now());
    
    // Day string in english to match React logic
    // Day string in english strictly to match database model
    final dayName = DateFormat('EEEE', 'en').format(DateTime.now()).toLowerCase();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: asyncData.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => Center(child: Text(context.l10n.errorOccurred(e.toString()), style: const TextStyle(color: Colors.red))),
            data: (data) {
              // 1. Calculations
              final activeGroups = data.groups.where((g) => g.isActive).toList();
              final activeStudents = data.students.where((s) => s.isActive).toList();
              
              final todayPayments = data.allPayments.where((p) => p.paymentDate == todayStr).toList();
              final todayTotal = todayPayments.fold(0.0, (sum, p) => sum + p.amount);
              
              final monthPayments = data.allPayments.where((p) => p.forMonth == thisMonthStr).toList();
              
              final presentToday = data.todayAttendance.where((a) => a.status == 'present').length;
              final absentToday = data.todayAttendance.where((a) => a.status == 'absent').length;

              // Outstanding logic
              double getEffectivePrice(StudentModel student) {
                if (student.isFreeStudent) return 0.0;
                final group = data.groups.where((g) => g.id == student.groupId).firstOrNull;
                if (group == null) return 0.0;
                if (student.studentMonthlyDiscount > 0) {
                  return group.defaultMonthlyPrice - student.studentMonthlyDiscount;
                }
                return group.defaultMonthlyPrice - group.groupMonthlyDiscount;
              }

              final outstandingList = <Map<String, dynamic>>[];
              for (var s in activeStudents.where((s) => !s.isFreeStudent)) {
                final requiredAmount = getEffectivePrice(s);
                final paid = monthPayments
                    .where((p) => p.studentId == s.id)
                    .fold(0.0, (sum, p) => sum + p.amount);
                final outstanding = (requiredAmount - paid).clamp(0.0, double.infinity);
                if (outstanding > 0) {
                  outstandingList.add({
                    'student': s,
                    'required': requiredAmount,
                    'paid': paid,
                    'outstanding': outstanding,
                  });
                }
              }
              outstandingList.sort((a, b) => (b['outstanding'] as double).compareTo(a['outstanding'] as double));
              
              final totalOutstanding = outstandingList.fold(0.0, (sum, item) => sum + (item['outstanding'] as double));
              final visibleOutstanding = _showAllOutstanding ? outstandingList : outstandingList.take(5).toList();

              final allActivitiesRaw = <ActivityModel>[];
              
              // Add payments
              for (var p in data.allPayments) {
                if (p.createdDate.isNotEmpty) {
                  allActivitiesRaw.add(ActivityModel(
                    id: p.id,
                    action: 'payment',
                    details: '${context.l10n.paymentOf} ${p.amount} ${context.l10n.currency} - ${p.studentName}',
                    timestamp: DateTime.tryParse(p.createdDate) ?? DateTime.fromMillisecondsSinceEpoch(0),
                  ));
                }
              }
              
              // Add students
              for (var s in data.students) {
                if (s.createdDate.isNotEmpty) {
                  allActivitiesRaw.add(ActivityModel(
                    id: s.id,
                    action: 'create',
                    details: 'تسجيل الطالب: ${s.fullName}',
                    timestamp: DateTime.tryParse(s.createdDate) ?? DateTime.fromMillisecondsSinceEpoch(0),
                  ));
                }
              }

              // Add attendance
              for (var a in data.allAttendance) {
                if (a.createdDate.isNotEmpty) {
                  final statusText = a.status == 'present' ? 'حضور' : (a.status == 'absent' ? 'غياب' : 'غياب بعذر');
                  allActivitiesRaw.add(ActivityModel(
                    id: a.id,
                    action: 'attendance',
                    details: 'تسجيل $statusText للطالب: ${a.studentName}',
                    timestamp: DateTime.tryParse(a.createdDate) ?? DateTime.fromMillisecondsSinceEpoch(0),
                  ));
                }
              }

              // Add groups
              for (var g in data.groups) {
                if (g.createdDate.isNotEmpty) {
                  allActivitiesRaw.add(ActivityModel(
                    id: g.id,
                    action: 'create',
                    details: 'تم إضافة مجموعة جديدة: ${g.name}',
                    timestamp: DateTime.tryParse(g.createdDate) ?? DateTime.fromMillisecondsSinceEpoch(0),
                  ));
                }
              }

              allActivitiesRaw.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              final activities = allActivitiesRaw.take(6).toList();

               return Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                     _buildHeader(colorScheme, userAsync.value),
                   const SizedBox(height: 16),
                   _buildSmartSuggestions(context, data, dayName),
                   // ── شريط الإجراءات السريعة المضمّن ───────────────────────────
                   const SizedBox(height: 12),
                   const QuickActionsBar(),
                   const SizedBox(height: 20),
                   _buildStatsGrid(data, activeGroups, activeStudents, todayTotal, todayPayments, totalOutstanding, outstandingList),
                   const SizedBox(height: 20),
                   _buildOrganizerShortcutCard(context),
                   const SizedBox(height: 20),
                   _buildCommunicationCard(context),
                   const SizedBox(height: 20),
                   _buildAcademicCard(context),
                   const SizedBox(height: 20),
                  _buildAttendanceChart(colorScheme, presentToday, absentToday),
                  const SizedBox(height: 20),
                  _buildTodaySessions(context, data, dayName),
                  const SizedBox(height: 20),
                  _buildOutstandingAlerts(context, totalOutstanding, outstandingList, visibleOutstanding),
                  const SizedBox(height: 20),
                  _buildRecentActivity(context, activities),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      )
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.onPrimary.withAlpha(50),
                backgroundImage: user?.profilePicture != null 
                    ? NetworkImage(user!.profilePicture!) 
                    : null,
                child: user?.profilePicture == null
                    ? Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName.substring(0, 1) : 'م',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.welcome,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withAlpha(200)),
                    ),
                    Text(
                      user?.fullName ?? '...',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _convertToTask(String title, String description) async {
    try {
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        date: DateTime.now(),
        isCompleted: false,
      );

      await ref.read(taskDbProvider).create(task.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.suggestionConvertedToTask(title)),
            action: SnackBarAction(
              label: context.l10n.viewTasks,
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const TasksScreen())
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorOccurred(e.toString()))),
        );
      }
    }
  }

  Widget _buildAttendanceChart(ColorScheme colorScheme, int present, int absent) {
    final total = present + absent;
    final presentPct = total == 0 ? 0.0 : (present / total) * 100;
    
    return _buildGlassCard(
      title: context.l10n.todayAttendance,
      icon: Icons.pie_chart_rounded,
      iconColor: const Color(0xFF0EA5E9),
      child: total == 0
          ? _buildEmptyState(
              Icons.event_available_rounded, context.l10n.noSessionsToday)
          : Column(
              children: [
                Row(
                  children: [
                    // الرسم البياني الدائري (Donut Chart)
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              startDegreeOffset: 270,
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFF10B981), // اخضر للحضور
                                  value: present.toDouble(),
                                  title: '',
                                  radius: 12,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFEF4444), // احمر للغياب
                                  value: absent.toDouble(),
                                  title: '',
                                  radius: 12,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${presentPct.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              Text(
                                'معدل الحضور',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: colorScheme.onSurface.withAlpha(150),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // الإحصائيات الدقيقة (بطاقات الحضور والغياب)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAttendanceStatRow(
                            context.l10n.present,
                            present,
                            const Color(0xFF10B981),
                            Icons.check_circle_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildAttendanceStatRow(
                            context.l10n.absent,
                            absent,
                            const Color(0xFFEF4444),
                            Icons.cancel_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // شريط إجمالي الطلاب
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withAlpha(20),
                        colorScheme.secondary.withAlpha(20)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.primary.withAlpha(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.groups_rounded, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('إجمالي المسجلين اليوم',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withAlpha(200),
                              )),
                        ],
                      ),
                      Text(
                        '$total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAttendanceStatRow(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color.withAlpha(220),
              ),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySessions(BuildContext context, DashboardData data, String dayName) {
    final activeGroups = data.groups.where((g) => g.isActive).toList();
    final todaySessions = activeGroups.where((g) => g.schedule.any((s) => s.day == dayName)).toList();

    return _buildGlassCard(
      title: context.l10n.todaySessions,
      icon: Icons.calendar_today_rounded,
      iconColor: Colors.blue,
      badge: '${todaySessions.length}',
      child: todaySessions.isEmpty
          ? _buildEmptyState(Icons.event_busy, context.l10n.noSessionsToday)
          : Column(
              children: todaySessions.map((g) {
                final groupStudentCount = data.students.where((s) => s.groupId == g.id && s.isActive).length;
                final attendedCount = data.todayAttendance.where((a) => a.groupId == g.id && a.status == 'present').length;
                final isRecorded = data.todayAttendance.any((a) => a.groupId == g.id);
                final session = g.schedule.firstWhere((s) => s.day == dayName);

                return InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(preGroupId: g.id))),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isRecorded ? Colors.green : Colors.blue).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isRecorded ? Icons.check_circle_rounded : Icons.access_time_filled_rounded,
                            color: isRecorded ? Colors.green : Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('${session.startTime} - ${session.endTime}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$attendedCount / $groupStudentCount', 
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: isRecorded ? Colors.green : Colors.blue)),
                            Text(context.l10n.studentsPresent, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildOutstandingAlerts(BuildContext context, double totalOutstanding, List<Map<String, dynamic>> outstandingList, List<Map<String, dynamic>> visibleOutstanding) {
    return _buildGlassCard(
      title: context.l10n.outstandingAlerts,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red,
      badge: '${outstandingList.length}',
      onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OutstandingPaymentsScreen())),
      actionText: context.l10n.viewAll,
      child: outstandingList.isEmpty
          ? _buildEmptyState(Icons.thumb_up_alt_rounded, context.l10n.noOutstandingPayments, color: Colors.green)
          : Column(
              children: [
                ...visibleOutstanding.map((item) {
                  final student = item['student'] as StudentModel;
                  final requiredAmt = item['required'] as double;
                  final paidAmt = item['paid'] as double;
                  final outstandingAmt = item['outstanding'] as double;
                  final pct = requiredAmt > 0 ? (paidAmt / requiredAmt) : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.fullName, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(student.groupName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('${outstandingAmt.toStringAsFixed(0)} ${context.l10n.currency}', 
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(pct > 0.7 ? Colors.green : Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (outstandingList.length > 5)
                  TextButton(
                    onPressed: () => setState(() => _showAllOutstanding = !_showAllOutstanding),
                    child: Text(_showAllOutstanding ? context.l10n.showLess : context.l10n.showMore(outstandingList.length - 5)),
                  ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(context.l10n.totalOutstandingThisMonth, style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(width: 8),
                    Text('${totalOutstanding.toStringAsFixed(0)} ${context.l10n.currency}', 
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.red)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<ActivityModel> activities) {
    return _buildGlassCard(
      title: context.l10n.recentActivity,
      icon: Icons.history_rounded,
      iconColor: Colors.deepPurple,
      child: activities.isEmpty
          ? _buildEmptyState(Icons.history_toggle_off_rounded, context.l10n.noRecentActivity)
          : Column(
              children: activities.map((activity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: Colors.deepPurple, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getActivityActionText(context, activity.action), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(activity.details, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(DateFormat.jm(Localizations.localeOf(context).languageCode).format(activity.timestamp), 
                        style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  String _getActivityActionText(BuildContext context, String action) {
    switch (action) {
      case 'create': return context.l10n.activityAdded;
      case 'update': return context.l10n.activityUpdated;
      case 'delete': return context.l10n.activityDeleted;
      case 'attendance': return context.l10n.activityAttendance;
      case 'payment': return context.l10n.activityPayment;
      default: return action;
    }
  }

  Widget _buildOrganizerShortcutCard(BuildContext context) {
    return _buildGlassCard(
      title: 'المنظم',
      icon: Icons.event_note_rounded,
      iconColor: const Color(0xFFF16938), // Matches the orange theme in screenshots
      child: Column(
        children: [
          _buildQuickActionTile(
            context,
            title: 'جدولك الأسبوعي وقائمة مهامك',
            subtitle: 'نظم وقتك، حصصك، ومهامك في مكان واحد مجدول',
            icon: Icons.calendar_month_rounded,
            color: const Color(0xFFF16938),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationCard(BuildContext context) {
    return _buildGlassCard(
      title: context.l10n.communicationManagement,
      icon: Icons.campaign_rounded,
      iconColor: Colors.orange,
      child: Column(
        children: [
          _buildQuickActionTile(
            context,
            title: context.l10n.generalAnnouncements,
            subtitle: context.l10n.sendInstantMessages,
            icon: Icons.notifications_active_rounded,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicCard(BuildContext context) {
    return _buildGlassCard(
      title: 'الإدارة الأكاديمية والدرجات',
      icon: Icons.school_rounded,
      iconColor: Colors.amber,
      child: Column(
        children: [
          _buildQuickActionTile(
            context,
            title: 'إدارة الدرجات',
            subtitle: 'سجل واستعرض درجات امتحانات الحصة والشهر',
            icon: Icons.grade_rounded,
            color: Colors.amber,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradesDashboardScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(20)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color.withAlpha(150)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    String? badge,
    VoidCallback? onAction,
    String? actionText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(badge, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onAction != null)
                  TextButton(
                    onPressed: onAction,
                    child: Text(actionText ?? context.l10n.viewAll, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message, {Color color = Colors.grey}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: color.withValues(alpha: 0.6), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }


  Widget _buildStatsGrid(
    DashboardData data,
    List<GroupModel> activeGroups,
    List<StudentModel> activeStudents,
    double todayTotal,
    List<PaymentModel> todayPayments,
    double totalOutstanding,
    List<Map<String, dynamic>> outstandingList,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildPremiumStatCard(
          title: context.l10n.groupsTitle,
          value: '${activeGroups.length}',
          subtitle: context.l10n.activeNow,
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF3B82F6),
        ),
        _buildPremiumStatCard(
          title: context.l10n.studentsTitle,
          value: '${activeStudents.length}',
          subtitle: context.l10n.totalCount(data.students.length),
          icon: Icons.people_rounded,
          color: const Color(0xFF10B981),
        ),
        _buildPremiumStatCard(
          title: context.l10n.todayRevenue,
          value: '${todayTotal.toStringAsFixed(0)} ${context.l10n.currency}',
          subtitle: context.l10n.operationsCount(todayPayments.length),
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFFF59E0B),
        ),
        _buildPremiumStatCard(
          title: context.l10n.debtsTitle,
          value: '${totalOutstanding.toStringAsFixed(0)} ${context.l10n.currency}',
          subtitle: context.l10n.studentsCount(outstandingList.length),
          icon: Icons.warning_rounded,
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      title,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestions(BuildContext context, DashboardData data, String dayName) {
    final suggestions = _generateSuggestions(context, data, dayName);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            context.l10n.smartSuggestions,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final sug = suggestions[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: sug.color.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border(
                    right: BorderSide(color: sug.color, width: 4),
                    top: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(30)),
                    bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(30)),
                    left: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(30)),
                  ),
                ),
                child: Stack(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: sug.onTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: sug.color.withAlpha(25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(sug.icon, color: sug.color, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      sug.title,
                                      style: TextStyle(
                                        color: sug.color,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                sug.message,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    context.l10n.takeAction,
                                    style: TextStyle(
                                      color: sug.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 8, color: sug.color),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (sug.onConvertToTask != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: sug.onConvertToTask,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: sug.color.withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Tooltip(
                                message: context.l10n.convertToTask,
                                child: Icon(Icons.add_task_rounded, color: sug.color, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<_SmartSuggestion> _generateSuggestions(BuildContext context, DashboardData data, String dayName) {
    final List<_SmartSuggestion> list = [];
    final now = DateTime.now();
    final thisMonthStr = DateFormat('yyyy-MM').format(now);

    // 1. Missing Attendance (Session started > 1 hour ago)
    for (final g in data.groups.where((g) => g.isActive)) {
      for (final session in g.schedule.where((s) => s.day == dayName)) {
        try {
          final startTimeParts = session.startTime.split(':');
          final sessionTime = DateTime(now.year, now.month, now.day, int.parse(startTimeParts[0]), int.parse(startTimeParts[1]));
          
          if (now.isAfter(sessionTime.add(const Duration(hours: 1)))) {
            final exists = data.todayAttendance.any((a) => a.groupId == g.id);
            if (!exists) {
              list.add(_SmartSuggestion(
                title: context.l10n.suggestionAttendanceTitle,
                message: context.l10n.suggestionAttendanceMissed(g.name),
                icon: Icons.notification_important_rounded,
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(preGroupId: g.id))),
                onConvertToTask: () => _convertToTask(context.l10n.suggestionAttendanceTaskTitle(g.name), context.l10n.suggestionAttendanceTaskTitle(g.name)),
              ));
            }
          }
        } catch (_) {}
      }
    }

    // 2. Performance Drop Analysis (Latest vs Average)
    for (final student in data.students.where((s) => s.isActive)) {
      final results = data.allResults.where((r) => r.studentId == student.id).toList()
        ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
      
      if (results.length >= 3) {
        final latest = results.first.percentage;
        final previousResults = results.skip(1).toList();
        final avg = previousResults.map((r) => r.percentage).fold(0.0, (a, b) => a + b) / previousResults.length;
        
        if (latest < avg * 0.7 && latest < 60) {
          list.add(_SmartSuggestion(
            title: context.l10n.suggestionPerformanceTitle,
            message: context.l10n.suggestionPerformanceMessage(student.fullName, latest.toStringAsFixed(0)),
            icon: Icons.trending_down_rounded,
            color: Colors.redAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentProfileScreen(studentId: student.id))),
            onConvertToTask: () => _convertToTask(context.l10n.suggestionPerformanceTaskTitle(student.fullName), context.l10n.suggestionPerformanceTaskTitle(student.fullName)),
          ));
        }
      }
    }

    // 3. Frequent Absence (3+ times in last 5)
    for (final student in data.students.where((s) => s.isActive).take(20)) {
      final studentAtt = data.allAttendance.where((a) => a.studentId == student.id).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      final last5 = studentAtt.take(5).toList();
      final absentCount = last5.where((a) => a.status == 'absent').length;
      
      if (absentCount >= 3) {
        list.add(_SmartSuggestion(
          title: context.l10n.suggestionAbsenceTitle,
          message: context.l10n.suggestionAbsenceMessage(student.fullName, absentCount),
          icon: Icons.person_off_rounded,
          color: Colors.red,
          onTap: () {
             final phone = student.parentPhoneNumber.isNotEmpty ? student.parentPhoneNumber : student.phoneNumber;
             final text = context.l10n.suggestionAbsenceWhatsApp(student.fullName);
             if (phone.isNotEmpty) {
               final uri = Uri.parse('https://wa.me/${phone.replaceAll(RegExp(r'\D'), '')}?text=${Uri.encodeComponent(text)}');
               launchUrl(uri, mode: LaunchMode.externalApplication);
             }
          },
          onConvertToTask: () => _convertToTask(context.l10n.suggestionAbsenceTaskTitle(student.fullName), context.l10n.suggestionAbsenceTaskTitle(student.fullName)),
        ));
      }
    }

    // 4. Loyal Debtor (High Attendance + No Payment this month)
    for (final student in data.students.where((s) => s.isActive && !s.isFreeStudent)) {
      final monthAttendance = data.allAttendance.where((a) => a.studentId == student.id && a.date.startsWith(thisMonthStr)).toList();
      final monthPaid = data.allPayments.any((p) => p.studentId == student.id && p.forMonth == thisMonthStr);
      
      if (monthAttendance.length >= 4 && !monthPaid) {
        list.add(_SmartSuggestion(
          title: context.l10n.suggestionDebtorTitle,
          message: context.l10n.suggestionDebtorMessage(student.fullName),
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.purple,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentProfileScreen(studentId: student.id))),
          onConvertToTask: () => _convertToTask(context.l10n.suggestionDebtorTaskTitle(student.fullName), context.l10n.suggestionDebtorTaskTitle(student.fullName)),
        ));
      }
    }

    // 5. Inactive Active-Groups
    for (final g in data.groups.where((g) => g.isActive)) {
      final lastWeek = now.subtract(const Duration(days: 7));
      final hasRecentAtt = data.allAttendance.any((a) => a.groupId == g.id && DateTime.parse(a.date).isAfter(lastWeek));
      
      if (!hasRecentAtt && data.students.any((s) => s.groupId == g.id && s.isActive)) {
        list.add(_SmartSuggestion(
          title: context.l10n.suggestionInactiveTitle,
          message: context.l10n.suggestionInactiveMessage(g.name),
          icon: Icons.group_off_rounded,
          color: Colors.blueGrey,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(preGroupId: g.id))),
          onConvertToTask: () => _convertToTask(context.l10n.suggestionInactiveTaskTitle(g.name), context.l10n.suggestionInactiveTaskTitle(g.name)),
        ));
      }
    }

    // 6. Honor Board Nomination (100% in last 2)
    for (final student in data.students.where((s) => s.isActive)) {
      final last2 = data.allResults.where((r) => r.studentId == student.id).toList()
        ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
      
      if (last2.length >= 2 && last2.take(2).every((r) => r.percentage >= 95)) {
        list.add(_SmartSuggestion(
          title: context.l10n.suggestionHonorTitle,
          message: context.l10n.suggestionHonorMessage(student.fullName),
          icon: Icons.workspace_premium_rounded,
          color: Colors.amber,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HonorBoardScreen())),
          onConvertToTask: () => _convertToTask(context.l10n.suggestionHonorTaskTitle(student.fullName), context.l10n.suggestionHonorTaskTitle(student.fullName)),
        ));
      }
    }

    // 7. Missing Portal Codes for New Students
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    for (final student in data.students.where((s) => s.isActive)) {
      try {
        final joinDate = DateTime.parse(student.joinDate);
        if (joinDate.isAfter(tenDaysAgo) && (student.portalCode == null || student.portalCode!.isEmpty)) {
           list.add(_SmartSuggestion(
            title: context.l10n.suggestionPortalTitle,
            message: context.l10n.suggestionPortalMessage(student.fullName),
            icon: Icons.vpn_key_rounded,
            color: Colors.teal,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentProfileScreen(studentId: student.id))),
            onConvertToTask: () => _convertToTask(context.l10n.suggestionPortalTaskTitle(student.fullName), context.l10n.suggestionPortalTaskTitle(student.fullName)),
          ));
        }
      } catch (_) {}
    }

    // 8. Pending Quiz Grading
    for (final dynamic q in data.quizzes) {
      if (q.status != 'published') continue;
      final results = data.allResults.where((r) => r.quizId == q.id).toList();
      final groupStudents = data.students.where((s) => s.groupId == q.groupId && s.isActive).length;
      
      if (results.length < groupStudents && groupStudents > 0) {
        list.add(_SmartSuggestion(
          title: context.l10n.suggestionGradingTitle,
          message: context.l10n.suggestionGradingMessage(q.title, groupStudents - results.length),
          icon: Icons.grade_rounded,
          color: Colors.blue,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizResultsScreen(quizId: q.id))),
          onConvertToTask: () => _convertToTask(context.l10n.suggestionGradingTaskTitle(q.title), context.l10n.suggestionGradingTaskTitle(q.title)),
        ));
      }
    }

    // Default Fallback
    if (list.isEmpty) {
      final activeCount = data.students.where((s) => s.isActive).length;
      list.add(_SmartSuggestion(
        title: context.l10n.welcome,
        message: context.l10n.welcomeMessage(activeCount),
        icon: Icons.auto_awesome_rounded,
        color: Colors.teal,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentsScreen())),
      ));
    }

    return list;
  }
}

// ── Schedule Sheet Widget ─────────────────────────────────────────────────────

class _ScheduleSheet extends StatefulWidget {
  final List<GroupModel> groups;
  final List<StudentModel> students;
  final List<AttendanceRecord> todayAttendance;

  const _ScheduleSheet({
    required this.groups,
    required this.students,
    required this.todayAttendance,
  });

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  String _selectedDay = DateFormat('EEEE', 'en').format(DateTime.now()).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final dayGroups = widget.groups.where((g) => g.schedule.any((s) => s.day == _selectedDay)).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text(context.l10n.weeklySchedule, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index - DateTime.now().weekday + 1));
                final dayName = DateFormat('EEEE', 'en').format(date).toLowerCase();
                final dayNameAr = DateFormat('EEEE', Localizations.localeOf(context).languageCode).format(date);
                final dayNum = DateFormat('d').format(date);
                
                final sessionsCount = widget.groups.where((g) => g.schedule.any((s) => s.day == dayName)).length;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = dayName),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _selectedDay == dayName ? Theme.of(context).primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _selectedDay == dayName ? [
                        BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayNameAr.substring(0, 3), style: TextStyle(
                          color: _selectedDay == dayName ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )),
                        const SizedBox(height: 4),
                        Text(dayNum, style: TextStyle(
                          color: _selectedDay == dayName ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        )),
                        if (sessionsCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _selectedDay == dayName ? Colors.white : Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: dayGroups.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.no_sessions_on_this_day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: dayGroups.length,
                    itemBuilder: (context, index) {
                      final group = dayGroups[index];
                      final session = group.schedule.firstWhere((s) => s.day == _selectedDay);
                      final studentCount = widget.students.where((s) => s.groupId == group.id && s.isActive).length;
                      final color = sessionColors[index % sessionColors.length];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AttendanceScreen(preGroupId: group.id),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Group icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(20),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.menu_book_rounded, color: color, size: 24),
                                ),
                                const SizedBox(width: 14),
                                // Group info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.groups_rounded, size: 14, color: Colors.grey.shade400),
                                          const SizedBox(width: 4),
                                          Text(
                                            context.l10n.student_label_count(studentCount),
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Time badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${session.startTime} ${int.parse(session.startTime.split(':')[0]) >= 12 ? context.l10n.pm_suffix : context.l10n.am_suffix}',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

}

class _SmartSuggestion {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onConvertToTask;

  _SmartSuggestion({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.onTap,
    this.onConvertToTask,
  });
}
