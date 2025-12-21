import 'package:flutter/material.dart';
import 'package:reserve_mobile/home_search/search/classes_search_page.dart';
import 'package:reserve_mobile/core/widgets/reserve_navbar.dart';
import 'package:reserve_mobile/core/widgets/reserve_drawer.dart'; // ✅ ADD THIS

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  // ====== ALL LOCAL IMAGES HERE (from img/ folder) ======
  static const List<_ClassItem> classes = [
    _ClassItem("Yoga", "img/yoga.jpg"),
    _ClassItem("Pilates", "img/pilates.jpg"),
    _ClassItem("Dance", "img/dance.jpg"),
    _ClassItem("Boxing", "img/boxing.jpg"),
    _ClassItem("Muaythai", "img/muaythai.jpg"),
    _ClassItem("Ice Skating", "img/iceskating.jpg"),
  ];

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // ✅ ADD THIS (for opening drawer on web)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ✅ ADD THIS (auto-open drawer once)
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openDrawer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ✅ ADD THIS
      drawer: const ReserveDrawer(), // ✅ ADD THIS
      backgroundColor: const Color(0xFFFDF3EE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ReserveNavbar(active: NavItem.home),
            _heroSection(context),
            _aboutSection(),
            _classesSection(context),
            _readySection(),
          ],
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

  // ================= HERO =================
  Widget _heroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              "img/reserve-logo.png",
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Discover your favorite classes and\nstart exploring today.",
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    _goTo(context, const ClassesSearchPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE7773A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.15),
                  ),
                  child: const Text(
                    "Explore Now!",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= ABOUT (2 images left) =================
  Widget _aboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 30, 40, 10),
      child: Row(
        children: [
          // LEFT: two stacked images
          Expanded(
            child: Column(
              children: [
                _roundedImage("img/what-is-top.jpg", height: 230),
                const SizedBox(height: 18),
                _roundedImage("img/what-is-bottom.jpg", height: 230),
              ],
            ),
          ),
          const SizedBox(width: 40),

          // RIGHT: purple description card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF4B4B7C),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 36,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFEFEFF6),
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "What is ReServe?",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "ReServe is a smart class booking app designed to make "
                    "joining fitness sessions simple, fast, and stress-free.\n\n"
                    "With fitness classes like Pilates, Yoga, and Boxing becoming "
                    "increasingly popular, spots can fill up within minutes. "
                    "ReServe solves this problem by giving users real-time access "
                    "to available classes and studios, allowing them to easily find "
                    "and reserve sessions anytime, anywhere.",
                    style: TextStyle(color: Colors.white, height: 1.5, fontSize: 14.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedImage(String assetPath, {required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // ================= CLASSES (6 cards) =================
  Widget _classesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + gradient-ish line look
          Row(
            children: [
              const Text(
                "Our Classes",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE7A07A), Color(0xFF8D8DBA)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 6 items in a single row (like your web)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: LandingScreen.classes.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: _classCard(c.title, c.assetPath),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 22),
          Center(
            child: ElevatedButton(
              onPressed: () => _goTo(context, const ClassesSearchPage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE7773A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.15),
              ),
              child: const Text("Explore All", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _classCard(String title, String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 260,
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(assetPath, fit: BoxFit.cover),
            // bottom gradient to make text readable
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 12,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(blurRadius: 8, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= READY =================
  Widget _readySection() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "img/ready.png",
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Column(
            children: const [
              Text(
                "Are you ready to serve?",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text(
                "Join Us Now!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
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
  const _ClassItem(this.title, this.assetPath);
}
