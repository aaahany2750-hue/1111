# FlashTransfer

FlashTransfer is a Flutter 3.24+ Android application for offline file transfer over Wi-Fi Direct. It uses Riverpod, Material 3, a native Kotlin MethodChannel bridge, SHA-256 verification, localization, and a feature-based clean architecture.

## Build

1. Install Flutter 3.24+ and Android Studio.
2. Run `flutter pub get`.
3. Run `flutter test`.
4. Generate an APK with `flutter build apk --release`.

## Release

Configure signing in `android/key.properties` and `android/app/build.gradle`, then run `flutter build appbundle --release`.
