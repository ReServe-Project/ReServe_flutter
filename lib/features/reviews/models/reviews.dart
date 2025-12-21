import 'dart:convert';

List<Review> reviewsFromJson(String str) => List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewsToJson(List<Review> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
  int id;
  String username; // Changed from 'user' to 'username'
  int rating;
  String comment;
  DateTime createdAt;

  Review({
    required this.id,
    required this.username,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json["id"],
    username: json["user"], // Keeps 'user' as the JSON key from your backend
    rating: json["rating"],
    comment: json["comment"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "rating": rating,
    "comment": comment,
    "created_at": createdAt.toIso8601String(),
  };
}