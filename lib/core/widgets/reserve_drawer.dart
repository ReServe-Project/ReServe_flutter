import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../routes/app_routes.dart';
import '../config/app_config.dart';

/// Simple app drawer used across pages. Kept intentionally small — expand as needed.
class ReserveDrawer extends StatelessWidget {
  const ReserveDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(auth.username ?? 'Guest'),
              accountEmail: null,
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/default_avatar.png'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Home'),
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center_rounded),
              title: const Text('Classes'),
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.classes),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Blog'),
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.blog),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Personal Goals'),
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.personalGoals),
            ),
            const Spacer(),
            Divider(height: 1, color: Colors.grey.shade300),
            auth.isLoggedIn
                ? ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      // perform logout then go to splash/login
                      await context.read<AuthProvider>().logout(baseUrl: AppConfig.baseUrl);
                      Navigator.pushReplacementNamed(context, AppRoutes.splash);
                    },
                  )
                : ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Login'),
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
