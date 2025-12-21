import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:reserve_mobile/core/auth/auth_provider.dart';
import 'package:reserve_mobile/core/config/app_config.dart';
import '../models/reviews.dart';

class ReviewService {
  static String get _base => AppConfig.baseUrl;

  // URL helpers
  static String _reviewsJsonUrl(int classId) =>
      '$_base/classes/$classId/reviews/json/';
  static String _addReviewUrl(int classId) =>
      '$_base/classes/$classId/add_review/';
  static String _deleteReviewUrl(int classId, int reviewId) =>
      '$_base/classes/$classId/delete_review/$reviewId/';

  // Get the CookieRequest from AuthProvider
  static CookieRequest _req(BuildContext context) {
    return context.read<AuthProvider>().request;
  }

  static Future<List<Review>> fetchReviews(
    BuildContext context,
    int classId,
  ) async {
    final request = _req(context);
    final url = _reviewsJsonUrl(classId);

    final res = await request.get(url);

    if (res is! List) {
      throw Exception("Failed to load reviews");
    }

    return res
        .map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<Map<String, dynamic>> submitReview({
    required BuildContext context,
    required int classId,
    required int rating,
    required String comment,
  }) async {
    final request = _req(context);
    final url = _addReviewUrl(classId);

    // For Django with pbp_django_auth, we need to send as form data
    // but add JSON content-type header
    final res = await request.post(url, {
      'rating': rating.toString(),
      'comment': comment,
    });

    // Try to parse response
    if (res is Map<String, dynamic>) {
      if (res.containsKey('error')) {
        throw Exception(res['error']);
      }
      return res;
    }

    if (res is String) {
      try {
        final parsed = json.decode(res);
        if (parsed is Map<String, dynamic>) {
          if (parsed.containsKey('error')) {
            throw Exception(parsed['error']);
          }
          return parsed;
        }
      } catch (e) {
        // Not JSON
      }
    }

    throw Exception('Unexpected response from server');
  }

  static Future<void> deleteReview({
    required BuildContext context,
    required int classId,
    required int reviewId,
  }) async {
    final request = _req(context);
    final url = _deleteReviewUrl(classId, reviewId);

    final res = await request.post(url, {});

    // Check if successful
    if (res is Map<String, dynamic>) {
      if (res.containsKey('success') && res['success'] == true) {
        return;
      }
      if (res.containsKey('error')) {
        throw Exception(res['error']);
      }
    }

    // If it's HTML (from web), check for errors
    if (res is String) {
      if (res.toLowerCase().contains('error') ||
          res.toLowerCase().contains('forbidden')) {
        throw Exception('Failed to delete review');
      }
      return; // Assume success if no error
    }

    throw Exception('Failed to delete review');
  }
}
