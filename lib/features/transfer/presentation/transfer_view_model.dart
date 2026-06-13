import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/transfer_models.dart';
import '../../../core/usecases/transfer_use_cases.dart';
import '../domain/transfer_queue_item.dart';
import 'transfer_state.dart';

class TransferViewModel extends StateNotifier<TransferState> {
  TransferViewModel({
    required WatchTransferMetricsUseCase watchMetrics,
    required StartTransferServerUseCase startServer,
    required StopTransferServerUseCase stopServer,
    required SendFileUseCase sendFile,
    required CancelTransfersUseCase cancelTransfers,
    required VerifyFileHashUseCase verifyHash,
  })  : _startServer = startServer,
        _stopServer = stopServer,
        _sendFile = sendFile,
        _cancelTransfers = cancelTransfers,
        _verifyHash = verifyHash,
        super(const TransferState()) {
    _metricsSubscription = watchMetrics().listen(_applyMetrics);
  }

  final StartTransferServerUseCase _startServer;
  final StopTransferServerUseCase _stopServer;
  final SendFileUseCase _sendFile;
  final CancelTransfersUseCase _cancelTransfers;
  final VerifyFileHashUseCase _verifyHash;
  late final StreamSubscription<TransferMetrics> _metricsSubscription;
  bool _processing = false;
  bool _cancelRequested = false;

  Future<void> enqueueFiles(List<TransferFile> files, {required String host, required int port}) async {
    final List<TransferQueueItem> additions = files.map((TransferFile file) {
      return TransferQueueItem(
        id: '${DateTime.now().microsecondsSinceEpoch}-${file.uri}',
        file: file,
        host: host,
        port: port,
        remainingBytes: file.sizeBytes,
      );
    }).toList(growable: false);
    state = state.copyWith(queue: <TransferQueueItem>[...state.queue, ...additions], clearError: true);
    await _processQueue();
  }

  Future<void> startServer({int port = 8988}) async {
    await _startServer(port: port);
    state = state.copyWith(serverRunning: true, clearError: true);
  }

  Future<void> stopServer() async {
    await _stopServer();
    state = state.copyWith(serverRunning: false);
  }

  Future<void> cancelAll() async {
    _cancelRequested = true;
    state = state.copyWith(cancelling: true);
    await _cancelTransfers();
    state = state.copyWith(
      queue: state.queue.map((TransferQueueItem item) {
        if (item.status == TransferStatus.completed || item.status == TransferStatus.failed) return item;
        return item.copyWith(status: TransferStatus.canceled);
      }).toList(growable: false),
      cancelling: false,
    );
  }

  Future<void> retryFailed() async {
    state = state.copyWith(
      queue: state.queue.map((TransferQueueItem item) {
        if (item.status != TransferStatus.failed) return item;
        return item.copyWith(status: TransferStatus.queued, progress: 0.0, transferredBytes: 0, remainingBytes: item.file.sizeBytes);
      }).toList(growable: false),
      clearError: true,
    );
    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;
    _cancelRequested = false;
    try {
      while (!_cancelRequested) {
        final int index = state.queue.indexWhere((TransferQueueItem item) => item.status == TransferStatus.queued);
        if (index < 0) break;
        await _sendQueueItem(index);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _sendQueueItem(int index) async {
    TransferQueueItem item = state.queue[index];
    _replaceItem(index, item.copyWith(status: TransferStatus.verifying));
    try {
      final String sha = item.file.sha256 ?? await _verifyHash(item.file.uri);
      item = state.queue[index];
      _replaceItem(index, item.copyWith(status: TransferStatus.transferring));
      await _sendFile(item.file.uri, item.host, item.port, sha256: sha);
      item = state.queue[index];
      _replaceItem(index, item.copyWith(status: TransferStatus.completed, progress: 1.0, transferredBytes: item.file.sizeBytes, remainingBytes: 0));
    } catch (error) {
      item = state.queue[index];
      _replaceItem(index, item.copyWith(status: _cancelRequested ? TransferStatus.canceled : TransferStatus.failed, errorMessage: error.toString()));
      if (!_cancelRequested) state = state.copyWith(errorMessage: error.toString());
    }
  }

  void _applyMetrics(TransferMetrics metrics) {
    final int index = state.queue.indexWhere((TransferQueueItem item) => item.file.name == metrics.fileName && item.status == TransferStatus.transferring);
    if (index < 0) {
      state = state.copyWith(activeMetrics: metrics);
      return;
    }
    final TransferQueueItem item = state.queue[index];
    final int remaining = (metrics.totalBytes - metrics.transferredBytes).clamp(0, metrics.totalBytes).toInt();
    final Duration? eta = metrics.speedBytesPerSecond <= 0 ? null : Duration(seconds: (remaining / metrics.speedBytesPerSecond).ceil());
    _replaceItem(index, item.copyWith(
      progress: metrics.progress,
      speedBytesPerSecond: metrics.speedBytesPerSecond,
      transferredBytes: metrics.transferredBytes,
      remainingBytes: remaining,
      estimatedRemaining: eta,
    ));
    state = state.copyWith(activeMetrics: metrics);
  }

  void _replaceItem(int index, TransferQueueItem item) {
    final List<TransferQueueItem> next = <TransferQueueItem>[...state.queue];
    next[index] = item;
    state = state.copyWith(queue: next);
  }

  @override
  void dispose() {
    _metricsSubscription.cancel();
    super.dispose();
  }
}
