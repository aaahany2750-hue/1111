import '../models/app_models.dart';
import '../repositories/settings_repository.dart';

class LoadSettingsUseCase {
  const LoadSettingsUseCase(this.repository);
  final SettingsRepository repository;
  Future<AppSettings> call() => repository.load();
}

class WatchSettingsUseCase {
  const WatchSettingsUseCase(this.repository);
  final SettingsRepository repository;
  Stream<AppSettings> call() => repository.watchSettings();
}

class SaveSettingsUseCase {
  const SaveSettingsUseCase(this.repository);
  final SettingsRepository repository;
  Future<void> call(AppSettings settings) => repository.save(settings);
}
