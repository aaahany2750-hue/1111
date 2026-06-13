import '../../../core/models/transfer_models.dart';

class TransferQueueItem {
  const TransferQueueItem({
    required this.id,
    required this.file,
    required this.host,
    required this.port,
    this.status = TransferStatus.queued,
    this.progress = 0,
    this.speedBytesPerSecond = 0,
    this.transferredBytes = 0,
    this.remainingBytes = 0,
    this.estimatedRemaining,
    this.errorMessage,
  });

  final String id;
  final TransferFile file;
  final String host;
  final int port;
  final TransferStatus status;
  final double progress;
  final int speedBytesPerSecond;
  final int transferredBytes;
  final int remainingBytes;
  final Duration? estimatedRemaining;
  final String? errorMessage;

  TransferQueueItem copyWith({
    TransferStatus? status,
    double? progress,
    int? speedBytesPerSecond,
    int? transferredBytes,
    int? remainingBytes,
    Duration? estimatedRemaining,
    String? errorMessage,
  }) {
    return TransferQueueItem(
      id: id,
      file: file,
      host: host,
      port: port,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speedBytesPerSecond: speedBytesPerSecond ?? this.speedBytesPerSecond,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      remainingBytes: remainingBytes ?? this.remainingBytes,
      estimatedRemaining: estimatedRemaining ?? this.estimatedRemaining,
      errorMessage: errorMessage,
    );
  }
}
