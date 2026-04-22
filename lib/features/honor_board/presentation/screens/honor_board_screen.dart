import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../students/data/models/student_model.dart';
import '../../data/models/honor_point_model.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/student_auth_provider.dart';

class HonorStudent {
  final StudentModel student;
  final double totalScore;
  final double avgQuizScore;
  final double attendanceRate;
  final Map<String, double> pointsByReason;

  HonorStudent({
    required this.student,
    required this.totalScore,
    required this.avgQuizScore,
    required this.attendanceRate,
    this.pointsByReason = const {},
  });
}

final honorBoardFiltersProvider = StateProvider<String?>((ref) => null);

final honorBoardProvider = Provider<AsyncValue<List<HonorStudent>>>((ref) {
  final studentsAsync = ref.watch(studentsProvider);
  final attendanceAsync = ref.watch(attendanceProvider);
  final quizzesAsync = ref.watch(allQuizResultsProvider);
  final pointsAsync = ref.watch(honorPointsProvider);

  if (studentsAsync.isLoading || attendanceAsync.isLoading || quizzesAsync.isLoading || pointsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (studentsAsync.hasError || attendanceAsync.hasError || quizzesAsync.hasError || pointsAsync.hasError) {
    return AsyncValue.error('Error loading data', StackTrace.current);
  }

  final students = studentsAsync.value!;
  final allAttendance = attendanceAsync.value!;
  final allQuizzes = quizzesAsync.value!;
  final allPoints = pointsAsync.value!;
  final filterGroup = ref.watch(honorBoardFiltersProvider);

  List<HonorStudent> honorList = [];

  for (var student in students) {
    if (filterGroup != null && filterGroup.isNotEmpty && student.groupId != filterGroup) {
      continue;
    }

    double automatedPoints = 0;
    final studentAttendance = allAttendance.where((a) => a.studentId == student.id).toList();
    final presentCount = studentAttendance.where((a) => a.status == 'present').length;
    automatedPoints += (presentCount * 5.0);

    final studentQuizzes = allQuizzes.where((r) => r.studentId == student.id).toList();
    final fullGradesCount = studentQuizzes.where((q) => q.percentage >= 100).length;
    automatedPoints += (fullGradesCount * 5.0);

    double avgQuizScore = 0.0;
    if (studentQuizzes.isNotEmpty) {
      avgQuizScore = studentQuizzes.map((q) => q.percentage).fold(0.0, (a, b) => a + b) / studentQuizzes.length;
    }

    double attendanceRate = 100.0;
    if (studentAttendance.isNotEmpty) {
      final presentOrExcused = studentAttendance.where((a) => a.status == 'present' || a.status == 'excused').length;
      attendanceRate = (presentOrExcused / studentAttendance.length) * 100;
    }

    final studentManualPoints = allPoints.where((p) => p.studentId == student.id).toList();
    final totalManualPoints = studentManualPoints.fold(0.0, (sum, p) => sum + p.points);
    
    Map<String, double> reasonMap = {
      "درجات مرتفعة": (fullGradesCount * 5.0),
      "حضور منتظم": (presentCount * 5.0),
      "واجبات": 0.0,
      "سلوك ممتاز": 0.0,
      "أخرى": 0.0,
      "مشاركة فعالة": 0.0,
    };
    
    for (var p in studentManualPoints) {
      reasonMap[p.reason] = (reasonMap[p.reason] ?? 0) + p.points;
    }

    double totalScore = (avgQuizScore * 0.7) + (attendanceRate * 0.3) + totalManualPoints + automatedPoints;

    if (studentQuizzes.isNotEmpty || studentAttendance.isNotEmpty || totalManualPoints > 0 || automatedPoints > 0) {
      honorList.add(HonorStudent(
        student: student,
        totalScore: totalScore,
        avgQuizScore: avgQuizScore,
        attendanceRate: attendanceRate,
        pointsByReason: reasonMap,
      ));
    }
  }

  honorList.sort((a, b) => b.totalScore.compareTo(a.totalScore));
  return AsyncValue.data(honorList);
});

class HonorBoardScreen extends ConsumerStatefulWidget {
  const HonorBoardScreen({super.key});

  @override
  ConsumerState<HonorBoardScreen> createState() => _HonorBoardScreenState();
}

class _HonorBoardScreenState extends ConsumerState<HonorBoardScreen> with SingleTickerProviderStateMixin {
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

  void _showGrantPointsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GrantPointsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final honorListAsync = ref.watch(honorBoardProvider);
    final isTeacher = ref.watch(isTeacherAuthenticatedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("المعلم الذكي", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D3436), fontSize: 22)),
            const Text("Smart Assistant", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE67E22), borderRadius: BorderRadius.circular(12)),
            child: const IconButton(onPressed: null, icon: Icon(Icons.school, color: Colors.white)),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu, color: Colors.grey)),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE67E22),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFE67E22),
          tabs: const [
            Tab(text: "الترتيب والشرف"),
            Tab(text: "سجل النقاط"),
          ],
        ),
      ),
      body: SafeArea(
        child: honorListAsync.when(
          data: (list) => TabBarView(
            controller: _tabController,
            children: [
              _buildRankingTab(list, colorScheme, theme, isTeacher),
              _buildPointsLogTab(colorScheme),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildRankingTab(List<HonorStudent> list, ColorScheme colorScheme, ThemeData theme, bool isTeacher) {
    if (list.isEmpty) return const Center(child: Text("لا يوجد بيانات"));
    final topStudent = list.first;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 25),
                    width: 140,
                    height: 160,
                    decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text("1", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  Container(
                    width: 120,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
                    child: Column(
                      children: [
                        const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 30),
                        Text(topStudent.student.fullName.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(topStudent.totalScore.toStringAsFixed(0), style: const TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("توزيع النقاط حسب السبب", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _buildReasonCard("درجات مرتفعة", topStudent.pointsByReason["درجات مرتفعة"] ?? 0, const Color(0xFFE3F2FD), Colors.blue, Icons.library_books),
                  _buildReasonCard("حضور منتظم", topStudent.pointsByReason["حضور منتظم"] ?? 0, const Color(0xFFE8F5E9), Colors.green, Icons.check_box),
                  _buildReasonCard("واجبات", topStudent.pointsByReason["واجبات"] ?? 0, const Color(0xFFF3E5F5), Colors.purple, Icons.edit_note),
                  _buildReasonCard("سلوك ممتاز", topStudent.pointsByReason["سلوك ممتاز"] ?? 0, const Color(0xFFFFF8E1), Colors.amber, Icons.star),
                  _buildReasonCard("أخرى", topStudent.pointsByReason["أخرى"] ?? 0, const Color(0xFFF5F5F5), Colors.grey, Icons.emoji_events),
                  _buildReasonCard("مشاركة فعالة", topStudent.pointsByReason["مشاركة فعالة"] ?? 0, const Color(0xFFFFF3E0), Colors.orange, Icons.person),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (isTeacher)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showGrantPointsSheet,
              icon: const Icon(Icons.add_circle, color: Colors.white),
              label: const Text("منح نقاط جديدة"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
        const SizedBox(height: 30),
        const Text("الترتيب الكامل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 15),
        ...list.asMap().entries.map((entry) => _buildRankingItem(entry.value, entry.key, colorScheme)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildRankingItem(HonorStudent h, int index, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(color: index < 3 ? const Color(0xFFFFD700).withValues(alpha: 0.2) : Colors.grey.shade100, shape: BoxShape.circle),
            child: Center(child: Text("${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: index < 3 ? const Color(0xFFE67E22) : Colors.grey))),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(h.student.fullName, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(h.totalScore.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22))),
          const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
        ],
      ),
    );
  }

  Widget _buildReasonCard(String label, double value, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                Text(value.toStringAsFixed(0), style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsLogTab(ColorScheme colorScheme) {
    final allPointsAsync = ref.watch(honorPointsProvider);
    final studentsAsync = ref.watch(studentsProvider);
    final isTeacher = ref.watch(isTeacherAuthenticatedProvider);
    final currentStudent = ref.watch(currentStudentProvider);

    return allPointsAsync.when(
      data: (points) {
        // Teacher sees all, Student sees only their own points
        final filteredPoints = isTeacher
            ? points
            : points.where((p) => p.studentId == currentStudent?.id).toList();

        return Column(
          children: [
            // Reset All button — Teacher only
            if (isTeacher && points.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    label: const Text("مسح جميع النقاط والبدء من الصفر",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () async {
                      // Capture context-dependent objects BEFORE any await
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);

                      // First confirmation
                      final first = await showDialog<bool>(
                        context: nav.context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("⚠️ تأكيد المسح"),
                          content: const Text("هل أنت متأكد من مسح جميع النقاط لجميع الطلاب؟\nلا يمكن التراجع عن هذه العملية."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("نعم، امسح", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (first != true) return;

                      // Second confirmation — use the nav object captured before any await
                      final second = await nav.push<bool>(
                        DialogRoute<bool>(
                          context: nav.context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.red.shade50,
                            title: const Text("🚨 تأكيد نهائي", style: TextStyle(color: Colors.red)),
                            content: const Text("هذا الإجراء سيحذف نقاط لوحة الشرف لجميع الطلاب نهائياً.\nهل تريد المتابعة؟"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("مسح الكل", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (second != true) return;

                      // Delete all
                      final db = ref.read(honorPointDbProvider);
                      for (final p in points) {
                        await db.delete(p.id);
                      }
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("تم مسح جميع النقاط بنجاح"),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Points list
            Expanded(
              child: filteredPoints.isEmpty
                  ? const Center(child: Text("لا يوجد سجل"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredPoints.length,
                      itemBuilder: (context, index) {
                        final sorted = List<HonorPointModel>.from(filteredPoints)
                          ..sort((a, b) => b.date.compareTo(a.date));
                        final p = sorted[index];
                        final student = studentsAsync.value?.firstWhere(
                          (s) => s.id == p.studentId,
                          orElse: () => studentsAsync.value!.first,
                        );
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            title: Text(isTeacher ? (student?.fullName ?? "طالب") : p.reason),
                            subtitle: Text(isTeacher
                                ? "${p.reason} • ${p.date.toLocal().toString().split(' ')[0]}"
                                : p.date.toLocal().toString().split(' ')[0]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("+${p.points.toStringAsFixed(0)}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
                                if (isTeacher) ...[
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("تأكيد الحذف"),
                                          content: const Text("هل أنت متأكد من حذف هذه النقاط؟"),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text("حذف", style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await ref.read(honorPointDbProvider).delete(p.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("تم الحذف بنجاح")),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(e.toString()),
    );
  }
}

class GrantPointsBottomSheet extends ConsumerStatefulWidget {
  const GrantPointsBottomSheet({super.key});

  @override
  ConsumerState<GrantPointsBottomSheet> createState() => _GrantPointsBottomSheetState();
}

class _GrantPointsBottomSheetState extends ConsumerState<GrantPointsBottomSheet> {
  List<String> selectedStudentIds = [];
  double points = 10;
  String selectedReason = "حضور منتظم";
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? selectedGroupId;

  final List<Map<String, dynamic>> reasons = [
    {"label": "درجات مرتفعة", "icon": Icons.library_books},
    {"label": "حضور منتظم", "icon": Icons.check_box},
    {"label": "واجبات", "icon": Icons.edit_note},
    {"label": "سلوك ممتاز", "icon": Icons.star},
    {"label": "أخرى", "icon": Icons.emoji_events},
    {"label": "مشاركة فعالة", "icon": Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final groupsAsync = ref.watch(groupsProvider);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("منح نقاط للطلاب", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 20),
            
            // Group Filter
            const Text("تصفية بالمجموعة", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: groupsAsync.when(
                  data: (groups) => DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("الكل"),
                    value: selectedGroupId,
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text("الكل")),
                      ...groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedGroupId = val;
                        selectedStudentIds.clear(); // Clear selections when filter changes
                      });
                    },
                  ),
                  loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text(e.toString()),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text("اختر الطلاب *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE67E22)), borderRadius: BorderRadius.circular(15)),
              child: studentsAsync.when(
                data: (students) {
                  final filteredStudents = selectedGroupId == null ? students : students.where((s) => s.groupId == selectedGroupId).toList();
                  if (filteredStudents.isEmpty) return const Center(child: Text("لا يوجد طلاب في هذه المجموعة"));
                  return ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (ctx, i) {
                      final s = filteredStudents[i];
                      final isSelected = selectedStudentIds.contains(s.id);
                      return CheckboxListTile(
                        activeColor: const Color(0xFFE67E22),
                        title: Text(s.fullName, style: const TextStyle(fontSize: 14)),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedStudentIds.add(s.id);
                            } else {
                              selectedStudentIds.remove(s.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("التاريخ", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                          if (d != null) setState(() => selectedDate = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${selectedDate.month}/${selectedDate.day}/${selectedDate.year}"), const Icon(Icons.calendar_today, size: 18, color: Colors.grey)]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("عدد النقاط *", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            Column(children: [InkWell(onTap: () => setState(() => points++), child: const Icon(Icons.arrow_drop_up, size: 20)), InkWell(onTap: () => setState(() => points > 0 ? points-- : null), child: const Icon(Icons.arrow_drop_down, size: 20))]),
                            const Spacer(),
                            Text(points.toStringAsFixed(0), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("السبب *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.8, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: reasons.length,
              itemBuilder: (context, i) {
                final r = reasons[i];
                final isSelected = selectedReason == r["label"];
                return InkWell(
                  onTap: () => setState(() => selectedReason = r["label"]),
                  child: Container(
                    decoration: BoxDecoration(color: isSelected ? const Color(0xFFFFF3E0) : Colors.white, border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.grey.shade300), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [if (isSelected) const Icon(Icons.check_box, color: Colors.green, size: 18), const SizedBox(width: 5), Text(r["label"], style: TextStyle(color: isSelected ? const Color(0xFFE67E22) : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)), const SizedBox(width: 5), Icon(r["icon"], color: isSelected ? const Color(0xFFE67E22) : Colors.grey, size: 18)],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text("ملاحظة (اختياري)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: notesController, decoration: InputDecoration(hintText: "...ملاحظة", filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedStudentIds.isEmpty ? null : _submit,
                icon: const Icon(Icons.star, color: Color(0xFFFFD700)),
                label: Text("منح النقاط لـ (${selectedStudentIds.length}) طلاب", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFCC80), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    final db = ref.read(honorPointDbProvider);
    final students = ref.read(studentsProvider).value;
    
    // Save the states before async operations and popping
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    for (var studentId in selectedStudentIds) {
      final student = students?.firstWhere((s) => s.id == studentId);
      final model = HonorPointModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + studentId,
        studentId: studentId,
        groupId: student?.groupId ?? "",
        points: points,
        date: selectedDate,
        reason: selectedReason,
        notes: notesController.text,
      );
      await db.create(model.toMap());
    }

    if (mounted) {
      // 1. Close the BottomSheet first
      navigator.pop();
      
      // 2. Show the success message using the saved messenger
      messenger.showSnackBar(
        const SnackBar(
          content: Text("تم منح النقاط بنجاح", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
