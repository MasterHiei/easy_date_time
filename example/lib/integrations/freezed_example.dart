// ignore_for_file: avoid_print

/// Freezed + json_serializable Example
///
/// Demonstrates: Using EasyDateTime with freezed and json_serializable.
///
/// Setup:
///   cd example
///   dart pub get
///   dart run build_runner build
///
/// Run: dart run lib/integrations/freezed_example.dart
library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'freezed_example.freezed.dart';
part 'freezed_example.g.dart';

// ============================================================
// Custom Converters (define these in your project)
// ============================================================

/// JsonConverter for non-nullable EasyDateTime fields.
///
/// Copy this class to your project and use with @EasyDateTimeConverter()
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}

/// JsonConverter for nullable EasyDateTime fields.
///
/// Copy this class to your project and use with @EasyDateTimeNullableConverter()
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
// Models
// ============================================================

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    @EasyDateTimeConverter() required EasyDateTime startTime,
    @EasyDateTimeNullableConverter() EasyDateTime? endTime,
    @Default(false) bool isAllDay,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    @EasyDateTimeConverter() required EasyDateTime createdAt,
    @EasyDateTimeNullableConverter() EasyDateTime? lastLoginAt,
    @EasyDateTimeNullableConverter() EasyDateTime? deletedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class Schedule with _$Schedule {
  const factory Schedule({
    required String id,
    @EasyDateTimeConverter() required EasyDateTime scheduledAt,
    @EasyDateTimeNullableConverter() EasyDateTime? completedAt,
    required String status,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}

// ============================================================
// Main
// ============================================================

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Freezed + json_serializable ===\n');

  // Create Event
  final event = Event(
    id: 'evt_001',
    title: 'Team Meeting',
    startTime: EasyDateTime(2025, 12, 7, 14, 0, 0, 0, 0, TimeZones.tokyo),
    endTime: EasyDateTime(2025, 12, 7, 15, 0, 0, 0, 0, TimeZones.tokyo),
  );

  print('Event:');
  print('  Title: ${event.title}');
  print('  Start: ${event.startTime}');
  print('  End: ${event.endTime}');
  print('');

  // Serialize
  final json = event.toJson();
  print('JSON: $json');
  print('');

  // Deserialize
  final restored = Event.fromJson(json);
  print('Restored:');
  print('  Title: ${restored.title}');
  print('  Start hour: ${restored.startTime.hour}');
  print('');

  // Parse API response
  final apiJson = {
    'id': 'evt_002',
    'title': 'Product Launch',
    'startTime': '2025-12-15T10:00:00+09:00',
    'endTime': '2025-12-15T12:00:00+09:00',
    'isAllDay': false,
  };

  final apiEvent = Event.fromJson(apiJson);
  print('From API:');
  print('  Title: ${apiEvent.title}');
  print('  Start: ${apiEvent.startTime}');
  print('  Hour preserved: ${apiEvent.startTime.hour}');
  print('');

  // copyWith (freezed feature)
  final rescheduled = event.copyWith(
    startTime: event.startTime + 1.days,
    endTime: event.endTime! + 1.days,
  );
  print('Rescheduled: ${rescheduled.startTime.toDateString()}');
}
