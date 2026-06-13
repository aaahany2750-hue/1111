import 'package:flutter_test/flutter_test.dart';
import 'package:flashtransfer/features/transfer/data/mappers/transfer_metrics_mapper.dart';

void main() {
  test('maps native transfer progress and computes percentage', () {
    const mapper = TransferMetricsMapper();

    final metrics = mapper.fromNativeEvent(<String, dynamic>{
      'fileName': 'movie.mp4',
      'transferredBytes': 50,
      'totalBytes': 100,
      'speedBytesPerSecond': 25,
      'done': false,
    });

    expect(metrics.fileName, 'movie.mp4');
    expect(metrics.progress, 0.5);
    expect(metrics.speedBytesPerSecond, 25);
  });
}
