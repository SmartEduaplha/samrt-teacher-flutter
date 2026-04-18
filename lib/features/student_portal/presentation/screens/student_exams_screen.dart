import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/providers/student_auth_provider.dart';
import '../../../quizzes/data/models/quiz_model.dart';
import 'student_exam_taking_screen.dart';

class StudentExamsScreen extends ConsumerWidget {
  const StudentExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(currentStudentProvider);
    final quizzesAsync = ref.watch(quizzesProvider);
    final resultsAsync = ref.watch(allQuizResultsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.exams),
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.pendingExams, icon: const Icon(Icons.assignment_rounded)),
              Tab(text: context.l10n.examResult, icon: const Icon(Icons.grading_rounded)),
            ],
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withAlpha(130),
          ),
        ),
        body: quizzesAsync.when(
          data: (quizzes) {
            return resultsAsync.when(
              data: (allResults) {
                final studentId = student?.id ?? '';
                final myResults = allResults
                    .where((r) => r.studentId == studentId)
                    .toList();
                final submittedQuizIds =
                    myResults.map((r) => r.quizId).toSet();

                // الاختبارات المتاحة: منشورة + لم يقدمها الطالب بعد
                final pendingQuizzes = quizzes.where((q) {
                  if (q.status != 'published') return false;
                  if (submittedQuizIds.contains(q.id)) return false;
                  // تأكد أن المجموعة تطابق مجموعة الطالب
                  if (q.groupId.isNotEmpty &&
                      q.groupId != student?.groupId) {
                    return false;
                  }
                  return true;
                }).toList();

                // النتائج — مرتبة بالأحدث
                final sortedResults = List<QuizResultModel>.from(myResults)
                  ..sort(
                      (a, b) => b.createdDate.compareTo(a.createdDate));

                return TabBarView(
                  children: [
                    _buildPendingTab(
                        context, pendingQuizzes, colorScheme, student),
                    _buildResultsTab(context, sortedResults, colorScheme),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }

  Widget _buildPendingTab(BuildContext context, List<QuizModel> quizzes,
      ColorScheme colorScheme, dynamic student) {
    if (quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_turned_in_rounded,
                size: 80, color: colorScheme.primary.withAlpha(80)),
            const SizedBox(height: 16),
            Text(
              'لا توجد اختبارات متاحة حالياً',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withAlpha(160),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر الاختبارات هنا عند نشرها من قبل المعلم.',
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(120),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.quiz_rounded,
                          color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (quiz.subject.isNotEmpty)
                            Text(
                              quiz.subject,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    colorScheme.onSurface.withAlpha(130),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: Icons.help_outline_rounded,
                      label: '${quiz.questions.length} سؤال',
                      color: Colors.blue,
                    ),
                    if (quiz.timeLimitMinutes > 0)
                      _InfoChip(
                        icon: Icons.timer_rounded,
                        label: '${quiz.timeLimitMinutes} دقيقة',
                        color: Colors.orange,
                      ),
                    _InfoChip(
                      icon: Icons.star_rounded,
                      label: '${quiz.totalMarks} درجة',
                      color: Colors.amber[700]!,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Start Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _startExam(context, quiz),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(context.l10n.startQuiz),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsTab(BuildContext context,
      List<QuizResultModel> results, ColorScheme colorScheme) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grading_rounded,
                size: 80, color: colorScheme.primary.withAlpha(80)),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج بعد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withAlpha(160),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final percentage = result.percentage;
        final isGood = percentage >= 70;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (isGood ? Colors.green : Colors.orange).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isGood ? Colors.green[700] : Colors.orange[800],
                  ),
                ),
              ),
            ),
            title: Text(
              result.quizTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${result.score.toStringAsFixed(0)} / ${result.totalMarks}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(130),
                  ),
                ),
                if (result.submittedAt.isNotEmpty)
                  Text(
                    result.submittedAt.substring(0, 10),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(100),
                    ),
                  ),
              ],
            ),
            trailing: Icon(
              isGood
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: isGood ? Colors.green : Colors.orange,
            ),
          ),
        );
      },
    );
  }

  void _startExam(BuildContext context, QuizModel quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.startQuiz),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت مستعد لبدء اختبار "${quiz.title}"؟'),
            const SizedBox(height: 12),
            if (quiz.timeLimitMinutes > 0)
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مدة الاختبار ${quiz.timeLimitMinutes} دقيقة. سيتم التسليم تلقائياً عند انتهاء الوقت.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentExamTakingScreen(quiz: quiz),
                ),
              );
            },
            child: const Text('ابدأ الآن'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
