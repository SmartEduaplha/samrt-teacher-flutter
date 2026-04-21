import 'package:flutter/material.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../screens/register_screen.dart';

class LoginView extends StatefulWidget {
  final bool isLoading;
  final void Function(String email, String password) onTeacherLogin;
  final void Function() onGoogleLogin;
  final void Function(String code) onStudentLogin;

  const LoginView({
    super.key,
    required this.isLoading,
    required this.onTeacherLogin,
    required this.onGoogleLogin,
    required this.onStudentLogin,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _portalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _portalCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_tabController.index == 0) {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showValidationError(context.l10n.errorEmptyFields);
        return;
      }
      widget.onTeacherLogin(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      if (_portalCodeController.text.isEmpty) {
        _showValidationError(context.l10n.errorEmptyStudentCode);
        return;
      }
      widget.onStudentLogin(_portalCodeController.text.trim());
    }
  }

  void _showValidationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.school_rounded, size: 80, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                context.l10n.loginTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 32),

              // ── Tab Bar ───────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: colorScheme.primary,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: colorScheme.onPrimary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: context.l10n.teacherPortal),
                    Tab(text: context.l10n.studentPortal),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Form Content ──────────────────────────────────────────────
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, child) {
                  return _tabController.index == 0
                      ? _buildTeacherForm(colorScheme)
                      : _buildStudentForm(colorScheme);
                },
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: widget.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _tabController.index == 0
                            ? context.l10n.teacherLogin
                            : context.l10n.studentLogin,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherForm(ColorScheme colorScheme) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: context.l10n.email,
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surface,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: context.l10n.password,
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surface,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            child: Text(context.l10n.noAccount),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.l10n.orViaGoogle,
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.outline)),
            ),
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: widget.isLoading ? null : widget.onGoogleLogin,
          icon: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/4/4a/Logo_2013_Google.png',
            height: 18,
            errorBuilder: (context, error, stack) => const Icon(Icons.login),
          ),
          label: Text(context.l10n.googleLogin),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentForm(ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          context.l10n.studentWelcome,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _portalCodeController,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
          decoration: InputDecoration(
            labelText: context.l10n.studentCode,
            hintText: 'S-0000',
            prefixIcon: const Icon(Icons.vpn_key_outlined),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.studentCodeHint,
          style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withAlpha(150)),
        ),
      ],
    );
  }
}
