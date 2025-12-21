import '../config/app_config.dart';

/// Builds URLs targeting the Django image proxy endpoint.
class DjangoImageProxy {
  static String proxyUrl(String originalUrl) {
    final encoded = Uri.encodeComponent(originalUrl);
    return '${AppConfig.baseUrl}/blog/api/proxy-image/?url=$encoded';
  }
}
