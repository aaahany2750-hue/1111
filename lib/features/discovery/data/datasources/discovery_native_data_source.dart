import '../../../../core/services/native_bridge.dart';

abstract interface class DiscoveryNativeDataSource {
  Stream<List<Map<String, dynamic>>> watchNativePeers();
  Future<List<Map<String, dynamic>>> discoverPeers();
  Future<void> stopDiscovery();
  Future<void> connect(String address);
  Future<void> disconnect();
}

class MethodChannelDiscoveryDataSource implements DiscoveryNativeDataSource {
  MethodChannelDiscoveryDataSource(this.bridge);

  final NativeBridge bridge;

  @override
  Stream<List<Map<String, dynamic>>> watchNativePeers() {
    return bridge.events.where((Map<String, dynamic> event) => event['type'] == 'peers').map((Map<String, dynamic> event) {
      final List<dynamic> peers = event['peers'] as List<dynamic>? ?? <dynamic>[];
      return peers.map((dynamic peer) => Map<String, dynamic>.from(peer as Map<dynamic, dynamic>)).toList(growable: false);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> discoverPeers() => bridge.discoverPeers();

  @override
  Future<void> stopDiscovery() => bridge.stopDiscovery();

  @override
  Future<void> connect(String address) => bridge.connect(address);

  @override
  Future<void> disconnect() => bridge.disconnect();
}
