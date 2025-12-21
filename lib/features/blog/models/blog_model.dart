class Blog {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? thumbnail;
  final DateTime createdAt;

  Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.thumbnail,
    required this.createdAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] ?? '',
      userId: json['user'] ?? json['user_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content, 'thumbnail': thumbnail};
  }

  Blog copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? thumbnail,
    DateTime? createdAt,
  }) {
    return Blog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
