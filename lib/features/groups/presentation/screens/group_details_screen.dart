import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/providers/db_providers.dart';
import '../../data/models/group_model.dart';
import '../../../students/data/models/student_model.dart';
import '../../../payments/data/models/payment_model.dart';

class GroupDetailsData {
  final GroupModel group;
  final List<StudentModel> students;
  final List<PaymentModel> payments;

  GroupDetailsData({
    required this.group,
    required this.students,
    required this.payments,
  });
}

final groupDetailsDataProvider = FutureProvider.family<GroupDetailsData, String>((ref, groupId) async {
  final group = (await ref.watch(groupsProvider.future)).firstWhere((g) => g.id == groupId);
  final allStudents = await ref.watch(studentsProvider.future);
  final students = allStudents.where((s) => s.groupId == groupId && s.isActive).toList();
  
  final allPayments = await ref.watch(paymentsProvider.future);
  final payments = allPayments.where((p) => students.any((s) => s.id == p.studentId)).toList();

  return GroupDetailsData(group: group, students: students, payments: payments);
});

class GroupDetailsScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  String _search = '';

  Map<String, String> get _groupTypeLabels => {
    'center': context.l10n.center,
    'privateGroup': context.l10n.privateGroup,
    'privateLesson': context.l10n.privateLesson,
    'online': context.l10n.online,
  };

  Map<String, String> get _dayLabels => {
    'saturday': context.l10n.saturday,
    'sunday': context.l10n.sunday,
    'monday': context.l10n.monday,
    'tuesday': context.l10n.tuesday,
    'wednesday': context.l10n.wednesday,
    'thursday': context.l10n.thursday,
    'friday': context.l10n.friday,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncData = ref.watch(groupDetailsDataProvider(widget.groupId));
    final thisMonthStr = DateFormat('yyyy-MM').format(DateTime.now());

    return Scaffold(
      backgroundColor: colorScheme.surfaceTint.withValues(alpha: 0.03),
      appBar: AppBar(
        title: Text(context.l10n.groupDetailsTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.blue),
            onPressed: () { /* context.push GroupForm */ },
            tooltip: context.l10n.editGroupTooltip,
          )
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.errorOccurred(e.toString()))),
        data: (data) {
          final db = ref.read(studentDbProvider); // for deleting later

          double getEffectivePrice(StudentModel student) {
            if (student.isFreeStudent) return 0;
            if (student.studentMonthlyDiscount > 0) {
              return data.group.defaultMonthlyPrice - student.studentMonthlyDiscount;
            }
            return data.group.defaultMonthlyPrice - data.group.groupMonthlyDiscount;
          }

          double getMonthlyBalance(String studentId) {
            final student = data.students.firstWhere((s) => s.id == studentId);
            final required = getEffectivePrice(student);
            final paid = data.payments
              .where((p) => p.studentId == studentId && p.forMonth == thisMonthStr)
              .fold(0.0, (sum, p) => sum + p.amount);
            return required - paid;
          }

          final totalRequired = data.students.fold(0.0, (sum, s) => sum + getEffectivePrice(s));
          final totalPaid = data.payments
            .where((p) => p.forMonth == thisMonthStr)
            .fold(0.0, (sum, p) => sum + p.amount);
          final totalOutstanding = data.students
            .where((s) => !s.isFreeStudent)
            .fold(0.0, (sum, s) => sum + (getMonthlyBalance(s.id) > 0 ? getMonthlyBalance(s.id) : 0));
          
          final freeCount = data.students.where((s) => s.isFreeStudent).length;

          final filteredStudents = data.students.where((s) => s.fullName.toLowerCase().contains(_search.toLowerCase())).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.group.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Text(_groupTypeLabels[data.group.type] ?? data.group.type, style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                                    ),
                                    if (data.group.subject.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(data.group.subject, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                    ]
                                  ],
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () { /* Attendance */ },
                                icon: const Icon(Icons.check_box_outlined, size: 16),
                                label: Text(context.l10n.recordAttendance),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Group Info Cards Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.2,
                        children: [
                          _buildMiniCard(context.l10n.totalStudents, '${data.students.length}', Colors.blue),
                          _buildMiniCard(context.l10n.paidThisMonth, '${totalPaid.toStringAsFixed(0)} ${context.l10n.currency}', Colors.green),
                          _buildMiniCard(context.l10n.statMonthlyRequired, '${totalRequired.toStringAsFixed(0)} ${context.l10n.currency}', Colors.amber.shade700),
                          _buildMiniCard(context.l10n.statOutstandingAmt, '${totalOutstanding.toStringAsFixed(0)} ${context.l10n.currency}', Colors.red),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Schedule
                      if (data.group.schedule.isNotEmpty) ...[
                        Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.l10n.weeklySchedule, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8, runSpacing: 8,
                                  children: data.group.schedule.map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
                                    child: Text('${_dayLabels[s.day] ?? s.day} ${s.startTime} - ${s.endTime}', style: const TextStyle(fontSize: 12)),
                                  )).toList(),
                                ),
                                if (data.group.location.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(data.group.location, style: const TextStyle(color: Colors.grey, fontSize: 12))])
                                ]
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),

              // Students Header
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(context.l10n.studentsWithCount(data.students.length), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (freeCount > 0) ...[
                                const SizedBox(width: 8),
                                Text('$freeCount ${context.l10n.freeBadge}', style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                              ]
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () { /* Add student */ },
                            icon: const Icon(Icons.person_add_rounded, size: 16),
                            label: Text(context.l10n.addStudent, style: const TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (data.students.length > 5)
                        TextField(
                          decoration: InputDecoration(
                            hintText: context.l10n.searchStudentsHint,
                            prefixIcon: const Icon(Icons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Students List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: filteredStudents.isEmpty
                  ? SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(_search.isEmpty ? context.l10n.noStudentsInGroup : context.l10n.noResultsFound, style: const TextStyle(color: Colors.grey)))))
                  : SliverList.separated(
                      itemCount: filteredStudents.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final student = filteredStudents[idx];
                        final balance = getMonthlyBalance(student.id);
                        final effectivePrice = getEffectivePrice(student);

                        return Container( // List Item
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                foregroundColor: Colors.blue.shade800,
                                child: Text(student.fullName.isNotEmpty ? student.fullName.substring(0, 1) : '?', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        const SizedBox(width: 6),
                                        if (student.isFreeStudent)
                                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)), child: Text(context.l10n.freeBadge, style: const TextStyle(color: Colors.green, fontSize: 10)))
                                        else if (student.studentMonthlyDiscount > 0)
                                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(4)), child: Text(context.l10n.discountAmount(student.studentMonthlyDiscount.toStringAsFixed(0)), style: const TextStyle(color: Colors.orange, fontSize: 10)))
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      student.isFreeStudent ? context.l10n.freeBadge : '${context.l10n.pricePerMonthLabel(effectivePrice.toStringAsFixed(0))}${student.phoneNumber.isNotEmpty ? ' · ${student.phoneNumber}' : ''}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!student.isFreeStudent) ...[
                                    if (balance > 0)
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)), child: Text(context.l10n.overdueAmtWithLabel(balance.toStringAsFixed(0)), style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)))
                                    else if (balance < 0)
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)), child: Text(context.l10n.creditAmtWithLabel(balance.abs().toStringAsFixed(0)), style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)))
                                    else
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)), child: Text(context.l10n.completeLabel, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      InkWell(onTap: () { /* StudentProfile */ }, child: Padding(padding: const EdgeInsets.all(4), child: Text(context.l10n.studentFile, style: TextStyle(fontSize: 11, color: Colors.blue.shade700)))),
                                      InkWell(onTap: () { /* Edit Student */ }, child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.edit, size: 14, color: Colors.grey))),
                                      InkWell(
                                        onTap: () async {
                                          final bool? confirm = await showDialog(context: context, builder: (_) => AlertDialog(
                                            title: Text(context.l10n.deleteStudentTitle), content: Text(context.l10n.deleteFromGroupConfirm),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
                                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.deleteAction, style: const TextStyle(color: Colors.red))),
                                            ],
                                          ));
                                          if (confirm == true) {
                                            await db.delete(student.id);
                                            ref.invalidate(studentsProvider);
                                          }
                                        },
                                        child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.delete_outline, size: 14, color: Colors.red)),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
              )
            ],
          );
        },
      )
    );
  }

  Widget _buildMiniCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
