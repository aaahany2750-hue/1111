import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const String routePath = '/history';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.history)),
      body: const Center(
        child: Text('Searchable transfer history is persisted with Drift schema in core/database.'),
      ),
    );
  }
}
