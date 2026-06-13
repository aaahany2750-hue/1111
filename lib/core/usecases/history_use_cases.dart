import '../models/transfer_models.dart';
import '../repositories/history_repository.dart';

class WatchHistoryUseCase {
  const WatchHistoryUseCase(this.repository);
  final HistoryRepository repository;
  Stream<List<TransferHistoryRecord>> call() => repository.watchHistory();
}

class SaveHistoryRecordUseCase {
  const SaveHistoryRecordUseCase(this.repository);
  final HistoryRepository repository;
  Future<void> call(TransferHistoryRecord record) => repository.save(record);
}

class DeleteHistoryRecordUseCase {
  const DeleteHistoryRecordUseCase(this.repository);
  final HistoryRepository repository;
  Future<void> call(int id) => repository.delete(id);
}

class ClearHistoryUseCase {
  const ClearHistoryUseCase(this.repository);
  final HistoryRepository repository;
  Future<void> call() => repository.clear();
}
