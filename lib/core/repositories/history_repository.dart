import '../models/transfer_models.dart';

abstract interface class HistoryRepository {
  Stream<List<TransferHistoryRecord>> watchHistory();
  Future<void> save(TransferHistoryRecord record);
  Future<void> delete(int id);
  Future<void> clear();
}
