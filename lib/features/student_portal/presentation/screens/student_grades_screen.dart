import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/student_auth_provider.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class StudentGradesScreen extends ConsumerWidget {
  const StudentGradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(currentStudentProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final gradesAsync = ref.watch(gradesByStudentProvider(student.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myGradesAndResults, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: gradesAsync.when(
        data: (grades) {
          if (grades.isEmpty) {
            return _buildEmptyState(context, colorScheme);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grades.length,
            itemBuilder: (context, index) {
              final grade = grades[index];
              final percentage = (grade.score / grade.maxScore) * 100;
              
              Color gradeColor = Colors.green;
              if (percentage < 50) {
                gradeColor = Colors.red;
              } else if (percentage < 75) {
                gradeColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: colorScheme.outline.withAlpha(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              grade.examName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            grade.examDate,
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: grade.score / grade.maxScore,
                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                  color: gradeColor,
                                  borderRadius: BorderRadius.circular(10),
                                  minHeight: 8,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.scoreOutOf(grade.score.toString(), grade.maxScore.toInt()),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: gradeColor.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: gradeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 60, color: colorScheme.primary.withAlpha(80)),
          const SizedBox(height: 16),
          Text(context.l10n.noGradesFound, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(context.l10n.gradesWillShowHere, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
