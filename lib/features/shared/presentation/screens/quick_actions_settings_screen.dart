import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/extensions/l10n_extensions.dart';

/// صفحة تخصيص شريط الإجراءات السريعة
class QuickActionsSettingsScreen extends ConsumerStatefulWidget {
  const QuickActionsSettingsScreen({super.key});

  @override
  ConsumerState<QuickActionsSettingsScreen> createState() =>
      _QuickActionsSettingsScreenState();
}

class _QuickActionsSettingsScreenState
    extends ConsumerState<QuickActionsSettingsScreen> {
  late List<_ActionItem> _items;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _buildItems();
  }

  void _buildItems() {
    final savedIds = ref.read(settingsProvider).quickActions;
    _items = _allActionItems(context: context, savedIds: savedIds);
  }

  /// كل الإجراءات المتاحة مع حالة enabled
  List<_ActionItem> _allActionItems({
    required BuildContext context,
    required List<String> savedIds,
  }) {
    final all = [
      _ActionItem(
        id: 'attendance',
        icon: Icons.fact_check_rounded,
        color: const Color(0xFF3B82F6),
        enabled: false,
      ),
      _ActionItem(
        id: 'payment',
        icon: Icons.payment_rounded,
        color: const Color(0xFF10B981),
        enabled: false,
      ),
      _ActionItem(
        id: 'add_student',
        icon: Icons.person_add_rounded,
        color: const Color(0xFF8B5CF6),
        enabled: false,
      ),
      _ActionItem(
        id: 'portal_code',
        icon: Icons.vpn_key_rounded,
        color: const Color(0xFF0EA5E9),
        enabled: false,
      ),
      _ActionItem(
        id: 'add_group',
        icon: Icons.group_add_rounded,
        color: const Color(0xFFEAB308),
        enabled: false,
      ),
      _ActionItem(
        id: 'add_announcement',
        icon: Icons.notification_add_rounded,
        color: const Color(0xFFF97316),
        enabled: false,
      ),
      _ActionItem(
        id: 'quizzes',
        icon: Icons.assignment_rounded,
        color: const Color(0xFFEC4899),
        enabled: false,
      ),
      _ActionItem(
        id: 'qr_scanner',
        icon: Icons.qr_code_scanner_rounded,
        color: const Color(0xFF6366F1),
        enabled: false,
      ),
    ];

    // ترتيب: المُفعَّلة أولاً بترتيب savedIds، ثم الباقية
    final ordered = <_ActionItem>[];
    for (final id in savedIds) {
      final found = all.where((a) => a.id == id).firstOrNull;
      if (found != null) ordered.add(found..enabled = true);
    }
    for (final item in all) {
      if (!ordered.any((o) => o.id == item.id)) {
        ordered.add(item..enabled = false);
      }
    }
    return ordered;
  }

  String _label(String id) {
    switch (id) {
      case 'attendance':
        return context.l10n.quickActionAttendance;
      case 'payment':
        return context.l10n.quickActionPayment;
      case 'add_student':
        return context.l10n.quickActionAddStudent;
      case 'portal_code':
        return context.l10n.quickActionPortalCode;
      case 'add_group':
        return 'إضافة مجموعة';
      case 'add_announcement':
        return 'إضافة تنبيه';
      case 'quizzes':
        return 'إدارة الاختبارات';
      case 'qr_scanner':
        return 'الماسح الضوئي (QR)';
      default:
        return id;
    }
  }

  Future<void> _save() async {
    final enabledIds = _items
        .where((item) => item.enabled)
        .map((item) => item.id)
        .toList();

    await ref.read(settingsProvider.notifier).setQuickActions(enabledIds);

    if (mounted) {
      setState(() => _isDirty = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.changesSaved),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.customizeQuickActions),
        centerTitle: true,
        actions: [
          if (_isDirty)
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text(context.l10n.save),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Hint Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(60),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.primary.withAlpha(40)),
            ),
            child: Row(
              children: [
                Icon(Icons.drag_indicator_rounded,
                    color: colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.quickActionsHint,
                    style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                  _isDirty = true;
                });
              },
              itemBuilder: (ctx, i) {
                final item = _items[i];
                return _ActionTile(
                  key: ValueKey(item.id),
                  item: item,
                  label: _label(item.id),
                  onToggle: (v) {
                    setState(() {
                      item.enabled = v;
                      _isDirty = true;
                    });
                  },
                );
              },
            ),
          ),

          // Save Button at bottom
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isDirty ? _save : null,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(context.l10n.save),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String id;
  final IconData icon;
  final Color color;
  bool enabled;

  _ActionItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.enabled,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;
  final String label;
  final ValueChanged<bool> onToggle;

  const _ActionTile({
    super.key,
    required this.item,
    required this.label,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: item.enabled
                ? item.color.withAlpha(80)
                : colorScheme.outline.withAlpha(40)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.enabled
                ? item.color.withAlpha(25)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item.icon,
            color: item.enabled ? item.color : colorScheme.outline,
            size: 22,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: item.enabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withAlpha(120),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: item.enabled,
              onChanged: onToggle,
              activeThumbColor: item.color,
              activeTrackColor: item.color.withAlpha(80),
            ),
            const SizedBox(width: 4),
            Icon(Icons.drag_handle_rounded,
                color: colorScheme.outline, size: 22),
          ],
        ),
      ),
    );
  }
}
