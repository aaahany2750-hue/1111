import 'package:flutter_test/flutter_test.dart';
import 'package:flashtransfer/core/models/transfer_models.dart';
import 'package:flashtransfer/core/repositories/transfer_repository.dart';
import 'package:flashtransfer/core/usecases/transfer_use_cases.dart';
import 'package:flashtransfer/features/transfer/presentation/transfer_view_model.dart';

class FakeTransferRepository implements TransferRepository {
  final List<String> sent = <String>[];

  @override
  Stream<TransferMetrics> watchMetrics() => const Stream<TransferMetrics>.empty();

  @override
  Future<void> startServer({int port = 8988}) async {}

  @override
  Future<void> stopServer() async {}

  @override
  Future<void> queueAndSend(String uri, String host, int port, {String? sha256}) async => sent.add(uri);

  @override
  Future<void> cancelTransfers() async {}

  @override
  Future<String> verifyHash(String uri) async => 'hash';
}

void main() {
  test('enqueueFiles sends every queued file sequentially', () async {
    final repository = FakeTransferRepository();
    final viewModel = TransferViewModel(
      watchMetrics: WatchTransferMetricsUseCase(repository),
      startServer: StartTransferServerUseCase(repository),
      stopServer: StopTransferServerUseCase(repository),
      sendFile: SendFileUseCase(repository),
      cancelTransfers: CancelTransfersUseCase(repository),
      verifyHash: VerifyFileHashUseCase(repository),
    );

    await viewModel.enqueueFiles(
      const <TransferFile>[
        TransferFile(uri: 'content://one', name: 'one.bin', sizeBytes: 1),
        TransferFile(uri: 'content://two', name: 'two.bin', sizeBytes: 1),
      ],
      host: '192.168.49.1',
      port: 8988,
    );

    expect(repository.sent, <String>['content://one', 'content://two']);
    expect(viewModel.state.completedCount, 2);
    viewModel.dispose();
  });
}
