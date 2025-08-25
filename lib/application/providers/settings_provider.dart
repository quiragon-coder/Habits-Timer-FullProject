import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final bool hapticsEnabled;

  const AppSettings({
    required this.themeMode,
    required this.hapticsEnabled,
  });

  AppSettings copyWith({ThemeMode? themeMode, bool? hapticsEnabled}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      );
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController() : super(const AppSettings(themeMode: ThemeMode.system, hapticsEnabled: true)) {
    _load();
  }

  static const _kThemeKey = 'themeMode';
  static const _kHapticsKey = 'hapticsEnabled';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_kThemeKey);
    final haptics = prefs.getBool(_kHapticsKey);
    state = state.copyWith(
      themeMode: ThemeMode.values.asMap().containsKey(themeIndex ?? -1) ? ThemeMode.values[themeIndex!] : state.themeMode,
      hapticsEnabled: haptics ?? state.hapticsEnabled,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeKey, mode.index);
  }

  Future<void> setHaptics(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHapticsKey, enabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController();
});
