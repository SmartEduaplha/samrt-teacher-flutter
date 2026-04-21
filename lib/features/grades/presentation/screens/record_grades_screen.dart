import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../data/models/grade_model.dart';
import '../../../students/data/models/student_model.dart';
import '../../../announcements/data/models/announcement_model.dart';

class RecordGradesScreen extends ConsumerStatefulWidget {
  const RecordGradesScreen({super.key});

  @override
  ConsumerState<RecordGradesScreen> createState() => _RecordGradesScreenState();
}

class _RecordGradesScreenState extends ConsumerState<RecordGradesScreen> {
  String? _selectedGroupId;
  String _selectedExamType = 'امتحان حصة';
  late DateTime _selectedDate;
  
  double _currentMaxScore = 10.0;
  
  final Map<String, TextEditingController> _gradeControllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    for (var controller in _gradeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateMaxScore() {
    if (_selectedGroupId == null) return;
    final groups = ref.read(groupsProvider).value ?? [];
    final settings = ref.read(settingsProvider);
    final group = groups.where((g) => g.id == _selectedGroupId).firstOrNull;
    
    if (group != null) {
      if (_selectedExamType == 'امتحان شهر') {
        _currentMaxScore = group.monthlyExamGrade ?? settings.defaultMonthlyExamGrade;
      } else {
        _currentMaxScore = group.quizGrade ?? settings.defaultQuizGrade;
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveGrades(List<StudentModel> students) async {
    if (_selectedGroupId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final gradesDb = ref.read(gradeDbProvider);
      final announcementDb = ref.read(announcementDbProvider);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      for (final student in students) {
        final ctrl = _gradeControllers[student.id];
        if (ctrl != null && ctrl.text.trim().isNotEmpty) {
          final score = double.tryParse(ctrl.text.trim());
          if (score != null) {
            final gradeId = '${student.id}_${_selectedExamType}_$dateStr';
            final grade = GradeModel(
              id: gradeId,
              studentId: student.id,
              groupId: _selectedGroupId!,
              examName: _selectedExamType,
              score: score,
              maxScore: _currentMaxScore,
              examDate: dateStr,
            );
            
            await gradesDb.create(grade.toMap());
            
            // Notification logic
            final announcementId = '${DateTime.now().millisecondsSinceEpoch}_${student.id}';
            final msg = 'تم رصد درجة $_selectedExamType\nالدرجة: $score / $_currentMaxScore';
            // Assuming AnnouncementModel doesn't have studentId currently, we put the student name in the title/content.
            final personalAnn = AnnouncementModel(
              id: announcementId,
              title: 'نتيجة امتحان للطالب: ${student.fullName}',
              content: msg,
              priority: AnnouncementPriority.medium,
              createdAt: DateTime.now(),
              groupId: _selectedGroupId,
            );
            await announcementDb.create(personalAnn.toMap());
          }
        }
      }
      
      ref.invalidate(gradesByGroupProvider(_selectedGroupId!));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل الدرجات بنجاح وإرسال الإشعارات'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeGroupsList = ref.watch(activeGroupsProvider).value ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل درجات امتحان'),
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'اختر المجموعة', border: OutlineInputBorder()),
                  initialValue: _selectedGroupId,
                  items: activeGroupsList.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedGroupId = val;
                      _updateMaxScore();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'نوع الامتحان', border: OutlineInputBorder()),
                        initialValue: _selectedExamType,
                        items: ['امتحان حصة', 'امتحان شهر'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedExamType = val!;
                            _updateMaxScore();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('dd / MM / yyyy').format(_selectedDate)),
                              const Icon(Icons.calendar_today_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Students List
          Expanded(
            child: _selectedGroupId == null
                ? const Center(child: Text('اختر المجموعة ل عرض الطلاب'))
                : _buildStudentsList(_selectedGroupId!),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(String groupId) {
    final studentsAsync = ref.watch(studentsByGroupProvider(groupId));
    
    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (students) {
        if (students.isEmpty) {
          return const Center(child: Text('لا يوجد طلاب نشطون في هذه المجموعة'));
        }
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Text('الدرجة النهائية لهذا الامتحان: ${_currentMaxScore.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final s = students[index];
                  _gradeControllers.putIfAbsent(s.id, () => TextEditingController());
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Text(s.fullName.substring(0, 1)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _gradeControllers[s.id],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'الدرجة',
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : () => _saveGrades(students),
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_rounded),
                  label: Text(_isLoading ? 'جاري الحفظ...' : 'حفظ الدرجات'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
