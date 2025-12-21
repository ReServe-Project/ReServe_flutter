import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../../core/config/app_config.dart';
import '../models/PersonalGoal.dart';

class PersonalGoalsCalendarData {
  final int year;
  final int month;
  final String monthName;

  /// Same structure as Django calendar.monthcalendar():
  /// List of weeks; each week is 7 ints (0 means blank).
  final List<List<int>> calendarGrid;

  /// Map "YYYY-MM-DD" -> list of goals (each goal has id/title/is_completed only)
  final Map<String, List<Map<String, dynamic>>> goalsByDateRaw;

  PersonalGoalsCalendarData({
    required this.year,
    required this.month,
    required this.monthName,
    required this.calendarGrid,
    required this.goalsByDateRaw,
  });

  List<PersonalGoal> flattenMonthlyGoalsSorted() {
    final goals = <PersonalGoal>[];

    final keys = goalsByDateRaw.keys.toList()..sort(); // sort by date string
    for (final dateStr in keys) {
      final items = goalsByDateRaw[dateStr] ?? [];
      for (final item in items) {
        goals.add(PersonalGoal.fromCalendarItem(item, dateStr));
      }
    }

    // stable-ish sort: by date then id
    goals.sort((a, b) {
      final d = a.date.compareTo(b.date);
      if (d != 0) return d;
      return a.id.compareTo(b.id);
    });

    return goals;
  }
}

class PersonalGoalsApi {
  static String _base(String path) => '${AppConfig.baseUrl}$path';

  static Future<PersonalGoalsCalendarData> fetchCalendar(
    CookieRequest request,
    int year,
    int month,
  ) async {
    final url = _base('/goals/calendar_data/$year/$month/');
    final response = await request.get(url);

    if (response is Map && response['success'] == true) {
      final data = response['data'];
      if (data is Map) {
        final cal = (data['calendar'] as List)
            .map((week) => (week as List).map((d) => (d as num).toInt()).toList())
            .toList();

        final goalsMap = <String, List<Map<String, dynamic>>>{};
        final rawGoals = data['goals'];

        if (rawGoals is Map) {
          rawGoals.forEach((k, v) {
            if (k is String && v is List) {
              goalsMap[k] = v.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            }
          });
        }

        return PersonalGoalsCalendarData(
          year: (data['year'] as num).toInt(),
          month: (data['month'] as num).toInt(),
          monthName: (data['month_name'] ?? '') as String,
          calendarGrid: cal,
          goalsByDateRaw: goalsMap,
        );
      }
    }

    throw Exception('Failed to fetch calendar: ${jsonEncode(response)}');
  }

  static Future<List<PersonalGoal>> fetchGoalsForDate(
    CookieRequest request, {
    required int year,
    required int month,
    required int day,
  }) async {
    final url = _base('/goals/goals/$year/$month/$day/');
    final response = await request.get(url);

    if (response is Map && response['success'] == true) {
      final goals = response['goals'];
      if (goals is List) {
        return goals
            .map((e) => PersonalGoal.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return <PersonalGoal>[];
    }

    throw Exception('Failed to fetch goals: ${jsonEncode(response)}');
  }

  /// Send as form POST.
  /// CookieRequest handles CSRF automatically
  static Future<void> addGoal(
    CookieRequest request, {
    required String title,
    required String dateStr, // YYYY-MM-DD
  }) async {
    final url = _base('/goals/add_goal/');
    
    try {
      // Ensure we're sending JSON content-type
      final response = await request.post(
        url,
        {'title': title, 'date': dateStr},
      );

      // Handle HTML response (error page from Django)
      if (response is String) {
        // Try to parse as JSON first (in case it's JSON-stringified)
        try {
          final decoded = jsonDecode(response);
          if (decoded is Map) {
            if (decoded['success'] == true) {
              return; // Success
            }
            final error = decoded['error'] ?? decoded['message'] ?? 'Failed to add goal';
            throw Exception(error.toString());
          }
        } catch (e) {
          // If JSON parsing fails, treat as HTML error
          if (response.contains('<!DOCTYPE') || response.contains('<html')) {
            // Extract error from HTML
            final match = RegExp(r'<h1>(.*?)</h1>').firstMatch(response);
            final errorMsg = match?.group(1) ?? 'Server returned HTML error page';
            throw Exception('Server error: $errorMsg. Check that the view returns JSON.');
          }
          throw Exception('Invalid response format. Got: ${response.substring(0, 100)}');
        }
      }
      
      // Handle JSON response
      if (response is Map) {
        if (response['success'] == true) {
          return; // Success
        }
        // Error in JSON response
        final error = response['error'] ?? response['message'] ?? 'Failed to add goal';
        throw Exception(error.toString());
      }
      
      throw Exception('Unexpected response type: ${response.runtimeType}. Expected Map or String.');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> toggleGoal(
    CookieRequest request, {
    required int goalId,
  }) async {
    final url = _base('/goals/toggle/$goalId/');
    
    try {
      final response = await request.post(url, {});

      if (response is Map) {
        if (response['success'] == true) {
          return;
        }
        final error = response['error'] ?? response['message'] ?? 'Failed to toggle goal';
        throw Exception(error);
      }
      
      if (response is String) {
        throw Exception('Server error: ${response.substring(0, 100)}');
      }
      
      throw Exception('Unexpected response: $response');
    } catch (e) {
      rethrow;
    }
  }
}
