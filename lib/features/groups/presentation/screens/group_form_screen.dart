import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../data/models/group_model.dart';
import '../../../students/data/models/student_model.dart'; // for academicYears

class GroupFormScreen extends ConsumerStatefulWidget {
  final GroupModel? groupToEdit;

  const GroupFormScreen({super.key, this.groupToEdit});

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _subjectController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _locationController;
  late TextEditingController _onlineLinkController;
  late TextEditingController _notesController;
  
  late String _selectedType;
  late String _selectedAcademicYear;
  
  List<ScheduleSlot> _schedule = [];
  bool _isLoading = false;

  final List<Map<String, String>> _daysList = [
    {'value': 'saturday', 'label': 'السبت'},
    {'value': 'sunday', 'label': 'الأحد'},
    {'value': 'monday', 'label': 'الاثنين'},
    {'value': 'tuesday', 'label': 'الثلاثاء'},
    {'value': 'wednesday', 'label': 'الأربعاء'},
    {'value': 'thursday', 'label': 'الخميس'},
    {'value': 'friday', 'label': 'الجمعة'},
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.groupToEdit;
    
    _nameController = TextEditingController(text: g?.name ?? '');
    _subjectController = TextEditingController(text: g?.subject ?? '');
    _priceController = TextEditingController(
        text: (g?.defaultMonthlyPrice ?? 0) > 0 ? g!.defaultMonthlyPrice.toStringAsFixed(0) : '');
    _discountController = TextEditingController(
        text: (g?.groupMonthlyDiscount ?? 0) > 0 ? g!.groupMonthlyDiscount.toStringAsFixed(0) : '0');
    _locationController = TextEditingController(text: g?.type != 'online' ? g?.location : '');
    _onlineLinkController = TextEditingController(text: g?.type == 'online' ? g?.onlineLink : '');
    _notesController = TextEditingController(text: g?.notes ?? '');
    
    _selectedType = g?.type ?? GroupType.center.value;
    _selectedAcademicYear = g?.academicYear ?? (academicYears.contains('year_1_sec') ? 'year_1_sec' : academicYears.first);
    if (g?.schedule != null) {
      _schedule = List.from(g!.schedule);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _locationController.dispose();
    _onlineLinkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    try {
      final db = ref.read(groupDbProvider);
      
      final data = {
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'subject': _subjectController.text.trim(),
        'academic_year': _selectedAcademicYear,
        'default_monthly_price': double.tryParse(_priceController.text) ?? 0.0,
        'group_monthly_discount': double.tryParse(_discountController.text) ?? 0.0,
        'location': _selectedType != 'online' ? _locationController.text.trim() : '',
        'online_link': _selectedType == 'online' ? _onlineLinkController.text.trim() : '',
        'notes': _notesController.text.trim(),
        'schedule': _schedule.map((s) => s.toMap()).toList(),
        'is_active': widget.groupToEdit?.isActive ?? true,
      };

      if (widget.groupToEdit == null) {
        await db.create(data);
      } else {
        await db.update(widget.groupToEdit!.id, data);
      }
      
      ref.invalidate(groupsProvider);
      ref.invalidate(activeGroupsProvider);
      
      if (!mounted) return;
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(widget.groupToEdit == null ? context.l10n.groupCreated : context.l10n.changesSaved), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(context.l10n.errorPrefix(e.toString())), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addSchedule() {
    setState(() {
      _schedule.add(const ScheduleSlot(day: 'saturday', startTime: '16:00', endTime: '18:00'));
    });
  }

  void _updateSchedule(int idx, {String? day, String? start, String? end}) {
    setState(() {
      final old = _schedule[idx];
      _schedule[idx] = ScheduleSlot(
        day: day ?? old.day,
        startTime: start ?? old.startTime,
        endTime: end ?? old.endTime,
      );
    });
  }

  Future<void> _pickTime(int idx, bool isStart) async {
    final old = _schedule[idx];
    final currentParts = (isStart ? old.startTime : old.endTime).split(':');
    final hd = currentParts.length == 2 ? int.tryParse(currentParts[0]) ?? 16 : 16;
    final md = currentParts.length == 2 ? int.tryParse(currentParts[1]) ?? 0 : 0;
    
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hd, minute: md),
    );
    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        _updateSchedule(idx, start: formatted);
      } else {
        _updateSchedule(idx, end: formatted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    double defaultPrice = double.tryParse(_priceController.text) ?? 0.0;
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    double effectivePrice = defaultPrice - discount;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.groupToEdit != null ? context.l10n.editGroup : context.l10n.newGroupTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Basic Info Card
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outline.withAlpha(30)),
                        ),
                        color: colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.l10n.basicInfo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              
                              _buildFieldWrapper(context.l10n.groupName, TextFormField(
                                controller: _nameController,
                                decoration: _inputDec(context.l10n.groupNameHint, colorScheme),
                                validator: (v) => v!.trim().isEmpty ? context.l10n.errorEmptyFields : null,
                              ), colorScheme),
                              const SizedBox(height: 16),
                              
                              _buildFieldWrapper(context.l10n.groupType, DropdownButtonFormField<String>(
                                initialValue: _selectedType,
                                isExpanded: true,
                                decoration: _inputDec('', colorScheme),
                                items: [
                                  DropdownMenuItem(value: 'center', child: Text(context.l10n.center)),
                                  DropdownMenuItem(value: 'private_group', child: Text(context.l10n.privateGroup)),
                                  DropdownMenuItem(value: 'private_lesson', child: Text(context.l10n.privateLesson)),
                                  DropdownMenuItem(value: 'online', child: Text(context.l10n.online)),
                                ],
                                onChanged: (v) => setState(() => _selectedType = v!),
                              ), colorScheme),
                              const SizedBox(height: 16),
                              
                              _buildFieldWrapper(context.l10n.subject, TextFormField(
                                controller: _subjectController,
                                decoration: _inputDec(context.l10n.subjectHint, colorScheme),
                              ), colorScheme),
                              const SizedBox(height: 16),
                              
                              _buildFieldWrapper(context.l10n.academicYear, DropdownButtonFormField<String>(
                                initialValue: _selectedAcademicYear,
                                isExpanded: true,
                                decoration: _inputDec('', colorScheme),
                                items: academicYears.map((y) => DropdownMenuItem(
                                  value: y, 
                                  child: Text(_getLocalizedYear(y, context))
                                )).toList(),
                                onChanged: (v) => setState(() => _selectedAcademicYear = v!),
                              ), colorScheme),
                              const SizedBox(height: 16),

                              _buildFieldWrapper(context.l10n.defaultPrice, TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDec('300', colorScheme),
                                onChanged: (_) => setState(() {}),
                                validator: (v) {
                                  final p = double.tryParse(v ?? '') ?? -1;
                                  if (p < 0) return context.l10n.invalidPrice;
                                  return null;
                                },
                              ), colorScheme),
                              const SizedBox(height: 16),
                              
