import 'package:flutter/material.dart';
import '../models/reviews.dart';
import '../services/review_services.dart';
import 'review_dialog.dart';

/// Embedded reviews section shown inside class detail page
class ClassReviewsSection extends StatefulWidget {
  final int classId;
  final String sessionCookie;
  final bool isMember;

  const ClassReviewsSection({
    super.key,
    required this.classId,
    required this.sessionCookie,
    required this.isMember,
  });

  @override
  State<ClassReviewsSection> createState() => _ClassReviewsSectionState();
}

class _ClassReviewsSectionState extends State<ClassReviewsSection> {
  List<Review> _reviews = [];
  Review? _userReview;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  /// Fetch reviews and detect user's own review
  Future<void> _loadReviews() async {
    final reviews = await ReviewService.fetchReviews(widget.classId);
    setState(() {
      _reviews = reviews;
      _userReview = reviews.firstWhere(
            (r) => r.username == 'me',
        orElse: () => null as Review,
      );
    });
  }

  /// Average rating calculation
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

          // Add / Update button
          if (widget.isMember)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C4974),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ReviewDialog(
                    initialRating: _userReview?.rating,
                    initialComment: _userReview?.comment,
                    onSubmit: (rating, comment) async {
                      await ReviewService.submitReview(
                        classId: widget.classId,
                        rating: rating,
                        comment: comment,
                        sessionCookie: widget.sessionCookie,
                      );
                      _loadReviews();
                    },
                  ),
                );
              },
              child: Text(_userReview == null ? 'Add Review' : 'Update Your Review'),
            ),

          const SizedBox(height: 24),

          // Reviews list
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
                Text(r.username, style: const TextStyle(fontWeight: FontWeight.bold)),
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
