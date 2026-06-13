import '../models/transfer_models.dart';
import '../repositories/transfer_repository.dart';

class WatchTransferMetricsUseCase {
  const WatchTransferMetricsUseCase(this.repository);
  final TransferRepository repository;
  Stream<TransferMetrics> call() => repository.watchMetrics();
}

class StartTransferServerUseCase {
  const StartTransferServerUseCase(this.repository);
  final TransferRepository repository;
  Future<void> call({int port = 8988}) => repository.startServer(port: port);
}

class StopTransferServerUseCase {
  const StopTransferServerUseCase(this.repository);
  final TransferRepository repository;
  Future<void> call() => repository.stopServer();
}

class SendFileUseCase {
  const SendFileUseCase(this.repository);
  final TransferRepository repository;
  Future<void> call(String uri, String host, int port, {String? sha256}) {
    return repository.queueAndSend(uri, host, port, sha256: sha256);
  }
}

class CancelTransfersUseCase {
  const CancelTransfersUseCase(this.repository);
  final TransferRepository repository;
  Future<void> call() => repository.cancelTransfers();
}

class VerifyFileHashUseCase {
  const VerifyFileHashUseCase(this.repository);
  final TransferRepository repository;
  Future<String> call(String uri) => repository.verifyHash(uri);
}
