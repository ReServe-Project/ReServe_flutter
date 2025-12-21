import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../config/app_config.dart';
import '../routes/app_routes.dart';
import 'package:reserve_mobile/features/checkout/pages/booking_history_page.dart';



enum NavItem { home, classes, blog, goals, history }

class ReserveNavbar extends StatelessWidget {
  final NavItem? active;
  const ReserveNavbar({super.key, this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EDE3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu),
        color: const Color(0xFF3B3B3B),
        iconSize: 26,
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    ),

    const SizedBox(width: 12),
          Image.asset("img/mini-logo.png", height: 34),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _navButton(
                    context,
                    "Home",
                    active: active == NavItem.home,
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                  ),
                  const SizedBox(width: 54),
                  _navButton(
                    context,
                    "Classes",
                    active: active == NavItem.classes,
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.classes),
                  ),
                  const SizedBox(width: 54),
                  _navButton(
                    context,
                    "Blog",
                    active: active == NavItem.blog,
                    onTap: () => _goTo(context, const BlogPlaceholder()),
                  ),
                  const SizedBox(width: 54),
                  _navButton(
                    context,
                    "Personal Goals",
                    active: active == NavItem.goals,
                    onTap: () => _goTo(context, const PersonalGoalsPlaceholder()),
                  ),
                  const SizedBox(width: 54),
                  _navButton(
                    context,
                    "History",
                    active: active == NavItem.history,
                    onTap: () => _goTo(context, const BookingHistoryPage()),
                  ),

                ],
              ),
            ),
          ),

          Consumer<AuthProvider>(
  builder: (context, auth, _) {
    // IF LOGGED IN → LOGOUT
    if (auth.request.loggedIn) {
      return ElevatedButton(
        style: _authButtonStyle(),
        onPressed: () async {
          await auth.logout(baseUrl: AppConfig.baseUrl);

          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        },
        child: const Text('Logout'),
      );
    }

    // IF NOT LOGGED IN → LOGIN
    return ElevatedButton(
      style: _authButtonStyle(),
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.login);
      },
      child: const Text('Login'),
    );
  },
),

        ],
      ),
    );
  }

  Widget _navButton(
    BuildContext context,
    String text, {
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            color: active ? const Color(0xFFE7773A) : const Color(0xFF3B3B3B),
          ),
        ),
      ),
    );
  }

  void _goTo(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => page),
  );
}

}

class BlogPlaceholder extends StatelessWidget {
  const BlogPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Blog Module Placeholder")),
    );
  }
}

class PersonalGoalsPlaceholder extends StatelessWidget {
  const PersonalGoalsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Personal Goals Module Placeholder")),
    );
  }
}



class AccountsPlaceholder extends StatelessWidget {
  const AccountsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Accounts / Login Module Placeholder")),
    );
  }
}

ButtonStyle _authButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF4E4B7A), // purple
    foregroundColor: Colors.white,            // text color
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999), // pill
    ),
    elevation: 0,
  );
}
