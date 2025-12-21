import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/reviews.dart';

/// Handles all communication with Django review endpoints
class ReviewService {

  /// Fetch all reviews for a class
  static Future<List<Review>> fetchReviews(int classId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/classes/$classId/reviews/json/'),
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Review.fromJson(e)).toList();
  }

  /// Add or update a review
  static Future<void> submitReview({
    required int classId,
    required int rating,
    required String comment,
    required String sessionCookie,
  }) async {
    await http.post(
      Uri.parse('${AppConfig.baseUrl}/classes/$classId/add_review/'),
      headers: {
        'Cookie': sessionCookie,
      },
      body: {
        'rating': rating.toString(),
        'comment': comment,
      },
    );
  }

  /// Delete a review
  static Future<void> deleteReview({
    required int classId,
    required int reviewId,
    required String sessionCookie,
  }) async {
    await http.post(
      Uri.parse('${AppConfig.baseUrl}/classes/$classId/delete_review/$reviewId/'),
      headers: {
        'Cookie': sessionCookie,
      },
    );
  }
}
