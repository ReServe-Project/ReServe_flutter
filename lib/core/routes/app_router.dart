import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../../features/auth/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/profile/profile_page.dart';

import '../../home_search/home/landing_screen.dart';
import '../../home_search/search/classes_search_page.dart';
import '../widgets/reserve_navbar.dart'; 

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
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case AppRoutes.classes:
        return MaterialPageRoute(builder: (_) => const ClassesSearchPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
