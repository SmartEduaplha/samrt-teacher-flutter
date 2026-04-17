import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../students/data/models/student_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/providers/db_providers.dart';

class HonorStudent {
  final StudentModel student;
  final double totalScore;
  final double avgQuizScore;
  final double attendanceRate;

  HonorStudent({
    required this.student,
    required this.totalScore,
    required this.avgQuizScore,
    required this.attendanceRate,
  });
}

final honorBoardFiltersProvider = StateProvider<String?>((ref) => null); // null means All Groups

final honorBoardProvider = Provider<AsyncValue<List<HonorStudent>>>((ref) {
  final studentsAsync = ref.watch(studentsProvider);
  final attendanceAsync = ref.watch(attendanceProvider);
  final quizzesAsync = ref.watch(allQuizResultsProvider);

  if (studentsAsync.isLoading ||
      attendanceAsync.isLoading ||
      quizzesAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (studentsAsync.hasError ||
      attendanceAsync.hasError ||
      quizzesAsync.hasError) {
    return AsyncValue.error('Error loading data', StackTrace.current);
  }

  final students = studentsAsync.value!;
  final allAttendance = attendanceAsync.value!;
  final allQuizzes = quizzesAsync.value!;
  final filterGroup = ref.watch(honorBoardFiltersProvider);

  List<HonorStudent> honorList = [];

  for (var student in students) {
    if (filterGroup != null && filterGroup.isNotEmpty && student.groupId != filterGroup) {
      continue;
    }

    // 1. Calculate Average Quiz Score (Scaled to 100)
    final studentQuizzes = allQuizzes.where((r) => r.studentId == student.id).toList();
    double avgQuizScore = 0.0;
    if (studentQuizzes.isNotEmpty) {
      avgQuizScore =
          studentQuizzes.map((q) => q.percentage).fold(0.0, (a, b) => a + b) /
              studentQuizzes.length;
    }

    // 2. Calculate Attendance Rate (Scaled to 100)
    final studentAttendance =
        allAttendance.where((a) => a.studentId == student.id).toList();
    double attendanceRate = 100.0; // Default if no classes yet
    if (studentAttendance.isNotEmpty) {
      final presentOrExcused = studentAttendance
          .where((a) => a.status == 'present' || a.status == 'excused')
          .length;
      attendanceRate = (presentOrExcused / studentAttendance.length) * 100;
    }

    // 3. Total Score: 70% Quizzes, 30% Attendance
    // If a student has no quizzes, and average is 0, they shouldn't top the board.
    // So we apply a slight penalty if they didn't take any quizzes.
    if (studentQuizzes.isEmpty) {
       avgQuizScore = 0.0; // They lose the 70% chunk
    }

    double totalScore = (avgQuizScore * 0.7) + (attendanceRate * 0.3);

    // Only include them if they have meaningful data (at least 1 attendance or quiz)
    if (studentQuizzes.isNotEmpty || studentAttendance.isNotEmpty) {
       honorList.add(HonorStudent(
          student: student,
          totalScore: totalScore,
          avgQuizScore: avgQuizScore,
          attendanceRate: attendanceRate,
      ));
    }
  }

  // Sort descending
  honorList.sort((a, b) => b.totalScore.compareTo(a.totalScore));

  return AsyncValue.data(honorList);
});

class HonorBoardScreen extends ConsumerWidget {
  const HonorBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final honorListAsync = ref.watch(honorBoardProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.honorBoardTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: InputDecoration(
                      labelText: context.l10n.groupLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    initialValue: ref.watch(honorBoardFiltersProvider),
                    items: [
                      DropdownMenuItem(value: null, child: Text(context.l10n.allGroups)),
                      if (groupsAsync.value != null)
                        ...groupsAsync.value!.map((g) =>
                            DropdownMenuItem(value: g.id, child: Text(g.name))),
                    ],
                    onChanged: (val) {
                      ref.read(honorBoardFiltersProvider.notifier).state = val;
                    },
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard
          Expanded(
            child: honorListAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(context.l10n.noSufficientData, style: TextStyle(color: colorScheme.onSurface.withAlpha(150))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length > 20 ? 20 : list.length, // Top 20
                  itemBuilder: (context, index) {
                    final hStudent = list[index];
                    return _buildHonorCard(context, hStudent, index);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHonorCard(BuildContext context, HonorStudent hStudent, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color rankColor;
    IconData rankIcon;
    double elevation = 0;

    if (index == 0) {
      rankColor = Colors.amber.shade600; // Gold
      rankIcon = Icons.military_tech_rounded;
      elevation = 4;
    } else if (index == 1) {
      rankColor = Colors.grey.shade400; // Silver
      rankIcon = Icons.military_tech_rounded;
      elevation = 2;
    } else if (index == 2) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankIcon = Icons.military_tech_rounded;
      elevation = 1;
    } else {
      rankColor = colorScheme.primary.withAlpha(150);
      rankIcon = Icons.stars_rounded;
    }

    return Card(
      elevation: elevation,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: index < 3 ? BorderSide(color: rankColor.withAlpha(100), width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: rankColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: index < 3 
                  ? Icon(rankIcon, color: rankColor, size: 32)
                  : Text('#${index + 1}', style: TextStyle(color: rankColor, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
            ),
            const SizedBox(width: 16),
            
            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hStudent.student.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  Text(
                    hStudent.student.groupName,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withAlpha(150)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniChip(
                        icon: Icons.quiz_rounded,
                        label: '${hStudent.avgQuizScore.toStringAsFixed(0)}%',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _MiniChip(
                        icon: Icons.check_circle_outline_rounded,
                        label: '${hStudent.attendanceRate.toStringAsFixed(0)}%',
                        color: Colors.green,
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    hStudent.totalScore.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    context.l10n.pointsLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
