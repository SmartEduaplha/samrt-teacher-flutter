import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// الإجراءات السريعة الافتراضية بالترتيب
const List<String> kDefaultQuickActions = [
  'attendance',
  'payment',
  'add_student',
  'portal_code',
];

/// مجهز إعدادات التطبيق (المظهر، اللغة، الأمان، الإجراءات السريعة)
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  final bool isPinEnabled;
  final String? pin;
  /// قائمة IDs الإجراءات السريعة المُفعَّلة بالترتيب
  final List<String> quickActions;
  
  // إعدادات الدرجات
  final double defaultQuizGrade;
  final bool isQuizGradeFixed;
  final double defaultMonthlyExamGrade;
  final bool isMonthlyExamGradeFixed;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'ar',
    this.isPinEnabled = false,
    this.pin,
    List<String>? quickActions,
    this.defaultQuizGrade = 10.0,
    this.isQuizGradeFixed = false,
    this.defaultMonthlyExamGrade = 50.0,
    this.isMonthlyExamGradeFixed = false,
  }) : quickActions = quickActions ?? kDefaultQuickActions;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? isPinEnabled,
    String? pin,
    List<String>? quickActions,
    double? defaultQuizGrade,
    bool? isQuizGradeFixed,
    double? defaultMonthlyExamGrade,
    bool? isMonthlyExamGradeFixed,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      pin: pin ?? this.pin,
      quickActions: quickActions ?? this.quickActions,
      defaultQuizGrade: defaultQuizGrade ?? this.defaultQuizGrade,
      isQuizGradeFixed: isQuizGradeFixed ?? this.isQuizGradeFixed,
      defaultMonthlyExamGrade: defaultMonthlyExamGrade ?? this.defaultMonthlyExamGrade,
      isMonthlyExamGradeFixed: isMonthlyExamGradeFixed ?? this.isMonthlyExamGradeFixed,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  static const _themeKey = 'theme_mode';
  static const _langKey = 'language';
  static const _pinEnabledKey = 'pin_enabled';
  static const _pinKey = 'app_pin';
  static const _quickActionsKey = 'quick_actions';
  
  static const _quizGradeKey = 'quiz_grade';
  static const _quizGradeFixedKey = 'quiz_grade_fixed';
  static const _monthlyGradeKey = 'monthly_grade';
  static const _monthlyGradeFixedKey = 'monthly_grade_fixed';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    final lang = prefs.getString(_langKey) ?? 'ar';
    final pinEnabled = prefs.getBool(_pinEnabledKey) ?? false;
    final pin = prefs.getString(_pinKey);
    final savedActions = prefs.getStringList(_quickActionsKey);
    
    final quizGrade = prefs.getDouble(_quizGradeKey) ?? 10.0;
    final quizFixed = prefs.getBool(_quizGradeFixedKey) ?? false;
    final monthlyGrade = prefs.getDouble(_monthlyGradeKey) ?? 50.0;
    final monthlyFixed = prefs.getBool(_monthlyGradeFixedKey) ?? false;

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      language: lang,
      isPinEnabled: pinEnabled,
      pin: pin,
      quickActions: savedActions ?? kDefaultQuickActions,
      defaultQuizGrade: quizGrade,
      isQuizGradeFixed: quizFixed,
      defaultMonthlyExamGrade: monthlyGrade,
      isMonthlyExamGradeFixed: monthlyFixed,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }

  Future<void> setPin(String? pin) async {
    final prefs = await SharedPreferences.getInstance();
    if (pin == null) {
      state = state.copyWith(isPinEnabled: false, pin: null);
      await prefs.setBool(_pinEnabledKey, false);
      await prefs.remove(_pinKey);
    } else {
      state = state.copyWith(isPinEnabled: true, pin: pin);
      await prefs.setBool(_pinEnabledKey, true);
      await prefs.setString(_pinKey, pin);
    }
  }

  Future<void> setQuickActions(List<String> actions) async {
    state = state.copyWith(quickActions: actions);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_quickActionsKey, actions);
  }

  Future<void> setDefaultGrades({
    double? quizGrade,
    bool? quizFixed,
    double? monthlyGrade,
    bool? monthlyFixed,
  }) async {
    state = state.copyWith(
      defaultQuizGrade: quizGrade,
      isQuizGradeFixed: quizFixed,
      defaultMonthlyExamGrade: monthlyGrade,
      isMonthlyExamGradeFixed: monthlyFixed,
    );
    
    final prefs = await SharedPreferences.getInstance();
    if (quizGrade != null) await prefs.setDouble(_quizGradeKey, quizGrade);
    if (quizFixed != null) await prefs.setBool(_quizGradeFixedKey, quizFixed);
    if (monthlyGrade != null) await prefs.setDouble(_monthlyGradeKey, monthlyGrade);
    if (monthlyFixed != null) await prefs.setBool(_monthlyGradeFixedKey, monthlyFixed);
  }
}
