import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../quizzes/data/models/quiz_model.dart';
import '../../../students/data/models/student_model.dart';

class QuizResultsScreen extends ConsumerStatefulWidget {
  final String quizId;
  const QuizResultsScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  String _search = '';

  Future<void> _sendResultToParent(
      QuizResultModel result, QuizModel? quiz, StudentModel? student) async {
    if (student == null) return;
    final phone = student.parentPhoneNumber.isNotEmpty
        ? student.parentPhoneNumber
        : student.phoneNumber;

    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.noPhoneRegistered)),
        );
      }
      return;
    }

    final message = context.l10n.whatsappQuizResultMessage(
        student.fullName,
        quiz?.title ?? context.l10n.quizResults,
        result.score.toStringAsFixed(1),
        result.totalMarks,
        result.percentage.toStringAsFixed(0));

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final quizzesState = ref.watch(quizzesProvider);
    final resultsState = ref.watch(quizResultsByQuizProvider(widget.quizId));
    final studentsState = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: quizzesState.when(
          data: (qs) {
            final q = qs.where((x) => x.id == widget.quizId).firstOrNull;
            return Text(q?.title ?? context.l10n.quizResults,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
          },
          loading: () => Text(context.l10n.loadingData),
          error: (_, _) => Text(context.l10n.quizResults),
        ),
      ),
      body: resultsState.when(
        data: (results) {
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined,
                      size: 64, color: colorScheme.outline.withAlpha(50)),
                  const SizedBox(height: 16),
                  Text(context.l10n.noResultsYet),
                  Text(context.l10n.resultsWillShowHere,
                      style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha(150))),
                ],
              ),
            );
          }

          final filtered = results.where((r) =>
              r.studentName.toLowerCase().contains(_search.toLowerCase())).toList();
          filtered.sort((a, b) => b.score.compareTo(a.score));

          final avgScore = results.fold(0.0, (sum, r) => sum + r.score) / results.length;
          final totalMarks = results.firstOrNull?.totalMarks ?? 0;

          return Column(
            children: [
              // ── Quick Stats ─────────────────────────────────────────
              _buildStatsRow(results, avgScore, totalMarks, colorScheme),

              // ── Search ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: context.l10n.searchByStudent,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
              ),

              // ── Results List ───────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final res = filtered[index];
                    return studentsState.when(
                      data: (students) {
                        final student = students.firstWhere((s) => s.id == res.studentId);
                        final quiz = quizzesState.value?.firstWhere((q) => q.id == res.quizId);
                        return _ResultCard(
                          result: res,
                          onWhatsApp: () => _sendResultToParent(res, quiz, student),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatsRow(List<QuizResultModel> results, double avg,
      int totalMarks, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      color: colorScheme.primary.withAlpha(10),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniStat(
              label: context.l10n.submittedInfo,
              value: results.length.toString(),
              color: colorScheme.primary),
          _MiniStat(
              label: context.l10n.avgScore,
              value: '${avg.toStringAsFixed(1)}/$totalMarks',
              color: colorScheme.primary),
          _MiniStat(
              label: context.l10n.highestScore,
              value: results.fold(0.0, (max, r) => r.score > max ? r.score : max).toStringAsFixed(0),
              color: Colors.green),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final QuizResultModel result;
  final VoidCallback onWhatsApp;

  const _ResultCard({required this.result, required this.onWhatsApp});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = result.percentage >= 50 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(result.studentName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        subtitle: Text(
          context.l10n.submissionDate(result.submittedAt.split('T')[0]),
          style: TextStyle(
              fontSize: 10, color: colorScheme.onSurface.withAlpha(150)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${result.score.toStringAsFixed(1)} / ${result.totalMarks}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 13, color: color)),
                Text('${result.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 10, color: color.withAlpha(180))),
              ],
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.green, size: 20),
              onPressed: onWhatsApp,
              tooltip: context.l10n.shareWithParent,
            ),
          ],
        ),
      ),
    );
  }
}
