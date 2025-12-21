import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'booking_model.dart';

class BookingService {
  final CookieRequest request;
  final String baseUrl;

  BookingService({
    required this.request,
    required this.baseUrl,
  });

  // =========================
  // FETCH BOOKING HISTORY
  // =========================
  Future<List<Booking>> fetchBookingHistory() async {
    final response = await request.get(
      '$baseUrl/checkout/api/history/',
    );

    if (response['success'] != true) {
      throw Exception('Failed to load booking history');
    }

    final List data = response['bookings'];
    return data.map((e) => Booking.fromJson(e)).toList();
  }

  // =========================
  // DELETE BOOKING
  // =========================
  Future<bool> deleteBooking(int bookingId) async {
    final response = await request.post(
      '$baseUrl/checkout/delete/$bookingId/',
      {},
    );

    return response['success'] == true;
  }

  // =========================
  // EDIT BOOKING
  // =========================
  Future<bool> editBooking({
    required int bookingId,
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final response = await request.post(
      '$baseUrl/checkout/edit/$bookingId/',
      {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
      },
    );

    return response['success'] == true;
  }
}
