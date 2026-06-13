import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  static const String routePath = '/games';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.games)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          Card(
            child: ListTile(
              leading: Icon(Icons.sports_esports),
              title: Text('Installed games'),
              subtitle: Text('APK-only and APK + resources transfers use Android-safe app metadata and SAF for restricted resources.'),
            ),
          ),
        ],
      ),
    );
  }
}
