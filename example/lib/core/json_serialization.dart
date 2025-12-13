// ignore_for_file: avoid_print

/// JSON Serialization Example
///
/// Demonstrates: toJson, fromJson, and integration patterns.
/// Run: dart run example/07_json.dart
library;

import 'dart:convert';
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== JSON Serialization ===\n');

  // --------------------------------------------------------
  // Basic serialization
  // --------------------------------------------------------
  print('Basic toJson/fromJson:');
  final dt = EasyDateTime(2025, 12, 25, 10, 30, 0, 0, 0, TimeZones.tokyo);
  final json = dt.toIso8601String();
  final restored = EasyDateTime.fromIso8601String(json);

  print('  Original:  $dt');
  print('  JSON:      $json');
  print('  Restored:  $restored');
  print('  Same:      ${dt.isAtSameMomentAs(restored)}');
  print('');

  // --------------------------------------------------------
  // In a model class
  // --------------------------------------------------------
  print('Model class serialization:');
  final event = Event(
    id: 'evt_001',
    title: 'Team Meeting',
    startTime: EasyDateTime(2025, 12, 7, 14, 0, 0, 0, 0, TimeZones.tokyo),
    endTime: EasyDateTime(2025, 12, 7, 15, 0, 0, 0, 0, TimeZones.tokyo),
  );

  final eventJson = event.toJson();
  print('  Event JSON: ${jsonEncode(eventJson)}');

  final restoredEvent = Event.fromJson(eventJson);
  print('  Restored: ${restoredEvent.title} at ${restoredEvent.startTime}');
  print('');

  // --------------------------------------------------------
  // Nullable fields
  // --------------------------------------------------------
  print('Nullable fields:');
  final user = User(
    id: 'usr_001',
    name: 'Alice',
    createdAt: EasyDateTime.now(),
    deletedAt: null,
  );

  final userJson = user.toJson();
  print('  User JSON: ${jsonEncode(userJson)}');
  print('  deletedAt: ${userJson['deletedAt']}');
  print('');

  // --------------------------------------------------------
  // Parsing API response
  // --------------------------------------------------------
  print('Parsing API response:');
  final apiJson = '''
  {
    "id": "evt_002",
    "title": "Product Launch",
    "startTime": "2025-12-15T10:00:00+09:00",
    "endTime": "2025-12-15T12:00:00+09:00"
  }
  ''';

  final apiData = jsonDecode(apiJson) as Map<String, dynamic>;
  final apiEvent = Event.fromJson(apiData);

  print('  Title: ${apiEvent.title}');
  print('  Start: ${apiEvent.startTime}');
  print('  Hour preserved: ${apiEvent.startTime.hour}');
}

// ============================================================
// Example model classes
// ============================================================

class Event {
  final String id;
  final String title;
  final EasyDateTime startTime;
  final EasyDateTime? endTime;

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: EasyDateTime.fromIso8601String(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? EasyDateTime.fromIso8601String(json['endTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };
}

class User {
  final String id;
  final String name;
  final EasyDateTime createdAt;
  final EasyDateTime? deletedAt;

  User({
    required this.id,
    required this.name,
    required this.createdAt,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };
}
