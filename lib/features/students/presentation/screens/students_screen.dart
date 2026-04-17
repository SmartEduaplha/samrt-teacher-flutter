import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/providers/db_providers.dart';
import 'student_form_screen.dart';
import 'student_profile_screen.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  String _searchQuery = '';
  String _groupFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(activeStudentsProvider);
    final groupsAsync = ref.watch(activeGroupsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceTint.withValues(alpha: 0.03),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              
              // ── Header ───────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people_alt_rounded,
                              size: 26, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.navStudents,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      studentsAsync.when(
                        data: (students) => Text(
                          context.l10n.studentsRegisteredCount(students.length),
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        loading: () => const Text('...', style: TextStyle(fontSize: 12)),
                        error: (_, _) => const Text('', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Export Excel
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.exportStudentListSoon)),
                          );
                        },
                        icon: const Icon(Icons.file_download_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentFormScreen()));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    context.l10n.addStudentLabel,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Search & Filter ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: context.l10n.searchByNameOrPhone,
                          hintStyle: const TextStyle(fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: groupsAsync.when(
                        data: (groups) {
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _groupFilter,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                              items: [
                                DropdownMenuItem(value: 'all', child: Text(context.l10n.allGroupsFilter)),
                                ...groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis))),
                              ],
                              onChanged: (v) => setState(() => _groupFilter = v!),
                            ),
                          );
                        },
                        loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                        error: (_, _) => Text(context.l10n.errorOccurred(''), style: const TextStyle(fontSize: 12, color: Colors.red)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Students List ────────────────────────────────────────────
              Expanded(
                child: studentsAsync.when(
                  data: (students) {
                    final filtered = students.where((s) {
                      final groupMatch = _groupFilter == 'all' || s.groupId == _groupFilter;
                      final nameMatch = s.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
                      final phoneMatch = s.phoneNumber.contains(_searchQuery);
                      return groupMatch && (nameMatch || phoneMatch);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_alt_rounded, size: 60, color: Colors.grey.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            Text(context.l10n.noStudentsFound, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                            if (students.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentFormScreen()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: Text(context.l10n.addFirstStudent),
                              )
                            ]
                          ],
                        ),
                      );
                    }

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final student = filtered[index];
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => StudentProfileScreen(studentId: student.id),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      student.fullName.isNotEmpty ? student.fullName.substring(0, 1) : '؟',
                                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                student.fullName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (student.isFreeStudent)
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.teal.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(context.l10n.freeStudent, style: const TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.bold)),
                                              )
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${student.groupName}${student.phoneNumber.isNotEmpty ? ' • ${student.phoneNumber}' : ''}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Actions
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => StudentProfileScreen(studentId: student.id),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          foregroundColor: colorScheme.primary,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(context.l10n.studentProfile, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            const Icon(Icons.chevron_left_rounded, size: 16),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudentFormScreen(studentToEdit: student)));
                                        },
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                        style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(context.l10n.deleteStudentTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              content: Text(context.l10n.deleteStudentConfirm),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                                  child: Text(context.l10n.deletePermanently),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await ref.read(studentDbProvider).delete(student.id);
                                            ref.invalidate(studentsProvider);
                                            ref.invalidate(activeStudentsProvider);
                                          }
                                        },
                                        icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade400),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                        style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(context.l10n.errorOccurred(e.toString()))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
