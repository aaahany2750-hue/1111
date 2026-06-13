import '../../../../core/services/native_bridge.dart';

abstract interface class TransferNativeDataSource {
  Stream<Map<String, dynamic>> watchTransferEvents();
  Future<void> startServer({int port = 8988});
  Future<void> stopServer();
  Future<void> sendFile(String uri, String host, int port, {String? sha256});
  Future<void> cancelTransfers();
  Future<String> sha256(String uri);
}

class MethodChannelTransferDataSource implements TransferNativeDataSource {
  MethodChannelTransferDataSource(this.bridge);

  final NativeBridge bridge;

  @override
  Stream<Map<String, dynamic>> watchTransferEvents() => bridge.events;

  @override
  Future<void> startServer({int port = 8988}) => bridge.startServer(port: port);

  @override
  Future<void> stopServer() => bridge.stopServer();

  @override
  Future<void> sendFile(String uri, String host, int port, {String? sha256}) {
    return bridge.sendFile(uri, host, port, sha256: sha256);
  }

  @override
  Future<void> cancelTransfers() => bridge.cancelTransfers();

  @override
  Future<String> sha256(String uri) => bridge.sha256(uri);
}
