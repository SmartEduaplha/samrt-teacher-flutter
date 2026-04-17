import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../students/data/models/student_model.dart';
import '../../../attendance/data/models/attendance_model.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  final String? preGroupId;

  const AttendanceScreen({super.key, this.preGroupId});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String? _selectedGroupId;
  late String _sessionDate;

  List<GroupModel> _groups = [];
  List<StudentModel> _students = [];
  List<AttendanceRecord> _existingRecords = [];
  Map<String, String> _attendance = {};

  bool _loading = true;
  bool _saving = false;
  bool _saved = false;

  // WhatsApp panel
  bool _showWaPanel = false;
  String _waTemplate = 'absent';
  String _waTarget = 'absent';
  String _teacherName = '';

  @override
  void initState() {
    super.initState();
    _sessionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedGroupId = widget.preGroupId;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await ref.read(groupsProvider.future);
    setState(() {
      _groups = groups.where((g) => g.isActive).toList();
      _loading = false;
    });

    if (_selectedGroupId != null) {
      _loadStudentsAndAttendance();
    }
  }

  Future<void> _loadStudentsAndAttendance() async {
    if (_selectedGroupId == null) return;
    setState(() => _loading = true);

    final studentDb = ref.read(studentDbProvider);
    final attendanceDb = ref.read(attendanceDbProvider);

    final allStudents =
        await studentDb.filter({'group_id': _selectedGroupId!, 'is_active': true});
    final existing = await attendanceDb
        .filter({'group_id': _selectedGroupId!, 'date': _sessionDate});

    final att = <String, String>{};
    if (existing.isNotEmpty) {
      for (final r in existing) {
        att[r.studentId] = r.status;
      }
    } else {
      for (final s in allStudents) {
        att[s.id] = 'present';
      }
    }

    setState(() {
      _students = allStudents;
      _existingRecords = existing;
      _attendance = att;
      _loading = false;
    });
  }

  void _toggle(String studentId) {
    setState(() {
      _attendance[studentId] =
          _attendance[studentId] == 'present' ? 'absent' : 'present';
    });
  }

  void _setAll(String status) {
    setState(() {
      for (final s in _students) {
        _attendance[s.id] = status;
      }
    });
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);

    final attendanceDb = ref.read(attendanceDbProvider);
    final existingMap = <String, String>{};
    for (final r in _existingRecords) {
      existingMap[r.studentId] = r.id;
    }

    final groupName =
        _groups.firstWhere((g) => g.id == _selectedGroupId).name;

    for (final student in _students) {
      final status = _attendance[student.id] ?? 'absent';
      final data = <String, dynamic>{
        'group_id': _selectedGroupId,
        'student_id': student.id,
        'student_name': student.fullName,
        'group_name': groupName,
        'date': _sessionDate,
        'status': status,
        'notes': '',
      };

      if (existingMap.containsKey(student.id)) {
        await attendanceDb.update(existingMap[student.id]!, data);
      } else {
        await attendanceDb.create(data);
      }
    }

    setState(() {
      _saving = false;
      _saved = true;
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _saved = false);
    });

    _loadStudentsAndAttendance();
  }

  // ── WhatsApp helpers ─────────────────────────────────────────────────────────
  String _getPhone(StudentModel student) {
    return student.parentPhoneNumber.isNotEmpty
        ? student.parentPhoneNumber
        : student.phoneNumber.isNotEmpty
            ? student.phoneNumber
            : student.parentPhoneNumber2.isNotEmpty
                ? student.parentPhoneNumber2
                : '';
  }

  Future<void> _openWhatsApp(String phone, String text) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return;
    final uri =
        Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _buildMessage(String studentName) {
    final groupName = _selectedGroupId != null
        ? _groups
            .firstWhere((g) => g.id == _selectedGroupId,
                orElse: () => _groups.first)
            .name
        : context.l10n.group;
    final dateFormatted = _formattedLocalizedDate();
    final teacher = _teacherName.isNotEmpty ? '\n— ${context.l10n.teacher}: $_teacherName' : '';

    switch (_waTemplate) {
      case 'present':
        return context.l10n.attendance_wa_msg_present_template(
            studentName, groupName, dateFormatted, teacher);
      case 'late':
        return context.l10n.attendance_wa_msg_late_template(
            studentName, groupName, dateFormatted, teacher);
      case 'reminder':
        return context.l10n.attendance_wa_msg_reminder_template(
            studentName, groupName, dateFormatted, teacher);
      case 'absent':
      default:
        return context.l10n.attendance_wa_msg_absent_template(
            studentName, groupName, dateFormatted, teacher);
    }
  }

  String _formattedLocalizedDate() {
    try {
      final dt = DateTime.parse('${_sessionDate}T12:00:00');
      final locale = Localizations.localeOf(context).languageCode;
      return DateFormat.yMMMMEEEEd(locale).format(dt);
    } catch (_) {
      return _sessionDate;
    }
  }

  List<StudentModel> get _targetStudents {
    return _students.where((s) {
      if (_waTarget == 'all') return true;
      if (_waTarget == 'absent') return _attendance[s.id] == 'absent';
      return _attendance[s.id] == 'present';
    }).toList();
  }

  int get _presentCount =>
      _attendance.values.where((v) => v == 'present').length;
  int get _absentCount =>
      _attendance.values.where((v) => v == 'absent').length;
  bool get _isEditing => _existingRecords.isNotEmpty;

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.attendance_title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            if (_isEditing) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.amber.withAlpha(77), width: 1),
                ),
                child: Text(context.l10n.attendance_edit_registered,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber)),
              ),
            ],
          ],
        ),
      ),
      body: _loading && _groups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                // ── Controls: Group + Date ─────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group selector
                        Text(context.l10n.group,
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGroupId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: context.l10n.attendance_select_group_hint,
                            filled: true,
                            fillColor: colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: colorScheme.outline.withAlpha(64)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: colorScheme.outline.withAlpha(64)),
                            ),
                          ),
                          items: _groups
                              .map((g) => DropdownMenuItem(
                                  value: g.id, child: Text(g.name)))
                              .toList(),
                          onChanged: (val) {
                            setState(() => _selectedGroupId = val);
                            _loadStudentsAndAttendance();
                          },
                        ),

                        const SizedBox(height: 16),

                        // Date selector
                        Text(context.l10n.attendance_session_date_label,
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.tryParse(_sessionDate) ??
                                  DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                              locale: const Locale('ar'),
                            );
                            if (picked != null) {
                              setState(() => _sessionDate =
                                  DateFormat('yyyy-MM-dd').format(picked));
                              _loadStudentsAndAttendance();
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colorScheme.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: colorScheme.outline.withAlpha(64)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: colorScheme.outline.withAlpha(64)),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today,
                                  size: 20),
                            ),
                            child: Text(_formattedLocalizedDate(),
                                style: theme.textTheme.bodyLarge),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Everything below needs a group selected ────────────────
                if (_selectedGroupId != null) ...[
                  const SizedBox(height: 12),

                  // ── Stats ────────────────────────────────────────────────
                  if (_students.isNotEmpty && !_loading) ...[
                    Row(
                      children: [
                        _StatBox(
                            label: context.l10n.attendance_stat_present,
                            value: _presentCount,
                            color: Colors.green),
                        const SizedBox(width: 10),
                        _StatBox(
                            label: context.l10n.attendance_stat_absent,
                            value: _absentCount,
                            color: Colors.red),
                        const SizedBox(width: 10),
                        _StatBox(
                            label: context.l10n.attendance_stat_total,
                            value: _students.length,
                            color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Quick actions ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            label: context.l10n.attendance_quick_all_present,
                            color: Colors.green,
                            onTap: () => _setAll('present'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickActionButton(
                            label: context.l10n.attendance_quick_all_absent,
                            color: Colors.red,
                            onTap: () => _setAll('absent'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Students list ────────────────────────────────────────
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_students.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(context.l10n.attendance_no_students_in_group,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withAlpha(128))),
                      ),
                    )
                  else ...[
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: _students.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final student = entry.value;
                          final isPresent =
                              _attendance[student.id] == 'present';
                          final hasPhone = _getPhone(student).isNotEmpty;

                          return Column(
                            children: [
                              if (idx > 0)
                                Divider(
                                    height: 1,
                                    color:
                                        colorScheme.outline.withAlpha(38)),
                              Container(
                                color: isPresent
                                    ? Colors.green.withAlpha(13)
                                    : Colors.red.withAlpha(13),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                  leading: GestureDetector(
                                    onTap: () => _toggle(student.id),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        isPresent
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        key: ValueKey(isPresent),
                                        color: isPresent
                                            ? Colors.green
                                            : Colors.red.shade400,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  title: Text(student.fullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  subtitle: student.isFreeStudent
                                      ? Container(
                                          margin:
                                              const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.green.withAlpha(38),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(context.l10n.freeStudent,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPresent
                                              ? Colors.green.withAlpha(38)
                                              : Colors.red.withAlpha(38),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                            isPresent 
                                                ? context.l10n.attendance_stat_present 
                                                : context.l10n.attendance_stat_absent,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isPresent
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700)),
                                      ),
                                      if (hasPhone) ...[
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            final text = _buildMessage(
                                                student.fullName);
                                            _openWhatsApp(
                                                _getPhone(student), text);
                                          },
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withAlpha(38),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.message,
                                                size: 16,
                                                color: Colors.green),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: () => _toggle(student.id),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Save Button ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _handleSave,
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Icon(_saved
                                ? Icons.check_rounded
                                : Icons.save_rounded),
                        label: Text(
                          _saving
                              ? context.l10n.attendance_saving_state
                              : _saved
                                  ? context.l10n.attendance_save_success_state
                                  : context.l10n.attendance_save_button_label,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── WhatsApp Bulk Button ───────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _showWaPanel = !_showWaPanel),
                        icon: const Icon(Icons.message_rounded,
                            color: Colors.green),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.l10n.attendance_whatsapp_bulk_toggle,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                            const SizedBox(width: 6),
                            AnimatedRotation(
                              turns: _showWaPanel ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.keyboard_arrow_down,
                                  size: 20, color: Colors.green),
                            ),
                          ],
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.green.withAlpha(102), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          backgroundColor: Colors.green.withAlpha(13),
                        ),
                      ),
                    ),

                    // ── WhatsApp Panel ─────────────────────────────────────
                    if (_showWaPanel) ...[
                      const SizedBox(height: 10),
                      _buildWhatsAppPanel(theme, colorScheme),
                    ],
                  ],
                ],
              ],
            ),
    );
  }

  Widget _buildWhatsAppPanel(ThemeData theme, ColorScheme colorScheme) {
    final studentsWithNoPhone =
        _targetStudents.where((s) => _getPhone(s).isEmpty).length;
    final sendCount =
        _targetStudents.where((s) => _getPhone(s).isNotEmpty).length;

    return Card(
      color: Colors.green.withAlpha(13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.green.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher name
            Text(context.l10n.attendance_wa_teacher_name_label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => setState(() => _teacherName = v),
              decoration: InputDecoration(
                hintText: context.l10n.attendance_wa_teacher_name_hint,
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 16),

            // Template selector
            Text(context.l10n.attendance_wa_msg_type_label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _WaTemplateChip(
                    id: 'absent',
                    label: context.l10n.attendance_wa_type_absent,
                    selected: _waTemplate,
                    activeColor: Colors.red,
                    onTap: () => setState(() => _waTemplate = 'absent')),
                _WaTemplateChip(
                    id: 'present',
                    label: context.l10n.attendance_wa_type_present,
                    selected: _waTemplate,
                    activeColor: Colors.green,
                    onTap: () => setState(() => _waTemplate = 'present')),
                _WaTemplateChip(
                    id: 'late',
                    label: context.l10n.attendance_wa_type_late,
                    selected: _waTemplate,
                    activeColor: Colors.amber,
                    onTap: () => setState(() => _waTemplate = 'late')),
                _WaTemplateChip(
                    id: 'reminder',
                    label: context.l10n.attendance_wa_type_reminder,
                    selected: _waTemplate,
                    activeColor: Colors.blue,
                    onTap: () => setState(() => _waTemplate = 'reminder')),
              ],
            ),

            const SizedBox(height: 16),

            // Target selector
            Text(context.l10n.attendance_wa_send_to_label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withAlpha(179),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _WaTargetTab(
                      label: context.l10n.attendance_wa_target_absent(_absentCount),
                      id: 'absent',
                      selected: _waTarget,
                      onTap: () => setState(() => _waTarget = 'absent')),
                  _WaTargetTab(
                      label: context.l10n.attendance_wa_target_present(_presentCount),
                      id: 'present',
                      selected: _waTarget,
                      onTap: () => setState(() => _waTarget = 'present')),
                  _WaTargetTab(
                      label: context.l10n.attendance_wa_target_all(_students.length),
                      id: 'all',
                      selected: _waTarget,
                      onTap: () => setState(() => _waTarget = 'all')),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withAlpha(179),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.attendance_wa_preview_label,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withAlpha(128),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(_buildMessage(context.l10n.attendance_wa_preview_name_placeholder),
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.7)),
                ],
              ),
            ),

            // Warning
            if (studentsWithNoPhone > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          context.l10n.attendance_wa_no_phone_warning(studentsWithNoPhone),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.amber)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Send button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: sendCount == 0
                    ? null
                    : () async {
                        for (final s in _targetStudents) {
                          if (_getPhone(s).isNotEmpty) {
                            final text = _buildMessage(s.fullName);
                            await _openWhatsApp(_getPhone(s), text);
                            await Future.delayed(
                                const Duration(milliseconds: 800));
                          }
                        }
                      },
                icon: const Icon(Icons.send_rounded),
                label: Text(context.l10n.attendance_wa_send_button_label(sendCount),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(77)),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.shade700)),
        ),
      ),
    );
  }
}

class _WaTemplateChip extends StatelessWidget {
  final String id;
  final String label;
  final String selected;
  final Color activeColor;
  final VoidCallback onTap;

  const _WaTemplateChip(
      {required this.id,
      required this.label,
      required this.selected,
      required this.activeColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = id == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : activeColor.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isActive ? activeColor : activeColor.withAlpha(77),
              width: 2),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : activeColor)),
      ),
    );
  }
}

class _WaTargetTab extends StatelessWidget {
  final String label;
  final String id;
  final String selected;
  final VoidCallback onTap;

  const _WaTargetTab(
      {required this.label,
      required this.id,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = id == selected;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 4,
                        offset: const Offset(0, 1))
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(128)),
          ),
        ),
      ),
    );
  }
}

// Extension for shade on Color
extension _ColorShade on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0)).toColor();
  }
}
