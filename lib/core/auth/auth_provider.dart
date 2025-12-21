import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class AuthProvider extends ChangeNotifier {
  final CookieRequest request = CookieRequest();

  String? _role; // "instructor" / "member"

  bool get isLoggedIn => request.loggedIn;

  String? get username {
    final u = request.jsonData['username']?.toString();
    if (u != null && u.isNotEmpty) return u;
    return null;
  }

  String get role => (_role ?? "member").toLowerCase(); // default safe
  bool get isInstructor => role == "instructor";
  bool get isMember => role == "member";

  Future<bool> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    try {
      final String loginUrl = '$baseUrl/accounts/api/login/';

      await request.login(loginUrl, {
        'username': username,
        'password': password,
      });

      // After login, ensure role is loaded (from login response or profile)
      _role = request.jsonData['role']?.toString().toLowerCase();
      if (_role == null || _role!.isEmpty) {
        await fetchMe(baseUrl: baseUrl);
      }

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
    _role = null;
    notifyListeners();
  }

  /// Fetch profile endpoint that returns:
  /// { "status": true, "profile": { "role": "...", "username": "...", ... } }
  Future<void> fetchMe({required String baseUrl}) async {
    try {
      final res = await request.get('$baseUrl/accounts/api/profile/');

      // ✅ Django returns nested "profile"
      final profile = (res is Map<String, dynamic>) ? res['profile'] : null;
      if (profile is Map<String, dynamic>) {
        _role = profile['role']?.toString().toLowerCase();
      } else {
        // fallback if response shape changes
        _role = (res is Map<String, dynamic>) ? res['role']?.toString().toLowerCase() : null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('FETCH PROFILE ERROR: $e');
    }
  }
}
