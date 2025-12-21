import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../../core/config/app_config.dart';
import '../models/blog_model.dart';

class BlogService {
  final CookieRequest client;
  final String baseUrl;

  /// IMPORTANT: `baseUrl` must exactly match the host used during login.
  ///
  /// Session cookies are scoped per-host, so logging in to `localhost` but
  /// posting to `127.0.0.1` will result in *no cookies being sent* and Django
  /// treating the request as anonymous.
  BlogService({required this.client, String? baseUrl})
    : baseUrl = baseUrl ?? AppConfig.baseUrl;

  void _requireLogin(String action) {
    if (!client.loggedIn) {
      throw Exception(
        'Not logged in. Please login before trying to $action. '
        '(No session cookie will be sent to $baseUrl)',
      );
    }
  }

  /// Fetch all blogs
  Future<List<Blog>> getAllBlogs() async {
    try {
      final response = await client.get('$baseUrl/blog/api/blogs/');

      // Check if response is an error
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (response is String) {
        final List<dynamic> data = jsonDecode(response);
        return data.map((blog) => Blog.fromJson(blog)).toList();
      } else {
        final List<dynamic> data = response;
        return data.map((blog) => Blog.fromJson(blog)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load blogs: $e');
    }
  }

  /// Fetch user's own blogs
  Future<List<Blog>> getUserBlogs() async {
    try {
      final response = await client.get('$baseUrl/blog/api/user-blogs/');

      // Check if response is an error
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (response is String) {
        final List<dynamic> data = jsonDecode(response);
        return data.map((blog) => Blog.fromJson(blog)).toList();
      } else {
        final List<dynamic> data = response;
        return data.map((blog) => Blog.fromJson(blog)).toList();
      }
    } catch (e) {
      throw Exception('Failed to load user blogs: $e');
    }
  }

  /// Fetch a single blog by ID
  Future<Blog> getBlogById(String id) async {
    try {
      final response = await client.get('$baseUrl/blog/api/blogs/$id/');

      // Check if response is an error
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (response is String) {
        final data = jsonDecode(response);
        return Blog.fromJson(data);
      } else {
        return Blog.fromJson(response);
      }
    } catch (e) {
      throw Exception('Failed to load blog: $e');
    }
  }

  /// Create a new blog
  Future<Blog> createBlog({
    required String title,
    required String content,
    String? thumbnail,
  }) async {
    try {
      _requireLogin('create a blog');
      final response = await client.post('$baseUrl/blog/api/blogs/', {
        'title': title,
        'content': content,
        if (thumbnail != null) 'thumbnail': thumbnail,
      });

      // Check if response is an error
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (response is String) {
        final data = jsonDecode(response);
        if (data is Map && data.containsKey('error')) {
          throw Exception(data['error']);
        }
        return Blog.fromJson(data);
      } else {
        return Blog.fromJson(response);
      }
    } catch (e) {
      throw Exception('Failed to create blog: $e');
    }
  }

  /// Update an existing blog
  Future<Blog> updateBlog({
    required String id,
    required String title,
    required String content,
    String? thumbnail,
  }) async {
    try {
      _requireLogin('update a blog');
      final response = await client.post('$baseUrl/blog/api/blogs/$id/', {
        'title': title,
        'content': content,
        if (thumbnail != null) 'thumbnail': thumbnail,
      });

      // Check if response is an error
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (response is String) {
        final data = jsonDecode(response);
        if (data is Map && data.containsKey('error')) {
          throw Exception(data['error']);
        }
        return Blog.fromJson(data);
      } else {
        return Blog.fromJson(response);
      }
    } catch (e) {
      throw Exception('Failed to update blog: $e');
    }
  }

  /// Delete a blog
  Future<void> deleteBlog(String id) async {
    try {
      _requireLogin('delete a blog');
      final response = await client.post('$baseUrl/blog/api/blogs/$id/', {
        '_method': 'DELETE',
      });

      // Some backends return 204 (no body) while others return JSON.
      // If we do get a JSON error payload, surface it.
      if (response is Map && response.containsKey('error')) {
        throw Exception(response['error']);
      }
    } catch (e) {
      throw Exception('Failed to delete blog: $e');
    }
  }
}
