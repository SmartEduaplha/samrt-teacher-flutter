import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';
import 'student_qr_screen.dart';
import 'student_exams_screen.dart';
import 'student_attendance_screen.dart';
import 'student_store_screen.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class StudentMainLayout extends StatefulWidget {
  const StudentMainLayout({super.key});

  @override
  State<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends State<StudentMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StudentDashboardScreen(),
    StudentQrScreen(),
    StudentExamsScreen(),
    StudentAttendanceScreen(),
    StudentStoreScreen(),
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
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.qr_code_rounded),
            selectedIcon: const Icon(Icons.qr_code_2_rounded),
            label: context.l10n.studentQrCode,
          ),
          NavigationDestination(
            icon: const Icon(Icons.quiz_outlined),
            selectedIcon: const Icon(Icons.quiz_rounded),
            label: context.l10n.exams,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: context.l10n.myAttendance,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: const Icon(Icons.shopping_bag_rounded),
            label: context.l10n.store,
          ),
        ],
      ),
    );
  }
}
