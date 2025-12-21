import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/django_image_proxy.dart';

/// A network image tailored for blog thumbnails.
///
/// Why this exists:
/// - On Flutter Web, direct image URLs can fail due to CORS/CORP, mixed-content,
///   redirects-to-login, or cookie/session issues.
/// - Some backends return relative paths like `/media/...`.
///
/// Behavior:
/// 1) Normalize relative URLs against [AppConfig.baseUrl].
/// 2) Try to load directly.
/// 3) If it fails, retry via the Django proxy endpoint.
/// 4) If that fails, show a local placeholder asset.
class BlogNetworkImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Placeholder shown when [url] is null/empty.
  final Widget? empty;

  /// Asset shown when network loading fails.
  final String fallbackAsset;

  const BlogNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.empty,
    this.fallbackAsset = 'assets/images/empty.png',
  });

  String? _normalizeUrl(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // Already absolute.
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) return trimmed;

    // Relative path ("/media/..." or "media/..." etc.)
    final base = Uri.parse(AppConfig.baseUrl);
    final resolved = base.resolve(trimmed);
    return resolved.toString();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizeUrl(url);

    if (normalized == null) {
      return empty ??
          const Center(child: Icon(Icons.image, color: Color(0xFF9A9A9A)));
    }

    Widget image = Image.network(
      normalized,
      fit: fit,
      // Provides graceful UX while loading.
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF2F2F2),
          alignment: Alignment.center,
          child: const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('BlogNetworkImage failed: $normalized ($error)');
        }
        // Retry via Django proxy (server-side fetch avoids CORS/CORP issues).
        final proxied = DjangoImageProxy.proxyUrl(normalized);
        return Image.network(
          proxied,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              // ignore: avoid_print
              print('BlogNetworkImage proxy failed: $proxied ($error)');
            }
            return Image.asset(fallbackAsset, fit: BoxFit.contain);
          },
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
