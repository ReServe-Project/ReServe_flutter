import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'blog_network_image.dart';

class BlogCard extends StatelessWidget {
  final dynamic blog;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const BlogCard({
    super.key,
    required this.blog,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  String _tryGetTitle() {
    try {
      final t = blog.title;
      if (t is String && t.trim().isNotEmpty) return t;
    } catch (_) {}
    return 'Lorem Ipsum Dolor Sit Amet';
  }

  String? _tryGetImage() {
    for (final field in ['imageUrl', 'image', 'thumbnailUrl', 'thumbnail']) {
      try {
        final v = (blog as dynamic);
        final val = field == 'imageUrl'
            ? v.imageUrl
            : field == 'image'
                ? v.image
                : field == 'thumbnailUrl'
                    ? v.thumbnailUrl
                    : v.thumbnail;
        if (val is String && val.trim().isNotEmpty) return val;
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = _tryGetTitle();
    final imageUrl = _tryGetImage();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onView,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E2DA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + overlays
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: const Color(0xFFF2F2F2),
                          child: BlogNetworkImage(
                            url: imageUrl,
                            fit: BoxFit.cover,
                            empty: const Center(
                              child: Icon(
                                Icons.image,
                                color: Color(0xFF9A9A9A),
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Delete / Edit pills (only if canEdit)
                      if (canEdit) ...[
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _PillButton(
                            label: 'Delete',
                            bg: const Color(0xFFE74C3C),
                            onTap: onDelete,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _PillButton(
                            label: 'Edit',
                            bg: const Color(0xFF2D9CDB),
                            onTap: onEdit,
                          ),
                        ),
                      ],

                      // Arrow button bottom-right
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: InkWell(
                          onTap: onView,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 34,
                            width: 34,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3C416B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.north_east,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter( 
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFA44E22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color bg;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter( // heading (bold)
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
