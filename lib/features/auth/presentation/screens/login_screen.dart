import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../viewmodels/login_view_model.dart';
import '../widgets/login_view.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loginViewModelProvider.select((s) => s.isLoading));
    final vm = ref.read(loginViewModelProvider.notifier);

    ref.listen(
      loginViewModelProvider.select((s) => s.errorMessage),
      (_, msg) {
        if (msg == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );

    ref.listen(
      loginViewModelProvider.select((s) => s.isSuccess),
      (_, success) {
        if (!success) return;
        Navigator.of(context).pushReplacementNamed('/home');
      },
    );

    return LoginView(
      isLoading: isLoading,
      onTeacherLogin: (email, password) =>
          vm.login(TeacherEmailLogin(email, password)),
      onGoogleLogin: () => vm.login(const GoogleLogin()),
      onStudentLogin: (code) => vm.login(StudentLogin(code)),
    );
  }
}
