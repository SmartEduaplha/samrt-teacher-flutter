import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:uuid/uuid.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../students/data/models/student_model.dart';
import 'qr_scan_history_screen.dart';

/// وضع المسح — حضور أو دفع
enum ScanMode { attendance, payment }

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  ScanMode _mode = ScanMode.attendance;
  bool _isProcessing = false;
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.qrScanner),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: context.l10n.scanHistory,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrScanHistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Mode Toggle ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<ScanMode>(
              segments: [
                ButtonSegment(
                  value: ScanMode.attendance,
                  label: Text(context.l10n.attendanceMode),
                  icon: const Icon(Icons.fact_check_rounded),
                ),
                ButtonSegment(
                  value: ScanMode.payment,
                  label: Text(context.l10n.paymentMode),
                  icon: const Icon(Icons.payments_rounded),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (set) {
                setState(() => _mode = set.first);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: _mode == ScanMode.attendance
                    ? Colors.teal.withAlpha(40)
                    : Colors.green.withAlpha(40),
                selectedForegroundColor: _mode == ScanMode.attendance
                    ? Colors.teal
                    : Colors.green[700],
              ),
            ),
          ),

          // ── Status Banner ────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _mode == ScanMode.attendance
                  ? Colors.teal.withAlpha(20)
                  : Colors.green.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _mode == ScanMode.attendance
                    ? Colors.teal.withAlpha(60)
                    : Colors.green.withAlpha(60),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _mode == ScanMode.attendance
                      ? Icons.fact_check_rounded
                      : Icons.payments_rounded,
                  color: _mode == ScanMode.attendance
                      ? Colors.teal
                      : Colors.green[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _mode == ScanMode.attendance
                        ? context.l10n.scanStudentQrHint
                        : context.l10n.scanStudentQrHint, // Can use separate if needed
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Scanner Area ─────────────────────────────────────────────
          Expanded(
            child: kIsWeb ? _buildWebFallback(colorScheme) : _buildScanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFallback(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner_rounded,
                    size: 80, color: colorScheme.primary.withAlpha(120)),
                const SizedBox(height: 16),
                Text(
                  'ماسح QR غير متاح على الويب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يرجى استخدام التطبيق على الهاتف لتفعيل خاصية مسح أكواد QR عبر الكاميرا.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
          ),
          // ── Overlay Frame ──
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _mode == ScanMode.attendance
                      ? Colors.teal
                      : Colors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // ── Processing indicator ──
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final scannedId = barcode.rawValue!;
    setState(() => _isProcessing = true);

    try {
      // البحث عن الطالب
      final student = await ref.read(studentDbProvider).get(scannedId);
      if (student == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم العثور على الطالب. كود غير صالح.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      if (_mode == ScanMode.attendance) {
        await _handleAttendanceScan(student);
      } else {
        await _handlePaymentScan(student);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // تأخير صغير لمنع المسح المتكرر
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleAttendanceScan(StudentModel student) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('HH:mm:ss').format(now);

    // إنشاء سجل حضور
    await ref.read(attendanceDbProvider).create({
      'student_id': student.id,
      'student_name': student.fullName,
      'group_id': student.groupId,
      'group_name': student.groupName,
      'date': dateStr,
      'status': 'present',
      'notes': 'تم التسجيل عبر QR',
    });

    // حفظ سجل المسح
    await _saveQrScan(student, 'attendance', null, dateStr, timeStr);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم تسجيل حضور: ${student.fullName}'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  Future<void> _handlePaymentScan(StudentModel student) async {
    if (!mounted) return;

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PaymentBottomSheet(studentName: student.fullName),
    );

    if (result == null || result <= 0) return;

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('HH:mm:ss').format(now);
    final monthStr = DateFormat('yyyy-MM').format(now);

    // إنشاء سجل دفع
    await ref.read(paymentDbProvider).create({
      'student_id': student.id,
      'student_name': student.fullName,
      'group_id': student.groupId,
      'group_name': student.groupName,
      'amount': result,
      'for_month': monthStr,
      'method': 'cash',
      'payment_date': dateStr,
      'receipt_number': 'QR-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      'notes': 'تم التسجيل عبر QR',
    });

    // حفظ سجل المسح
    await _saveQrScan(student, 'payment', result, dateStr, timeStr);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم تسجيل دفعة ${result.toStringAsFixed(0)} ج.م من: ${student.fullName}'),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  }

  Future<void> _saveQrScan(
    StudentModel student,
    String actionType,
    double? amount,
    String date,
    String time,
  ) async {
    await ref.read(qrScanDbProvider).create({
      'student_id': student.id,
      'student_name': student.fullName,
      'action_type': actionType,
      'amount': amount,
      'group_id': student.groupId,
      'group_name': student.groupName,
      'date': date,
      'time': time,
    });
  }
}

// ── Payment Amount Bottom Sheet ───────────────────────────────────────────────

class _PaymentBottomSheet extends StatefulWidget {
  final String studentName;
  const _PaymentBottomSheet({required this.studentName});

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments_rounded, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تسجيل دفعة مالية',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.studentName,
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'المبلغ (ج.م)',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'يرجى إدخال المبلغ';
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) return 'مبلغ غير صالح';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit
            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(
                    context,
                    double.parse(_amountController.text),
                  );
                }
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('تسجيل الدفعة'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
