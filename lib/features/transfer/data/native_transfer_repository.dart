import '../../../core/models/transfer_models.dart';
import '../../../core/repositories/transfer_repository.dart';
import 'datasources/transfer_native_data_source.dart';
import 'mappers/transfer_metrics_mapper.dart';

class NativeTransferRepository implements TransferRepository {
  NativeTransferRepository({
    required TransferNativeDataSource dataSource,
    TransferMetricsMapper mapper = const TransferMetricsMapper(),
  })  : _dataSource = dataSource,
        _mapper = mapper;

  final TransferNativeDataSource _dataSource;
  final TransferMetricsMapper _mapper;

  @override
  Stream<TransferMetrics> watchMetrics() {
    return _dataSource
        .watchTransferEvents()
        .where((Map<String, dynamic> event) => event['type'] == 'transferProgress')
        .map(_mapper.fromNativeEvent);
  }

  @override
  Future<void> startServer({int port = 8988}) => _dataSource.startServer(port: port);

  @override
  Future<void> stopServer() => _dataSource.stopServer();

  @override
  Future<void> queueAndSend(String uri, String host, int port, {String? sha256}) {
    return _dataSource.sendFile(uri, host, port, sha256: sha256);
  }

  @override
  Future<void> cancelTransfers() => _dataSource.cancelTransfers();

  @override
  Future<String> verifyHash(String uri) => _dataSource.sha256(uri);
}
