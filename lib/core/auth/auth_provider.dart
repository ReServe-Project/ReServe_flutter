import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class AuthProvider extends ChangeNotifier {
  final CookieRequest request = CookieRequest();

  bool get isLoggedIn => request.loggedIn;

  String? get username => request.jsonData['username']?.toString();

  Future<bool> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      // ✅ Correct endpoint in your Django: /accounts/api/login/
      final String loginUrl = '$baseUrl/accounts/api/login/';

      await request.login(loginUrl, {
        'username': username,
        'password': password,
      });

      notifyListeners();
      return request.loggedIn;
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      return false;
    }
  }

  Future<void> logout({required String baseUrl}) async {
    try {
      final String logoutUrl = '$baseUrl/accounts/api/logout/';
      await request.logout(logoutUrl);
    } catch (e) {
      // ignore
    }
    notifyListeners();
  }
}
