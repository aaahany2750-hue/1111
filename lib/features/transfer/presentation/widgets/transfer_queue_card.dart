import 'package:flutter/material.dart';

import '../../domain/transfer_queue_item.dart';

class TransferQueueCard extends StatelessWidget {
  const TransferQueueCard({required this.item, super.key});

  final TransferQueueItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.insert_drive_file),
                const SizedBox(width: 12),
                Expanded(child: Text(item.file.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(item.status.name),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: item.progress.clamp(0.0, 1.0).toDouble()),
            const SizedBox(height: 8),
            Text('${item.transferredBytes} / ${item.file.sizeBytes} bytes · ${item.speedBytesPerSecond} B/s'),
            if (item.estimatedRemaining != null) Text('Remaining: ${item.estimatedRemaining!.inSeconds}s'),
            if (item.errorMessage != null) Text(item.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
    );
  }
}
