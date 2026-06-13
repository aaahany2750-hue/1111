import '../models/app_models.dart';

abstract interface class SettingsRepository {
  Stream<AppSettings> watchSettings();
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}
