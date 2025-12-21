import 'package:flutter/material.dart';
import 'package:reserve_mobile/core/widgets/reserve_navbar.dart';
import 'package:reserve_mobile/home_search/models/fitness_class.dart';
import 'package:reserve_mobile/home_search/services/classes_service.dart';
import 'package:reserve_mobile/core/utils/image_utils.dart';
import 'package:reserve_mobile/features/checkout/pages/checkout_page.dart';

class ClassDetailPage extends StatelessWidget {
  final FitnessClass fitnessClass; // passed from list (may be partial)

  const ClassDetailPage({super.key, required this.fitnessClass});

  @override
  Widget build(BuildContext context) {
    final id = fitnessClass.id;
    if (id == null) {
      // fallback if somehow no id
      return Scaffold(
        backgroundColor: const Color(0xFFFDF3EE),
        bottomNavigationBar: const ReserveNavbar(active: NavItem.classes),
        body: Column(
          children: [
            const Expanded(
              child: Center(child: Text("Invalid class (missing id).")),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3EE),
      bottomNavigationBar: const ReserveNavbar(active: NavItem.classes),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<FitnessClass>(
              future: ClassesService.fetchById(context, id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "Error loading class detail: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final c = snapshot.data ?? fitnessClass;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroImage(c),
                      _content(context, c),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= HERO IMAGE =================
  Widget _heroImage(FitnessClass c) {
    final url = c.imageUrl.trim();

    return SizedBox(
      width: double.infinity,
      height: 380,
      child: url.isNotEmpty
          ? Image.network(
        corsFix(url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackHero(),
      )
          : _fallbackHero(),
    );
  }

  Widget _fallbackHero() {
    return Container(
      color: const Color(0xFFF0E6DE),
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Color(0xFF6B4A36)),
      ),
    );
  }

  // ================= CONTENT =================
  Widget _content(BuildContext context, FitnessClass c) {
    final dt = c.datetime;
    final dateText = (dt == null) ? "-" : _formatDateTime(dt);

    final ownerText =
    (c.owner == null || c.owner!.trim().isEmpty) ? "-" : c.owner!.trim();

    final locText = c.location.trim().isEmpty ? "-" : c.location.trim();
    final descText = c.description.trim().isEmpty ? "-" : c.description.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 40, 60, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.name,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            c.categoryLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B4A36),
            ),
          ),
          const SizedBox(height: 16),

          // PRICE + CHECKOUT BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                c.formattedPrice,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE7773A),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7773A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(
                        classId: c.id!,
                        className: c.name,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Checkout",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _infoChip(Icons.schedule, dateText),
              _infoChip(Icons.place, locText),
              _infoChip(Icons.person, ownerText),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              descText,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.6,
                color: Color(0xFF3B3B3B),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8D8CC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B4A36)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B3B3B),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    final d = days[(dt.weekday - 1).clamp(0, 6)];
    final m = months[(dt.month - 1).clamp(0, 11)];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');

    return "$d, ${dt.day} $m ${dt.year} • $hh:$mm";
  }
}
