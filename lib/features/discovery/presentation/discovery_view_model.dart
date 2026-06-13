import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/models/device_peer.dart';
import '../../../core/usecases/discovery_use_cases.dart';
import 'discovery_state.dart';

class DiscoveryViewModel extends StateNotifier<DiscoveryState> {
  DiscoveryViewModel({
    required WatchPeersUseCase watchPeers,
    required RefreshPeersUseCase refreshPeers,
    required ConnectToPeerUseCase connectToPeer,
    required DisconnectPeerUseCase disconnectPeer,
  })  : _watchPeers = watchPeers,
        _refreshPeers = refreshPeers,
        _connectToPeer = connectToPeer,
        _disconnectPeer = disconnectPeer,
        super(const DiscoveryState()) {
    _peerSubscription = _watchPeers().listen(
      (List<DevicePeer> peers) => state = state.copyWith(peers: peers, clearFailure: true),
      onError: (Object error, StackTrace stackTrace) {
        state = state.copyWith(failure: WifiFailure(error.toString()), loading: false);
      },
    );
  }

  final WatchPeersUseCase _watchPeers;
  final RefreshPeersUseCase _refreshPeers;
  final ConnectToPeerUseCase _connectToPeer;
  final DisconnectPeerUseCase _disconnectPeer;
  late final StreamSubscription<List<DevicePeer>> _peerSubscription;

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearFailure: true);
    try {
      final List<DevicePeer> peers = await _refreshPeers();
      state = state.copyWith(peers: peers, loading: false, clearFailure: true);
    } catch (error) {
      state = state.copyWith(loading: false, failure: WifiFailure(error.toString()));
    }
  }

  Future<void> connect(DevicePeer peer) async {
    state = state.copyWith(connectingAddress: peer.address, clearFailure: true);
    try {
      await _connectToPeer(peer);
      state = state.copyWith(clearConnectingAddress: true, clearFailure: true);
    } catch (error) {
      state = state.copyWith(
        clearConnectingAddress: true,
        failure: WifiFailure(error.toString()),
      );
    }
  }

  Future<void> disconnect() async {
    try {
      await _disconnectPeer();
    } catch (error) {
      state = state.copyWith(failure: WifiFailure(error.toString()));
    }
  }

  @override
  void dispose() {
    _peerSubscription.cancel();
    super.dispose();
  }
}
