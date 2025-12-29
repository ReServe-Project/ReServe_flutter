import 'dart:io' show Platform;

class AppConfig {
  /// Django backend base URL.
  ///
  /// Notes:
  /// - Android emulator must use 10.0.2.2 to reach the host machine.
  /// - iOS simulator and desktop builds can usually use localhost.
  ///
  /// Keep this consistent across login + all API calls, otherwise session
  /// cookies will not be sent.
  static String get baseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {
      // Platform isn't available on web.
    }
    return 'https://khayru-rafa-reserve.pbp.cs.ui.ac.id';
  }
}
