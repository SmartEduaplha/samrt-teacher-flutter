import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/student_auth_provider.dart';

part 'login_view_model.freezed.dart';

// ── Strategy interface ────────────────────────────────────────────────────────

abstract interface class LoginStrategy {
  Future<void> execute(Ref ref);
}

// ── Strategy implementations ──────────────────────────────────────────────────

class TeacherEmailLogin implements LoginStrategy {
  final String email;
  final String password;
  const TeacherEmailLogin(this.email, this.password);

  @override
  Future<void> execute(Ref ref) async {
    await ref.read(authServiceProvider).login(email, password);
    ref.invalidate(currentUserProvider);
    ref.invalidate(isAuthenticatedProvider);
  }
}

class GoogleLogin implements LoginStrategy {
  const GoogleLogin();

  @override
  Future<void> execute(Ref ref) async {
    await ref.read(authServiceProvider).signInWithGoogle();
    ref.invalidate(currentUserProvider);
    ref.invalidate(isAuthenticatedProvider);
  }
}

class StudentLogin implements LoginStrategy {
  final String portalCode;
  const StudentLogin(this.portalCode);

  @override
  Future<void> execute(Ref ref) async {
    final student = await ref.read(authServiceProvider).loginStudent(portalCode);
    await ref.read(currentStudentProvider.notifier).login(student);
  }
}

// ── ViewModel interface ───────────────────────────────────────────────────────

abstract interface class ILoginViewModel {
  bool get isLoading;
  Future<void> login(LoginStrategy strategy);
}

// ── State ─────────────────────────────────────────────────────────────────────

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(false) bool isSuccess,
  }) = _LoginState;
}

// ── ViewModel implementation ──────────────────────────────────────────────────

class LoginViewModel extends StateNotifier<LoginState> implements ILoginViewModel {
  final Ref _ref;

  LoginViewModel(this._ref) : super(const LoginState());

  @override
  bool get isLoading => state.isLoading;

  @override
  Future<void> login(LoginStrategy strategy) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await strategy.execute(_ref);
      if (mounted) state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }
}

final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(ref),
);
