import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../../../core/config/app_config.dart';
import '../models/user_profile.dart';

class ProfileApi {
  static Future<UserProfile> fetchMyProfile(CookieRequest request) async {
    final url = '${AppConfig.baseUrl}/accounts/api/profile/';
    final response = await request.get(url);

    if (response is Map && response['status'] == true) {
      final profileJson = response['profile'];
      if (profileJson is Map) {
        return UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
      }
    }

    // If backend sends useful errors, forward them
    if (response is Map) {
      throw Exception(jsonEncode(response));
    }

    throw Exception(jsonEncode({
      "status": false,
      "message": "Failed to load profile.",
    }));
  }

  static Future<UserProfile> updateProfile(
    CookieRequest request, {
    required String displayName,
    required int? heightCm,
    required double? weightKg,
  }) async {
    final url = '${AppConfig.baseUrl}/accounts/api/profile/update/';

    final body = <String, String>{
      'display_name': displayName,
    };

    // Only send if user filled it; otherwise let it stay null on backend
    if (heightCm != null) body['height_cm'] = heightCm.toString();
    if (weightKg != null) body['weight_kg'] = weightKg.toString();

    final response = await request.post(url, body);

    // Success case
    if (response is Map && response['status'] == true) {
      final profileJson = response['profile'];
      if (profileJson is Map) {
        return UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
      }

      // Status true but missing profile (unexpected)
      throw Exception(jsonEncode({
        "status": false,
        "message": "Profile updated, but server returned invalid data.",
      }));
    }

    // Failure case: forward backend JSON so UI can display field errors
    if (response is Map) {
      throw Exception(jsonEncode(response));
    }

    // Fallback if response is not a Map (unexpected)
    throw Exception(jsonEncode({
      "status": false,
      "message": "Failed to update profile.",
    }));
  }
}
