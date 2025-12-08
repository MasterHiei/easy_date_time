// ignore_for_file: avoid_print

/// Retrofit Type-Safe API Example
///
/// Demonstrates: Using EasyDateTime with Retrofit for type-safe APIs.
///
/// Setup:
///   cd example
///   dart pub get
///   dart run build_runner build
///
/// Run: dart run lib/integrations/retrofit_example.dart
library;

import 'package:dio/dio.dart';
import 'package:easy_date_time/easy_date_time.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'retrofit_example.g.dart';

// ============================================================
// Custom Converters (define these in your project)
// ============================================================

/// JsonConverter for non-nullable EasyDateTime fields.
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}

/// JsonConverter for nullable EasyDateTime fields.
class EasyDateTimeNullableConverter
    implements JsonConverter<EasyDateTime?, String?> {
  const EasyDateTimeNullableConverter();

  @override
  EasyDateTime? fromJson(String? json) =>
      json == null ? null : EasyDateTime.fromIso8601String(json);

  @override
  String? toJson(EasyDateTime? object) => object?.toIso8601String();
}

// ============================================================
// Request/Response Models
// ============================================================

@JsonSerializable()
class EventResponse {
  final String id;
  final String title;

  @EasyDateTimeConverter()
  final EasyDateTime startTime;

  @EasyDateTimeNullableConverter()
  final EasyDateTime? endTime;

  @EasyDateTimeConverter()
  final EasyDateTime createdAt;

  EventResponse({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    required this.createdAt,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) =>
      _$EventResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventResponseToJson(this);
}

@JsonSerializable()
class CreateEventRequest {
  final String title;

  @EasyDateTimeConverter()
  final EasyDateTime startTime;

  @EasyDateTimeNullableConverter()
  final EasyDateTime? endTime;

  CreateEventRequest({
    required this.title,
    required this.startTime,
    this.endTime,
  });

  factory CreateEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEventRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateEventRequestToJson(this);
}

@JsonSerializable()
class ScheduleResponse {
  final String id;

  @EasyDateTimeConverter()
  final EasyDateTime scheduledAt;

  @EasyDateTimeNullableConverter()
  final EasyDateTime? completedAt;

  final String status;

  ScheduleResponse({
    required this.id,
    required this.scheduledAt,
    this.completedAt,
    required this.status,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleResponseToJson(this);
}

// ============================================================
// Retrofit API Client
// ============================================================

@RestApi(baseUrl: 'https://api.example.com')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET('/events')
  Future<List<EventResponse>> getEvents();

  @GET('/events/{id}')
  Future<EventResponse> getEvent(@Path('id') String id);

  @POST('/events')
  Future<EventResponse> createEvent(@Body() CreateEventRequest request);

  @GET('/events')
  Future<List<EventResponse>> getEventsInRange(
    @Query('start') String start,
    @Query('end') String end,
  );

  @GET('/schedules')
  Future<List<ScheduleResponse>> getSchedules(@Query('date') String date);
}

// ============================================================
// Main (simulated)
// ============================================================

void main() {
  initializeTimeZone();

  print('=== Retrofit Type-Safe API ===\n');

  // Simulate API response
  final apiJson = {
    'id': 'evt_001',
    'title': 'Team Standup',
    'startTime': '2025-12-07T09:00:00+09:00',
    'endTime': '2025-12-07T09:30:00+09:00',
    'createdAt': '2025-12-01T10:00:00Z',
  };

  final event = EventResponse.fromJson(apiJson);
  print('Event Response:');
  print('  Title: ${event.title}');
  print('  Start: ${event.startTime}');
  print('  Hour preserved: ${event.startTime.hour}');
  print('');

  // Create request
  final request = CreateEventRequest(
    title: 'New Meeting',
    startTime: EasyDateTime(2025, 12, 15, 14, 0, 0, 0, 0, TimeZones.shanghai),
    endTime: EasyDateTime(2025, 12, 15, 16, 0, 0, 0, 0, TimeZones.shanghai),
  );

  print('Create Request:');
  final requestJson = request.toJson();
  print('  title: ${requestJson['title']}');
  print('  startTime: ${requestJson['startTime']}');
  print('  endTime: ${requestJson['endTime']}');
  print('');

  // Schedule response
  final scheduleJson = {
    'id': 'sch_001',
    'scheduledAt': '2025-12-10T15:30:00+08:00',
    'completedAt': null,
    'status': 'pending',
  };

  final schedule = ScheduleResponse.fromJson(scheduleJson);
  print('Schedule Response:');
  print('  ID: ${schedule.id}');
  print('  Scheduled: ${schedule.scheduledAt}');
  print('  Hour: ${schedule.scheduledAt.hour}');
  print('  Completed: ${schedule.completedAt ?? "Not yet"}');
  print('');

  // Query example
  print('Query Parameters:');
  final start = EasyDateTime.now().startOfDay;
  final end = start + 7.days;
  print('  start: ${start.toIso8601String()}');
  print('  end: ${end.toIso8601String()}');
}
