import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import 'dart:math';


import '../../../../core/providers/db_providers.dart';
import '../../data/models/student_model.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../grades/data/models/grade_model.dart';
import '../../../quizzes/data/models/quiz_model.dart';
import '../../../payments/presentation/screens/add_payment_screen.dart';
import 'student_form_screen.dart';

class StudentProfileData {
  final StudentModel student;
  final GroupModel? group;
  final List<AttendanceRecord> attendance;
  final List<PaymentModel> payments;
  final List<GradeModel> grades;
  final List<QuizResultModel> quizResults;
  final List<GradeModel> groupGrades;
  final List<AttendanceRecord> groupAttendance;

  StudentProfileData({
    required this.student,
    this.group,
    required this.attendance,
    required this.payments,
    required this.grades,
    required this.quizResults,
    required this.groupGrades,
    required this.groupAttendance,
  });
}

final studentProfileDataProvider = FutureProvider.family<StudentProfileData, String>((ref, studentId) async {
  final students = await ref.watch(studentsProvider.future);
  final student = students.firstWhere((s) => s.id == studentId, orElse: () => throw Exception('Student not found'));

  final groups = await ref.watch(groupsProvider.future);
  final group = groups.where((g) => g.id == student.groupId).firstOrNull;

  final dbAttendance = ref.read(attendanceDbProvider);
  final attendance = await dbAttendance.filter({'student_id': studentId});

  final dbPayments = ref.read(paymentDbProvider);
  final payments = await dbPayments.filter({'student_id': studentId});

  final dbGrades = ref.read(gradeDbProvider);
  final grades = await dbGrades.filter({'student_id': studentId});

  final dbQuizResults = ref.read(quizResultDbProvider);
  final quizResults = await dbQuizResults.filter({'student_id': studentId});

  List<GradeModel> groupGrades = [];
  List<AttendanceRecord> groupAttendance = [];
  if (group != null) {
    groupGrades = await dbGrades.filter({'group_id': group.id});
    groupAttendance = await dbAttendance.filter({'group_id': group.id});
  }

  // Sorting
  attendance.sort((a, b) => b.date.compareTo(a.date));
  payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  grades.sort((a, b) => b.examDate.compareTo(a.examDate));
  quizResults.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

  return StudentProfileData(
    student: student,
    group: group,
    attendance: attendance,
    payments: payments,
    grades: grades,
    quizResults: quizResults,
    groupGrades: groupGrades,
    groupAttendance: groupAttendance,
  );
});

