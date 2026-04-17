import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../students/data/models/student_model.dart';
import 'add_payment_screen.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class OutstandingPaymentsScreen extends ConsumerStatefulWidget {
  const OutstandingPaymentsScreen({super.key});

  @override
  ConsumerState<OutstandingPaymentsScreen> createState() =>
      _OutstandingPaymentsScreenState();
}

class _OutstandingPaymentsScreenState
    extends ConsumerState<OutstandingPaymentsScreen> {
  String _groupFilter = 'all';
  late String _thisMonth;

  @override
  void initState() {
    super.initState();
    _thisMonth = DateFormat('yyyy-MM').format(DateTime.now());
  }

  Future<void> _sendWhatsApp(StudentModel student, double balance) async {
    final phone = student.parentPhoneNumber.isNotEmpty
        ? student.parentPhoneNumber
        : student.phoneNumber;

    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.noPhoneNumberRegistered)),
        );
      }
      return;
    }

    final message = context.l10n.outstandingPaymentWhatsappTemplate(
      student.fullName,
      balance.toStringAsFixed(0),
      context.l10n.currency_egp,
      _thisMonth.replaceFirst('-', '/'),
    );

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final studentsAsync = ref.watch(studentsProvider);
    final groupsAsync = ref.watch(groupsProvider);
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.outstandingPaymentsTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: studentsAsync.when(
        data: (allStudents) => groupsAsync.when(
          data: (allGroups) => paymentsAsync.when(
            data: (allPayments) {
              final activeGroups = allGroups.where((g) => g.isActive).toList();
              final thisMonthPayments =
                  allPayments.where((p) => p.forMonth == _thisMonth).toList();

              // Calculate outstanding logic
              final List<_OutstandingEntry> outstanding = [];

              for (final student in allStudents) {
                if (!student.isActive || student.isFreeStudent) continue;

                final group =
                    activeGroups.where((g) => g.id == student.groupId).firstOrNull;
                if (group == null) continue;

                // Apply group filter
                if (_groupFilter != 'all' && student.groupId != _groupFilter) {
                  continue;
                }

                // Logic from React: calculate mandatory amount
                final double effective = student.studentMonthlyDiscount > 0
                    ? group.defaultMonthlyPrice - student.studentMonthlyDiscount
                    : group.defaultMonthlyPrice - (group.groupMonthlyDiscount);

                // Calculate already paid
                final double paid = thisMonthPayments
                    .where((p) => p.studentId == student.id)
                    .fold(0.0, (sum, p) => sum + p.amount);

                final double balance = effective - paid;

                if (balance > 0) {
                  outstanding.add(_OutstandingEntry(
                    student: student,
                    group: group,
                    effective: effective,
                    paid: paid,
                    balance: balance,
                  ));
                }
              }

              outstanding.sort((a, b) => b.balance.compareTo(a.balance));

              final totalOutstanding =
                  outstanding.fold(0.0, (sum, e) => sum + e.balance);

              return Column(
                children: [
                  // ── Summary Cards ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _StatCard(
                          title: context.l10n.outstandingStudentsCount,
                          value: outstanding.length.toString(),
                          color: Colors.red,
                          icon: Icons.people_outline_rounded,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          title: context.l10n.totalOutstandingAmount,
                          value:
                              '${totalOutstanding.toStringAsFixed(0)} ${context.l10n.currency_egp}',
                          color: Colors.amber.shade700,
                          icon: Icons.credit_card_rounded,
                        ),
                      ],
                    ),
                  ),

                  // ── Filter ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      initialValue: _groupFilter,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.filterByGroup,
                        prefixIcon: const Icon(Icons.groups_rounded),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 'all', child: Text(context.l10n.allGroups)),
                        ...activeGroups.map((g) => DropdownMenuItem(
                            value: g.id, child: Text(g.name))),
                      ],
                      onChanged: (val) =>
                          setState(() => _groupFilter = val ?? 'all'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── List ───────────────────────────────────────────────
                  Expanded(
                    child: outstanding.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    size: 64, color: Colors.green.withAlpha(50)),
                                const SizedBox(height: 16),
                                Text(context.l10n.noOutstandingPaymentsSuccess,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green)),
                                Text(context.l10n.allStudentsPaidMessage,
                                    style: TextStyle(
                                        color: colorScheme.onSurface
                                            .withAlpha(150))),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                            itemCount: outstanding.length,
                            itemBuilder: (context, index) {
                              final entry = outstanding[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                      color: colorScheme.outline.withAlpha(40)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                Colors.red.withAlpha(20),
                                            child: Text(
                                                entry.student.fullName[0],
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(entry.student.fullName,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                Text(
                                                  context.l10n
                                                      .outstandingEntrySubtitle(
                                                    entry.group.name,
                                                    entry.effective
                                                        .toStringAsFixed(0),
                                                    entry.paid.toStringAsFixed(0),
                                                  ),
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: colorScheme
                                                          .onSurface
                                                          .withAlpha(150)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withAlpha(25),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${entry.balance.toStringAsFixed(0)} ${context.l10n.currency_egp}',
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Divider(height: 1),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _sendWhatsApp(
                                                  entry.student, entry.balance),
                                              icon: const Icon(
                                                  Icons.message_rounded,
                                                  size: 18),
                                              label: Text(context.l10n.remind),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.green,
                                                side: BorderSide(
                                                    color: Colors.green
                                                        .withAlpha(100)),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      AddPaymentScreen(
                                                          preStudentId:
                                                              entry.student.id),
                                                ),
                                              ),
                                              icon: const Icon(
                                                  Icons.payments_rounded,
                                                  size: 18),
                                              label: Text(context.l10n.receive),
                                              style: FilledButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
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

class _OutstandingEntry {
  final StudentModel student;
  final GroupModel group;
  final double effective;
  final double paid;
  final double balance;

  _OutstandingEntry({
    required this.student,
    required this.group,
    required this.effective,
    required this.paid,
    required this.balance,
  });
}
