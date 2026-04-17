import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../quizzes/data/models/quiz_model.dart';
import 'quiz_builder_screen.dart';
import 'quiz_results_screen.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class QuizzesScreen extends ConsumerStatefulWidget {
  const QuizzesScreen({super.key});

  @override
  ConsumerState<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends ConsumerState<QuizzesScreen> {
  String _selectedGroupId = 'all';

  Future<void> _handleDelete(QuizModel quiz) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteQuizTitle),
        content: Text(context.l10n.deleteQuizConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.delete)),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(quizDbProvider).delete(quiz.id);
    }
  }

  Future<void> _toggleStatus(QuizModel quiz) async {
    final newStatus = quiz.status == 'published' ? 'closed' : 'published';
    await ref.read(quizDbProvider).update(quiz.id, {'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final quizzesAsync = ref.watch(quizzesProvider);
    final resultsAsync = ref.watch(allQuizResultsProvider);
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.quizzesTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // ── Stats Header ───────────────────────────────────────────
          _buildStatsHeader(quizzesAsync, resultsAsync),

          // ── Group Filter ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: groupsAsync.when(
              data: (groups) => DropdownButtonFormField<String>(
                initialValue: _selectedGroupId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.l10n.filterByGroup,
                  prefixIcon: const Icon(Icons.groups_rounded),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'all', child: Text(context.l10n.allGroups)),
                  ...groups.map((g) => DropdownMenuItem(
                      value: g.id, child: Text(g.name))),
                ],
                onChanged: (val) =>
                    setState(() => _selectedGroupId = val ?? 'all'),
              ),
              loading: () => const SizedBox(height: 10),
              error: (_, _) => const SizedBox(),
            ),
          ),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: quizzesAsync.when(
              data: (allQuizzes) {
                final filtered = allQuizzes.where((q) {
                  return _selectedGroupId == 'all' || q.groupId == _selectedGroupId;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined,
                            size: 64, color: colorScheme.outline.withAlpha(50)),
                        const SizedBox(height: 16),
                        Text(context.l10n.noQuizzesFound,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(context.l10n.createFirstQuizMessage,
                            style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(150))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final quiz = filtered[index];
                    return resultsAsync.when(
                      data: (allResults) {
                        final quizResults =
                            allResults.where((r) => r.quizId == quiz.id).toList();
                        return _QuizCard(
                          quiz: quiz,
                          results: quizResults,
                          onDelete: () => _handleDelete(quiz),
                          onToggleStatus: () => _toggleStatus(quiz),
                        );
                      },
                      loading: () => const Card(
                          child: SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))),
                      error: (_, _) => const SizedBox(),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const QuizBuilderScreen())),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newQuiz),
      ),
    );
  }

  Widget _buildStatsHeader(
      AsyncValue<List<QuizModel>> quizzes, AsyncValue<List<QuizResultModel>> results) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatBox(
            title: context.l10n.averageResults,
            value: results.when(
              data: (list) {
                if (list.isEmpty) return '0%';
                final avg =
                    list.fold(0.0, (sum, r) => sum + r.percentage) / list.length;
                return '${avg.toStringAsFixed(0)}%';
              },
              loading: () => '...',
              error: (_, _) => '0%',
            ),
            color: Colors.deepPurple,
            icon: Icons.analytics_rounded,
          ),
          const SizedBox(width: 10),
          _StatBox(
            title: context.l10n.totalQuizzes,
            value: quizzes.when(
              data: (list) => list.length.toString(),
              loading: () => '...',
              error: (_, _) => '0',
            ),
            color: Colors.blue,
            icon: Icons.assignment_rounded,
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final List<QuizResultModel> results;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _QuizCard({
    required this.quiz,
    required this.results,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final avgPct = results.isEmpty
        ? null
        : results.fold(0.0, (sum, r) => sum + r.percentage) / results.length;

    final Color statusColor = quiz.status == 'published'
        ? Colors.green
        : (quiz.status == 'draft' ? Colors.orange : Colors.grey);

    final String statusLabel = quiz.status == 'published'
        ? context.l10n.activeStatus
        : (quiz.status == 'draft'
            ? context.l10n.draftStatus
            : context.l10n.closedStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outline.withAlpha(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(quiz.groupName,
                          style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withAlpha(150))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withAlpha(50)),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetaItem(
                    icon: Icons.help_outline,
                    label: context.l10n.questionsCount(quiz.questions.length)),
                const SizedBox(width: 16),
                _MetaItem(
                    icon: Icons.people_outline,
                    label: context.l10n.resultsCount(results.length)),
                if (quiz.publishDate.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  _MetaItem(icon: Icons.calendar_today_outlined, label: quiz.publishDate),
                ],
              ],
            ),
            if (avgPct != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.averageResults,
                      style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withAlpha(150),
                          fontWeight: FontWeight.w500)),
                  Text('${avgPct.toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _getScoreColor(avgPct))),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: avgPct / 100,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: _getScoreColor(avgPct),
                  minHeight: 6,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => QuizResultsScreen(quizId: quiz.id))),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: Text(context.l10n.results),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                      quiz.status == 'published'
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.amber.shade700,
                      size: 20),
                  onPressed: onToggleStatus,
                  tooltip: quiz.status == 'published'
                      ? context.l10n.close
                      : context.l10n.publish,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double pct) {
    if (pct >= 75) return Colors.green;
    if (pct >= 50) return Colors.amber.shade700;
    return Colors.red;
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            Text(title,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withAlpha(180))),
          ],
        ),
      ),
    );
  }
}
