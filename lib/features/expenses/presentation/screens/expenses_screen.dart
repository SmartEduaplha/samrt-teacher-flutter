import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/db_providers.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  String _category = 'other';
  late String _expenseDate;
  late String _forMonth;
  late String _filterMonth;
  String _filterCategory = 'all';
  bool _isRecurring = false;
  bool _showForm = false;
  bool _saving = false;

  // Arabic category labels matching the images
  static const Map<String, String> _categoryLabels = {
    'rent': 'إيجار',
    'salaries': 'رواتب',
    'supplies': 'مستلزمات',
    'utilities': 'مرافق',
    'maintenance': 'صيانة',
    'marketing': 'تسويق',
    'other': 'أخرى',
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _expenseDate = DateFormat('MM/dd/yyyy').format(now);
    _forMonth = DateFormat('MMMM yyyy').format(now);
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
    _amountController.text = '0';
    _notesController.clear();
    setState(() {
      _category = 'other';
      _expenseDate = DateFormat('MM/dd/yyyy').format(now);
      _forMonth = DateFormat('MMMM yyyy').format(now);
      _isRecurring = false;
      _saving = false;
      _showForm = false;
    });
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال العنوان"), backgroundColor: Colors.orange),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال مبلغ صحيح"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _saving = true);

    // Parse dates back to storage format
    DateTime? expDate;
    try {
      expDate = DateFormat('MM/dd/yyyy').parse(_expenseDate);
    } catch (_) {
      expDate = DateTime.now();
    }
    DateTime? forMonthDate;
    try {
      forMonthDate = DateFormat('MMMM yyyy').parse(_forMonth);
    } catch (_) {
      forMonthDate = DateTime.now();
    }

    final expenseDb = ref.read(expenseDbProvider);
    await expenseDb.create({
      'title': _titleController.text,
      'category': _category,
      'amount': amount,
      'expense_date': DateFormat('yyyy-MM-dd').format(expDate),
      'for_month': DateFormat('yyyy-MM').format(forMonthDate),
      'notes': _notesController.text,
      'is_recurring': _isRecurring,
    });

    _resetForm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم حفظ المصروف بنجاح"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف المصروف"),
        content: const Text("هل أنت متأكد من حذف هذا المصروف؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(expenseDbProvider).delete(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("المعلم الذكي",
                style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D3436), fontSize: 20)),
            Text("Smart Assistant", style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE67E22), borderRadius: BorderRadius.circular(12)),
            child: const IconButton(onPressed: null, icon: Icon(Icons.school, color: Colors.white, size: 20)),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu, color: Colors.grey)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE67E22).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long, color: Color(0xFFE67E22)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("إدارة المصروفات",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("تتبع مصاريف المركز التعليمي بدقة",
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    // Add Button
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _showForm = !_showForm),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("إضافة مصروف", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Stats Cards ────────────────────────────────────────────
              expensesAsync.when(
                data: (allExpenses) {
                  final filtered = allExpenses.where((e) {
                    final monthMatch = e.forMonth == _filterMonth;
                    final catMatch = _filterCategory == 'all' || e.category == _filterCategory;
                    return monthMatch && catMatch;
                  }).toList();
                  final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Total Expenses Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "ج ${total.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                const Text("إجمالي مصروفات الفترة",
                                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Count Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  filtered.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                const Text("إجمالي الحركات المحاسبية",
                                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(height: 90),
                error: (_, e) => const SizedBox(),
              ),

              const SizedBox(height: 16),

              // ── Filters ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Month filter
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse('$_filterMonth-01') ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _filterMonth = DateFormat('yyyy-MM').format(picked);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMMM yyyy').format(
                                    DateTime.tryParse('$_filterMonth-01') ?? DateTime.now()),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Category filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _filterCategory,
                            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                            items: [
                              const DropdownMenuItem(value: 'all', child: Text('كل التصنيفات')),
                              ..._categoryLabels.entries.map(
                                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                              ),
                            ],
                            onChanged: (val) => setState(() => _filterCategory = val ?? 'all'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Add Form (Inline) ──────────────────────────────────────
              if (_showForm)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("سجل مصروف جديد",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            InkWell(
                              onTap: () => setState(() => _showForm = false),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 18, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title + Amount row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("العنوان *",
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _titleController,
                                    textAlign: TextAlign.right,
                                    decoration: _inputDecoration("مثال: فاتورة كهرباء"),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("مبلغ المصروف (ج) *",
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    decoration: _inputDecoration("0"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Category + Date row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("التصنيف",
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _category,
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                        items: _categoryLabels.entries
                                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                            .toList(),
                                        onChanged: (val) => setState(() => _category = val!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("تاريخ الدفع",
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                      );
                                      if (picked != null) {
                                        setState(() => _expenseDate =
                                            DateFormat('MM/dd/yyyy').format(picked));
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                                          Text(_expenseDate,
                                              style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Notes + For Month row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("ملاحظات إضافية",
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _notesController,
                                    textAlign: TextAlign.right,
                                    decoration: _inputDecoration("أي ملاحظة تفصيل"),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("عن شهر",
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                      );
                                      if (picked != null) {
                                        setState(() => _forMonth =
                                            DateFormat('MMMM yyyy').format(picked));
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                          Text(_forMonth,
                                              style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Recurring checkbox
                        InkWell(
                          onTap: () => setState(() => _isRecurring = !_isRecurring),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("مصروف متكرر (يتكرر شهرياً)",
                                  style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 10),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isRecurring ? const Color(0xFFE67E22) : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  color: _isRecurring ? const Color(0xFFE67E22) : Colors.transparent,
                                ),
                                child: _isRecurring
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE67E22),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              _saving ? "جارى الحفظ..." : "حفظ المصروف",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ── Expense List ───────────────────────────────────────────
              expensesAsync.when(
                data: (allExpenses) {
                  final filtered = allExpenses.where((e) {
                    final monthMatch = e.forMonth == _filterMonth;
                    final catMatch = _filterCategory == 'all' || e.category == _filterCategory;
                    return monthMatch && catMatch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.money_off_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text("لا توجد مصروفات مسجلة",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final exp = filtered[index];
                      final catLabel = _categoryLabels[exp.category] ?? 'أخرى';
                      final catColor = _categoryColor(exp.category);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => _handleDelete(exp.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 10),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "ج ${exp.amount.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(exp.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(exp.expenseDate,
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                      Row(
                                        children: [
                                          if (exp.isRecurring) ...[
                                            const Icon(Icons.refresh_rounded,
                                                size: 12, color: Colors.blue),
                                            const SizedBox(width: 4),
                                          ],
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: catColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(catLabel,
                                                style: TextStyle(
                                                    color: catColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (exp.notes.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(exp.notes,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                        textAlign: TextAlign.right),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Color _categoryColor(String category) {
    switch (category) {
      case 'rent': return Colors.indigo;
      case 'salaries': return Colors.teal;
      case 'supplies': return Colors.purple;
      case 'utilities': return Colors.blue;
      case 'maintenance': return Colors.orange;
      case 'marketing': return Colors.pink;
      default: return Colors.grey;
    }
  }
}
