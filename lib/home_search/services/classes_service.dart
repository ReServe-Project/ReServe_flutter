import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:reserve_mobile/core/auth/auth_provider.dart';
import 'package:reserve_mobile/core/config/app_config.dart';
import 'package:reserve_mobile/home_search/models/fitness_class.dart';

class ClassesService {
  static String get _base => AppConfig.baseUrl;

  static String get _listUrl => '$_base/api/classes/';
  static String get _createUrl => '$_base/api/classes/create/';
  static String _updateUrl(int id) => '$_base/api/classes/$id/update/';
  static String _deleteUrl(int id) => '$_base/api/classes/$id/delete/';

  static CookieRequest _req(BuildContext context) {
    return context.read<AuthProvider>().request;
  }

  static void _ensureNotHtml(dynamic res, {required String url}) {
    if (res is String && res.contains("<!DOCTYPE")) {
      throw Exception("Endpoint returned HTML (not JSON): $url");
    }
  }

  static Map<String, String> _toFormData(Map<String, dynamic> data) {
    return data.map((k, v) => MapEntry(k, (v ?? "").toString()));
  }

  static Future<List<FitnessClass>> fetchAll(BuildContext context) async {
    final request = _req(context);
    final res = await request.get(_listUrl);
    _ensureNotHtml(res, url: _listUrl);

    if (res is! List) {
      throw Exception("Invalid response from $_listUrl (expected List)");
    }

    return res
        .map((e) => FitnessClass.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<FitnessClass> fetchById(BuildContext context, int id) async {
  final request = _req(context);
  final url = '$_base/api/classes/$id/'; // ✅ your detail endpoint
  final res = await request.get(url);
  _ensureNotHtml(res, url: url);

  if (res is Map) {
    return FitnessClass.fromJson(Map<String, dynamic>.from(res));
  }
  throw Exception("Invalid response from $url (expected Map)");
}


  static Future<FitnessClass> create({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    final request = _req(context);
    final res = await request.post(_createUrl, _toFormData(data));
    _ensureNotHtml(res, url: _createUrl);

    if (res is Map && res["data"] is Map) {
      return FitnessClass.fromJson(Map<String, dynamic>.from(res["data"]));
    }
    if (res is Map) {
      return FitnessClass.fromJson(Map<String, dynamic>.from(res));
    }

    throw Exception("Invalid response from $_createUrl (expected Map)");
  }

  static Future<FitnessClass> update({
    required BuildContext context,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final request = _req(context);
    final url = _updateUrl(id);

    final res = await request.post(url, _toFormData(data));
    _ensureNotHtml(res, url: url);

    if (res is Map && res["data"] is Map) {
      return FitnessClass.fromJson(Map<String, dynamic>.from(res["data"]));
    }
    if (res is Map) {
      return FitnessClass.fromJson(Map<String, dynamic>.from(res));
    }

    throw Exception("Invalid response from $url (expected Map)");
  }

  static Future<void> delete({
    required BuildContext context,
    required int id,
  }) async {
    final request = _req(context);
    final url = _deleteUrl(id);

    final res = await request.post(url, {});
    _ensureNotHtml(res, url: url);
  }
}
