import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/blog_model.dart';
import '../services/blog_service.dart';

class BlogProvider extends ChangeNotifier {
  late BlogService _blogService;
  List<Blog> _allBlogs = [];
  List<Blog> _userBlogs = [];
  Blog? _selectedBlog;
  bool _isLoading = false;
  String? _errorMessage;

  BlogProvider({required CookieRequest client}) {
    _blogService = BlogService(client: client);
  }

  // Getters
  List<Blog> get allBlogs => _allBlogs;
  List<Blog> get userBlogs => _userBlogs;
  Blog? get selectedBlog => _selectedBlog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all blogs
  Future<void> fetchAllBlogs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allBlogs = await _blogService.getAllBlogs();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user's own blogs
  Future<void> fetchUserBlogs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userBlogs = await _blogService.getUserBlogs();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a single blog
  Future<void> fetchBlogById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedBlog = await _blogService.getBlogById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new blog
  Future<bool> createBlog({
    required String title,
    required String content,
    String? thumbnail,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBlog = await _blogService.createBlog(
        title: title,
        content: content,
        thumbnail: thumbnail,
      );

      _userBlogs.add(newBlog);
      _allBlogs.add(newBlog);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a blog
  Future<bool> updateBlog({
    required String id,
    required String title,
    required String content,
    String? thumbnail,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedBlog = await _blogService.updateBlog(
        id: id,
        title: title,
        content: content,
        thumbnail: thumbnail,
      );

      // Update in lists
      final allBlogsIndex = _allBlogs.indexWhere((blog) => blog.id == id);
      if (allBlogsIndex != -1) {
        _allBlogs[allBlogsIndex] = updatedBlog;
      }

      final userBlogsIndex = _userBlogs.indexWhere((blog) => blog.id == id);
      if (userBlogsIndex != -1) {
        _userBlogs[userBlogsIndex] = updatedBlog;
      }

      if (_selectedBlog?.id == id) {
        _selectedBlog = updatedBlog;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a blog
  Future<bool> deleteBlog(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _blogService.deleteBlog(id);

      // Remove from lists
      _allBlogs.removeWhere((blog) => blog.id == id);
      _userBlogs.removeWhere((blog) => blog.id == id);

      if (_selectedBlog?.id == id) {
        _selectedBlog = null;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear selected blog
  void clearSelectedBlog() {
    _selectedBlog = null;
    notifyListeners();
  }
}
