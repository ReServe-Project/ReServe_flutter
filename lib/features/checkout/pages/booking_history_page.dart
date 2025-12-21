import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'edit_booking_page.dart';

import 'package:reserve_mobile/core/widgets/reserve_navbar.dart';
import 'package:reserve_mobile/core/config/app_config.dart';
import 'package:reserve_mobile/core/routes/app_routes.dart';

import 'package:reserve_mobile/home_search/models/fitness_class.dart';
import 'package:reserve_mobile/home_search/services/classes_service.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  late Future<List<Booking>> _future;
  final Map<int, FitnessClass> _classCache = {};

  // 🎨 COLOR PALETTE (matches blog page)
  static const Color bgCream = Color(0xFFFFF7ED);
  static const Color cardWhite = Colors.white;
  static const Color primaryOrange = Color(0xFFF97316);
  static const Color primaryIndigo = Color(0xFF3F3D6B);
  static const Color mutedGray = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _future = BookingService.fetchHistory(context);
  }

  void _reload() {
    setState(() {
      _future = BookingService.fetchHistory(context);
    });
  }

  Future<FitnessClass?> _fetchClass(BuildContext context, int classId) async {
    if (_classCache.containsKey(classId)) {
      return _classCache[classId];
    }
    try {
      final cls = await ClassesService.fetchById(context, classId);
      _classCache[classId] = cls;
      return cls;
    } catch (_) {
      return null;
    }
  }

  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return "";
    if (imageUrl.startsWith("http")) return imageUrl;
    return "${AppConfig.baseUrl}$imageUrl";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,

      bottomNavigationBar: const ReserveNavbar(
        active: NavItem.history,
      ),

      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            margin: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER =================
                const Text(
                  "History",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800, // ✅ heavier bold
                    color: primaryIndigo,
                  ),
                ),

                const SizedBox(height: 30),

                /// ================= CONTENT =================
                Expanded(
                  child: FutureBuilder<List<Booking>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      }

                      final bookings = snapshot.data!;
                      if (bookings.isEmpty) {
                        return const Center(
                          child: Text("You have no booking history."),
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ============ MAIN COLUMN ============
                          Expanded(
                            flex: 3,
                            child: ListView.separated(
                              itemCount: bookings.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                final b = bookings[index];

                                return Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: cardWhite,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderGray),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      /// IMAGE
                                      FutureBuilder<FitnessClass?>(
                                        future:
                                        _fetchClass(context, b.classId),
                                        builder: (context, snap) {
                                          final imageUrl =
                                              snap.data?.imageUrl ?? "";
                                          final fullUrl =
                                          _resolveImageUrl(imageUrl);

                                          return ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            child: fullUrl.isEmpty
                                                ? Container(
                                              width: 120,
                                              height: 90,
                                              color: Colors.grey.shade300,
                                              child: const Center(
                                                child: Text("No Image"),
                                              ),
                                            )
                                                : Image.network(
                                              fullUrl,
                                              width: 120,
                                              height: 90,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(width: 20),

                                      /// TEXT
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.className,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight:
                                                FontWeight.w700, // ✅ stronger
                                                color: primaryOrange,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "${b.fullName} • ${b.phoneNumber}",
                                              style: const TextStyle(
                                                color: mutedGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// RIGHT SIDE
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            b.bookingDate
                                                .toLocal()
                                                .toString()
                                                .substring(0, 16),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: mutedGray,
                                            ),
                                          ),
                                          const SizedBox(height: 6),

                                          FutureBuilder<FitnessClass?>(
                                            future: _fetchClass(
                                                context, b.classId),
                                            builder: (_, snap) {
                                              return Text(
                                                snap.data?.location ?? "",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: mutedGray,
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 12),

                                          Row(
                                            children: [
                                              OutlinedButton(
                                                onPressed: () async {
                                                  await BookingService
                                                      .deleteBooking(
                                                    context,
                                                    b.id,
                                                  );
                                                  _reload();
                                                },
                                                style:
                                                OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                  primaryOrange,
                                                  side: const BorderSide(
                                                    color: primaryOrange,
                                                  ),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                  ),
                                                ),
                                                child:
                                                const Text("Delete"),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          EditBookingPage(
                                                            booking: b,
                                                          ),
                                                    ),
                                                  );
                                                  _reload();
                                                },
                                                style:
                                                ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  primaryIndigo,
                                                  foregroundColor:
                                                  Colors.white, // ✅ white text
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                  ),
                                                ),
                                                child: const Text("Edit"),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 30),

                          /// ============ SIDEBAR ============
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderGray),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/images/track.png",
                                    height: 120,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Check out more classes!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryIndigo,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryIndigo,
                                      foregroundColor:
                                      Colors.white, // ✅ white text
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.classes,
                                      );
                                    },
                                    child:
                                    const Text("Explore more"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