                              _buildFieldWrapper(context.l10n.groupDiscount, Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _discountController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDec('0', colorScheme),
                                    onChanged: (_) => setState(() {}),
                                    validator: (v) {
                                      final d = double.tryParse(v ?? '') ?? 0;
                                      final p = double.tryParse(_priceController.text) ?? 0;
                                      if (d > p && p > 0) return context.l10n.discountGreaterPrice;
                                      return null;
                                    },
                                  ),
                                  if (_priceController.text.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4, right: 4),
                                      child: Text(
                                        context.l10n.actualPrice(effectivePrice.toStringAsFixed(0)),
                                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                ],
                              ), colorScheme),
                              const SizedBox(height: 16),

                              if (_selectedType != 'online')
                                _buildFieldWrapper(context.l10n.location, TextFormField(
                                  controller: _locationController,
                                  decoration: _inputDec(context.l10n.locationHint, colorScheme),
                                ), colorScheme)
                              else
                                _buildFieldWrapper(context.l10n.sessionLink, TextFormField(
                                  controller: _onlineLinkController,
                                  decoration: _inputDec('https://...', colorScheme),
                                  textDirection: TextDirection.ltr,
                                ), colorScheme),
                                
                              const SizedBox(height: 16),
                              _buildFieldWrapper(context.l10n.notes, TextFormField(
                                controller: _notesController,
                                decoration: _inputDec(context.l10n.notesHint, colorScheme),
                                maxLines: 2,
                              ), colorScheme),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Schedule Card
                      if (_selectedType != 'online')
                        Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colorScheme.outline.withAlpha(30)),
                          ),
                          color: colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.l10n.weeklySchedule, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    OutlinedButton.icon(
                                      onPressed: _addSchedule,
                                      icon: const Icon(Icons.add_rounded, size: 16),
                                      label: Text(context.l10n.addTime),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_schedule.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Text(context.l10n.noScheduleSet, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                    ),
                                  )
                                else
                                  Column(
                                    children: _schedule.asMap().entries.map((entry) {
                                      int idx = entry.key;
                                      ScheduleSlot s = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: DropdownButtonFormField<String>(
                                                initialValue: s.day,
                                                isExpanded: true,
                                                decoration: _inputDec('', colorScheme),
                                                items: _daysList.map((d) => DropdownMenuItem(
                                                  value: d['value']!, 
                                                  child: Text(_getLocalizedDay(d['value']!, context))
                                                )).toList(),
                                                onChanged: (v) => _updateSchedule(idx, day: v!),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () => _pickTime(idx, true),
                                                child: Container(
                                                  height: 48,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(border: Border.all(color: colorScheme.outline.withAlpha(30)), borderRadius: BorderRadius.circular(8)),
                                                  child: Text(s.startTime, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Text(context.l10n.to, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () => _pickTime(idx, false),
                                                child: Container(
                                                  height: 48,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(border: Border.all(color: colorScheme.outline.withAlpha(30)), borderRadius: BorderRadius.circular(8)),
                                                  child: Text(s.endTime, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                              onPressed: () => setState(() => _schedule.removeAt(idx)),
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 100), // padding for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Blue 600
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded, size: 18),
                label: Text(_isLoading ? context.l10n.saving : (widget.groupToEdit != null ? context.l10n.saveChanges : context.l10n.createGroup), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(context.l10n.cancel, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedDay(String day, BuildContext context) {
    switch (day) {
      case 'saturday': return context.l10n.saturday;
      case 'sunday': return context.l10n.sunday;
      case 'monday': return context.l10n.monday;
      case 'tuesday': return context.l10n.tuesday;
      case 'wednesday': return context.l10n.wednesday;
      case 'thursday': return context.l10n.thursday;
      case 'friday': return context.l10n.friday;
      default: return day;
    }
  }

  String _getLocalizedYear(String key, BuildContext context) {
    switch (key) {
      case 'year_1_primary': return context.l10n.year_1_primary;
      case 'year_2_primary': return context.l10n.year_2_primary;
      case 'year_3_primary': return context.l10n.year_3_primary;
      case 'year_4_primary': return context.l10n.year_4_primary;
      case 'year_5_primary': return context.l10n.year_5_primary;
      case 'year_6_primary': return context.l10n.year_6_primary;
      case 'year_1_prep': return context.l10n.year_1_prep;
      case 'year_2_prep': return context.l10n.year_2_prep;
      case 'year_3_prep': return context.l10n.year_3_prep;
      case 'year_1_sec': return context.l10n.year_1_sec;
      case 'year_2_sec': return context.l10n.year_2_sec;
      case 'year_3_sec': return context.l10n.year_3_sec;
      case 'year_university': return context.l10n.year_university;
      case 'year_other': return context.l10n.year_other;
      default: return key;
    }
  }

  Widget _buildFieldWrapper(String label, Widget child, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurface)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDec(String hint, ColorScheme colorScheme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant.withAlpha(150)),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outline.withAlpha(30))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outline.withAlpha(30))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.red.shade300)),
    );
  }
}
