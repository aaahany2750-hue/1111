import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transfer_models.dart';
import '../usecases/transfer_use_cases.dart';

class TransferState {
  const TransferState({
    this.activeMetrics,
    this.errorMessage,
    this.serverRunning = false,
  });

  final TransferMetrics? activeMetrics;
  final String? errorMessage;
  final bool serverRunning;

  TransferState copyWith({
    TransferMetrics? activeMetrics,
    String? errorMessage,
    bool? serverRunning,
  }) {
    return TransferState(
      activeMetrics: activeMetrics ?? this.activeMetrics,
      errorMessage: errorMessage,
      serverRunning: serverRunning ?? this.serverRunning,
    );
  }
}

class TransferViewModel extends StateNotifier<TransferState> {
  TransferViewModel({
    required WatchTransferMetricsUseCase watchMetrics,
    required StartTransferServerUseCase startServer,
    required StopTransferServerUseCase stopServer,
    required SendFileUseCase sendFile,
    required VerifyFileHashUseCase verifyHash,
  })  : _startServer = startServer,
        _stopServer = stopServer,
        _sendFile = sendFile,
        _verifyHash = verifyHash,
        super(const TransferState()) {
    _metricsSubscription = watchMetrics().listen((TransferMetrics metrics) {
      state = state.copyWith(activeMetrics: metrics);
    });
  }

  final StartTransferServerUseCase _startServer;
  final StopTransferServerUseCase _stopServer;
  final SendFileUseCase _sendFile;
  final VerifyFileHashUseCase _verifyHash;
  late final StreamSubscription<TransferMetrics> _metricsSubscription;

  Future<void> startServer({int port = 8988}) async {
    await _startServer(port: port);
    state = state.copyWith(serverRunning: true);
  }

  Future<void> stopServer() async {
    await _stopServer();
    state = state.copyWith(serverRunning: false);
  }

  Future<void> sendFile(String uri, String host, int port) async {
    final String sha = await _verifyHash(uri);
    await _sendFile(uri, host, port, sha256: sha);
  }

  @override
  void dispose() {
    _metricsSubscription.cancel();
    super.dispose();
  }
}
