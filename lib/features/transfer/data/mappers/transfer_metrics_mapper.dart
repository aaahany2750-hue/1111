import '../../../../core/models/transfer_models.dart';

class TransferMetricsMapper {
  const TransferMetricsMapper();

  TransferMetrics fromNativeEvent(Map<String, dynamic> event, {int queueSize = 0}) {
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
