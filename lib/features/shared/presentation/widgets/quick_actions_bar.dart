import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../payments/presentation/screens/add_payment_screen.dart';
import '../../../students/presentation/screens/student_form_screen.dart';
import '../../../students/data/models/student_model.dart';
import '../../../groups/presentation/screens/group_form_screen.dart';
import '../../../announcements/presentation/screens/announcements_screen.dart';
import '../../../quizzes/presentation/screens/quizzes_screen.dart';
import '../../../qr_scanner/presentation/screens/qr_scanner_screen.dart';

/// شريط الإجراءات السريعة — شريط أفقي يفتح Bottom Sheet بكروت الإجراءات
class QuickActionsBar extends ConsumerWidget {
  const QuickActionsBar({super.key});

  // ── بناء كل الإجراءات المتاحة ──────────────────────────────────────────────
  List<_QuickActionDef> _buildAllActions(BuildContext context, WidgetRef ref) {
    return [
      _QuickActionDef(
        id: 'attendance',
        label: context.l10n.quickActionAttendance,
        icon: Icons.fact_check_rounded,
        color: const Color(0xFF3B82F6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceScreen()),
        ),
      ),
      _QuickActionDef(
        id: 'payment',
        label: context.l10n.quickActionPayment,
        icon: Icons.payment_rounded,
        color: const Color(0xFF10B981),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPaymentScreen()),
        ),
      ),
      _QuickActionDef(
        id: 'add_student',
        label: context.l10n.quickActionAddStudent,
        icon: Icons.person_add_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentFormScreen()),
        ),
      ),
      _QuickActionDef(
        id: 'portal_code',
        label: context.l10n.quickActionPortalCode,
        icon: Icons.vpn_key_rounded,
        color: const Color(0xFF0EA5E9),
        onTap: () => _showPortalCodePicker(context, ref),
      ),
      _QuickActionDef(
        id: 'add_group',
        label: 'إضافة مجموعة',
        icon: Icons.group_add_rounded,
        color: const Color(0xFFEAB308),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroupFormScreen()),
        ),
      ),
      _QuickActionDef(
        id: 'add_announcement',
        label: 'إضافة تنبيه',
        icon: Icons.notification_add_rounded,
        color: const Color(0xFFF97316),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
        ),
      ),
      _QuickActionDef(
        id: 'quizzes',
        label: 'إدارة الاختبارات',
        icon: Icons.assignment_rounded,
        color: const Color(0xFFEC4899),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizzesScreen()),
        ),
      ),
      _QuickActionDef(
        id: 'qr_scanner',
        label: 'الماسح الضوئي (QR)',
        icon: Icons.qr_code_scanner_rounded,
        color: const Color(0xFF6366F1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QrScannerScreen()),
        ),
      ),
    ];
  }

  // ── فتح picker لاختيار الطالب لكود البوابة ─────────────────────────────────
  void _showPortalCodePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PortalCodeStudentPicker(
        onStudentSelected: (student) async {
          Navigator.pop(context);
          await _generateAndShowCode(context, ref, student);
        },
      ),
    );
  }

  // ── توليد كود البوابة ───────────────────────────────────────────────────────
  Future<void> _generateAndShowCode(
    BuildContext context,
    WidgetRef ref,
    StudentModel student,
  ) async {
    final code = _generateCode();
    try {
      await ref
          .read(studentDbProvider)
          .update(student.id, {'portal_code': code});

      if (!context.mounted) return;
      _showCodeDialog(context, student.fullName, code);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(rng >> (i * 4)) % chars.length])
        .join();
  }

  void _showCodeDialog(BuildContext context, String studentName, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.l10n.quickActionPortalCode,
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(studentName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF0EA5E9).withAlpha(80), width: 2),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0EA5E9),
                  letterSpacing: 6,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.copiedToClipboard),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(context.l10n.copy),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.done),
          ),
        ],
      ),
    );
  }

  // ── فتح Bottom Sheet بكروت الإجراءات ───────────────────────────────────────
  void _openActionsSheet(BuildContext context, WidgetRef ref) {
    final quickActionIds = ref.read(settingsProvider).quickActions;
    final allActions = _buildAllActions(context, ref);
    final activeActions = quickActionIds
        .map((id) => allActions.where((a) => a.id == id).firstOrNull)
        .whereType<_QuickActionDef>()
        .toList();

    if (activeActions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ActionsBottomSheet(actions: activeActions),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final quickActionIds = ref.watch(settingsProvider).quickActions;
    final allActions = _buildAllActions(context, ref);
    final activeActions = quickActionIds
        .map((id) => allActions.where((a) => a.id == id).firstOrNull)
        .whereType<_QuickActionDef>()
        .toList();

    if (activeActions.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openActionsSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withAlpha(180),
              colorScheme.secondaryContainer.withAlpha(180),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.primary.withAlpha(40),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── أيقونة الشريط ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bolt_rounded,
                  color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 10),

            // ── نص ───────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختصارات سريعة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    activeActions.map((a) => a.label).join('  ·  '),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withAlpha(160),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── أيقونات مصغّرة ─────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: activeActions.take(4).map((action) {
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: action.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: action.color.withAlpha(60)),
                  ),
                  child: Icon(action.icon, color: action.color, size: 16),
                );
              }).toList(),
            ),

            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_up_rounded,
                color: colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Sheet بكروت الإجراءات ──────────────────────────────────────────────

