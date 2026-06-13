export '../models/app_models.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/discovery/data/datasources/discovery_native_data_source.dart';
import '../../features/discovery/data/native_discovery_repository.dart';
import '../../features/discovery/presentation/discovery_state.dart';
import '../../features/discovery/presentation/discovery_view_model.dart';
import '../../features/transfer/data/datasources/transfer_native_data_source.dart';
import '../../features/transfer/data/native_transfer_repository.dart';
import '../../features/transfer/presentation/transfer_state.dart';
import '../../features/transfer/presentation/transfer_view_model.dart';
import '../models/app_models.dart';
import '../repositories/discovery_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/history_repository.dart';
import '../repositories/transfer_repository.dart';
import '../services/native_bridge.dart';
import '../services/settings_service.dart';
import '../services/history_service.dart';
import '../usecases/discovery_use_cases.dart';
import '../usecases/settings_use_cases.dart';
import '../usecases/history_use_cases.dart';
import '../usecases/transfer_use_cases.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/history_view_model.dart';

final nativeBridgeProvider = Provider<NativeBridge>((ref) {
  return NativeBridge();
});

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return NativeDiscoveryRepository(dataSource: MethodChannelDiscoveryDataSource(ref.watch(nativeBridgeProvider)));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return NativeTransferRepository(dataSource: MethodChannelTransferDataSource(ref.watch(nativeBridgeProvider)));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return InMemorySettingsRepository();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return InMemoryHistoryRepository();
});

final watchPeersUseCaseProvider = Provider<WatchPeersUseCase>((ref) {
  return WatchPeersUseCase(ref.watch(discoveryRepositoryProvider));
});

final refreshPeersUseCaseProvider = Provider<RefreshPeersUseCase>((ref) {
  return RefreshPeersUseCase(ref.watch(discoveryRepositoryProvider));
});

final connectToPeerUseCaseProvider = Provider<ConnectToPeerUseCase>((ref) {
  return ConnectToPeerUseCase(ref.watch(discoveryRepositoryProvider));
});

final disconnectPeerUseCaseProvider = Provider<DisconnectPeerUseCase>((ref) {
  return DisconnectPeerUseCase(ref.watch(discoveryRepositoryProvider));
});

final watchTransferMetricsUseCaseProvider = Provider<WatchTransferMetricsUseCase>((ref) {
  return WatchTransferMetricsUseCase(ref.watch(transferRepositoryProvider));
});

final startTransferServerUseCaseProvider = Provider<StartTransferServerUseCase>((ref) {
  return StartTransferServerUseCase(ref.watch(transferRepositoryProvider));
});

final stopTransferServerUseCaseProvider = Provider<StopTransferServerUseCase>((ref) {
  return StopTransferServerUseCase(ref.watch(transferRepositoryProvider));
});

final sendFileUseCaseProvider = Provider<SendFileUseCase>((ref) {
  return SendFileUseCase(ref.watch(transferRepositoryProvider));
});

final verifyFileHashUseCaseProvider = Provider<VerifyFileHashUseCase>((ref) {
  return VerifyFileHashUseCase(ref.watch(transferRepositoryProvider));
});

final cancelTransfersUseCaseProvider = Provider<CancelTransfersUseCase>((ref) {
  return CancelTransfersUseCase(ref.watch(transferRepositoryProvider));
});

final saveSettingsUseCaseProvider = Provider<SaveSettingsUseCase>((ref) {
  return SaveSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final watchHistoryUseCaseProvider = Provider<WatchHistoryUseCase>((ref) {
  return WatchHistoryUseCase(ref.watch(historyRepositoryProvider));
});

final deleteHistoryRecordUseCaseProvider = Provider<DeleteHistoryRecordUseCase>((ref) {
  return DeleteHistoryRecordUseCase(ref.watch(historyRepositoryProvider));
});

final clearHistoryUseCaseProvider = Provider<ClearHistoryUseCase>((ref) {
  return ClearHistoryUseCase(ref.watch(historyRepositoryProvider));
});

final discoveryViewModelProvider = StateNotifierProvider<DiscoveryViewModel, DiscoveryState>((ref) {
  return DiscoveryViewModel(
    watchPeers: ref.watch(watchPeersUseCaseProvider),
    refreshPeers: ref.watch(refreshPeersUseCaseProvider),
    connectToPeer: ref.watch(connectToPeerUseCaseProvider),
    disconnectPeer: ref.watch(disconnectPeerUseCaseProvider),
  );
});

final transferViewModelProvider = StateNotifierProvider<TransferViewModel, TransferState>((ref) {
  return TransferViewModel(
    watchMetrics: ref.watch(watchTransferMetricsUseCaseProvider),
    startServer: ref.watch(startTransferServerUseCaseProvider),
    stopServer: ref.watch(stopTransferServerUseCaseProvider),
    sendFile: ref.watch(sendFileUseCaseProvider),
    cancelTransfers: ref.watch(cancelTransfersUseCaseProvider),
    verifyHash: ref.watch(verifyFileHashUseCaseProvider),
  );
});

final historyViewModelProvider = StateNotifierProvider<HistoryViewModel, HistoryState>((ref) {
  return HistoryViewModel(
    watchHistory: ref.watch(watchHistoryUseCaseProvider),
    deleteRecord: ref.watch(deleteHistoryRecordUseCaseProvider),
    clearHistory: ref.watch(clearHistoryUseCaseProvider),
  );
});

final settingsControllerProvider = StateNotifierProvider<SettingsViewModel, AppSettings>((ref) {
  return SettingsViewModel(saveSettings: ref.watch(saveSettingsUseCaseProvider));
});
