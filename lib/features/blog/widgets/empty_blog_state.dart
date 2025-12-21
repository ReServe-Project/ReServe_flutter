import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyBlogState extends StatelessWidget {
  final VoidCallback onCreateBlog;

  const EmptyBlogState({super.key, required this.onCreateBlog});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Image.asset(
            'assets/images/empty.png',
            height: 90,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 14),
          Text(
            'No Blogs Found :(',
            style: GoogleFonts.poppins( // heading
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE86C2A),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'Create your own blog now!',
            style: GoogleFonts.inter( // subheading
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8F8F8F),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 26,
            child: ElevatedButton(
              onPressed: onCreateBlog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C416B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '+ Create',
                style: GoogleFonts.inter( 
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
