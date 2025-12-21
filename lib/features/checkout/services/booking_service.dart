// booking_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:reserve_mobile/core/auth/auth_provider.dart';
import 'package:reserve_mobile/core/config/app_config.dart';
import '../models/booking_model.dart';

class BookingService {
  static String get _base => AppConfig.baseUrl;

  // =========================
  // API ENDPOINTS ONLY
  // =========================
  static String _checkoutUrl(int classId) =>
      '$_base/checkout/api/book/$classId/';
  static String get _historyUrl =>
      '$_base/checkout/api/history/';
  static String _deleteUrl(int id) =>
      '$_base/checkout/api/delete/$id/';
  static String _editUrl(int id) =>
      '$_base/checkout/api/edit/$id/';

  static CookieRequest _req(BuildContext context) {
    return context.read<AuthProvider>().request;
  }

  static void _ensureNotHtml(dynamic res, {required String url}) {
    if (res is String && res.contains("<!DOCTYPE")) {
      throw Exception("HTML returned instead of JSON: $url");
    }
  }

  // =========================
  // CHECKOUT
  // =========================
  static Future<void> checkout({
    required BuildContext context,
    required int classId,
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final request = _req(context);
    final url = _checkoutUrl(classId);

    final res = await request.postJson(
      url,
      jsonEncode({
        "full_name": fullName,
        "email": email,
        "phone_number": phoneNumber,
      }),
    );

    _ensureNotHtml(res, url: url);

    if (res is! Map || res["success"] != true) {
      throw Exception(res is Map ? res["error"] : "Checkout failed");
    }
  }

  // =========================
  // FETCH HISTORY
  // =========================
  static Future<List<Booking>> fetchHistory(
      BuildContext context) async {
    final request = _req(context);
    final res = await request.get(_historyUrl);

    _ensureNotHtml(res, url: _historyUrl);

    if (res is! Map || res["bookings"] is! List) {
      throw Exception("Invalid response from $_historyUrl");
    }

    return (res["bookings"] as List)
        .map((e) =>
        Booking.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // =========================
  // DELETE BOOKING
  // =========================
  static Future<void> deleteBooking(
      BuildContext context,
      int bookingId,
      ) async {
    final request = _req(context);
    final url = _deleteUrl(bookingId);

    final res = await request.post(url, {});
    _ensureNotHtml(res, url: url);

    if (res is! Map || res["success"] != true) {
      throw Exception("Delete booking failed");
    }
  }

  // =========================
  // EDIT BOOKING
  // =========================
  static Future<void> editBooking({
    required BuildContext context,
    required int bookingId,
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final request = _req(context);
    final url = _editUrl(bookingId);

    final res = await request.postJson(
      url,
      jsonEncode({
        "full_name": fullName,
        "email": email,
        "phone_number": phoneNumber,
      }),
    );

    _ensureNotHtml(res, url: url);

    if (res is! Map || res["success"] != true) {
      throw Exception(res is Map ? res["error"] : "Edit booking failed");
    }
  }
}
