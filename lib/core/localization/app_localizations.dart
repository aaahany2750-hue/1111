import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ar')];
  static const LocalizationsDelegate<AppLocalizations> delegate = _Delegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _values = <String, Map<String, String>>{
    'en': <String, String>{'discover': 'Discover', 'transfers': 'Transfers', 'games': 'Games', 'history': 'History', 'settings': 'Settings', 'nearby': 'Nearby Devices', 'refresh': 'Refresh', 'connect': 'Connect', 'disconnect': 'Disconnect', 'active': 'Active Transfers', 'empty': 'Nothing here yet', 'language': 'Language', 'theme': 'Theme', 'permissions': 'Permissions', 'diagnostics': 'Diagnostics'},
    'ar': <String, String>{'discover': 'اكتشاف', 'transfers': 'النقل', 'games': 'الألعاب', 'history': 'السجل', 'settings': 'الإعدادات', 'nearby': 'الأجهزة القريبة', 'refresh': 'تحديث', 'connect': 'اتصال', 'disconnect': 'قطع الاتصال', 'active': 'عمليات النقل النشطة', 'empty': 'لا يوجد شيء بعد', 'language': 'اللغة', 'theme': 'السمة', 'permissions': 'الأذونات', 'diagnostics': 'التشخيصات'},
  };

  String _text(String key) => _values[locale.languageCode]?[key] ?? _values['en']![key]!;

  String get discover => _text('discover');
  String get transfers => _text('transfers');
  String get games => _text('games');
  String get history => _text('history');
  String get settings => _text('settings');
  String get nearby => _text('nearby');
  String get refresh => _text('refresh');
  String get connect => _text('connect');
  String get disconnect => _text('disconnect');
  String get active => _text('active');
  String get empty => _text('empty');
  String get language => _text('language');
  String get theme => _text('theme');
  String get permissions => _text('permissions');
  String get diagnostics => _text('diagnostics');
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) => <String>['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
