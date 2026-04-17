import '../../../../l10n/generated/app_localizations.dart';

/// نموذج المصروف (Expense)
class ExpenseModel {
  final String id;
  final String title;
  final String category; // rent | salaries | supplies | utilities | maintenance | marketing | other
  final double amount;
  final String expenseDate; // yyyy-MM-dd
  final String forMonth; // yyyy-MM
  final String notes;
  final bool isRecurring;
  final String createdDate;
  final String updatedDate;

  const ExpenseModel({
    required this.id,
    required this.title,
    this.category = 'other',
    required this.amount,
    required this.expenseDate,
    required this.forMonth,
    this.notes = '',
    this.isRecurring = false,
    required this.createdDate,
    required this.updatedDate,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      expenseDate: map['expense_date'] as String? ?? '',
      forMonth: map['for_month'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      isRecurring: map['is_recurring'] as bool? ?? false,
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'expense_date': expenseDate,
      'for_month': forMonth,
      'notes': notes,
      'is_recurring': isRecurring,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }
}

/// تصنيفات المصروفات
enum ExpenseCategory {
  rent('rent', 'إيجار'),
  salaries('salaries', 'رواتب'),
  supplies('supplies', 'مستلزمات'),
  utilities('utilities', 'مرافق'),
  maintenance('maintenance', 'صيانة'),
  marketing('marketing', 'تسويق'),
  other('other', 'أخرى');

  final String value;
  final String label;
  const ExpenseCategory(this.value, this.label);

  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ExpenseCategory.rent:
        return l10n.category_rent;
      case ExpenseCategory.salaries:
        return l10n.category_salaries;
      case ExpenseCategory.supplies:
        return l10n.category_supplies;
      case ExpenseCategory.utilities:
        return l10n.category_utilities;
      case ExpenseCategory.maintenance:
        return l10n.category_maintenance;
      case ExpenseCategory.marketing:
        return l10n.category_marketing;
      case ExpenseCategory.other:
        return l10n.category_other;
    }
  }

  static ExpenseCategory fromValue(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
