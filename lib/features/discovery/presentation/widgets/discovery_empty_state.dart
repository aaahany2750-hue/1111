import 'package:flutter/material.dart';

class DiscoveryEmptyState extends StatelessWidget {
  const DiscoveryEmptyState({required this.message, required this.onRefresh, super.key});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.wifi_find, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRefresh, icon: const Icon(Icons.refresh), label: const Text('Scan again')),
          ],
        ),
      ),
    );
  }
}
