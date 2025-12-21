import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../config/app_config.dart';
import '../routes/app_routes.dart';
import 'package:reserve_mobile/features/blog/screens/blog_list_screen.dart';



enum NavItem { home, classes, history, blog, goals, profile }

class ReserveNavbar extends StatelessWidget {
  final NavItem? active;
  const ReserveNavbar({super.key, this.active});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: const Color(0xFFF7EDE3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            _navItem(
              context,
              label: "Home",
              icon: Icons.home_rounded,
              isActive: active == NavItem.home,
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
            ),
            _navItem(
              context,
              label: "Classes",
              icon: Icons.fitness_center_rounded, // barbel
              isActive: active == NavItem.classes,
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.classes),
            ),
            _navItem(
              context,
              label: "History",
              icon: Icons.history_rounded,
              isActive: active == NavItem.history,
              onTap: () => _goTo(context, const HistoryPlaceholder()),
            ),
            _navItem(
              context,
              label: "Blog",
              icon: Icons.image_outlined,
              isActive: active == NavItem.blog,
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.blog),
            ),
            _navItem(
              context,
              label: "Goals",
              icon: Icons.timer_outlined,
              isActive: active == NavItem.goals,
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.personalGoals),
            ),
            _navItem(
              context,
              label: auth.request.loggedIn ? "Profile" : "Login",
              icon: Icons.person_rounded,
              isActive: active == NavItem.profile,
              onTap: () {
  final auth = context.read<AuthProvider>();
  if (auth.request.loggedIn) {
    Navigator.pushReplacementNamed(context, AppRoutes.profile);
  } else {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFF4E4B7A); // your purple
    final inactiveColor = const Color(0xFF9B8E86); // soft brown/grey

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
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

// keep your placeholders (same as yours)
class BlogPlaceholder extends StatelessWidget {
  const BlogPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Blog Module Placeholder")));
  }
}

class PersonalGoalsPlaceholder extends StatelessWidget {
  const PersonalGoalsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Personal Goals Module Placeholder")));
  }
}

class HistoryPlaceholder extends StatelessWidget {
  const HistoryPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("History Module Placeholder")));
  }
}
