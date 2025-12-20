import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Delay 1 frame so context/provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goNext();
    });
  }

  void _goNext() {
    final auth = context.read<AuthProvider>();

    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
