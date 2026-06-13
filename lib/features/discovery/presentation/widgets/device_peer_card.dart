import 'package:flutter/material.dart';

import '../../../../core/models/device_peer.dart';

class DevicePeerCard extends StatelessWidget {
  const DevicePeerCard({
    required this.peer,
    required this.connecting,
    required this.onConnect,
    super.key,
  });

  final DevicePeer peer;
  final bool connecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(peer.isGroupOwner ? Icons.router : Icons.android),
        ),
        title: Text(peer.name),
        subtitle: Text('${peer.address} · ${peer.connectionStatus.name}'),
        trailing: connecting
            ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : FilledButton(onPressed: onConnect, child: const Text('Connect')),
      ),
    );
  }
}
