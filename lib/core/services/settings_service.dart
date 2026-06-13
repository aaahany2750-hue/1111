import 'dart:async';

import '../models/app_models.dart';
import '../repositories/settings_repository.dart';

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository() : _controller = StreamController<AppSettings>.broadcast();

  AppSettings _settings = const AppSettings();
  final StreamController<AppSettings> _controller;

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _settings;
    yield* _controller.stream;
  }

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
    _controller.add(settings);
  }
}
