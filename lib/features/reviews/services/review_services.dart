import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/reviews.dart'; // Ensure this file defines the "Review" class

/// Handles all communication with Django review endpoints
class ReviewService {

  /// Fetch all reviews for a class
  static Future<List<Review>> fetchReviews(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/classes/$classId/reviews/json/'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Review.fromJson(e)).toList();
      } else {
        // Handle server errors (e.g., 404, 500)
        print("Server error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Handle connection errors
      print("Error fetching reviews: $e");
      return [];
    }
  }

  /// Add or update a review
  static Future<void> submitReview({
    required int classId,
    required int rating,
    required String comment,
    required String sessionCookie,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/classes/$classId/add_review/'),
        headers: {
          'Cookie': sessionCookie,
        },
        body: {
          'rating': rating.toString(),
          'comment': comment,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Failed to submit review: ${response.statusCode}");
      }
    } catch (e) {
      print("Error submitting review: $e");
    }
  }

  /// Delete a review
  static Future<void> deleteReview({
    required int classId,
    required int reviewId,
    required String sessionCookie,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/classes/$classId/delete_review/$reviewId/'),
        headers: {
          'Cookie': sessionCookie,
        },
      );

      if (response.statusCode != 200) {
        print("Failed to delete review: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting review: $e");
    }
  }
}