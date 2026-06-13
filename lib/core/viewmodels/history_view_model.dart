import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transfer_models.dart';
import '../usecases/history_use_cases.dart';

class HistoryState {
  const HistoryState({this.records = const <TransferHistoryRecord>[]});

  final List<TransferHistoryRecord> records;
}

class HistoryViewModel extends StateNotifier<HistoryState> {
  HistoryViewModel({
    required WatchHistoryUseCase watchHistory,
    required DeleteHistoryRecordUseCase deleteRecord,
    required ClearHistoryUseCase clearHistory,
  })  : _deleteRecord = deleteRecord,
        _clearHistory = clearHistory,
        super(const HistoryState()) {
    _subscription = watchHistory().listen((List<TransferHistoryRecord> records) {
      state = HistoryState(records: records);
    });
  }

  final DeleteHistoryRecordUseCase _deleteRecord;
  final ClearHistoryUseCase _clearHistory;
  late final StreamSubscription<List<TransferHistoryRecord>> _subscription;

  Future<void> delete(int id) => _deleteRecord(id);

  Future<void> clear() => _clearHistory();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
