import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../students/data/models/student_model.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التذكيرات الذكية', style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person_off_rounded), text: 'غياب اليوم'),
            Tab(icon: Icon(Icons.money_off_rounded), text: 'متأخرات الدفع'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AbsentTodayTab(),
          _DebtRemindersTab(),
        ],
      ),
    );
  }
}

class _AbsentTodayTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final attendanceAsync = ref.watch(attendanceProvider);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return attendanceAsync.when(
      data: (allAttendance) {
        final todayAbsents = allAttendance.where((a) => a.date == today && a.status == 'absent').toList();
        
        if (todayAbsents.isEmpty) {
          return _EmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'لا يوجد غياب اليوم',
            subtitle: 'جميع الطلاب مسجل حضورهم أو لم يبدأ العمل بعد.',
          );
        }

        return studentsAsync.when(
          data: (students) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todayAbsents.length,
              itemBuilder: (context, index) {
                final record = todayAbsents[index];
                final student = students.firstWhere((s) => s.id == record.studentId, orElse: () => StudentModel(id: '', fullName: 'غير معروف', updatedDate: '', createdDate: ''));
                
                return _ReminderCard(
                  title: student.fullName,
                  subtitle: 'غائب اليوم - ${student.phoneNumber}',
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: Colors.green,
                  onTap: () => _sendWhatsApp(
                    student.parentPhoneNumber.isNotEmpty ? student.parentPhoneNumber : student.phoneNumber,
                    'مرحباً ولي أمر الطالب ${student.fullName}، نحيطكم علماً بأن الطالب قد تغيب عن حصة اليوم بتاريخ $today. نرجو المتابعة.',
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error Student: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error Attendance: $err')),
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

class _DebtRemindersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final paymentsAsync = ref.watch(paymentsProvider);
    final groupsAsync = ref.watch(groupsProvider);
    
    final thisMonth = DateFormat('yyyy-MM').format(DateTime.now());

    return studentsAsync.when(
      data: (students) {
        final groupList = groupsAsync.value ?? [];
        final paymentList = paymentsAsync.value ?? [];
        
        // Filter students with debt this month
        final debtorStudents = students.where((s) {
          if (s.isFreeStudent) return false;
          final group = groupList.where((g) => g.id == s.groupId).firstOrNull;
          if (group == null) return false;
          
          final effectivePrice = s.studentMonthlyDiscount > 0 
              ? (group.defaultMonthlyPrice - s.studentMonthlyDiscount)
              : (group.defaultMonthlyPrice - group.groupMonthlyDiscount);
          
          final paidThisMonth = paymentList
              .where((p) => p.studentId == s.id && p.forMonth == thisMonth)
              .fold(0.0, (sum, p) => sum + p.amount);
          
          return paidThisMonth < effectivePrice;
        }).toList();

        if (debtorStudents.isEmpty) {
          return _EmptyState(
            icon: Icons.monetization_on_outlined,
            title: 'لا توجد مديونيات',
            subtitle: 'جميع الطلاب سددوا مستحقات هذا الشهر.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: debtorStudents.length,
          itemBuilder: (context, index) {
            final student = debtorStudents[index];
            return _ReminderCard(
              title: student.fullName,
              subtitle: 'لم يسدد اشتراك شهر ${DateFormat('MMMM', 'ar').format(DateTime.now())}',
              icon: Icons.send_rounded,
              iconColor: Colors.blue,
              onTap: () => _sendWhatsApp(
                student.parentPhoneNumber.isNotEmpty ? student.parentPhoneNumber : student.phoneNumber,
                'مرحباً ولي أمر الطالب ${student.fullName}، نود تذكيركم بضرورة سداد اشتراك الشهر الحالي لضمان استمرارية الطالب في المجموعة. شكراً لتفهمكم.',
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
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

class _ReminderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ReminderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withAlpha(30)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Text(title.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withAlpha(150))),
        trailing: FilledButton.tonalIcon(
          onPressed: onTap,
          icon: Icon(icon, size: 16),
          label: const Text('تذكير', style: TextStyle(fontSize: 12)),
          style: FilledButton.styleFrom(
            backgroundColor: iconColor.withAlpha(20),
            foregroundColor: iconColor,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: colorScheme.primary.withAlpha(80)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurface.withAlpha(150))),
          ],
        ),
      ),
    );
  }
}
