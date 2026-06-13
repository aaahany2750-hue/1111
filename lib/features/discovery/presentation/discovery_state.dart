import '../../../core/errors/failure.dart';
import '../../../core/models/device_peer.dart';

class DiscoveryState {
  const DiscoveryState({
    this.peers = const <DevicePeer>[],
    this.loading = false,
    this.connectingAddress,
    this.failure,
  });

  final List<DevicePeer> peers;
  final bool loading;
  final String? connectingAddress;
  final Failure? failure;

  bool get hasPeers => peers.isNotEmpty;

  DiscoveryState copyWith({
    List<DevicePeer>? peers,
    bool? loading,
    String? connectingAddress,
    Failure? failure,
    bool clearFailure = false,
    bool clearConnectingAddress = false,
  }) {
    return DiscoveryState(
      peers: peers ?? this.peers,
      loading: loading ?? this.loading,
      connectingAddress: clearConnectingAddress ? null : connectingAddress ?? this.connectingAddress,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
