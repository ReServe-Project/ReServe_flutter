import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:reserve_mobile/home_search/home/landing_screen.dart';


import 'core/auth/auth_provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/blog/providers/blog_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BlogProvider>(
          create: (_) {
            // This shouldn't be called, but as fallback
            return BlogProvider(client: AuthProvider().request);
          },
          update: (context, authProvider, previousBlogProvider) {
            // Use the authenticated client from AuthProvider
            return BlogProvider(client: authProvider.request);
          },
        ),
        /// 🔐 Django session / cookies
        Provider<CookieRequest>(
          create: (_) => CookieRequest(),
        ),

        /// 🔑 Your existing auth provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReServe',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.initialRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

