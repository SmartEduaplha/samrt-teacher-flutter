import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../payments/data/models/payment_model.dart';
import 'add_payment_screen.dart';
import 'outstanding_payments_screen.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  String _groupFilter = 'all';
  late String _monthFilter;

  @override
  void initState() {
    super.initState();
    _monthFilter = DateFormat('yyyy-MM').format(DateTime.now());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(PaymentModel payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deletePaymentTitle),
        content: Text(context.l10n.deletePaymentConfirmMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.deleteAction)),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(paymentDbProvider).delete(payment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.paymentDeletedMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final paymentsAsync = ref.watch(paymentsProvider);
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.paymentsTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            tooltip: context.l10n.outstandingPaymentsTitle,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const OutstandingPaymentsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filters ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.l10n.searchPaymentHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse('$_monthFilter-01') ??
                                DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            locale: const Locale('ar'),
                          );
                          if (picked != null) {
                            setState(() => _monthFilter =
                                DateFormat('yyyy-MM').format(picked));
                          }
                        },
                        child: InputDecorator(
                          decoration:
                              _filterDecoration(context.l10n.monthLabel, colorScheme),
                          child: Text(_monthFilter,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: groupsAsync.when(
                        data: (groups) => DropdownButtonFormField<String>(
                          initialValue: _groupFilter,
                          isExpanded: true,
                          decoration:
                              _filterDecoration(context.l10n.group, colorScheme),
                          items: [
                            DropdownMenuItem(
                                value: 'all', child: Text(context.l10n.allGroups)),
                            ...groups.map((g) => DropdownMenuItem(
                                value: g.id, child: Text(g.name))),
                          ],
                          onChanged: (val) =>
                              setState(() => _groupFilter = val ?? 'all'),
                        ),
                        loading: () => const SizedBox(height: 10),
                        error: (_, _) => const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: paymentsAsync.when(
              data: (payments) {
                final filtered = payments.where((p) {
                  final groupMatch =
                      _groupFilter == 'all' || p.groupId == _groupFilter;
                  final monthMatch = p.forMonth == _monthFilter;
                  final searchMatch = p.studentName
                          .toLowerCase()
                          .contains(_search.toLowerCase()) ||
                      p.receiptNumber.contains(_search);
                  return groupMatch && monthMatch && searchMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAttribute.center.toMainAxisAlignment(),
                      children: [
                        Icon(Icons.credit_card_off_rounded,
                            size: 64, color: colorScheme.outline.withAlpha(50)),
                        const SizedBox(height: 16),
                        Text(context.l10n.noPaymentsFound,
                            style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(150))),
                      ],
                    ),
                  );
                }

                final total = filtered.fold(0.0, (sum, p) => sum + p.amount);

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      color: colorScheme.primary.withAlpha(15),
                      child: Text(
                        context.l10n.totalPaymentsSummary(
                          total.toStringAsFixed(0),
                          context.l10n.currency_egp,
                          filtered.length,
                        ),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withAlpha(30),
                                child: const Icon(Icons.credit_card_rounded,
                                    color: Colors.green, size: 20),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(p.studentName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  Text(
                                      '${p.amount.toStringAsFixed(0)} ${context.l10n.currency_egp}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.green)),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${p.groupName} · ${PaymentMethod.fromValue(p.method).getLocalizedLabel(context.l10n)}',
                                        style: const TextStyle(fontSize: 11)),
                                    if (p.receiptNumber.isNotEmpty)
                                      Text(
                                          context.l10n
                                              .receiptNumberLabel(p.receiptNumber),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: colorScheme.onSurface
                                                  .withAlpha(150))),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.red, size: 20),
                                onPressed: () => _handleDelete(p),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPaymentScreen())),
        tooltip: context.l10n.addPaymentTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }

  InputDecoration _filterDecoration(String label, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(50))),
    );
  }
}

// Extension to avoid 'MainAttribute' error in older Flutter versions if any center logic is needed
enum MainAttribute { center }
extension on MainAttribute {
  MainAxisAlignment toMainAxisAlignment() => MainAxisAlignment.center;
}
