import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- المظهر والشكل ---
          _buildSectionHeader(context.l10n.themeAppearance, Icons.palette_outlined),
          Card(
            child: Column(
              children: [
                _buildRadioTile<ThemeMode>(
                  title: context.l10n.themeLight,
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settingsNotifier.setThemeMode(v!),
                  icon: Icons.light_mode_rounded,
                ),
                _buildRadioTile<ThemeMode>(
                  title: context.l10n.themeDark,
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settingsNotifier.setThemeMode(v!),
                  icon: Icons.dark_mode_rounded,
                ),
                _buildRadioTile<ThemeMode>(
                  title: context.l10n.themeSystem,
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settingsNotifier.setThemeMode(v!),
                  icon: Icons.brightness_auto_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- اللغة ---
          _buildSectionHeader(context.l10n.language, Icons.language_rounded),
          Card(
            child: Column(
              children: [
                _buildRadioTile<String>(
                  title: context.l10n.arabic,
                  value: 'ar',
                  groupValue: settings.language,
                  onChanged: (v) => settingsNotifier.setLanguage(v!),
                  icon: Icons.translate_rounded,
                ),
                _buildRadioTile<String>(
                  title: context.l10n.english,
                  value: 'en',
                  groupValue: settings.language,
                  onChanged: (v) => settingsNotifier.setLanguage(v!),
                  icon: Icons.translate_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- الأمان ---
          _buildSectionHeader(context.l10n.security, Icons.security_rounded),
          Card(
            child: SwitchListTile(
              title: Text(context.l10n.appLock),
              subtitle: Text(context.l10n.appLockSubtitle),
              value: settings.isPinEnabled,
              secondary: const Icon(Icons.pin_rounded),
              onChanged: (enabled) {
                if (enabled) {
                  _showSetPinDialog(context, settingsNotifier);
                } else {
                  settingsNotifier.setPin(null);
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          // --- البيانات ---
          _buildSectionHeader(context.l10n.backupData, Icons.cloud_done_rounded),
          Card(
            child: ListTile(
              title: Text(context.l10n.exportImport),
              subtitle: Text(context.l10n.backupSubtitle),
              leading: const Icon(Icons.backup_rounded),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                // TODO: Navigate to Backup management screen or trigger action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.comingSoon)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return RadioListTile<T>(
      title: Text(title),
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: onChanged,
      secondary: Icon(icon, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showSetPinDialog(BuildContext context, SettingsNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.setPin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ctx.l10n.enterFourDigits),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '0000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.length == 4) {
                notifier.setPin(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: Text(ctx.l10n.save),
          ),
        ],
      ),
    );
  }
}
