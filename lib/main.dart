import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/db_providers.dart';
import 'core/providers/student_auth_provider.dart';
import 'core/providers/settings_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/shared/presentation/screens/main_layout.dart';
import 'features/student_portal/presentation/screens/student_main_layout.dart';
import 'features/shared/presentation/widgets/pin_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('ar');

  runApp(
    const ProviderScope(
      child: TeacherAssistantApp(),
    ),
  );
}

class TeacherAssistantApp extends ConsumerWidget {
  const TeacherAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(userTypeProvider);
    final authState = ref.watch(authStateProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Teacher Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,

      // ── Localization ────────────────────────────────────────────────
      locale: Locale(settings.language),
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // English
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        return child!;
      },
      home: PinGate(
        child: authState.when(
          data: (user) {
            // التحقق من نوع المستخدم الحالي
            switch (userType) {
              case UserType.teacher:
                return const MainLayout();
              case UserType.student:
                return const StudentMainLayout();
              case UserType.none:
                return const LoginScreen();
            }
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Scaffold(
            body: Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}
