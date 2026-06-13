import '../models/device_peer.dart';
import '../repositories/discovery_repository.dart';

class WatchPeersUseCase {
  const WatchPeersUseCase(this.repository);
  final DiscoveryRepository repository;
  Stream<List<DevicePeer>> call() => repository.watchPeers();
}

class RefreshPeersUseCase {
  const RefreshPeersUseCase(this.repository);
  final DiscoveryRepository repository;
  Future<List<DevicePeer>> call() => repository.refresh();
}

class ConnectToPeerUseCase {
  const ConnectToPeerUseCase(this.repository);
  final DiscoveryRepository repository;
  Future<void> call(DevicePeer peer) => repository.connect(peer);
}

class DisconnectPeerUseCase {
  const DisconnectPeerUseCase(this.repository);
  final DiscoveryRepository repository;
  Future<void> call() => repository.disconnect();
}
