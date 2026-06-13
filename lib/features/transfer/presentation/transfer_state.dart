import '../../../core/models/transfer_models.dart';
import '../domain/transfer_queue_item.dart';

class TransferState {
  const TransferState({
    this.queue = const <TransferQueueItem>[],
    this.activeMetrics,
    this.serverRunning = false,
    this.cancelling = false,
    this.errorMessage,
  });

  final List<TransferQueueItem> queue;
  final TransferMetrics? activeMetrics;
  final bool serverRunning;
  final bool cancelling;
  final String? errorMessage;

  int get queueSize => queue.where((TransferQueueItem item) => item.status == TransferStatus.queued).length;
  int get completedCount => queue.where((TransferQueueItem item) => item.status == TransferStatus.completed).length;
  int get failedCount => queue.where((TransferQueueItem item) => item.status == TransferStatus.failed).length;
  int get totalBytes => queue.fold<int>(0, (int sum, TransferQueueItem item) => sum + item.file.sizeBytes);
  int get transferredBytes => queue.fold<int>(0, (int sum, TransferQueueItem item) => sum + item.transferredBytes);

  TransferState copyWith({
    List<TransferQueueItem>? queue,
    TransferMetrics? activeMetrics,
    bool? serverRunning,
    bool? cancelling,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransferState(
      queue: queue ?? this.queue,
      activeMetrics: activeMetrics ?? this.activeMetrics,
      serverRunning: serverRunning ?? this.serverRunning,
      cancelling: cancelling ?? this.cancelling,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
