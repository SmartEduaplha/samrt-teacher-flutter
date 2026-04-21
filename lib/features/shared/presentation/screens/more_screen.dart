import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/student_auth_provider.dart';

import '../../../../core/extensions/l10n_extensions.dart';
import '../../../auth/presentation/screens/profile_screen.dart';

import '../../../payments/presentation/screens/payments_list_screen.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../groups/presentation/screens/groups_screen.dart';
import '../../../honor_board/presentation/screens/honor_board_screen.dart';
import '../../../quizzes/presentation/screens/quizzes_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../../qr_scanner/presentation/screens/qr_scanner_screen.dart';
import 'settings_screen.dart';
import 'quick_actions_settings_screen.dart';

// Note: Ensure other feature screens are imported as needed. 
// For now, I'll keep the ones I can see in the breadcrumbs or that are clearly defined.

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moreMenu),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Account Section ─────────────────────────────────────────
          _SectionHeader(title: context.l10n.profile, icon: Icons.person_rounded),
          const SizedBox(height: 8),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.person_outline_rounded,
                iconColor: colorScheme.primary,
                title: context.l10n.profile,
                subtitle: context.l10n.profileSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.settings_rounded,
                iconColor: Colors.blueGrey,
                title: context.l10n.appSettings,
                subtitle: context.l10n.appSettingsSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Academic Management Section ──────────────────────────────
          _SectionHeader(title: context.l10n.academicManagement, icon: Icons.school_rounded),
          const SizedBox(height: 8),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.groups_rounded,
                iconColor: Colors.indigo,
                title: context.l10n.navGroups,
                subtitle: context.l10n.groupsAndLevelSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupsScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.event_note_rounded,
                iconColor: Colors.amber[800]!,
                title: 'المنظم',
                subtitle: 'نظم وقتك وحصصك ومهامك',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TasksScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.quiz_rounded,
                iconColor: Colors.purple,
                title: context.l10n.quizzes,
                subtitle: context.l10n.quizzesSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizzesScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Smart Tools Section ────────────────────────────────────────
          _SectionHeader(title: context.l10n.smartTools, icon: Icons.auto_awesome_rounded),
          const SizedBox(height: 8),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.qr_code_scanner_rounded,
                iconColor: Colors.teal,
                title: context.l10n.qrScanner,
                subtitle: context.l10n.scanStudentQrHint,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: context.l10n.customizeQuickActions,
                subtitle: context.l10n.quickActionsHint,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QuickActionsSettingsScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Financial Management Section ─────────────────────────────

          _SectionHeader(title: context.l10n.financialManagement, icon: Icons.account_balance_wallet_rounded),
          const SizedBox(height: 8),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.payments_rounded,
                iconColor: Colors.green,
                title: context.l10n.financials,
                subtitle: context.l10n.financialsSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentsListScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.money_off_rounded,
                iconColor: Colors.redAccent,
                title: context.l10n.expenses,
                subtitle: context.l10n.expensesSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpensesScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Student Excellence Section ───────────────────────────────
          _SectionHeader(title: context.l10n.studentExcellence, icon: Icons.auto_awesome_rounded),
          const SizedBox(height: 8),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.emoji_events_rounded,
                iconColor: Colors.orange,
                title: context.l10n.honorBoard,
                subtitle: context.l10n.honorBoardSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HonorBoardScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Others ───────────────────────────────────────────────────
          _SectionHeader(title: context.l10n.notifications, icon: Icons.notifications_active_rounded),
          const SizedBox(height: 8),
          _MenuCard(
            items: [
              _MenuItem(
                icon: Icons.notifications_none_rounded,
                iconColor: Colors.blue,
                title: context.l10n.notifications,
                subtitle: context.l10n.notificationsSubtitle,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Logout ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: Text(
                context.l10n.logout,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.logout),
        content: Text(ctx.l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              await ref.read(currentStudentProvider.notifier).logout();
              if (context.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(ctx.l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Column(
            children: [
              if (idx > 0)
                Divider(
                  height: 1,
                  indent: 60,
                  color: colorScheme.outline.withAlpha(38),
                ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 22),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withAlpha(128),
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: item.onTap,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
