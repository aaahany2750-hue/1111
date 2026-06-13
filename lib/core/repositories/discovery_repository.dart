import '../models/device_peer.dart';

abstract interface class DiscoveryRepository {
  Stream<List<DevicePeer>> watchPeers();
  Future<List<DevicePeer>> refresh();
  Future<void> stopDiscovery();
  Future<void> connect(DevicePeer peer);
  Future<void> disconnect();
}
