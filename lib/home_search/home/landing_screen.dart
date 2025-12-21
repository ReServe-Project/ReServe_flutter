import 'package:flutter/material.dart';
import 'package:reserve_mobile/home_search/search/classes_search_page.dart';
import 'package:reserve_mobile/core/widgets/reserve_navbar.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  // ====== ALL LOCAL IMAGES HERE (from img/ folder) ======
  static const List<_ClassItem> classes = [
    _ClassItem("Dance", "img/dance.jpg", Icons.music_note_rounded),
    _ClassItem("Pilates", "img/pilates.jpg", Icons.self_improvement_rounded),
    _ClassItem("Yoga", "img/yoga.jpg", Icons.spa_rounded),
    _ClassItem("Boxing", "img/boxing.jpg", Icons.sports_mma_rounded),
    _ClassItem("Muaythai", "img/muaythai.jpg", Icons.sports_kabaddi_rounded),
    _ClassItem("Ice Skating", "img/iceskating.jpg", Icons.ac_unit_rounded),
  ];

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3EE),
      bottomNavigationBar: const ReserveNavbar(active: NavItem.home),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _heroSection(context), // <-- land.png at the top
              const SizedBox(height: 14),
              _categorySection(context),
              const SizedBox(height: 18),
              _classesSection(context),
              const SizedBox(height: 18),
              _featureSection(),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _goTo(BuildContext context, Widget page) {
    // If you click Home while already on Home, just do nothing.
    if (page.runtimeType == LandingScreen && ModalRoute.of(context)?.isCurrent == true) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ================= HERO (TOP IMAGE LIKE EXAMPLE) =================
  Widget _heroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.asset(
          "img/land.png",
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ================= "Which class to book today?" (ICON PER SPORT) =================
  Widget _categorySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Which class to book today?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: LandingScreen.classes.map((c) {
              return _categoryCard(
                title: c.title,
                icon: c.icon,
                onTap: () => _goTo(context, ClassesSearchPage(initialCategory: c.title)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF3B3B6D)),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2B2B2B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CLASS CAROUSEL (USE YOUR CLASS IMAGES) =================
  Widget _classesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // gradient divider
          Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [Color(0xFFE7A07A), Color(0xFF8D8DBA)],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: LandingScreen.classes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final c = LandingScreen.classes[i];
                return _miniClassCard(c.title, c.assetPath);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniClassCard(String title, String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 120,
        height: 170,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(assetPath, fit: BoxFit.cover),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.60),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FEATURE CARDS (DESCRIPTIONS INCLUDED) =================
  Widget _featureSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: const [
                _FeatureCard(
                  title: "Various Blogs",
                  body:
                      "Read real stories, share your own, and explore ideas from the community.",
                  bg: Color(0xFFF9F2E8),
                  titleColor: Color(0xFF2B2B2B),
                  bodyColor: Color(0xFF2B2B2B),
                ),
                SizedBox(height: 12),
                _FeatureCard(
                  title: "Trusted Reviews",
                  body: "Explore ratings and feedback from verified experiences.",
                  bg: Color(0xFFE7773A),
                  titleColor: Colors.white,
                  bodyColor: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _FeatureCard(
              title: "Setting Goals!",
              body:
                  "Set goals you can actually follow through on. Create a target, add a timeline, and check your progress regularly — so you don’t lose direction.",
              bg: Color(0xFF4B4B7C),
              titleColor: Colors.white,
              bodyColor: Colors.white,
              tall: true,
            ),
          ),
        ],
      ),
    );
  }

  
}

// ================= FEATURE CARD WIDGET =================
class _FeatureCard extends StatelessWidget {
  final String title;
  final String body;
  final Color bg;
  final Color titleColor;
  final Color bodyColor;
  final bool tall;

  const _FeatureCard({
    required this.title,
    required this.body,
    required this.bg,
    required this.titleColor,
    required this.bodyColor,
    this.tall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      constraints: tall ? const BoxConstraints(minHeight: 190) : null,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 12.2,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: bodyColor.withOpacity(0.95),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SIMPLE DATA MODEL =================
class _ClassItem {
  final String title;
  final String assetPath;
  final IconData icon;
  const _ClassItem(this.title, this.assetPath, this.icon);
}
