import 'package:flutter/material.dart';

import 'package:reserve_mobile/home_search/home/landing_screen.dart';
import 'package:reserve_mobile/home_search/search/classes_search_page.dart';
import 'package:reserve_mobile/core/widgets/reserve_navbar.dart'; 
import 'package:reserve_mobile/core/routes/app_routes.dart';


class ReserveDrawer extends StatelessWidget {
  const ReserveDrawer({super.key});

  void _goTo(BuildContext context, Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Row(
                children: [
                  Image.asset("img/mini-logo.png", height: 30),
                  const SizedBox(width: 10),
                  const Text(
                    "ReServe",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6B4A36),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text("Home"),
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center_rounded),
              title: const Text("Classes"),
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.classes),
            ),
            ListTile(
              leading: const Icon(Icons.article_rounded),
              title: const Text("Blog"),
              onTap: () => _goTo(context, const BlogPlaceholder()),
            ),
            ListTile(
              leading: const Icon(Icons.flag_rounded),
              title: const Text("Personal Goals"),
              onTap: () => _goTo(context, const PersonalGoalsPlaceholder()),
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text("History"),
              onTap: () => _goTo(context, const HistoryPlaceholder()),
            ),

            const Spacer(),
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goTo(context, const AccountsPlaceholder()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B4B7C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
