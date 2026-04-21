import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/student_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/providers/db_providers.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final StudentModel? studentToEdit;

  const StudentFormScreen({super.key, this.studentToEdit});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal Info
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _parentPhone2Controller;
  late TextEditingController _landlineController;
  late TextEditingController _addressController;
  late String _gender; // 'male' or 'female'
  
  // Academic
  late String _selectedYear;
  String? _selectedGroup;
  
  // Discounts
  bool _hasDiscount = false;
  late TextEditingController _discountController;
  bool _isFreeStudent = false;
  
  // Extra
  late TextEditingController _notesController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.studentToEdit;
    
    _nameController = TextEditingController(text: s?.fullName ?? '');
    _phoneController = TextEditingController(text: s?.phoneNumber ?? '');
    _parentPhoneController = TextEditingController(text: s?.parentPhoneNumber ?? '');
    _parentPhone2Controller = TextEditingController(text: s?.parentPhoneNumber2 ?? '');
    _landlineController = TextEditingController(text: s?.landlineNumber ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _gender = s?.gender ?? 'male';
    
    _selectedYear = s?.academicYear ?? academicYears.firstWhere((e) => e == 'year_1_sec', orElse: () => academicYears.first);
    _selectedGroup = s?.groupId;
    
    _discountController = TextEditingController(
      text: (s?.studentMonthlyDiscount ?? 0) > 0 ? s!.studentMonthlyDiscount.toStringAsFixed(0) : ''
    );
    _hasDiscount = (s?.studentMonthlyDiscount ?? 0) > 0;
    _isFreeStudent = s?.isFreeStudent ?? false;
    
    _notesController = TextEditingController(text: s?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _parentPhoneController.dispose();
    _parentPhone2Controller.dispose();
    _landlineController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.selectGroup), backgroundColor: Colors.red));
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final db = ref.read(studentDbProvider);
      
      final groups = await ref.read(groupsProvider.future);
      String groupName = '';
      try {
        groupName = groups.firstWhere((g) => g.id == _selectedGroup).name;
      } catch (_) {}

      final data = {
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'parent_phone_number': _parentPhoneController.text.trim(),
        'parent_phone_number_2': _parentPhone2Controller.text.trim(),
        'landline_number': _landlineController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _gender,
        'academic_year': _selectedYear,
        'group_id': _selectedGroup,
        'group_name': groupName,
        'student_monthly_discount': _hasDiscount ? (double.tryParse(_discountController.text) ?? 0.0) : 0.0,
        'is_free_student': _isFreeStudent,
        'notes': _notesController.text.trim(),
        'is_active': widget.studentToEdit?.isActive ?? true,
      };

      if (widget.studentToEdit == null) {
        await db.create(data);
      } else {
        await db.update(widget.studentToEdit!.id, data);
      }
      
      ref.invalidate(studentsProvider);
      ref.invalidate(activeStudentsProvider);
      
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.studentToEdit == null ? context.l10n.studentRegisteredSuccess : context.l10n.changesSaved), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.errorLoadingGroups}: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getYearLabel(String yearKey) {
    switch (yearKey) {
      case 'year_1_sec': return context.l10n.year_1_sec;
      case 'year_2_sec': return context.l10n.year_2_sec;
      case 'year_3_sec': return context.l10n.year_3_sec;
      case 'year_6_primary': return context.l10n.year_6_primary;
      case 'year_5_primary': return context.l10n.year_5_primary;
      case 'year_4_primary': return context.l10n.year_4_primary;
      case 'year_3_primary': return context.l10n.year_3_primary;
      case 'year_2_primary': return context.l10n.year_2_primary;
      case 'year_1_primary': return context.l10n.year_1_primary;
      case 'year_3_prep': return context.l10n.year_3_prep;
      case 'year_2_prep': return context.l10n.year_2_prep;
      case 'year_1_prep': return context.l10n.year_1_prep;
      case 'year_university': return context.l10n.year_university;
      default: return context.l10n.year_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final groupsAsync = ref.watch(activeGroupsProvider);

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
                    widget.studentToEdit != null ? context.l10n.editStudent : context.l10n.newStudentLabel,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Card 1: Personal Info
                      _buildCard(
                        title: context.l10n.personalData,
                        icon: Icons.person_outline_rounded,
                        children: [
                          _buildFieldWrapper(context.l10n.fullNameLabel, TextFormField(
                            controller: _nameController,
                            decoration: _inputDec(context.l10n.fullNameHint),
                            validator: (v) => v!.trim().isEmpty ? context.l10n.nameRequired : null,
                          )),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildFieldWrapper(context.l10n.studentPhone, TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _inputDec(context.l10n.phoneFormatHint),
                                )),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFieldWrapper(context.l10n.parentPhone1, TextFormField(
                                  controller: _parentPhoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _inputDec(context.l10n.phoneFormatHint),
                                  validator: (v) => v!.trim().isEmpty ? context.l10n.parentPhoneRequired : null,
                                )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildFieldWrapper(context.l10n.parentPhone2, TextFormField(
                                  controller: _parentPhone2Controller,
                                  keyboardType: TextInputType.phone,
                                  decoration: _inputDec(context.l10n.emergencyPhoneHint),
                                )),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFieldWrapper(context.l10n.landline, TextFormField(
                                  controller: _landlineController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _inputDec(context.l10n.optional),
                                )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldWrapper(context.l10n.address, TextFormField(
                            controller: _addressController,
                            decoration: _inputDec(context.l10n.addressHint),
                          )),
                          const SizedBox(height: 16),
                          _buildFieldWrapper(context.l10n.genderLabel, RadioGroup<String>(
                            groupValue: _gender,
                            onChanged: (v) => setState(() => _gender = v!),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(context.l10n.male, style: const TextStyle(fontSize: 14)),
                                    value: 'male',
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(context.l10n.female, style: const TextStyle(fontSize: 14)),
                                    value: 'female',
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ]
                      ),
                      const SizedBox(height: 16),

                      // Card 2: Academic Info
                      _buildCard(
                        title: context.l10n.academicData,
                        icon: Icons.school_outlined,
                        children: [
                          _buildFieldWrapper(context.l10n.academicYearLabel, DropdownButtonFormField<String>(
                            initialValue: _selectedYear,
                            decoration: _inputDec(''),
                            items: academicYears.map((y) => DropdownMenuItem(value: y, child: Text(_getYearLabel(y)))).toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedYear = v!;
                                // Don't reset _selectedGroup, just let it be. If the user explicitly selects a year, 
                                // it won't break the _selectedGroup unless they change it next.
                              });
                            },
                          )),
                          const SizedBox(height: 16),
                          _buildFieldWrapper(context.l10n.targetGroup, groupsAsync.when(
                            data: (groups) {
                              if (groups.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    context.l10n.noGroupsYet,
                                    style: TextStyle(color: colorScheme.error, fontSize: 13),
                                  ),
                                );
                              }

                                return DropdownButtonFormField<String>(
                                initialValue: groups.any((g) => g.id == _selectedGroup) ? _selectedGroup : null,
                                decoration: _inputDec(context.l10n.selectGroupHint),
                                items: groups.map((g) => DropdownMenuItem(value: g.id, child: Text('${g.name} - ${_getYearLabel(g.academicYear)}'))).toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedGroup = v;
                                    if (v != null) {
                                      // Automatically select the correct academic year based on the chosen group
                                      final selectedG = groups.firstWhere((g) => g.id == v);
                                      if (academicYears.contains(selectedG.academicYear)) {
                                        _selectedYear = selectedG.academicYear;
                                      }
                                    }
                                  });
                                },
                                validator: (v) => v == null ? context.l10n.groupRequired : null,
                                isExpanded: true,
                              );
                            },
                            loading: () => const SizedBox(
                              height: 48,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                            error: (_, _) => Text(
                              context.l10n.errorLoadingGroups,
                              style: TextStyle(color: colorScheme.error, fontSize: 12),
                            ),
                          )),
                        ]
                      ),
                      const SizedBox(height: 16),

                      // Card 3: Discounts
                      _buildCard(
                        title: context.l10n.discountsAndExemptions,
                        icon: Icons.percent_rounded,
                        children: [
                          // Is Free Student Toggle
                          Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                            child: SwitchListTile(
                              title: Text(context.l10n.freeStudentToggle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              subtitle: Text(context.l10n.fullExemption, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              activeThumbColor: Colors.teal,
                              value: _isFreeStudent,
                              onChanged: (v) {
                                setState(() {
                                  _isFreeStudent = v;
                                  if (v) _hasDiscount = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Has Custom Discount Toggle
                          if (!_isFreeStudent)
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: Text(context.l10n.hasIndividualDiscount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    subtitle: Text(context.l10n.plusGroupDiscount, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    activeThumbColor: colorScheme.primary,
                                    value: _hasDiscount,
                                    onChanged: (v) => setState(() => _hasDiscount = v),
                                  ),
                                  if (_hasDiscount)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                      child: TextFormField(
                                        controller: _discountController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDec(context.l10n.discountValue),
                                        validator: (v) => _hasDiscount && v!.trim().isEmpty ? context.l10n.required : null,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ]
                      ),
                      const SizedBox(height: 16),

                      // Card 4: Extras
                      _buildCard(
                        title: context.l10n.extra,
                        icon: Icons.notes_rounded,
                        children: [
                          _buildFieldWrapper(context.l10n.studentNotes, TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: _inputDec(context.l10n.studentNotesHint),
                          ))
                        ]
                      ),
                      const SizedBox(height: 100), // padding for bottom sheet
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
                onPressed: _isLoading ? null : _saveStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded, size: 18),
                label: Text(_isLoading ? context.l10n.saving : (widget.studentToEdit != null ? context.l10n.changesSaved : context.l10n.registerStudent), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWrapper(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDec(String hint) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant.withAlpha(150)),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline.withAlpha(50))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline.withAlpha(50))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.error.withAlpha(150))),
    );
  }
}
