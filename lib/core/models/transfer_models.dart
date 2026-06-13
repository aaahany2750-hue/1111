enum TransferDirection { send, receive }
enum TransferStatus { queued, connecting, transferring, verifying, completed, failed, canceled }

class TransferFile {
  const TransferFile({
    required this.uri,
    required this.name,
    required this.sizeBytes,
    this.sha256,
    this.mimeType,
  });

  final String uri;
  final String name;
  final int sizeBytes;
  final String? sha256;
  final String? mimeType;
}

class TransferMetrics {
  const TransferMetrics({
    required this.fileName,
    required this.progress,
    required this.speedBytesPerSecond,
    required this.transferredBytes,
    required this.totalBytes,
    required this.queueSize,
    this.status = TransferStatus.transferring,
  });

  final String fileName;
  final double progress;
  final int speedBytesPerSecond;
  final int transferredBytes;
  final int totalBytes;
  final int queueSize;
  final TransferStatus status;

  factory TransferMetrics.fromNativeEvent(Map<String, dynamic> event, {int queueSize = 0}) {
    final int transferred = (event['transferredBytes'] as num? ?? 0).toInt();
    final int total = (event['totalBytes'] as num? ?? 0).toInt();
    return TransferMetrics(
      fileName: event['fileName'] as String? ?? '',
      progress: total <= 0 ? 0.0 : transferred / total,
      speedBytesPerSecond: (event['speedBytesPerSecond'] as num? ?? 0).toInt(),
      transferredBytes: transferred,
      totalBytes: total,
      queueSize: queueSize,
      status: event['done'] == true ? TransferStatus.completed : TransferStatus.transferring,
    );
  }
}

class TransferHistoryRecord {
  const TransferHistoryRecord({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.fileName,
    required this.fileSize,
    required this.transferDate,
    required this.duration,
    required this.status,
    required this.direction,
    this.sha256,
  });

  final int id;
  final String sender;
  final String receiver;
  final String fileName;
  final int fileSize;
  final DateTime transferDate;
  final Duration duration;
  final TransferStatus status;
  final TransferDirection direction;
  final String? sha256;
}
