import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- added
import '../providers/blog_provider.dart';
import '../widgets/blog_card.dart';
import '../widgets/empty_blog_state.dart';
import '../widgets/blog_network_image.dart';
import 'blog_detail_screen.dart';
import 'create_blog_screen.dart';
import 'edit_blog_screen.dart';
import '../../../core/auth/auth_provider.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAllBlogs();
  }

  void _fetchAllBlogs() {
    context.read<BlogProvider>().fetchAllBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ===== Header (matches screenshot) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6E9D8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/R_logo.png',
                        height: 95,
                        width: 95,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  height: 1,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Share Your\n',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2D3E50),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Blogs',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFE86C2A),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' With Us!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2D3E50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 26,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const CreateBlogScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3C416B),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  '+ Create Blog',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                ),
              ),

              const SizedBox(height: 24),

              // ===== Tabs (pill + orange divider like screenshot) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabPill(
                        label: 'All Blogs',
                        isSelected: _selectedTabIndex == 0,
                        onTap: () {
                          setState(() => _selectedTabIndex = 0);
                          context.read<BlogProvider>().fetchAllBlogs();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 2,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE86C2A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TabPill(
                        label: 'My Blogs',
                        isSelected: _selectedTabIndex == 1,
                        onTap: () {
                          setState(() => _selectedTabIndex = 1);
                          context.read<BlogProvider>().fetchUserBlogs();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== Content =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<BlogProvider>(
                  builder: (context, blogProvider, _) {
                    if (blogProvider.isLoading) {
                      return const SizedBox(
                        height: 280,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final blogs = _selectedTabIndex == 0
                        ? blogProvider.allBlogs
                        : blogProvider.userBlogs;

                    if (blogs.isEmpty) {
                      return EmptyBlogState(
                        onCreateBlog: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateBlogScreen(),
                            ),
                          );
                        },
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedTabIndex == 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Your Blogs',
                              style: GoogleFonts.poppins( // heading
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2D3E50),
                              ),
                            ),
                          ),

                        if (_selectedTabIndex == 0) ...[
                          // "Featured" row (shows up to 4 blogs)
                          if (blogs.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: SizedBox(
                                height: 120,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      blogs.length >= 4 ? 4 : blogs.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final blog = blogs[index];
                                    return _FeaturedMiniCard(blog: blog);
                                  },
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Explore More Blogs',
                              style: GoogleFonts.poppins( // <-- heading
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2D3E50),
                              ),
                            ),
                          ),
                        ],

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: blogs.length,
                          itemBuilder: (context, index) {
                            final blog = blogs[index];
                            final username =
                                context.read<AuthProvider>().username;
                            final canEdit = username != null &&
                                username.isNotEmpty &&
                                (blog as dynamic).userId == username;

                            return BlogCard(
                              blog: blog,
                              canEdit: canEdit,
                              onEdit: () {
                                if (!canEdit) return;
                                Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditBlogScreen(blog: blog),
                                      ),
                                    )
                                    .then((updated) {
                                      if (updated == true && context.mounted) {
                                        final blogProvider =
                                            context.read<BlogProvider>();
                                        blogProvider.fetchAllBlogs();
                                        blogProvider.fetchUserBlogs();
                                      }
                                    });
                              },
                              onDelete: () {
                                if (!canEdit) return;
                                _showDeleteConfirmation(
                                  context,
                                  (blog as dynamic).id as String,
                                );
                              },
                              onView: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BlogDetailScreen(
                                      blogId: (blog as dynamic).id as String,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String blogId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Blog',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700), // heading
        ),
        content: Text(
          'Are you sure you want to delete this blog?',
          style: GoogleFonts.inter(), // subheading/body
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () async {
              final blogProvider = context.read<BlogProvider>();
              final ok = await blogProvider.deleteBlog(blogId);

              if (!context.mounted) return;
              Navigator.pop(context);

              if (ok) {
                if (_selectedTabIndex == 0) {
                  await blogProvider.fetchAllBlogs();
                } else {
                  await blogProvider.fetchUserBlogs();
                }

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Blog deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      blogProvider.errorMessage ??
                          'Failed to delete blog. Please try again.',
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter( 
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE86C2A) : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter( //
            color: isSelected ? Colors.white : const Color(0xFFB4B4B4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FeaturedMiniCard extends StatelessWidget {
  final dynamic blog;

  const _FeaturedMiniCard({required this.blog});

  String _tryGetTitle() {
    try {
      final t = blog.title;
      if (t is String && t.trim().isNotEmpty) return t;
    } catch (_) {}
    return 'Untitled';
  }

  String _tryGetContent() {
    try {
      final c = blog.content; 
      if (c is String && c.trim().isNotEmpty) return c.trim();
    } catch (_) {}
    return '';
  }

  String? _tryGetImage() {
    // Tries common field names without breaking if missing.
    for (final field in ['thumbnail', 'thumbnailUrl', 'imageUrl', 'image']) {
      try {
        final v = (blog as dynamic);
        final val = field == 'thumbnail'
            ? v.thumbnail
            : field == 'thumbnailUrl'
                ? v.thumbnailUrl
                : field == 'imageUrl'
                    ? v.imageUrl
                    : v.image;
        if (val is String && val.trim().isNotEmpty) return val;
      } catch (_) {}
    }
    return null;
  }

  String _snippet(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final title = _tryGetTitle();
    final content = _snippet(_tryGetContent());
    final imageUrl = _tryGetImage();

    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height:98,
              width: 110,
              color: const Color(0xFFF2F2F2),
              child: BlogNetworkImage(
                url: imageUrl,
                fit: BoxFit.cover,
                empty: const Icon(Icons.image, color: Color(0xFF9A9A9A)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFA44E22),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content.isEmpty ? ' ' : content,
                  maxLines: 3, 
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF7A7A7A),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

