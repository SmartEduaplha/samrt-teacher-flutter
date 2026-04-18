import 'package:flutter/material.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../groups/presentation/screens/groups_screen.dart';
import '../../../students/presentation/screens/students_screen.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import 'more_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const GroupsScreen(),
    const StudentsScreen(),
    const AttendanceScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: context.l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups_rounded),
            label: context.l10n.navGroups,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: context.l10n.navStudents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fact_check_outlined),
            selectedIcon: const Icon(Icons.fact_check_rounded),
            label: context.l10n.navAttendance,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_rounded),
            label: context.l10n.navMore,
          ),
        ],
      ),
    );
  }
}
