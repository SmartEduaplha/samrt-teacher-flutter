import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/student_auth_provider.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../attendance/data/models/attendance_model.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(currentStudentProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final attendanceAsync = ref.watch(attendanceByStudentProvider(student.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.attendanceHistory, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: attendanceAsync.when(
        data: (studentRecords) {
          if (studentRecords.isEmpty) {
            return _buildEmptyState(context, colorScheme);
          }

          // ترتيب السجلات: الأحدث أولاً
          final sortedRecords = List<AttendanceRecord>.from(studentRecords)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedRecords.length,
            itemBuilder: (context, index) {
              final record = sortedRecords[index];
              final isPresent = record.status == 'present';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outline.withAlpha(30)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isPresent ? Colors.green : Colors.red).withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isPresent ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    record.date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${context.l10n.dayLabel} ${DateFormat('EEEE', context.l10n.localeName).format(DateTime.parse(record.date))}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isPresent ? Colors.green : Colors.red).withAlpha(isPresent ? 255 : 30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPresent ? context.l10n.present : context.l10n.absent,
                      style: TextStyle(
                        color: isPresent ? Colors.white : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
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
          Icon(Icons.calendar_today_outlined, size: 60, color: colorScheme.primary.withAlpha(80)),
          const SizedBox(height: 16),
          Text(context.l10n.noAttendanceFound, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(context.l10n.attendanceWillShowHere, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
