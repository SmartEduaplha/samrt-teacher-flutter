import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../data/models/group_model.dart';
import '../screens/group_form_screen.dart';

class GroupCard extends ConsumerWidget {
  final GroupModel group;

  const GroupCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Colors and styling based on group type
    Color baseColor;
    IconData iconData;
    String typeLabel = GroupType.fromValue(group.type).label;

    switch (group.type) {
      case 'center':
        baseColor = Colors.blue;
        iconData = Icons.menu_book_rounded;
        break;
      case 'privateGroup':
        baseColor = Colors.purple;
        iconData = Icons.home_rounded;
        break;
      case 'privateLesson':
        baseColor = Colors.amber.shade700;
        iconData = Icons.school_rounded;
        break;
      case 'online':
        baseColor = Colors.teal;
        iconData = Icons.laptop_chromebook_rounded;
        break;
      default:
        baseColor = Colors.blue;
        iconData = Icons.menu_book_rounded;
    }

    // Get real-time student count
    final studentsAsync = ref.watch(studentsByGroupProvider(group.id));
    final studentCount = studentsAsync.valueOrNull?.length ?? 0;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Icon + Name + Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconData, color: baseColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      if (group.subject.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            group.subject,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: baseColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: baseColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Students + Price
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.people_alt_rounded,
                        size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      '$studentCount طالب',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Text(
                  '${group.effectivePrice.toStringAsFixed(0)} ج/شهر',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Schedule
            if (group.schedule.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: group.schedule.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${_translateDay(s.day)} ${s.startTime}-${s.endTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            if (group.schedule.isNotEmpty) const SizedBox(height: 12),

            // Row 4: Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to Details
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('التفاصيل', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.chevron_left_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GroupFormScreen(groupToEdit: group),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    // Show Delete Dialog matching React logic
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('حذف المجموعة', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: const Text(
                            'سيتم حذف المجموعة وجميع بيانات الطلاب المرتبطة بها نهائياً. هل أنت متأكد؟'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('حذف نهائياً'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // Actually delete the group
                      final dbProvider = ref.read(groupDbProvider);
                      await dbProvider.delete(group.id);
                      ref.invalidate(groupsProvider);
                      ref.invalidate(activeGroupsProvider);
                    }
                  },
                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade400),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _translateDay(String engDay) {
    switch (engDay) {
      case 'saturday': return 'السبت';
      case 'sunday': return 'الأحد';
      case 'monday': return 'الاثنين';
      case 'tuesday': return 'الثلاثاء';
      case 'wednesday': return 'الأربعاء';
      case 'thursday': return 'الخميس';
      case 'friday': return 'الجمعة';
      default: return engDay;
    }
  }
}
