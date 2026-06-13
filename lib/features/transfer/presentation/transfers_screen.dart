import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/localization/app_localizations.dart';
import 'transfer_state.dart';
import 'widgets/transfer_queue_card.dart';
import 'widgets/transfer_summary_card.dart';

class TransfersScreen extends ConsumerWidget {
  const TransfersScreen({super.key});

  static const String routePath = '/transfers';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TransferState state = ref.watch(transferViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.active),
        actions: <Widget>[
          IconButton(
            onPressed: state.queue.isEmpty ? null : () => ref.read(transferViewModelProvider.notifier).cancelAll(),
            icon: const Icon(Icons.cancel),
            tooltip: 'Cancel transfers',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TransferSummaryCard(state: state),
          const SizedBox(height: 12),
          if (state.errorMessage != null) Card(child: ListTile(leading: const Icon(Icons.error), title: Text(state.errorMessage!))),
          if (state.queue.isEmpty) const Card(child: ListTile(title: Text('No queued transfers'), subtitle: Text('Select files to start a multi-file transfer.'))),
          for (final item in state.queue) TransferQueueCard(item: item),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.serverRunning
            ? () => ref.read(transferViewModelProvider.notifier).stopServer()
            : () => ref.read(transferViewModelProvider.notifier).startServer(),
        icon: Icon(state.serverRunning ? Icons.stop : Icons.play_arrow),
        label: Text(state.serverRunning ? 'Stop server' : 'Start server'),
      ),
    );
  }
}
