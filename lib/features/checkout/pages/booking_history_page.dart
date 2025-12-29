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

  static const Color bgCream = Color(0xFFFFF7ED);
  static const Color cardWhite = Colors.white;
  static const Color titleBrown = Color(0xFF8B4A2B);
  static const Color mutedGray = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);

  static const Color dangerRed = Color(0xFFDC2626);
  static const Color editBlue = Color(0xFF3B82F6);

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

  String _formatDateTimeLikeScreenshot(DateTime dt) {
    final local = dt.toLocal();
    const months = <String>[
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    final day = local.day.toString().padLeft(2, "0");
    final month = months[local.month - 1];
    final year = local.year.toString();

    final hour = local.hour.toString().padLeft(2, "0");
    final minute = local.minute.toString().padLeft(2, "0");

    return "$day $month $year $hour.$minute";
  }

  ButtonStyle _pillStyle({
    required Color bg,
    required Color fg,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      minimumSize: const Size(0, 30),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      bottomNavigationBar: const ReserveNavbar(active: NavItem.history),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final horizontalPad = w < 420 ? 14.0 : 18.0;
            final topPad = w < 420 ? 14.0 : 18.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    topPad,
                    horizontalPad,
                    12,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        "History",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 14),

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

                            final bookings = snapshot.data ?? [];
                            if (bookings.isEmpty) {
                              return const Center(
                                child: Text("You have no booking history."),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.only(bottom: 10),
                              itemCount: bookings.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final b = bookings[index];

                                return Container(
                                  decoration: BoxDecoration(
                                    color: cardWhite,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderGray),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // IMAGE (small + rounded)
                                      FutureBuilder<FitnessClass?>(
                                        future: _fetchClass(context, b.classId),
                                        builder: (context, snap) {
                                          final imageUrl =
                                              snap.data?.imageUrl ?? "";
                                          final fullUrl =
                                              _resolveImageUrl(imageUrl);

                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: fullUrl.isEmpty
                                                ? Container(
                                                    width: 56,
                                                    height: 56,
                                                    color: Colors.grey.shade300,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Image.network(
                                                    fullUrl,
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                  ),
                                          );
                                        },
                                      ),

                                      const SizedBox(width: 12),

                                      // MIDDLE: Title
                                      Expanded(
                                        child: Text(
                                          b.className,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: titleBrown,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatDateTimeLikeScreenshot(
                                                b.bookingDate),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: mutedGray,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          FutureBuilder<FitnessClass?>(
                                            future: _fetchClass(
                                                context, b.classId),
                                            builder: (_, snap) {
                                              final loc =
                                                  (snap.data?.location ?? "");
                                              return Text(
                                                loc,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: mutedGray,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await BookingService
                                                      .deleteBooking(
                                                    context,
                                                    b.id,
                                                  );
                                                  _reload();
                                                },
                                                style: _pillStyle(
                                                  bg: dangerRed,
                                                  fg: Colors.white,
                                                ),
                                                child: const Text("Delete"),
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
                                                style: _pillStyle(
                                                  bg: editBlue,
                                                  fg: Colors.white,
                                                ),
                                                child: const Text("Edit"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.classes,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1F2937),
                            side: const BorderSide(color: borderGray),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text("Explore more classes"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
