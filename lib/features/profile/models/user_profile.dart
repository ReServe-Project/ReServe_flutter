class UserProfile {
  final String? rsId;
  final String username;
  final String displayName;
  final String? handle;
  final String? role;
  final int? heightCm;
  final double? weightKg;
  final String? lastLoginIso;

  UserProfile({
    required this.rsId,
    required this.username,
    required this.displayName,
    required this.handle,
    required this.role,
    required this.heightCm,
    required this.weightKg,
    required this.lastLoginIso,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      rsId: json['rs_id']?.toString(),
      username: json['username']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      handle: json['handle']?.toString(),
      role: json['role']?.toString(),
      heightCm: json['height_cm'] is int ? json['height_cm'] as int : int.tryParse(json['height_cm']?.toString() ?? ''),
      weightKg: json['weight_kg'] is num ? (json['weight_kg'] as num).toDouble() : double.tryParse(json['weight_kg']?.toString() ?? ''),
      lastLoginIso: json['last_login']?.toString(),
    );
  }
}
