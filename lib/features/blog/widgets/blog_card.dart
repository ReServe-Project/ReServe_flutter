import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import '../../../core/utils/django_image_proxy.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final bool canEdit;

  const BlogCard({
    super.key,
    required this.blog,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: (blog.thumbnail != null && blog.thumbnail!.isNotEmpty)
                      ? _ProxyableThumbnail(url: blog.thumbnail!)
                      : Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                              size: 40,
                            ),
                          ),
                        ),
                ),
              ),
              // Action buttons overlay
              Positioned(
                top: 8,
                right: 8,
                left: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    if (canEdit)
                      Row(
                        children: [
                          // Delete button
                          FloatingActionButton.small(
                            onPressed: onDelete,
                            backgroundColor: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit button
                          FloatingActionButton.small(
                            onPressed: onEdit,
                            backgroundColor: Colors.blue,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
              // View button overlay (bottom right)
              Positioned(
                bottom: 8,
                right: 8,
                child: FloatingActionButton.small(
                  onPressed: onView,
                  backgroundColor: const Color(0xFF2D3E50),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5C3D2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  blog.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProxyableThumbnail extends StatelessWidget {
  final String url;

  const _ProxyableThumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          DjangoImageProxy.proxyUrl(url),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 40,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
