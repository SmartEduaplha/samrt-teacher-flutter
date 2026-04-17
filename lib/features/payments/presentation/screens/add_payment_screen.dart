import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../students/data/models/student_model.dart';
import '../../../payments/data/models/payment_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  final String? preStudentId;

  const AddPaymentScreen({super.key, this.preStudentId});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  List<GroupModel> _groups = [];
  List<StudentModel> _allStudents = [];
  List<StudentModel> _filteredStudents = [];

  String? _selectedGroupId;
  String? _selectedStudentId;
  StudentModel? _student;

  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late String _forMonth;
  String _method = 'cash';
  late String _paymentDate;
  String _nextReceipt = '';

  bool _loading = true;
  bool _saving = false;
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _forMonth = DateFormat('yyyy-MM').format(DateTime.now());
    _paymentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedStudentId = widget.preStudentId;
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final groups = await ref.read(groupsProvider.future);
    final students = await ref.read(studentsProvider.future);
    final payments = await ref.read(paymentsProvider.future);

    final activeGroups = groups.where((g) => g.isActive).toList();
    final activeStudents = students.where((s) => s.isActive).toList();

    // Compute next receipt number
    int maxReceipt = 0;
    for (final p in payments) {
      final n = int.tryParse(p.receiptNumber) ?? 0;
      if (n > maxReceipt) maxReceipt = n;
    }

    setState(() {
      _groups = activeGroups;
      _allStudents = activeStudents;
      _filteredStudents = activeStudents;
      _nextReceipt = (maxReceipt + 1).toString();
      _loading = false;
    });

    // Pre-fill if student was passed
    if (widget.preStudentId != null) {
      final st = activeStudents
          .where((s) => s.id == widget.preStudentId)
          .firstOrNull;
      if (st != null) {
        _selectStudent(st);
        setState(() => _selectedGroupId = st.groupId);
      }
    }
  }

  void _selectStudent(StudentModel student) {
    setState(() {
      _selectedStudentId = student.id;
      _student = student;
    });
  }

  double? get _expectedAmount {
    if (_student == null || _student!.isFreeStudent) return null;
    final group =
        _groups.where((g) => g.id == _student!.groupId).firstOrNull;
    if (group == null) return null;
    if (_student!.studentMonthlyDiscount > 0) {
      return group.defaultMonthlyPrice - _student!.studentMonthlyDiscount;
    }
    return group.defaultMonthlyPrice - (group.groupMonthlyDiscount);
  }

  bool _validate() {
    final errors = <String, String>{};
    if (_selectedStudentId == null || _selectedStudentId!.isEmpty) {
      errors['student'] = context.l10n.pleaseSelectStudent;
    }
    final amt = double.tryParse(_amountController.text);
    if (amt == null || amt <= 0) {
      errors['amount'] = context.l10n.amountGreaterThanZero;
    }
    if (_forMonth.isEmpty) {
      errors['month'] = context.l10n.pleaseSelectMonth;
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _saving = true);

    if (_student?.isFreeStudent == true) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.freeStudentTitle),
          content: Text(context.l10n.freeStudentConfirmMessage),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.confirm)),
          ],
        ),
      );
      if (confirm != true) {
        setState(() => _saving = false);
        return;
      }
    }

    final paymentDb = ref.read(paymentDbProvider);
    await paymentDb.create({
      'student_id': _student!.id,
      'student_name': _student!.fullName,
      'group_id': _student!.groupId,
      'group_name': _student!.groupName,
      'amount': double.parse(_amountController.text),
      'for_month': _forMonth,
      'method': _method,
      'payment_date': _paymentDate,
      'receipt_number': _nextReceipt,
      'notes': _notesController.text,
    });

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.paymentRecordedSuccessfully),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.recordNewPayment,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Group filter (optional) ──────────────────────
                          if (widget.preStudentId == null) ...[
                            Text(context.l10n.groupOptionalFilter,
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGroupId,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                  context.l10n.selectGroupFilter, colorScheme),
                              items: [
                                DropdownMenuItem(
                                    value: '_all',
                                    child: Text(context.l10n.allStudents)),
                                ..._groups.map((g) => DropdownMenuItem(
                                    value: g.id, child: Text(g.name))),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedGroupId = val;
                                  if (val == '_all' || val == null) {
                                    _filteredStudents = _allStudents;
                                  } else {
                                    _filteredStudents = _allStudents
                                        .where((s) => s.groupId == val)
                                        .toList();
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Student selector ──────────────────────────
                            Text(context.l10n.studentRequired,
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedStudentId,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                context.l10n.selectStudent,
                                colorScheme,
                                hasError: _errors.containsKey('student'),
                              ),
                              items: _filteredStudents.map((s) {
                                return DropdownMenuItem(
                                  value: s.id,
                                  child: Text(
                                      '${s.fullName}${s.isFreeStudent ? context.l10n.freeLabelSuffix : ""}'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final st = _allStudents
                                      .firstWhere((s) => s.id == val);
                                  _selectStudent(st);
                                }
                              },
                            ),
                            if (_errors.containsKey('student'))
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(_errors['student']!,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.red)),
                              ),
                            const SizedBox(height: 12),
                          ],

                          // ── Student Info Card ───────────────────────────
                          if (_student != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(20),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_student!.fullName,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue.shade800)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _student!.isFreeStudent
                                        ? '${_student!.groupName} · ${context.l10n.freeStudentSuffix}'
                                        : _expectedAmount != null
                                            ? '${_student!.groupName} · ${context.l10n.requiredAmountSuffix(_expectedAmount!.toStringAsFixed(0), context.l10n.currency_egp)}'
                                            : _student!.groupName,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade600),
                                  ),
                                ],
                              ),
                            ),

                          // ── Amount + Month ──────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        context.l10n.amountCurrencyRequired(
                                            context.l10n.currency_egp),
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _amountController,
                                      keyboardType:
                                          TextInputType.number,
                                      decoration: _inputDecoration(
                                        _expectedAmount != null
                                            ? _expectedAmount!
                                                .toStringAsFixed(0)
                                            : context.l10n.recordPayment,
                                        colorScheme,
                                        hasError:
                                            _errors.containsKey('amount'),
                                      ),
                                      onChanged: (_) =>
                                          setState(() {}),
                                    ),
                                    if (_errors.containsKey('amount'))
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4),
                                        child: Text(_errors['amount']!,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.red)),
                                      ),
                                    if (_expectedAmount != null &&
                                        _amountController
                                            .text.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Builder(builder: (_) {
                                        final amt = double.tryParse(
                                                _amountController.text) ??
                                            0;
                                        if (amt < _expectedAmount!) {
                                          final remaining =
                                              (_expectedAmount! - amt)
                                                  .toStringAsFixed(0);
                                          return Text(
                                              context.l10n.partialPaymentLabel(
                                                  remaining,
                                                  context.l10n.currency_egp),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors
                                                      .grey.shade600));
                                        } else if (amt >
                                            _expectedAmount!) {
                                          final excess =
                                              (amt - _expectedAmount!)
                                                  .toStringAsFixed(0);
                                          return Text(
                                              context.l10n.excessPaymentLabel(
                                                  excess,
                                                  context.l10n.currency_egp),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors
                                                      .grey.shade600));
                                        }
                                        return Text(context.l10n.paymentStatusCompleted,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    Colors.grey.shade600));
                                      }),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(context.l10n.monthRequired,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      onTap: () async {
                                        final picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.tryParse(
                                                  '$_forMonth-01') ??
                                              DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                          locale: const Locale('ar'),
                                        );
                                        if (picked != null) {
                                          setState(() => _forMonth =
                                              DateFormat('yyyy-MM')
                                                  .format(picked));
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: _inputDecoration(
                                          '',
                                          colorScheme,
                                          hasError: _errors
                                              .containsKey('month'),
                                        ),
                                        child: Text(_forMonth,
                                            style: theme
                                                .textTheme.bodyLarge),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Method + Date ───────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(context.l10n.paymentMethod,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      initialValue: _method,
                                      isExpanded: true,
                                      decoration: _inputDecoration(
                                          '', colorScheme),
                                      items: PaymentMethod.values
                                          .map((m) => DropdownMenuItem(
                                              value: m.value,
                                              child: Text(m.getLocalizedLabel(
                                                  context.l10n))))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(
                                              () => _method = val);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(context.l10n.paymentDate,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      onTap: () async {
                                        final picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              DateTime.tryParse(
                                                      _paymentDate) ??
                                                  DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now().add(
                                              const Duration(
                                                  days: 365)),
                                          locale: const Locale('ar'),
                                        );
                                        if (picked != null) {
                                          setState(() => _paymentDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(picked));
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: _inputDecoration(
                                            '', colorScheme),
                                        child: Text(_paymentDate,
                                            style: theme
                                                .textTheme.bodyLarge),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Notes ───────────────────────────────────────
                          Text(context.l10n.notes,
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: _inputDecoration(
                                context.l10n.notesHint, colorScheme),
                          ),

                          const SizedBox(height: 12),
                          Divider(
                              color: colorScheme.outline.withAlpha(51)),
                          const SizedBox(height: 8),
                          Text(
                              context.l10n.autoReceiptNumber(_nextReceipt),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withAlpha(102))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Actions ─────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _handleSubmit,
                            icon: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.credit_card_rounded),
                            label: Text(
                                _saving
                                    ? context.l10n.saving
                                    : context.l10n.recordPayment,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18)),
                          ),
                          child: Text(context.l10n.cancel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    ColorScheme colorScheme, {
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: hasError
                ? Colors.red
                : colorScheme.outline.withAlpha(64)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: hasError
                ? Colors.red
                : colorScheme.outline.withAlpha(64)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }
}