class _ActionsBottomSheet extends StatelessWidget {
  final List<_QuickActionDef> actions;
  const _ActionsBottomSheet({required this.actions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.bolt_rounded,
                      color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإجراءات السريعة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'اضغط للانتقال مباشرةً',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // كروت الإجراءات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: actions.length <= 2 ? actions.length : 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: actions.length,
              itemBuilder: (ctx, i) => _ActionCard(
                action: actions[i],
                onTap: () {
                  Navigator.pop(context);
                  actions[i].onTap();
                },
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

// ── كارت الإجراء ───────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final _QuickActionDef action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: action.color.withAlpha(18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: action.color.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // أيقونة
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: action.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color, size: 20),
              ),

              // النص
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom Sheet اختيار طالب لكود البوابة ────────────────────────────────────

class _PortalCodeStudentPicker extends ConsumerStatefulWidget {
  final void Function(StudentModel student) onStudentSelected;
  const _PortalCodeStudentPicker({required this.onStudentSelected});

  @override
  ConsumerState<_PortalCodeStudentPicker> createState() =>
      _PortalCodeStudentPickerState();
}

class _PortalCodeStudentPickerState
    extends ConsumerState<_PortalCodeStudentPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final studentsAsync = ref.watch(studentsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.vpn_key_rounded,
                      color: Color(0xFF0EA5E9), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.quickActionPortalCode,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        context.l10n.selectStudentForPortalCode,
                        style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(150)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: context.l10n.searchStudents,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: colorScheme.outline.withAlpha(60)),
                ),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withAlpha(60),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Students List
          Expanded(
            child: studentsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (students) {
                final active = students
                    .where((s) => s.isActive)
                    .where((s) {
                      if (_query.isEmpty) return true;
                      return s.fullName
                          .toLowerCase()
                          .contains(_query.toLowerCase());
                    })
                    .toList();

                if (active.isEmpty) {
                  return Center(
                    child: Text(context.l10n.noStudentsFound,
                        style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(120))),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: active.length,
                  itemBuilder: (ctx, i) {
                    final student = active[i];
                    final hasCode = student.portalCode != null &&
                        student.portalCode!.isNotEmpty;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF0EA5E9).withAlpha(30),
                        child: Text(
                          student.fullName.isNotEmpty
                              ? student.fullName[0]
                              : '?',
                          style: const TextStyle(
                              color: Color(0xFF0EA5E9),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(student.fullName,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        student.groupName.isNotEmpty
                            ? student.groupName
                            : context.l10n.groupNotSet,
                        style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(130)),
                      ),
                      trailing: hasCode
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                student.portalCode!,
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            )
                          : Icon(Icons.refresh_rounded,
                              color: colorScheme.primary, size: 20),
                      onTap: () => widget.onStudentSelected(student),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

// ── تعريف الإجراء ─────────────────────────────────────────────────────────────

class _QuickActionDef {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
