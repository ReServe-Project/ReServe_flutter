import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import 'booking_model.dart';
import 'booking_service.dart';
import 'edit_booking_page.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  late BookingService service;
  late Future<List<Booking>> futureBookings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    service = BookingService(
      request: auth.request,
      baseUrl: 'http://127.0.0.1:8000',
    );

    futureBookings = service.fetchBookingHistory();
  }

  void refreshBookings() {
    setState(() {
      futureBookings = service.fetchBookingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: FutureBuilder<List<Booking>>(
        future: futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Text('No bookings found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => refreshBookings(),
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      b.className,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${b.fullName}'),
                        Text('Email: ${b.email}'),
                        Text('Phone: ${b.phoneNumber}'),
                        Text('Status: ${b.paymentStatus}'),
                        Text(
                          'Price: Rp ${b.totalPrice.toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        // =====================
                        // EDIT
                        // =====================
                        if (value == 'edit') {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditBookingPage(booking: b),
                            ),
                          );

                          if (updated == true) {
                            refreshBookings();
                          }
                        }

                        // =====================
                        // DELETE
                        // =====================
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Booking'),
                              content: const Text(
                                'Are you sure you want to delete this booking?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success =
                            await service.deleteBooking(b.id);

                            if (!mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text('Booking deleted successfully'),
                                ),
                              );
                              refreshBookings();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text('Failed to delete booking'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
