import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مجهز إعدادات التطبيق (المظهر، اللغة، الأمان)
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  final bool isPinEnabled;
  final String? pin;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'ar',
    this.isPinEnabled = false,
    this.pin,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? isPinEnabled,
    String? pin,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      pin: pin ?? this.pin,
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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    final lang = prefs.getString(_langKey) ?? 'ar';
    final pinEnabled = prefs.getBool(_pinEnabledKey) ?? false;
    final pin = prefs.getString(_pinKey);

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      language: lang,
      isPinEnabled: pinEnabled,
      pin: pin,
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
}
