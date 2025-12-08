// ignore_for_file: avoid_print

/// Dio HTTP Client Example
///
/// Demonstrates: Using EasyDateTime with Dio for HTTP requests.
///
/// Setup:
///   cd example
///   dart pub get
///
/// Run: dart run 12_dio.dart
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_date_time/easy_date_time.dart';

// ============================================================
// Models
// ============================================================

class ApiEvent {
  final String id;
  final String title;
  final EasyDateTime startTime;
  final EasyDateTime? endTime;

  ApiEvent({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
  });

  factory ApiEvent.fromJson(Map<String, dynamic> json) {
    return ApiEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: EasyDateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? EasyDateTime.parse(json['end_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
      };
}

// ============================================================
// API Service
// ============================================================

class EventService {
  final Dio dio;

  EventService(this.dio);

  /// GET /api/events
  Future<List<ApiEvent>> getEvents() async {
    final response = await dio.get<List<dynamic>>('/api/events');

    return response.data!
        .map((json) => ApiEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/events
  Future<ApiEvent> createEvent(ApiEvent event) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/events',
      data: event.toJson(),
    );

    return ApiEvent.fromJson(response.data!);
  }

  /// GET /api/events?start=...&end=...
  Future<List<ApiEvent>> getEventsInRange({
    required EasyDateTime start,
    required EasyDateTime end,
  }) async {
    final response = await dio.get<List<dynamic>>(
      '/api/events',
      queryParameters: {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      },
    );

    return response.data!
        .map((json) => ApiEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

// ============================================================
// Main (simulated without actual HTTP)
// ============================================================

void main() {
  initializeTimeZone();

  print('=== Dio HTTP Client ===\n');

  // Simulate API response
  final apiResponseJson = '''
  {
    "id": "evt_001",
    "title": "Product Launch",
    "start_time": "2025-12-15T10:00:00+09:00",
    "end_time": "2025-12-15T12:00:00+09:00"
  }
  ''';

  // Parse response
  final jsonData = jsonDecode(apiResponseJson) as Map<String, dynamic>;
  final event = ApiEvent.fromJson(jsonData);

  print('Parsed Response:');
  print('  ID: ${event.id}');
  print('  Title: ${event.title}');
  print('  Start: ${event.startTime}');
  print('  Hour preserved: ${event.startTime.hour}');
  print('');

  // Serialize for request
  final requestBody = event.toJson();
  print('Request Body:');
  print('  ${jsonEncode(requestBody)}');
  print('');

  // Query parameters
  print('Query Parameters:');
  final startOfWeek = EasyDateTime.now().startOfDay;
  final endOfWeek = startOfWeek + 7.days;
  print('  start: ${startOfWeek.toIso8601String()}');
  print('  end: ${endOfWeek.toIso8601String()}');
  print('');

  // Create new event
  final newEvent = ApiEvent(
    id: 'evt_new',
    title: 'New Meeting',
    startTime: EasyDateTime(2025, 12, 20, 14, 0, 0, 0, 0, TimeZones.tokyo),
    endTime: EasyDateTime(2025, 12, 20, 15, 0, 0, 0, 0, TimeZones.tokyo),
  );

  print('Create Event Request:');
  print('  ${jsonEncode(newEvent.toJson())}');
}
