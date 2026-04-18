import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../data/models/qr_scan_model.dart';

class QrScanHistoryScreen extends ConsumerWidget {
  const QrScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scansAsync = ref.watch(qrScansProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scanHistory),
      ),
      body: scansAsync.when(
        data: (scans) {
          if (scans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_rounded,
                      size: 80, color: colorScheme.primary.withAlpha(80)),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noScansYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.noScansYetHint,
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
            );
          }

          // ترتيب حسب الأحدث
          final sorted = List<QrScanModel>.from(scans)
            ..sort((a, b) => b.createdDate.compareTo(a.createdDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final scan = sorted[index];
              final isAttendance = scan.actionType == 'attendance';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (isAttendance ? Colors.teal : Colors.green)
                          .withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isAttendance
                          ? Icons.fact_check_rounded
                          : Icons.payments_rounded,
                      color: isAttendance ? Colors.teal : Colors.green[700],
                    ),
                  ),
                  title: Text(
                    scan.studentName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (isAttendance ? Colors.teal : Colors.green)
                                  .withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAttendance ? context.l10n.attendance : 'دفعة ${scan.amount?.toStringAsFixed(0) ?? ''} ج.م',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isAttendance
                                    ? Colors.teal
                                    : Colors.green[700],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.access_time_rounded,
                              size: 14,
                              color: colorScheme.onSurface.withAlpha(100)),
                          const SizedBox(width: 4),
                          Text(
                            '${scan.date} — ${scan.time}',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                        ],
                      ),
                      if (scan.groupName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          scan.groupName,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(130),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('حدث خطأ: $e')),
      ),
    );
  }
}
