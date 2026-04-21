import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import 'record_grades_screen.dart';

class GradesDashboardScreen extends ConsumerStatefulWidget {
  const GradesDashboardScreen({super.key});

  @override
  ConsumerState<GradesDashboardScreen> createState() => _GradesDashboardScreenState();
}

class _GradesDashboardScreenState extends ConsumerState<GradesDashboardScreen> {
  String? _selectedGroupId;

  @override
  Widget build(BuildContext context) {
    final activeGroupsList = ref.watch(activeGroupsProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الدرجات'), // Grades Management
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordGradesScreen()));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('تسجيل درجات'),
      ),
      body: activeGroupsList.isEmpty
          ? const Center(child: Text('لا توجد مجموعات نشطة بعد'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'اختر المجموعة لعرض درجاتها',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedGroupId,
                    items: activeGroupsList.map((g) {
                      return DropdownMenuItem(
                        value: g.id,
                        child: Text(g.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedGroupId = val;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _selectedGroupId == null
                      ? const Center(child: Text('الرجاء اختيار مجموعة للبدء'))
                      : _buildGradesList(context, _selectedGroupId!),
                ),
              ],
            ),
    );
  }

  Widget _buildGradesList(BuildContext context, String groupId) {
    final gradesAsync = ref.watch(gradesByGroupProvider(groupId));

    return gradesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (grades) {
        if (grades.isEmpty) {
          return const Center(child: Text('لم يتم تسجيل درجات لهذه المجموعة بعد.'));
        }

        // Group the grades by examName & examDate
        final groupedGrades = <String, List<dynamic>>{};
        for (var grade in grades) {
          final key = '${grade.examName}|${grade.examDate}|${grade.maxScore}';
          groupedGrades.putIfAbsent(key, () => []).add(grade);
        }

        final sortedKeys = groupedGrades.keys.toList()..sort((a, b) {
          final dateA = a.split('|')[1];
          final dateB = b.split('|')[1];
          return dateB.compareTo(dateA); // newest first
        });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final key = sortedKeys[index];
            final examGrades = groupedGrades[key]!;
            final parts = key.split('|');
            final examName = parts[0];
            final examDate = parts[1];
            final maxScoreStr = parts.length > 2 ? parts[2] : '';

            // Calc avg and pass/fail? Maybe just total registered students
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.assignment_turned_in_rounded, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(examName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('التاريخ: $examDate  |  الدرجة النهائية: $maxScoreStr'),
                children: [
                  ...examGrades.map((grade) {
                    final studentAsync = ref.watch(studentsProvider);
                    final students = studentAsync.value ?? [];
                    final studentName = students.firstWhere((s) => s.id == grade.studentId, orElse: () => students.first).fullName;
                    
                    return ListTile(
                      title: Text(studentName),
                      trailing: Text('${grade.score} / ${grade.maxScore}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    );
                  })
                ],
              ),
            );
          },
        );
      },
    );
  }
}
