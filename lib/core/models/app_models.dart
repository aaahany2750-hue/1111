import 'dart:ui';

import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.optionalPasswordEnabled = false,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final bool optionalPasswordEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? optionalPasswordEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      optionalPasswordEnabled: optionalPasswordEnabled ?? this.optionalPasswordEnabled,
    );
  }
}
