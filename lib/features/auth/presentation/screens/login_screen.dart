import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/student_auth_provider.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _portalCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _loginTeacher() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError(context.l10n.errorEmptyFields);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      ref.invalidate(currentUserProvider);
      ref.invalidate(isAuthenticatedProvider);

      if (!mounted) return;
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInWithGoogle();
      
      ref.invalidate(currentUserProvider);
      ref.invalidate(isAuthenticatedProvider);

      if (!mounted) return;
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loginStudent() async {
    if (_portalCodeController.text.isEmpty) {
      _showError(context.l10n.errorEmptyStudentCode);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final student = await auth.loginStudent(_portalCodeController.text.trim());
      
      await ref.read(currentStudentProvider.notifier).login(student);

      if (!mounted) return;
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
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
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _portalCodeController.dispose();
    super.dispose();
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
                onPressed: _isLoading ? null : () {
                  if (_tabController.index == 0) {
                    _loginTeacher();
                  } else {
                    _loginStudent();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _tabController.index == 0 ? context.l10n.teacherLogin : context.l10n.studentLogin,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: Text(context.l10n.noAccount),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.l10n.orViaGoogle, style: TextStyle(fontSize: 12, color: colorScheme.outline)),
            ),
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _loginWithGoogle,
          icon: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/4/4a/Logo_2013_Google.png', 
            height: 18,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
          ),
          label: Text(context.l10n.googleLogin),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
          decoration: InputDecoration(
            labelText: context.l10n.studentCode,
            hintText: 'S-0000',
            prefixIcon: const Icon(Icons.vpn_key_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.studentCodeHint,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant.withAlpha(150)),
        ),
      ],
    );
    }
}

