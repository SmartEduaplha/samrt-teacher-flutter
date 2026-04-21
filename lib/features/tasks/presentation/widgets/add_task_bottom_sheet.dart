import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/db_providers.dart';
import '../../data/models/task_model.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  String? _selectedGroup;
  String _selectedType = 'واجب';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedRepeat = 'بدون';
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _taskTypes = [
    {'label': 'واجب', 'icon': Icons.menu_book_rounded},
    {'label': 'تسميع', 'icon': Icons.mic_rounded},
    {'label': 'امتحان', 'icon': Icons.assignment_rounded},
    {'label': 'تحضير', 'icon': Icons.content_paste_go_rounded},
    {'label': 'تكريم', 'icon': Icons.emoji_events_rounded},
    {'label': 'اختبار قصير', 'icon': Icons.bolt_rounded},
    {'label': 'ماليات', 'icon': Icons.attach_money_rounded},
    {'label': 'طباعة', 'icon': Icons.print_rounded},
    {'label': 'تواصل', 'icon': Icons.phone_rounded},
    {'label': 'أخرى', 'icon': Icons.more_horiz_rounded},
  ];

  final List<String> _repeatOptions = ['بدون', 'يومياً', 'أسبوعياً', 'شهرياً'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveTask() async {
    final title = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : _selectedType;
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _notesController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      isCompleted: false,
      groupId: _selectedGroup,
      type: _selectedType,
      time: _selectedTime?.format(context),
      repeat: _selectedRepeat,
      notes: _notesController.text.trim(),
    );

    await ref.read(taskDbProvider).create(task.toMap());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40), // Balance
                const Text(
                  'إضافة مهمة جديدة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 20, color: colorScheme.onSurface),
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Group Picker
            Align(
              alignment: Alignment.centerRight,
              child: Text('المجموعة (اختياري)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface.withAlpha(200))),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  // TODO: Show group picker if needed
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF16938).withAlpha(200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('بدون مجموعة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Task Type Grid
            Align(
              alignment: Alignment.centerRight,
              child: Text('نوع المهمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface.withAlpha(200))),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.end,
              children: _taskTypes.map((typeObj) {
                final isSelected = _selectedType == typeObj['label'];
                return InkWell(
                  onTap: () => setState(() => _selectedType = typeObj['label']),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 60) / 3,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0EFFF) : colorScheme.surfaceContainerHighest.withAlpha(100),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3B82F6) : colorScheme.outline.withAlpha(30),
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          typeObj['icon'],
                          color: isSelected ? const Color(0xFF3B82F6) : colorScheme.onSurface.withAlpha(150),
                          size: 26,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          typeObj['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF3B82F6) : colorScheme.onSurface.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Date and Time Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التاريخ (اختياري)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface.withAlpha(200))),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withAlpha(100),
                            border: Border.all(color: colorScheme.outline.withAlpha(40)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null ? 'mm/dd/yyyy' : DateFormat('MM/dd/yyyy').format(_selectedDate!),
                                style: TextStyle(color: _selectedDate == null ? colorScheme.onSurface.withAlpha(100) : colorScheme.onSurface),
                              ),
                              Icon(Icons.calendar_month_rounded, size: 18, color: colorScheme.onSurface.withAlpha(150)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الوقت (اختياري)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface.withAlpha(200))),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) setState(() => _selectedTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withAlpha(100),
                            border: Border.all(color: colorScheme.outline.withAlpha(40)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime == null ? '--:-- --' : _selectedTime!.format(context),
                                style: TextStyle(color: _selectedTime == null ? colorScheme.onSurface.withAlpha(100) : colorScheme.onSurface),
                              ),
                              Icon(Icons.schedule_rounded, size: 18, color: colorScheme.onSurface.withAlpha(150)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Repeat Options
            Align(
              alignment: Alignment.centerRight,
              child: Text('تكرار التنبيه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface.withAlpha(200))),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(100),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withAlpha(30)),
              ),
              child: Row(
                children: _repeatOptions.map((opt) {
                  final isSelected = _selectedRepeat == opt;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRepeat = opt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isSelected ? [
                            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))
                          ] : null,
                        ),
                        child: Center(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? colorScheme.onSurface : colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            Align(
              alignment: Alignment.centerRight,
              child: Text('ملاحظات / وصف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface.withAlpha(200))),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب تفاصيل المهمة هنا...',
                hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha(100), fontSize: 13),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outline.withAlpha(40)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outline.withAlpha(40)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFFF16938)], // Purple to Orange
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFA855F7).withAlpha(80), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('إضافة المهمة ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
