import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_peer.dart';
import '../usecases/discovery_use_cases.dart';

class DiscoveryState {
  const DiscoveryState({
    this.peers = const <DevicePeer>[],
    this.loading = false,
    this.errorMessage,
  });

  final List<DevicePeer> peers;
  final bool loading;
  final String? errorMessage;

  DiscoveryState copyWith({
    List<DevicePeer>? peers,
    bool? loading,
    String? errorMessage,
  }) {
    return DiscoveryState(
      peers: peers ?? this.peers,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}

class DiscoveryViewModel extends StateNotifier<DiscoveryState> {
  DiscoveryViewModel({
    required RefreshPeersUseCase refreshPeers,
    required ConnectToPeerUseCase connectToPeer,
    required DisconnectPeerUseCase disconnectPeer,
  })  : _refreshPeers = refreshPeers,
        _connectToPeer = connectToPeer,
        _disconnectPeer = disconnectPeer,
        super(const DiscoveryState());

  final RefreshPeersUseCase _refreshPeers;
  final ConnectToPeerUseCase _connectToPeer;
  final DisconnectPeerUseCase _disconnectPeer;

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      final List<DevicePeer> peers = await _refreshPeers();
      state = state.copyWith(peers: peers, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: error.toString());
    }
  }

  Future<void> connect(DevicePeer peer) => _connectToPeer(peer);

  Future<void> disconnect() => _disconnectPeer();
}
