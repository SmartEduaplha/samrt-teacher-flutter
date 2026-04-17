import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/db_providers.dart';
import '../../data/models/store_item_model.dart';

class StoreFormScreen extends ConsumerStatefulWidget {
  final StoreItemModel? itemToEdit;

  const StoreFormScreen({super.key, this.itemToEdit});

  @override
  ConsumerState<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends ConsumerState<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late String _selectedCategory;
  late bool _isActive;
  bool _isLoading = false;

  final List<String> _categories = [
    'مذكرات',
    'كتب',
    'ملخصات',
    'بنك أسئلة',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _priceController = TextEditingController(
        text: item != null ? item.price.toStringAsFixed(0) : '');
    _imageUrlController = TextEditingController(text: item?.imageUrl ?? '');
    _selectedCategory = item?.category ?? 'مذكرات';
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final db = ref.read(storeDbProvider);
      final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'image_url': _imageUrlController.text.trim(),
        'category': _selectedCategory,
        'is_active': _isActive,
        'updated_date': now,
      };

      if (widget.itemToEdit == null) {
        data['created_date'] = now;
        await db.create(data);
      } else {
        await db.update(widget.itemToEdit!.id, data);
      }

      ref.invalidate(storeProvider);

      if (!mounted) return;
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(widget.itemToEdit == null
              ? 'تم إضافة العنصر بنجاح'
              : 'تم تحديث البيانات'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceTint.withValues(alpha: 0.05),
      appBar: AppBar(
        title: Text(widget.itemToEdit != null ? 'تعديل عنصر' : 'إضافة عنصر جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildFieldWrapper(
                        'اسم المذكرة أو الكتاب *',
                        TextFormField(
                          controller: _titleController,
                          decoration: _inputDec('مثال: مراجعة ليلة الامتحان'),
                          validator: (v) =>
                              v!.trim().isEmpty ? 'يرجى إدخال الاسم' : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldWrapper(
                        'الوصف',
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _inputDec('وصف مختصر للمحتوى...'),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFieldWrapper(
                              'السعر (ج.م) *',
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDec('0'),
                                validator: (v) {
                                  if (v!.trim().isEmpty) return 'مطلوب';
                                  if (double.tryParse(v) == null) return 'خطأ';
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFieldWrapper(
                              'التصنيف *',
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: _inputDec(''),
                                items: _categories
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedCategory = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFieldWrapper(
                        'رابط صورة الغلاف (URL)',
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: _inputDec('https://...'),
                          textDirection: ui.TextDirection.ltr,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('العنصر متاح حالياً للطلاب'),
                        subtitle: const Text('يمكنك تعطيل العنصر مؤقتاً دون حذفه'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _saveItem,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: Text(
                      _isLoading
                          ? 'جاري الحفظ...'
                          : (widget.itemToEdit != null
                              ? 'حفظ التعديلات'
                              : 'إضافة للمتجر'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWrapper(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}
