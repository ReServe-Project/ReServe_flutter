import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reviews.dart';
import '../services/review_services.dart';
import 'review_dialog.dart';
import 'package:reserve_mobile/core/auth/auth_provider.dart';

class ClassReviewsSection extends StatefulWidget {
  final int classId;
  final bool isMember; // REMOVED: sessionCookie

  const ClassReviewsSection({
    super.key,
    required this.classId,
    required this.isMember, // REMOVED: sessionCookie
  });

  @override
  State<ClassReviewsSection> createState() => _ClassReviewsSectionState();
}

class _ClassReviewsSectionState extends State<ClassReviewsSection> {
  List<Reviews> _reviews = [];
  Reviews? _userReview;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await ReviewService.fetchReviews(context, widget.classId);

      setState(() {
        _reviews = reviews;

        final auth = context.read<AuthProvider>();
        if (auth.isLoggedIn && auth.username != null) {
          try {
            _userReview = reviews.firstWhere(
                  (r) => r.user == auth.username,
            );
          } catch (_) {
            _userReview = null;
          }
        } else {
          _userReview = null;
        }
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        _reviews = [];
        _userReview = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUserReview() async {
    if (_userReview == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete your review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ReviewService.deleteReview(
        context: context,
        classId: widget.classId,
        reviewId: _userReview!.id,
      );

      await _loadReviews();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews (${_reviews.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              if (widget.isMember)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF07A3B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Checkout'),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Average rating
          if (_reviews.isNotEmpty) ...[
            Row(
              children: [
                Row(
                  children: List.generate(3, (i) {
                    return Icon(
                      i + 1 <= averageRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ),
                const SizedBox(width: 6),
                Text('${averageRating.toStringAsFixed(1)} / 3'),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Add / Update / Delete buttons
          if (widget.isMember)
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C4974),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to add a review'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (_) => ReviewDialog(
                        initialRating: _userReview?.rating,
                        initialComment: _userReview?.comment,
                        onSubmit: (rating, comment) async {
                          try {
                            await ReviewService.submitReview(
                              context: context,
                              classId: widget.classId,
                              rating: rating,
                              comment: comment,
                            );
                            await _loadReviews();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Review submitted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to submit review: $e'),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                  child: Text(_userReview == null ? 'Add Review' : 'Update Review'),
                ),

                const SizedBox(width: 10),

                if (_userReview != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _deleteUserReview,
                    child: const Text('Delete Review'),
                  ),
              ],
            ),

          const SizedBox(height: 24),

          // Reviews list
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._reviews.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.user, style: const TextStyle(fontWeight: FontWeight.bold)),

                      if (context.read<AuthProvider>().isLoggedIn &&
                          context.read<AuthProvider>().username == r.user)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Your Review',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: List.generate(3, (i) {
                      return Icon(
                        i + 1 <= r.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(r.comment),
                ],
              ),
            )),
        ],
      ),
    );
  }
}