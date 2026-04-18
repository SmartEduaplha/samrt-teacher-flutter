import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/student_auth_provider.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../announcements/data/models/announcement_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';


class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(currentStudentProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final attendanceAsync = ref.watch(attendanceByStudentProvider(student.id));
    final quizResultsAsync = ref.watch(quizResultsByStudentProvider(student.id));
    final gradesAsync = ref.watch(gradesByStudentProvider(student.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.studentPortal, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceByStudentProvider(student.id));
          ref.invalidate(quizResultsByStudentProvider(student.id));
          ref.invalidate(gradesByStudentProvider(student.id));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Welcome Card ──────────────────────────────────────────────
            _buildWelcomeCard(context, student, colorScheme, theme),
            
            const SizedBox(height: 24),
            
            // ── Stats Row ─────────────────────────────────────────────────
            attendanceAsync.when(
              data: (studentRecords) {
                final presentCount = studentRecords.where((r) => r.status == 'present').length;
                final totalCount = studentRecords.length;
                final attendanceRate = totalCount == 0 ? 0.0 : (presentCount / totalCount) * 100;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        context.l10n.attendanceRate,
                        '${attendanceRate.toStringAsFixed(1)}%',
                        Icons.event_available_rounded,
                        Colors.blue,
                        colorScheme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: quizResultsAsync.when(
                        data: (studentResults) {
                          final lastScore = studentResults.isNotEmpty ? studentResults.last.score : 0.0;
                          return _buildStatCard(
                            context,
                            context.l10n.lastScore,
                            lastScore.toString(),
                            Icons.assignment_turned_in_rounded,
                            Colors.green,
                            colorScheme,
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, _) => const Text('Error'),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('Error'),
            ),

            const SizedBox(height: 24),

            // ── Performance Progress ──────────────────────────────────────
            quizResultsAsync.when(
              data: (results) => gradesAsync.when(
                data: (grades) => _buildPerformanceSection(context, results, grades, colorScheme, theme),
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
              ),
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // ── Notifications ─────────────────────────────────────────────
            _buildNotificationsSection(context, student, colorScheme, theme, ref),

            const SizedBox(height: 24),

            // ── Group Info ────────────────────────────────────────────────
            _buildInfoTile(
              context,
              context.l10n.currentGroup,
              student.groupName,
              Icons.groups_rounded,
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              context.l10n.academicYear,
              student.academicYear,
              Icons.school_rounded,
              colorScheme,
            ),
            
            const SizedBox(height: 32),
            
            // ── Motivation Text ───────────────────────────────────────────
            Center(
              child: Text(
                context.l10n.keepGoing(student.fullName.split(' ')[0]),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context, dynamic results, dynamic grades, ColorScheme colorScheme, ThemeData theme) {
    double totalWeightedScore = 0;
    int itemsCount = 0;

    for (var r in results) {
      totalWeightedScore += r.percentage;
      itemsCount++;
    }
    for (var g in grades) {
      final percentage = g.maxScore > 0 ? (g.score / g.maxScore) * 100 : 0.0;
      totalWeightedScore += percentage;
      itemsCount++;
    }

    final average = itemsCount == 0 ? 0.0 : totalWeightedScore / itemsCount;
    final color = average >= 85 ? Colors.green : (average >= 65 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.overallPerformance,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${average.toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: average / 100,
              minHeight: 10,
              backgroundColor: color.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getPerformanceFeedback(context, average),
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _getPerformanceFeedback(BuildContext context, double score) {
    if (score >= 90) return context.l10n.performanceFeedback(context.l10n.performanceExceptional);
    if (score >= 75) return context.l10n.performanceFeedback(context.l10n.performanceDoingGreat);
    if (score >= 50) return context.l10n.performanceFeedback(context.l10n.performanceAcceptable);
    return context.l10n.performanceFeedback(context.l10n.performanceNeedsAttention);
  }

  Widget _buildNotificationsSection(BuildContext context, dynamic student, ColorScheme colorScheme, ThemeData theme, WidgetRef ref) {
    final announcementsAsync = ref.watch(studentAnnouncementsProvider(student.groupId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.latestAnnouncements,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (student.notes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(context.l10n.privateMessage, style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
        
        // ── Individual Student Notes (Private) ──────────────────────────
        if (student.notes.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withAlpha(60), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_pin_rounded, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    student.notes,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Real-time Announcements (Public/Group) ─────────────────────
        announcementsAsync.when(
          data: (announcements) {
            if (announcements.isEmpty && student.notes.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    context.l10n.noAnnouncements,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }

            return Column(
              children: announcements.map((announcement) {
                final color = _getPriorityColor(announcement.priority);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withAlpha(40), color.withAlpha(10)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withAlpha(80), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Icon(Icons.campaign_rounded, size: 80, color: color.withAlpha(15)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 14),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        announcement.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  announcement.content,
                                  style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          )),
          error: (err, _) => Center(child: Text('${context.l10n.errorOccurred}: $err')),
        ),
      ],
    );
  }

  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.high: return Colors.red;
      case AnnouncementPriority.medium: return Colors.orange;
      case AnnouncementPriority.low: return Colors.blue;
    }
  }

  Widget _buildWelcomeCard(BuildContext context, dynamic student, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.onPrimary.withAlpha(50),
                child: Text(
                  student.fullName.substring(0, 1),
                  style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.welcomeBack,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withAlpha(200)),
                    ),
                    Text(
                      student.fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String value, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.l10n.confirmLogout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(context.l10n.logoutConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(currentStudentProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.logout),
          ),
        ],
      ),
    );
  }
}
