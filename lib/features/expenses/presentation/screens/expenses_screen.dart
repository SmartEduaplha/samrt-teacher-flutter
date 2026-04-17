import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'other';
  late String _expenseDate;
  late String _forMonth;
  late String _filterMonth;
  String _filterCategory = 'all';
  bool _isRecurring = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _expenseDate = DateFormat('yyyy-MM-dd').format(now);
    _forMonth = DateFormat('yyyy-MM').format(now);
    _filterMonth = DateFormat('yyyy-MM').format(now);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _resetForm() {
    final now = DateTime.now();
    _titleController.clear();
    _amountController.clear();
    _notesController.clear();
    setState(() {
      _category = 'other';
      _expenseDate = DateFormat('yyyy-MM-dd').format(now);
      _forMonth = DateFormat('yyyy-MM').format(now);
      _isRecurring = false;
      _saving = false;
    });
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
    setState(() => _saving = true);

    final expenseDb = ref.read(expenseDbProvider);
    await expenseDb.create({
      'title': _titleController.text,
      'category': _category,
      'amount': double.parse(_amountController.text),
      'expense_date': _expenseDate,
      'for_month': _forMonth,
      'notes': _notesController.text,
      'is_recurring': _isRecurring,
    });

    _resetForm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.expenseRecordedSuccess)),
      );
    }
  }

  Future<void> _handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteExpenseTitle),
        content: Text(context.l10n.deleteExpenseConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.delete)),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(expenseDbProvider).delete(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.manageExpensesTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // ── Stats Header ───────────────────────────────────────────
          expensesAsync.when(
            data: (allExpenses) {
              final filtered = allExpenses.where((e) {
                final monthMatch = e.forMonth == _filterMonth;
                final catMatch =
                    _filterCategory == 'all' || e.category == _filterCategory;
                return monthMatch && catMatch;
              }).toList();
              final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StatBox(
                      title: context.l10n.totalExpenses,
                      value:
                          '${total.toStringAsFixed(0)} ${context.l10n.currency_egp}',
                      color: Colors.red,
                      icon: Icons.trending_down_rounded,
                    ),
                    const SizedBox(width: 10),
                    _StatBox(
                      title: context.l10n.transactionsCount,
                      value: filtered.length.toString(),
                      color: Colors.blue,
                      icon: Icons.receipt_long_rounded,
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 100),
            error: (_, _) => const SizedBox(),
          ),

          // ── Filters ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.tryParse('$_filterMonth-01') ??
                            DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        locale: const Locale('ar'),
                      );
                      if (picked != null) {
                        setState(() => _filterMonth =
                            DateFormat('yyyy-MM').format(picked));
                      }
                    },
                    child: InputDecorator(
                      decoration: _filterDecoration(colorScheme),
                      child: Text(_filterMonth,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterCategory,
                    isExpanded: true,
                    decoration: _filterDecoration(colorScheme),
                    items: [
                      DropdownMenuItem(
                          value: 'all', child: Text(context.l10n.allCategories)),
                      ...ExpenseCategory.values.map((c) => DropdownMenuItem(
                          value: c.value,
                          child: Text(c.getLocalizedLabel(context.l10n)))),
                    ],
                    onChanged: (val) =>
                        setState(() => _filterCategory = val ?? 'all'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: expensesAsync.when(
              data: (allExpenses) {
                final filtered = allExpenses.where((e) {
                  final monthMatch = e.forMonth == _filterMonth;
                  final catMatch =
                      _filterCategory == 'all' || e.category == _filterCategory;
                  return monthMatch && catMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money_off_rounded,
                            size: 64, color: colorScheme.outline.withAlpha(50)),
                        const SizedBox(height: 16),
                        Text(context.l10n.noExpensesRecorded,
                            style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(150))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final exp = filtered[index];
                    final catObj = ExpenseCategory.fromValue(exp.category);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(exp.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text(
                                '${exp.amount.toStringAsFixed(0)} ${context.l10n.currency_egp}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red)),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                    catObj.getLocalizedLabel(context.l10n),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Text(exp.expenseDate,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.onSurface
                                          .withAlpha(120))),
                              if (exp.isRecurring) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.refresh_rounded,
                                    size: 12, color: Colors.blue),
                              ],
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 20),
                          onPressed: () => _handleDelete(exp.id),
                        ),
                      ),
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
        onPressed: () => _openAddForm(context, colorScheme, theme),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addExpense),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  void _openAddForm(
      BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: colorScheme.outline.withAlpha(50),
                            borderRadius: BorderRadius.circular(2))),
                  ],
                ),
                const SizedBox(height: 20),
                Text(context.l10n.recordNewExpense,
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: _formDecoration(
                      '${context.l10n.titleLabel} *', colorScheme),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: _formDecoration(
                      '${context.l10n.amountLabel} (${context.l10n.currency_egp}) *',
                      colorScheme),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration:
                      _formDecoration(context.l10n.categoryLabel, colorScheme),
                  items: ExpenseCategory.values
                      .map((c) => DropdownMenuItem(
                          value: c.value,
                          child: Text(c.getLocalizedLabel(context.l10n))))
                      .toList(),
                  onChanged: (val) => setModalState(() => _category = val!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse(_expenseDate) ??
                                DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            locale: const Locale('ar'),
                          );
                          if (picked != null) {
                            setModalState(() => _expenseDate =
                                DateFormat('yyyy-MM-dd').format(picked));
                          }
                        },
                        child: InputDecorator(
                          decoration: _formDecoration(
                              context.l10n.paymentDate, colorScheme),
                          child: Text(_expenseDate),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse('$_forMonth-01') ??
                                DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            locale: const Locale('ar'),
                          );
                          if (picked != null) {
                            setModalState(() => _forMonth =
                                DateFormat('yyyy-MM').format(picked));
                          }
                        },
                        child: InputDecorator(
                          decoration: _formDecoration(
                              context.l10n.forMonth, colorScheme),
                          child: Text(_forMonth),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  decoration:
                      _formDecoration(context.l10n.notesLabel, colorScheme),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(context.l10n.recurringExpenseLabel,
                      style: const TextStyle(fontSize: 14)),
                  value: _isRecurring,
                  onChanged: (val) => setModalState(() => _isRecurring = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            await _handleSave();
                            if (context.mounted) Navigator.pop(ctx);
                          },
                    child: Text(
                        _saving
                            ? '${context.l10n.saving}...'
                            : context.l10n.saveExpense,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _filterDecoration(ColorScheme colorScheme) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  InputDecoration _formDecoration(String label, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withAlpha(30),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(50))),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            Text(title,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withAlpha(180))),
          ],
        ),
      ),
    );
  }
}
