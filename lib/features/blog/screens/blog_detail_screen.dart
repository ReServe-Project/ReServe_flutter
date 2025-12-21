import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blog_provider.dart';
import '../../../core/utils/django_image_proxy.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  @override
  void initState() {
    super.initState();
    _fetchBlog();
  }

  void _fetchBlog() {
    context.read<BlogProvider>().fetchBlogById(widget.blogId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.read<BlogProvider>().clearSelectedBlog();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<BlogProvider>(
        builder: (context, blogProvider, _) {
          if (blogProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final blog = blogProvider.selectedBlog;

          if (blog == null) {
            return const Center(child: Text('Blog not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                if (blog.thumbnail != null && blog.thumbnail!.isNotEmpty)
                  _ProxyableNetworkImage(
                    url: blog.thumbnail!,
                    width: double.infinity,
                    height: 300,
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                        size: 60,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        blog.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3D2E),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Metadata
                      Row(
                        children: [
                          const Text(
                            'By ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            'username',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            blog.createdAt.toString().split(' ')[0],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(height: 1, color: Colors.grey),
                      const SizedBox(height: 20),

                      // Content
                      Text(
                        blog.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProxyableNetworkImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const _ProxyableNetworkImage({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Retry via Django proxy.
        return Image.network(
          DjangoImageProxy.proxyUrl(url),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 60,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
