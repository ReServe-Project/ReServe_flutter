class FitnessClass {
  final int? id;

  /// Django: owner = ForeignKey(User, ...)
  /// API might send username or object. We keep it flexible.
  final String? owner;

  /// Django: name
  final String name;

  /// Django: category (code: yoga, pilates, ...)
  final String category;

  /// Django: price (int)
  final int price;

  /// Django: image_url (URLField blank=True)
  final String imageUrl;

  /// Django: description (TextField blank=True)
  final String description;

  /// Django: datetime (nullable)
  final DateTime? datetime;

  /// Django: location (blank=True)
  final String location;

  const FitnessClass({
    this.id,
    required this.owner,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.datetime,
    required this.location,
  });

  // ---------- JSON ----------
  factory FitnessClass.fromJson(Map<String, dynamic> json) {
    // owner can be: null, string username, or object. handle all.
    String? ownerValue;
    final rawOwner = json["owner"];
    if (rawOwner == null) {
      ownerValue = null;
    } else if (rawOwner is String) {
      ownerValue = rawOwner;
    } else if (rawOwner is Map<String, dynamic>) {
      // common patterns: {"username": "..."} or {"email": "..."} etc.
      ownerValue = (rawOwner["username"] ?? rawOwner["email"] ?? rawOwner["id"])?.toString();
    } else {
      ownerValue = rawOwner.toString();
    }

    DateTime? dt;
    final rawDt = json["datetime"];
    if (rawDt != null && rawDt.toString().trim().isNotEmpty) {
      dt = DateTime.tryParse(rawDt.toString());
    }

    return FitnessClass(
      id: (json["id"] is int) ? json["id"] as int : int.tryParse(json["id"]?.toString() ?? ""),
      owner: ownerValue,
      name: (json["name"] ?? "").toString(),
      category: (json["category"] ?? "").toString(),
      price: (json["price"] is int) ? json["price"] as int : int.tryParse(json["price"]?.toString() ?? "0") ?? 0,
      imageUrl: (json["image_url"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
      datetime: dt,
      location: (json["location"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "owner": owner,
      "name": name,
      "category": category,
      "price": price,
      "image_url": imageUrl,
      "description": description,
      "datetime": datetime?.toIso8601String(),
      "location": location,
    };
  }

  // ---------- UI helpers ----------
  String get categoryLabel {
    switch (category) {
      case "yoga":
        return "Yoga";
      case "pilates":
        return "Pilates";
      case "dance":
        return "Dance";
      case "boxing":
        return "Boxing";
      case "muaythai":
        return "Muaythai";
      case "ice-skating":
        return "Ice Skating";
      default:
        return category; // fallback
    }
  }

  String get formattedPrice => "Rp ${_formatThousands(price)}";

  static String _formatThousands(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
