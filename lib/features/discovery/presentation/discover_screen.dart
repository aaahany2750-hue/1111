import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/device_peer.dart';
import 'discovery_state.dart';
import 'widgets/device_peer_card.dart';
import 'widgets/discovery_empty_state.dart';
import 'widgets/discovery_error_view.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  static const String routePath = '/discover';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final DiscoveryState state = ref.watch(discoveryViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.nearby),
        actions: <Widget>[
          IconButton(
            onPressed: state.loading ? null : () => ref.read(discoveryViewModelProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: l.refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(discoveryViewModelProvider.notifier).refresh(),
        child: _DiscoveryBody(state: state),
      ),
    );
  }
}

class _DiscoveryBody extends ConsumerWidget {
  const _DiscoveryBody({required this.state});

  final DiscoveryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    if (state.loading && state.peers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.failure != null && state.peers.isEmpty) {
      return DiscoveryErrorView(
        failure: state.failure!,
        onRetry: () => ref.read(discoveryViewModelProvider.notifier).refresh(),
      );
    }
    if (state.peers.isEmpty) {
      return DiscoveryEmptyState(
        message: l.empty,
        onRefresh: () => ref.read(discoveryViewModelProvider.notifier).refresh(),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: state.peers.length,
      itemBuilder: (BuildContext context, int index) {
        final DevicePeer peer = state.peers[index];
        return DevicePeerCard(
          peer: peer,
          connecting: state.connectingAddress == peer.address,
          onConnect: () => ref.read(discoveryViewModelProvider.notifier).connect(peer),
        );
      },
    );
  }
}
