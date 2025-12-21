import 'package:reserve_mobile/core/config/app_config.dart';

String corsFix(String url) {
  final u = url.trim();
  if (u.isEmpty) return u;

  // Use your own Django backend proxy:
  return "${AppConfig.baseUrl}/api/image-proxy/?url=${Uri.encodeComponent(u)}";
}
