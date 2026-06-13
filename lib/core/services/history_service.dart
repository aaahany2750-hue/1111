import 'dart:async';

import '../models/transfer_models.dart';
import '../repositories/history_repository.dart';

class InMemoryHistoryRepository implements HistoryRepository {
  InMemoryHistoryRepository() : _controller = StreamController<List<TransferHistoryRecord>>.broadcast();

  final List<TransferHistoryRecord> _records = <TransferHistoryRecord>[];
  final StreamController<List<TransferHistoryRecord>> _controller;

  @override
  Stream<List<TransferHistoryRecord>> watchHistory() async* {
    yield List<TransferHistoryRecord>.unmodifiable(_records);
    yield* _controller.stream;
  }

  @override
  Future<void> save(TransferHistoryRecord record) async {
    _records.removeWhere((TransferHistoryRecord existing) => existing.id == record.id);
    _records.add(record);
    _controller.add(List<TransferHistoryRecord>.unmodifiable(_records));
  }

  @override
  Future<void> delete(int id) async {
    _records.removeWhere((TransferHistoryRecord record) => record.id == id);
    _controller.add(List<TransferHistoryRecord>.unmodifiable(_records));
  }

  @override
  Future<void> clear() async {
    _records.clear();
    _controller.add(const <TransferHistoryRecord>[]);
  }
}
