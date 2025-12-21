import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reserve_mobile/core/auth/auth_provider.dart';
import 'package:reserve_mobile/core/widgets/reserve_navbar.dart';

import 'package:reserve_mobile/home_search/models/fitness_class.dart';
import 'package:reserve_mobile/home_search/services/classes_service.dart';
import 'package:reserve_mobile/home_search/search/class_detail_page.dart';
import 'package:reserve_mobile/home_search/search/class_form_page.dart';
import 'package:reserve_mobile/home_search/widgets/class_card.dart';


class ClassesSearchPage extends StatefulWidget {
  final String? initialCategory; // <-- added

  const ClassesSearchPage({super.key, this.initialCategory}); // <-- updated

  @override
  State<ClassesSearchPage> createState() => _ClassesSearchPageState();
}


class _ClassesSearchPageState extends State<ClassesSearchPage> {
  // ================== FILTER STATE ==================
  String selectedCategory = "All Classes";

  // ================== CATEGORIES (UI labels) ==================
  final List<String> categories = const [
    "All Classes",
    "Yoga",
    "Pilates",
    "Dance",
    "Boxing",
    "Muaythai",
    "Ice Skating",
  ];

  // ================== DATA SOURCE ==================
  Future<List<FitnessClass>>? _classesFuture;

  // store role info so other methods (outside build) can use it
  bool _isInstructor = false;
  String _currentUser = "";

  @override
  void initState() {
  super.initState();
  // ✅ safe: no provider call, just set initial filter if provided
  final initial = widget.initialCategory;
  if (initial != null && categories.contains(initial)) {
    selectedCategory = initial;
  }
}


  // ---------- Helpers ----------
  String _labelToCode(String label) {
    switch (label) {
      case "Yoga":
        return "yoga";
      case "Pilates":
        return "pilates";
      case "Dance":
        return "dance";
      case "Boxing":
        return "boxing";
      case "Muaythai":
        return "muaythai";
      case "Ice Skating":
        return "ice-skating";
      default:
        return "";
    }
  }

  String _codeToLabel(String code) {
    switch (code) {
      case "yoga":
        return "Yoga";
      case "pilates":
        return "Pilates";
      case "dance":
        return "Dance";
      case "boxing":
        return "Boxing";
      case "muaythai":
        return "Muaythai";
      case "ice-skating":
        return "Ice Skating";
      default:
        return code;
    }
  }

  List<FitnessClass> _applyFilter(List<FitnessClass> all) {
    if (selectedCategory == "All Classes") return all;
    final code = _labelToCode(selectedCategory);
    return all.where((c) => c.category == code).toList();
  }

  void _goToDetails(FitnessClass c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassDetailPage(fitnessClass: c),
      ),
    );
  }

  void _refreshClasses() {
  setState(() {
    _classesFuture = ClassesService.fetchAll(context);
  });
}


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _isInstructor = auth.isInstructor;
    _currentUser = auth.username ?? "";

    // ✅ initialize future safely HERE (only once)
    _classesFuture ??= ClassesService.fetchAll(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3EE),
      bottomNavigationBar: const ReserveNavbar(active: NavItem.classes),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _heroHeader(),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Center(child: _filterPill()),
                  ),
                  const SizedBox(height: 12),
                  _createButtonRow(context, _isInstructor), // instructor-only
                  FutureBuilder<List<FitnessClass>>(
                    future: _classesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(60, 40, 60, 30),
                          child: Text(
                            "Error loading classes: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final all = snapshot.data ?? const <FitnessClass>[];
                      final products = _applyFilter(all);

                      return _productsGrid(products);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HERO HEADER =================
  Widget _heroHeader() {
    return SizedBox(
      width: double.infinity,
      height: 330,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "img/hero-classes.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.18)),
          ),
          const Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Our Classes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterPill() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 980),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < categories.length; i++) ...[
              _filterButton(categories[i]),
              if (i == 0) ...[
                const SizedBox(width: 14),
                Container(
                  width: 1.5,
                  height: 30,
                  color: const Color(0xFFB9A79A),
                ),
                const SizedBox(width: 14),
              ] else if (i != categories.length - 1) ...[
                const SizedBox(width: 12),
              ],
            ]
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String label) {
    final bool active = selectedCategory == label;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6B4A36) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFF6B4A36),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF6B4A36),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _createButtonRow(BuildContext context, bool isInstructor) {
  if (!isInstructor) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(top: 24), // tighter spacing under pill
    child: Center(
      child: ElevatedButton(
        onPressed: () async {
          final created = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ClassFormPage(),
    ),
  );
          if (created == true) {
    setState(() {
      _classesFuture = ClassesService.fetchAll(context);
    });
  }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B4A36),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "+ Create Class",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );
}


  // ================= PRODUCTS GRID =================
  Widget _productsGrid(List<FitnessClass> products) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 34, 60, 30),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 4;
          if (constraints.maxWidth < 1100) crossAxisCount = 3;
          if (constraints.maxWidth < 800) crossAxisCount = 2;
          if (constraints.maxWidth < 520) crossAxisCount = 1;

          if (products.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No classes found.",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B4A36),
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 26,
              mainAxisSpacing: 26,
              mainAxisExtent: 290,
            ),
            itemBuilder: (context, index) {
  final c = products[index];
  return ClassCard(
    c: c,
    isInstructor: _isInstructor,
    currentUser: _currentUser,
    onChanged: () {
      setState(() {
        _classesFuture = ClassesService.fetchAll(context);
      });
    },
  );
},

          );
        },
      ),
    );
  }

  Widget _productCard(FitnessClass c) {
    final bool canManage = _isInstructor && c.owner == _currentUser;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: (c.imageUrl.isNotEmpty)
                ? Image.network(
                    c.imageUrl,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: const Color(0xFFF0E6DE),
                      child: const Icon(Icons.image_not_supported),
                    ),
                  )
                : Container(
                    height: 150,
                    color: const Color(0xFFF0E6DE),
                    child: const Icon(Icons.image),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              c.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Rp ${c.price}",
              style: const TextStyle(color: Color(0xFF5C5C5C)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              _codeToLabel(c.category),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B4A36),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: canManage
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _goToDetails(c),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE7773A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Details",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: edit
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF6B4A36), width: 1.5),
                            foregroundColor: const Color(0xFF6B4A36),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Edit", style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final confirm = await _confirmDelete(context);
                            if (confirm != true) return;
                            // TODO: delete
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 1.5),
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () => _goToDetails(c),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7773A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Details", style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Class"),
          content: const Text("Are you sure you want to delete this class?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
