import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/localization/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final AppSettings settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(l.language),
            trailing: SegmentedButton<String>(
              selected: <String>{settings.locale?.languageCode ?? Localizations.localeOf(context).languageCode},
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'en', label: Text('EN')),
                ButtonSegment<String>(value: 'ar', label: Text('AR')),
              ],
              onSelectionChanged: (Set<String> selected) {
                ref.read(settingsControllerProvider.notifier).setLocale(Locale(selected.first));
              },
            ),
          ),
          ListTile(
            title: Text(l.theme),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              items: const <DropdownMenuItem<ThemeMode>>[
                DropdownMenuItem<ThemeMode>(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem<ThemeMode>(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem<ThemeMode>(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  ref.read(settingsControllerProvider.notifier).setTheme(mode);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l.permissions),
            subtitle: const Text('Location, Nearby Wi-Fi Devices, media and SAF guidance'),
          ),
          ListTile(
            title: Text(l.diagnostics),
            subtitle: const Text('Native Wi-Fi Direct and transfer health'),
          ),
        ],
      ),
    );
  }
}
