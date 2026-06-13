import 'package:flutter/material.dart';

import '../transfer_state.dart';

class TransferSummaryCard extends StatelessWidget {
  const TransferSummaryCard({required this.state, super.key});

  final TransferState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          children: <Widget>[
            _Metric(label: 'Queued', value: '${state.queueSize}'),
            _Metric(label: 'Completed', value: '${state.completedCount}'),
            _Metric(label: 'Failed', value: '${state.failedCount}'),
            _Metric(label: 'Transferred', value: '${state.transferredBytes}/${state.totalBytes} B'),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
