import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../usecases/settings_use_cases.dart';

class SettingsViewModel extends StateNotifier<AppSettings> {
  SettingsViewModel({required SaveSettingsUseCase saveSettings})
      : _saveSettings = saveSettings,
        super(const AppSettings());

  final SaveSettingsUseCase _saveSettings;

  Future<void> setTheme(ThemeMode mode) async {
    final AppSettings next = state.copyWith(themeMode: mode);
    state = next;
    await _saveSettings(next);
  }

  Future<void> setLocale(Locale locale) async {
    final AppSettings next = state.copyWith(locale: locale);
    state = next;
    await _saveSettings(next);
  }

  Future<void> setOptionalPasswordEnabled({required bool enabled}) async {
    final AppSettings next = state.copyWith(optionalPasswordEnabled: enabled);
    state = next;
    await _saveSettings(next);
  }
}
