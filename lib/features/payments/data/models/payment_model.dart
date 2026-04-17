import '../../../../l10n/generated/app_localizations.dart';

/// نموذج الدفعة (Payment)
class PaymentModel {
  final String id;
  final String studentId;
  final String studentName;
  final String groupId;
  final String groupName;
  final double amount;
  final String forMonth; // yyyy-MM
  final String method; // cash | bankTransfer | vodafoneCash | other
  final String paymentDate; // yyyy-MM-dd
  final String receiptNumber;
  final String notes;
  final String createdDate;
  final String updatedDate;

  const PaymentModel({
    required this.id,
    required this.studentId,
    this.studentName = '',
    this.groupId = '',
    this.groupName = '',
    required this.amount,
    required this.forMonth,
    this.method = 'cash',
    this.paymentDate = '',
    this.receiptNumber = '',
    this.notes = '',
    required this.createdDate,
    required this.updatedDate,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as String,
      studentId: map['student_id'] as String? ?? '',
      studentName: map['student_name'] as String? ?? '',
      groupId: map['group_id'] as String? ?? '',
      groupName: map['group_name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      forMonth: map['for_month'] as String? ?? '',
      method: map['method'] as String? ?? 'cash',
      paymentDate: map['payment_date'] as String? ?? '',
      receiptNumber: map['receipt_number'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdDate: map['created_date'] as String? ?? '',
      updatedDate: map['updated_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'group_id': groupId,
      'group_name': groupName,
      'amount': amount,
      'for_month': forMonth,
      'method': method,
      'payment_date': paymentDate,
      'receipt_number': receiptNumber,
      'notes': notes,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? groupId,
    String? groupName,
    double? amount,
    String? forMonth,
    String? method,
    String? paymentDate,
    String? receiptNumber,
    String? notes,
    String? createdDate,
    String? updatedDate,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      amount: amount ?? this.amount,
      forMonth: forMonth ?? this.forMonth,
      method: method ?? this.method,
      paymentDate: paymentDate ?? this.paymentDate,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}

/// طرق الدفع
enum PaymentMethod {
  cash('cash', 'نقدي'),
  bankTransfer('bankTransfer', 'تحويل بنكي'),
  vodafoneCash('vodafoneCash', 'فودافون كاش'),
  other('other', 'أخرى');

  final String value;
  final String label;
  const PaymentMethod(this.value, this.label);

  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case PaymentMethod.cash:
        return l10n.method_cash;
      case PaymentMethod.bankTransfer:
        return l10n.method_bankTransfer;
      case PaymentMethod.vodafoneCash:
        return l10n.method_vodafoneCash;
      case PaymentMethod.other:
        return l10n.method_other;
    }
  }

  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}
