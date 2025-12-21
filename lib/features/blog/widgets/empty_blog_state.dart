import 'package:flutter/material.dart';

class EmptyBlogState extends StatelessWidget {
  final VoidCallback onCreateBlog;

  const EmptyBlogState({super.key, required this.onCreateBlog});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Calendar emoji/icon
          Text('📅', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            'No Blogs Found :(',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE67E22),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your own blog now!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateBlog,
            icon: const Icon(Icons.add),
            label: const Text('Create Blog'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5998),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
