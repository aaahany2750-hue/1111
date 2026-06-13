import 'package:flutter_test/flutter_test.dart';
import 'package:flashtransfer/core/models/device_peer.dart';
import 'package:flashtransfer/core/repositories/discovery_repository.dart';
import 'package:flashtransfer/core/usecases/discovery_use_cases.dart';
import 'package:flashtransfer/features/discovery/presentation/discovery_view_model.dart';

class FakeDiscoveryRepository implements DiscoveryRepository {
  final List<DevicePeer> peers = <DevicePeer>[const DevicePeer(name: 'Pixel', address: 'aa:bb', status: 3)];

  @override
  Stream<List<DevicePeer>> watchPeers() => const Stream<List<DevicePeer>>.empty();

  @override
  Future<List<DevicePeer>> refresh() async => peers;

  @override
  Future<void> stopDiscovery() async {}

  @override
  Future<void> connect(DevicePeer peer) async {}

  @override
  Future<void> disconnect() async {}
}

void main() {
  test('refresh loads peers into state', () async {
    final repository = FakeDiscoveryRepository();
    final viewModel = DiscoveryViewModel(
      watchPeers: WatchPeersUseCase(repository),
      refreshPeers: RefreshPeersUseCase(repository),
      connectToPeer: ConnectToPeerUseCase(repository),
      disconnectPeer: DisconnectPeerUseCase(repository),
    );

    await viewModel.refresh();

    expect(viewModel.state.peers, hasLength(1));
    expect(viewModel.state.loading, isFalse);
    viewModel.dispose();
  });
}
