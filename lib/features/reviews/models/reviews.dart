// To parse this JSON data, do
//
//     final reviews = reviewsFromJson(jsonString);

import 'dart:convert';

List<Reviews> reviewsFromJson(String str) => List<Reviews>.from(json.decode(str).map((x) => Reviews.fromJson(x)));

String reviewsToJson(List<Reviews> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reviews {
  int id;
  String user;
  int rating;
  String comment;
  DateTime createdAt;

  Reviews({
    required this.id,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Reviews.fromJson(Map<String, dynamic> json) => Reviews(
    id: json["id"],
    user: json["user"],
    rating: json["rating"],
    comment: json["comment"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user,
    "rating": rating,
    "comment": comment,
    "created_at": createdAt.toIso8601String(),
  };
}
