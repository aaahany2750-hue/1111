import '../models/transfer_models.dart';

abstract interface class TransferRepository {
  Stream<TransferMetrics> watchMetrics();
  Future<void> startServer({int port = 8988});
  Future<void> stopServer();
  Future<void> queueAndSend(String uri, String host, int port, {String? sha256});
  Future<void> cancelTransfers();
  Future<String> verifyHash(String uri);
}
