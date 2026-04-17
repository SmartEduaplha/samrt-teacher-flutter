import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../data/models/announcement_model.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  String _selectedGroupId = 'all';

  Future<void> _handleDelete(AnnouncementModel announcement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التنبيه؟'),
        content: const Text('سيتم حذف هذا التنبيه نهائياً من بوابات الطلاب.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف')),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(announcementDbProvider).delete(announcement.id);
    }
  }

  void _showAddAnnouncement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => const _AddAnnouncementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final announcementsAsync = ref.watch(allAnnouncementsProvider);
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات العامة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(10),
              border: Border(bottom: BorderSide(color: colorScheme.outline.withAlpha(20))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إدارة التواصل مع الطلاب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('قم بإنشاء تنبيهات تظهر فورياً في بوابة الطالب',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withAlpha(150))),
              ],
            ),
          ),

          // ── Filter ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: groupsAsync.when(
              data: (groups) => DropdownButtonFormField<String>(
                initialValue: _selectedGroupId,
                decoration: InputDecoration(
                  labelText: 'عرض تنبيهات مجموعة',
                  prefixIcon: const Icon(Icons.filter_list_rounded),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('كل التنبيهات')),
                  const DropdownMenuItem(value: 'global', child: Text('التنبيهات العامة فقط')),
                  ...groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
                ],
                onChanged: (val) => setState(() => _selectedGroupId = val ?? 'all'),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => const SizedBox(),
            ),
          ),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: announcementsAsync.when(
              data: (all) {
                final filtered = all.where((a) {
                  if (_selectedGroupId == 'all') return true;
                  if (_selectedGroupId == 'global') return a.groupId == null || a.groupId!.isEmpty;
                  return a.groupId == _selectedGroupId;
                }).toList();

                // Sort by date (newest first)
                filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            size: 64, color: colorScheme.outline.withAlpha(50)),
                        const SizedBox(height: 16),
                        const Text('لا توجد تنبيهات حالياً',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final announcement = filtered[index];
                    return _AnnouncementCard(
                      announcement: announcement,
                      onDelete: () => _handleDelete(announcement),
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
        onPressed: _showAddAnnouncement,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('تنبيه جديد'),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onDelete;

  const _AnnouncementCard({required this.announcement, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color priorityColor = switch (announcement.priority) {
      AnnouncementPriority.high => Colors.red,
      AnnouncementPriority.medium => Colors.orange,
      AnnouncementPriority.low => Colors.blue,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withAlpha(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.campaign_rounded, color: priorityColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        announcement.groupName ?? 'تنبيه عام لكل الطلاب',
                        style: TextStyle(fontSize: 11, color: colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(announcement.content,
                style: TextStyle(fontSize: 13, height: 1.5, color: colorScheme.onSurface.withAlpha(200))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(100),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    DateFormat('yyyy/MM/dd - hh:mm a').format(announcement.createdAt),
                    style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withAlpha(150)),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.priority_high_rounded, size: 12, color: priorityColor),
                    Text(
                      switch (announcement.priority) {
                        AnnouncementPriority.high => 'عاجل',
                        AnnouncementPriority.medium => 'متوسط',
                        AnnouncementPriority.low => 'عادي',
                      },
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: priorityColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAnnouncementSheet extends ConsumerStatefulWidget {
  const _AddAnnouncementSheet();

  @override
  ConsumerState<_AddAnnouncementSheet> createState() => _AddAnnouncementSheetState();
}

class _AddAnnouncementSheetState extends ConsumerState<_AddAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  AnnouncementPriority _priority = AnnouncementPriority.low;
  String? _selectedGroupId;
  String? _selectedGroupName;
  bool _isGlobal = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final announcement = AnnouncementModel(
        id: '',
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        groupId: _isGlobal ? null : _selectedGroupId,
        groupName: _isGlobal ? null : _selectedGroupName,
        createdAt: DateTime.now(),
      );

      await ref.read(announcementDbProvider).create(announcement.toMap());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groupsAsync = ref.watch(groupsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.add_comment_rounded, color: Colors.blue),
              const SizedBox(width: 10),
              const Text('إنشاء تنبيه جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'عنوان التنبيه',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'نص التنبيه',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.description_rounded),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('الأولوية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Row(
            children: AnnouncementPriority.values.map((p) {
              final Color color = switch (p) {
                AnnouncementPriority.high => Colors.red,
                AnnouncementPriority.medium => Colors.orange,
                AnnouncementPriority.low => Colors.blue,
              };
              final String label = switch (p) {
                AnnouncementPriority.high => 'عاجل',
                AnnouncementPriority.medium => 'متوسط',
                AnnouncementPriority.low => 'عادي',
              };
              return Expanded(
                child: ChoiceChip(
                  label: Text(label),
                  selected: _priority == p,
                  onSelected: (val) => setState(() => _priority = p),
                  selectedColor: color.withAlpha(50),
                  labelStyle: TextStyle(
                    color: _priority == p ? color : colorScheme.onSurface,
                    fontWeight: _priority == p ? FontWeight.bold : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('المجموعة المستهدفة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          SwitchListTile(
            title: const Text('تنبيه عام (لكل الطلاب)', style: TextStyle(fontSize: 14)),
            value: _isGlobal,
            onChanged: (val) => setState(() => _isGlobal = val),
          ),
          if (!_isGlobal)
            groupsAsync.when(
              data: (groups) => DropdownButtonFormField<String>(
                initialValue: _selectedGroupId,
                decoration: const InputDecoration(labelText: 'اختر المجموعة'),
                items: groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                onChanged: (val) {
                  final group = groups.firstWhere((g) => g.id == val);
                  setState(() {
                    _selectedGroupId = val;
                    _selectedGroupName = group.name;
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => const Text('Error loading groups'),
            ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded),
            label: const Text('نشر التنبيه الآن'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }
}
