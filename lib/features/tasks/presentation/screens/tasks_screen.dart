import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/providers/db_providers.dart';
import '../../data/models/task_model.dart';
import '../widgets/add_task_bottom_sheet.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _selectedMainTab = 1; // 0 = الجدول الأسبوعي, 1 = قائمة المهام
  int _selectedFilterTab = 0; // 0 = الكل, 1 = قيد التنفيذ, 2 = مكتملة
  DateTime _currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday % 7)); 
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar_SA', null);
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => const AddTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('المنظم', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('المنظم', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('نظّم وقتك وحصصك ومهامك', style: TextStyle(color: colorScheme.onSurface.withAlpha(150), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_month_rounded, size: 36, color: const Color(0xFFF16938)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Segmented Control
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(100),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withAlpha(30)),
              ),
              child: Row(
                children: [
                   _buildMainTab(1, 'قائمة المهام', Icons.check_box_rounded),
                   _buildMainTab(0, 'الجدول الأسبوعي', Icons.calendar_view_week_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedMainTab == 0
                        ? _buildWeeklyScheduleView(tasks)
                        : _buildTasksListView(tasks),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTab(int index, String title, IconData icon) {
    final isSelected = _selectedMainTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMainTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFF16938) : Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFFF16938) : Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: WEEKLY SCHEDULE ---
  Widget _buildWeeklyScheduleView(List<TaskModel> tasks) {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final dateFormatter = DateFormat('dd MMMM', 'ar');
    
    // Formatting example: "19 أبريل - 25 أبريل 2026"
    final weekTitle = '${dateFormatter.format(_currentWeekStart)} — ${dateFormatter.format(weekEnd)} ${weekEnd.year}';

    return Column(
      children: [
        // Week Navigator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7))),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(40))),
                ),
              ),
              Text(
                weekTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(
                onPressed: () => setState(() => _currentWeekStart = _currentWeekStart.add(const Duration(days: 7))),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(40))),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Days Row
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            reverse: true, // Arabic RTL layout
            itemBuilder: (ctx, i) {
              final dayDate = _currentWeekStart.add(Duration(days: i));
              final isSelected = DateFormat('yyyy-MM-dd').format(dayDate) == DateFormat('yyyy-MM-dd').format(_selectedDate);
              final dayName = DateFormat('EEEE', 'ar').format(dayDate);
              final dayNum = DateFormat('dd').format(dayDate);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = dayDate),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF6F3) : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF16938) : Theme.of(context).colorScheme.outline.withAlpha(30),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFF16938).withAlpha(20), blurRadius: 8, offset: const Offset(0, 4))] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFFF16938) : Theme.of(context).colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF16938) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          dayNum,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mock indicator
                      Container(
                        width: 12,
                        height: 2,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF16938).withAlpha(100) : Theme.of(context).colorScheme.outline.withAlpha(30),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(40),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        
        const SizedBox(height: 32),
        // Placeholder for schedule of the selected day
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available_rounded, size: 64, color: Theme.of(context).colorScheme.outline.withAlpha(50)),
              const SizedBox(height: 16),
              const Text('لا توجد حصص مبرمجة اليوم', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: TASKS LIST ---
  Widget _buildTasksListView(List<TaskModel> allTasks) {
    final inProgress = allTasks.where((t) => !t.isCompleted).toList();
    final completed = allTasks.where((t) => t.isCompleted).toList();
    
    // Define "late" as incomplete tasks with date before today
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lateTasks = inProgress.where((t) => t.date.isBefore(DateTime.parse(todayStr))).toList();

    List<TaskModel> displayedTasks = [];
    if (_selectedFilterTab == 0) displayedTasks = allTasks;
    if (_selectedFilterTab == 1) displayedTasks = inProgress;
    if (_selectedFilterTab == 2) displayedTasks = completed;

    // Sort tasks
    displayedTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return b.date.compareTo(a.date);
    });

    return Column(
      children: [
        // Stats Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
                _buildStatBox('مكتملة', completed.length, const Color(0xFF10B981), const Color(0xFFDCFCE7), Icons.check_box_rounded),
              const SizedBox(width: 8),
                _buildStatBox('قيد التنفيذ', inProgress.length, const Color(0xFF3B82F6), const Color(0xFFE0EFFF), Icons.circle),
              const SizedBox(width: 8),
                _buildStatBox('متأخرة', lateTasks.length, const Color(0xFFEF4444), const Color(0xFFFFE4E6), Icons.alarm_rounded),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Add Task Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFFF16938)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFFA855F7).withAlpha(80), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: _showAddTaskSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('إضافة مهمة جديدة ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Filter Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildFilterTab(0, 'الكل'),
              _buildFilterTab(1, 'قيد التنفيذ'),
              _buildFilterTab(2, 'مكتملة'),
            ].reversed.toList(),
          ),
        ),
        const SizedBox(height: 16),

        // List
        Expanded(
          child: displayedTasks.isEmpty
              ? _buildEmptyTasksState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: displayedTasks.length,
                  itemBuilder: (ctx, i) {
                    final t = displayedTasks[i];
                    return _buildTaskCard(t);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String title, int count, Color color, Color bgColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color.withAlpha(200)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String title) {
    final isSelected = _selectedFilterTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Theme.of(context).colorScheme.onSurface.withAlpha(150),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTasksState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_rounded, size: 80, color: Theme.of(context).colorScheme.outline.withAlpha(50)),
        const SizedBox(height: 16),
        Text('لا توجد مهام هنا', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150), fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(taskDbProvider).delete(task.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline.withAlpha(40)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (val) {
              ref.read(taskDbProvider).update(task.id, {'is_completed': val});
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? colorScheme.outline : colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: task.type != null ? Text(task.type!, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 11)) : null,
          trailing: task.time != null ? Text(task.time!, style: TextStyle(color: colorScheme.onSurface.withAlpha(150), fontSize: 12)) : null,
        ),
      ),
    );
  }
}
