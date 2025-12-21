import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../../features/auth/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/blog/screens/blog_list_screen.dart';
import '../../features/blog/screens/create_blog_screen.dart';
import '../../features/blog/screens/blog_detail_screen.dart';

import '../../home_search/home/landing_screen.dart';
import '../../home_search/search/classes_search_page.dart';
import '../../personal_goal/screens/PersonalGoal_page.dart';

class AppRouter {
  static const String initialRoute = AppRoutes.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case AppRoutes.blog:
        return MaterialPageRoute(builder: (_) => const BlogListScreen());
      case AppRoutes.createBlog:
        return MaterialPageRoute(builder: (_) => const CreateBlogScreen());
      case AppRoutes.blogDetail:
        final blogId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => BlogDetailScreen(blogId: blogId ?? ''),
        );
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case AppRoutes.classes:
        return MaterialPageRoute(builder: (_) => const ClassesSearchPage());
      case AppRoutes.personalGoals:
        return MaterialPageRoute(builder: (_) => const PersonalGoalsPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