class StudentProfileScreen extends ConsumerStatefulWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncData = ref.watch(studentProfileDataProvider(widget.studentId));

    return Scaffold(
      backgroundColor: colorScheme.surfaceTint.withValues(alpha: 0.03),
      appBar: AppBar(
        title: Text(context.l10n.studentProfile, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorOccurred(e.toString()))),
        data: (data) {
          final s = data.student;
          final g = data.group;

          double getEffectivePrice() {
            if (g == null || s.isFreeStudent) return 0;
            if (s.studentMonthlyDiscount > 0) return g.defaultMonthlyPrice - s.studentMonthlyDiscount;
            return g.defaultMonthlyPrice - g.groupMonthlyDiscount;
          }

          final effectivePrice = getEffectivePrice();
          final thisMonthKey = DateFormat('yyyy-MM').format(DateTime.now());
          final monthlyPaid = data.payments.where((p) => p.forMonth == thisMonthKey).fold(0.0, (sum, p) => sum + p.amount);
          final balance = effectivePrice - monthlyPaid;
          
          final presentCount = data.attendance.where((a) => a.status == 'present').length;
          final totalAtt = data.attendance.length;
          final attRate = totalAtt > 0 ? (presentCount / totalAtt * 100).round() : 0;
          
          final totalPaid = data.payments.fold(0.0, (sum, p) => sum + p.amount);
          final avgGrade = data.grades.isNotEmpty 
            ? (data.grades.fold(0.0, (sum, g) => sum + (g.score / g.maxScore * 100)) / data.grades.length) 
            : null;

          Future<void> sendWhatsApp() async {
            final phone = s.parentPhoneNumber.isNotEmpty ? s.parentPhoneNumber : s.phoneNumber;
            if (phone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.noPhoneFound)));
              return;
            }
            final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
            final msg = Uri.encodeComponent(context.l10n.whatsappGenericGreeting(s.fullName));
            final url = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          }

          Future<void> generatePortalCode() async {
            final random = Random();
            final code = (100000 + random.nextInt(900000)).toString();
            await ref.read(studentDbProvider).update(s.id, {'portal_code': code});
            
            // تحديث المزودات لضمان ظهور الكود فوراً
            ref.invalidate(studentsProvider);
            ref.invalidate(studentProfileDataProvider(widget.studentId));

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.portalCodeGenerated)));
            }
          }

          return SafeArea(
            bottom: true,
            child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Profile Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade700,
                            child: Text(s.fullName.isNotEmpty ? s.fullName.substring(0, 1) : '?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.blue.shade700)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(s.fullName, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    if (s.isFreeStudent)
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)), child: Text(context.l10n.free, style: const TextStyle(color: Colors.green, fontSize: 10)))
                                  ],
                                ),
                                Text(g?.name ?? context.l10n.groupNotSet, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          if (s.phoneNumber.isNotEmpty || s.parentPhoneNumber.isNotEmpty)
                            Expanded(child: OutlinedButton.icon(
                              onPressed: sendWhatsApp,
                              icon: const Icon(Icons.mark_chat_unread_rounded, size: 20, color: Colors.green),
                              label: Text(context.l10n.whatsapp, style: const TextStyle(color: Colors.green)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green)),
                            )),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentFormScreen(studentToEdit: s),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: Text(context.l10n.edit),
                          )),
                          const SizedBox(width: 8),
                          Expanded(child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddPaymentScreen(preStudentId: s.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.payment, size: 16),
                            label: Text(context.l10n.payment),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stat Cards Grid
                      GridView.count(
                        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.2,
                        children: [
                          _buildMiniCard('$attRate%', '$presentCount/$totalAtt ${context.l10n.attendanceTab}', Colors.blue, context),
                          _buildMiniCard('${balance.abs().toStringAsFixed(0)} ج', s.isFreeStudent ? context.l10n.free : balance > 0 ? context.l10n.outstanding : balance < 0 ? context.l10n.creditBalance : context.l10n.complete, balance > 0 ? Colors.red : (balance < 0 ? Colors.green : Colors.grey.shade800), context),
                          _buildMiniCard('${totalPaid.toStringAsFixed(0)} ج', context.l10n.totalPaid, Colors.green, context),
                          _buildMiniCard(avgGrade != null ? '${avgGrade.toStringAsFixed(1)}%' : '—', context.l10n.averageGrade, Colors.purple, context),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Info Text Cards
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)), child: Padding(padding: const EdgeInsets.all(12), child: Column(
                              children: [
                                if (s.phoneNumber.isNotEmpty) _buildInfoRow(context.l10n.studentPhone, s.phoneNumber),
                                if (s.parentPhoneNumber.isNotEmpty) _buildInfoRow(context.l10n.parentPhone1, s.parentPhoneNumber),
                                if (!s.isFreeStudent) _buildInfoRow(context.l10n.monthlyPrice, '${effectivePrice.toStringAsFixed(0)} ج', isBold: true),
                              ],
                            ))),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)), child: Padding(padding: const EdgeInsets.all(12), child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.l10n.thisMonth, style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 4),
                                _buildInfoRow('المطلوب', '${effectivePrice.toStringAsFixed(0)} ج'),
                                _buildInfoRow('المدفوع', '${monthlyPaid.toStringAsFixed(0)} ج', valueColor: Colors.green),
                                const Divider(),
                                _buildInfoRow(context.l10n.remainingAmount,
                                  balance > 0 ? '${balance.toStringAsFixed(0)} ج' : (balance < 0 ? '${context.l10n.creditBalance} ${balance.abs().toStringAsFixed(0)} ج' : '${context.l10n.complete} ✓'),
                                  valueColor: balance > 0 ? Colors.red : Colors.green, isBold: true
                                )
                              ],
                            ))),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Student Portal Code section
                      Card(
                        elevation: 0,
                        color: colorScheme.primaryContainer.withAlpha(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.primary.withAlpha(50)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(context.l10n.portalCode, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                                    const SizedBox(height: 2),
                                    Text(s.portalCode ?? context.l10n.inactivePortalCode, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: s.portalCode == null ? colorScheme.outline : colorScheme.onPrimaryContainer)),
                                  ],
                                ),
                              ),
                              if (s.portalCode == null)
                                FilledButton.tonal(
                                  onPressed: generatePortalCode,
                                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                                  child: Text(context.l10n.activateCode, style: Theme.of(context).textTheme.labelSmall),
                                )
                              else
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: s.portalCode!));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم نسخ الكود إلى الحافظة')),
                                        );
                                      },
                                      icon: const Icon(Icons.copy_rounded, size: 20),
                                      color: colorScheme.primary,
                                    ),
                                    IconButton(
                                      onPressed: () => _sendWhatsApp(
                                        s.phoneNumber.isNotEmpty ? s.phoneNumber : s.parentPhoneNumber,
                                        'مرحباً ${s.fullName}،\n\nكود الدخول الخاص بك في تطبيق الأستاذ هو: *${s.portalCode}*\n\nيمكنك استخدامه الآن لمتابعة الحضور والدرجات.',
                                      ),
                                      icon: const Icon(Icons.share_rounded, size: 20),
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue.shade700,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.blue.shade700,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: context.l10n.performance),
                      Tab(text: context.l10n.attendanceTab),
                      Tab(text: context.l10n.paymentsTab),
                      Tab(text: context.l10n.gradesTab),
                      Tab(text: context.l10n.quizzesTab),
                      Tab(text: context.l10n.reportsTab),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildPerformanceTab(data, attRate, avgGrade, effectivePrice, monthlyPaid, context),
                _buildAttendanceTab(data.attendance, context),
                _buildPaymentsTab(data.payments, context),
                _buildGradesTab(data.grades, context),
                _buildQuizzesTab(data.quizResults, context),
                _buildChartsTab(data.quizResults, colorScheme, context),
              ],
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 11, color: valueColor ?? Colors.black87), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String value, String label, Color color, BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(StudentProfileData data, int attRate, double? avgGrade, double effectivePrice, double monthlyPaid, BuildContext context) {
    final groupAttCount = data.groupAttendance.where((a) => a.studentId != data.student.id && a.status == 'present').length;
    final groupTotalAtt = data.groupAttendance.where((a) => a.studentId != data.student.id).length;
    final groupAttRate = groupTotalAtt > 0 ? (groupAttCount / groupTotalAtt * 100).round() : 0;
    
    final groupOtherGrades = data.groupGrades.where((g) => g.studentId != data.student.id).toList();
    final groupAvgGrade = groupOtherGrades.isNotEmpty ? (groupOtherGrades.fold(0.0, (s, g) => s + (g.score / g.maxScore * 100)) / groupOtherGrades.length).round() : 0;
    
    final paymentScore = effectivePrice > 0 ? ((monthlyPaid / effectivePrice) * 100).clamp(0, 100).round() : 100;
    final totalQuizScore = data.quizResults.fold(0.0, (s, r) => s + r.percentage);
    final quizAvg = data.quizResults.isNotEmpty ? (totalQuizScore / data.quizResults.length).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRadarChartCard(
            studentAtt: attRate.toDouble(), groupAtt: groupAttRate.toDouble(),
            studentGrade: avgGrade ?? 0.0, groupGrade: groupAvgGrade.toDouble(),
            studentPayment: paymentScore.toDouble(), groupPayment: 100,
            studentQuiz: quizAvg.toDouble(), groupQuiz: 50,
            context: context
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: (attRate >= 75 && (avgGrade ?? 0) >= 70) ? Colors.green.shade50 : ((attRate < 50 || (avgGrade ?? 100) < 50) ? Colors.red.shade50 : Colors.amber.shade50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.overallPerformanceSummary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('• ${context.l10n.attendanceRateLabel}: $attRate% ${(attRate >= 75 ? "✅ ${context.l10n.excellent}" : attRate >= 50 ? "⚠️ ${context.l10n.needsImprovement}" : "❌ ${context.l10n.low}")}', style: TextStyle(color: attRate >= 75 ? Colors.green.shade800 : Colors.red.shade800)),
                  if (avgGrade != null) Text('• ${context.l10n.averageGrade}: ${avgGrade.toStringAsFixed(1)}% ${(avgGrade >= 75 ? "✅ ${context.l10n.excellent}" : avgGrade >= 50 ? "⚠️ ${context.l10n.acceptable}" : "❌ ${context.l10n.needsFollowUp}")}', style: TextStyle(color: avgGrade >= 75 ? Colors.green.shade800 : Colors.red.shade800)),
                  if (groupAvgGrade > 0 && avgGrade != null) Text('• ${context.l10n.comparisonToGroup}: ${avgGrade > groupAvgGrade ? context.l10n.higherThanGroupWithVal((avgGrade - groupAvgGrade).toStringAsFixed(1)) : context.l10n.lowerThanGroupWithVal((groupAvgGrade - avgGrade).toStringAsFixed(1))}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('• ${context.l10n.payment}: $paymentScore% ${paymentScore >= 100 ? "✅ ${context.l10n.complete}" : "⚠️ ${context.l10n.incomplete}"}', style: TextStyle(color: paymentScore >= 100 ? Colors.green.shade800 : Colors.red.shade800)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRadarChartCard({required double studentAtt, required double groupAtt, required double studentGrade, required double groupGrade, required double studentPayment, required double groupPayment, required double studentQuiz, required double groupQuiz, required BuildContext context}) {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.overallComparison, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: RadarChart(
                RadarChartData(
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  gridBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                    getTitle: (index, angle) {
                    final titles = [context.l10n.attendanceTab, context.l10n.gradesTab, context.l10n.payment, context.l10n.quizzesTab];
                    return RadarChartTitle(text: titles[index], angle: 0, positionPercentageOffset: 0.1);
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.blue.withValues(alpha: 0.3),
                      borderColor: Colors.blue,
                      entryRadius: 3,
                      dataEntries: [RadarEntry(value: studentAtt), RadarEntry(value: studentGrade), RadarEntry(value: studentPayment), RadarEntry(value: studentQuiz)],
                      borderWidth: 2,
                    ),
                    RadarDataSet(
                      fillColor: Colors.grey.withValues(alpha: 0.2),
                      borderColor: Colors.grey,
                      entryRadius: 0,
                      dataEntries: [RadarEntry(value: groupAtt), RadarEntry(value: groupGrade), RadarEntry(value: groupPayment), RadarEntry(value: groupQuiz)],
                      borderWidth: 1,
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stop, color: Colors.blue, size: 16), Text(' ${context.l10n.student}', style: TextStyle(fontSize: 12)),
                SizedBox(width: 16),
                Icon(Icons.stop, color: Colors.grey, size: 16), Text(' ${context.l10n.group}', style: TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTab(List<AttendanceRecord> records, BuildContext context) {
    if (records.isEmpty) return Center(child: Text(context.l10n.noAttendanceRecords, style: const TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final a = records[i];
        final isPresent = a.status == 'present';
        return Card(
          elevation: 0, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            title: Text(a.date, style: Theme.of(context).textTheme.bodyMedium),
            subtitle: a.notes.isNotEmpty ? Text(a.notes, style: Theme.of(context).textTheme.bodySmall) : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: isPresent ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text(isPresent ? context.l10n.present : context.l10n.absent, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isPresent ? Colors.green.shade700 : Colors.red.shade700)),
            )
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab(List<PaymentModel> payments, BuildContext context) {
    if (payments.isEmpty) return Center(child: Text(context.l10n.noPaymentRecords, style: const TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (ctx, i) {
        final p = payments[i];
        return Card(
          elevation: 0, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            title: Text('${p.amount.toStringAsFixed(0)} ج', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green)),
            subtitle: Text('${p.forMonth} · ${p.method}', style: Theme.of(context).textTheme.bodySmall),
            trailing: Text(p.paymentDate, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
          ),
        );
      },
    );
  }

  Widget _buildGradesTab(List<GradeModel> grades, BuildContext context) {
    if (grades.isEmpty) return Center(child: Text(context.l10n.noGradesFound, style: const TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grades.length,
      itemBuilder: (ctx, i) {
        final g = grades[i];
        final pct = (g.score / g.maxScore) * 100;
        return Card(
          elevation: 0, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            title: Text(g.examName, style: Theme.of(context).textTheme.bodyMedium),
            subtitle: Text(g.examDate, style: Theme.of(context).textTheme.bodySmall),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${g.score}/${g.maxScore}', style: Theme.of(context).textTheme.bodyMedium),
                Text('${pct.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            )
          ),
        );
      },
    );
  }

  Widget _buildQuizzesTab(List<QuizResultModel> quizzes, BuildContext context) {
    if (quizzes.isEmpty) return Center(child: Text(context.l10n.noQuizzesFound, style: const TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (ctx, i) {
        final q = quizzes[i];
        final dateObj = DateTime.tryParse(q.submittedAt);
        final dateStr = dateObj != null ? DateFormat('yyyy-MM-dd').format(dateObj) : q.submittedAt;
        return Card(
          elevation: 0, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            title: Text(q.quizTitle, style: const TextStyle(fontSize: 14)),
            subtitle: Text(dateStr, style: const TextStyle(fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text('${q.percentage.toStringAsFixed(0)}%', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
            )
          ),
        );
      },
    );
  }

  Widget _buildChartsTab(List<QuizResultModel> quizzes, ColorScheme colors, BuildContext context) {
    if (quizzes.isEmpty) {
      return Center(child: Text(context.l10n.notEnoughQuizzesForChart, style: const TextStyle(color: Colors.grey)));
    }

    // Sort by date just in case
    final sorted = List<QuizResultModel>.from(quizzes)..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
    
    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
        spots.add(FlSpot(i.toDouble(), sorted[i].percentage));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.studentProgressChart, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
             child: Card(
               elevation: 0,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: LineChart(
                   LineChartData(
                     minY: 0,
                     maxY: 100,
                     gridData: const FlGridData(show: true, drawVerticalLine: false),
                     titlesData: FlTitlesData(
                       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       bottomTitles: AxisTitles(
                         sideTitles: SideTitles(
                           showTitles: true,
                           interval: 1,
                           getTitlesWidget: (value, meta) {
                             if (value.toInt() >= 0 && value.toInt() < sorted.length) {
                               return Padding(
                                 padding: const EdgeInsets.only(top: 8.0),
                                 child: Text(
                                   '#${value.toInt() + 1}',
                                   style: const TextStyle(fontSize: 10, color: Colors.grey),
                                 ),
                               );
                             }
                             return const SizedBox();
                           },
                         ),
                       ),
                     ),
                     borderData: FlBorderData(show: false),
                     lineBarsData: [
                       LineChartBarData(
                         spots: spots,
                         isCurved: true,
                         color: colors.primary,
                         barWidth: 3,
                         isStrokeCapRound: true,
                         dotData: const FlDotData(show: true),
                         belowBarData: BarAreaData(
                           show: true,
                           color: colors.primary.withAlpha(25),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             ),
          )
        ],
      ),
    );
  }

  Future<void> _sendWhatsApp(String phone, String message) async {
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
