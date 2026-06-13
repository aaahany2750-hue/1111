import '../../../core/models/device_peer.dart';
import '../../../core/repositories/discovery_repository.dart';
import 'datasources/discovery_native_data_source.dart';
import 'mappers/device_peer_mapper.dart';

class NativeDiscoveryRepository implements DiscoveryRepository {
  NativeDiscoveryRepository({
    required DiscoveryNativeDataSource dataSource,
    DevicePeerMapper mapper = const DevicePeerMapper(),
  })  : _dataSource = dataSource,
        _mapper = mapper;

  final DiscoveryNativeDataSource _dataSource;
  final DevicePeerMapper _mapper;

  @override
  Stream<List<DevicePeer>> watchPeers() {
    return _dataSource.watchNativePeers().map((List<Map<String, dynamic>> peers) {
      return peers.map(_mapper.fromNativeMap).toList(growable: false);
    });
  }

  @override
  Future<List<DevicePeer>> refresh() async {
    final List<Map<String, dynamic>> peers = await _dataSource.discoverPeers();
    return peers.map(_mapper.fromNativeMap).toList(growable: false);
  }

  @override
  Future<void> stopDiscovery() => _dataSource.stopDiscovery();

  @override
  Future<void> connect(DevicePeer peer) => _dataSource.connect(peer.address);

  @override
  Future<void> disconnect() => _dataSource.disconnect();
}
