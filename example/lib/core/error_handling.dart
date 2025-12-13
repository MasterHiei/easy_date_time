// ignore_for_file: avoid_print

/// Error Handling Example
///
/// Demonstrates: safe parsing and validation.
/// Run: dart run example/10_error_handling.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Error Handling ===\n');

  // --------------------------------------------------------
  // Safe parsing with tryParse
  // --------------------------------------------------------
  print('tryParse (returns null on failure):');
  final valid = EasyDateTime.tryParse('2025-12-07T10:30:00Z');
  final invalid = EasyDateTime.tryParse('not-a-date');
  final empty = EasyDateTime.tryParse('');

  print('  Valid:   $valid');
  print('  Invalid: $invalid');
  print('  Empty:   $empty');
  print('');

  // --------------------------------------------------------
  // Exception handling with parse
  // --------------------------------------------------------
  print('parse (throws on failure):');
  try {
    EasyDateTime.parse('invalid');
  } on InvalidDateFormatException catch (e) {
    print('  Caught: ${e.runtimeType}');
    print('  Source: ${e.source}');
  }
  print('');

  // --------------------------------------------------------
  // Safe timezone lookup
  // --------------------------------------------------------
  print('TimeZones.tryGet (returns null on failure):');
  final validZone = TimeZones.tryGet('Asia/Tokyo');
  final invalidZone = TimeZones.tryGet('Invalid/Zone');

  print('  Valid:   ${validZone?.name}');
  print('  Invalid: $invalidZone');
  print('');

  // --------------------------------------------------------
  // Timezone validation
  // --------------------------------------------------------
  print('TimeZones.isValid:');
  print('  Asia/Tokyo:    ${TimeZones.isValid('Asia/Tokyo')}');
  print('  America/New_York: ${TimeZones.isValid('America/New_York')}');
  print('  Invalid/Zone:  ${TimeZones.isValid('Invalid/Zone')}');
  print('  Empty string:  ${TimeZones.isValid('')}');
  print('');

  // --------------------------------------------------------
  // Practical: Safe API response handling
  // --------------------------------------------------------
  print('Practical: Safe API handling');

  Map<String, dynamic> apiResponse = {
    'eventTime': '2025-12-07T10:30:00+08:00',
    'cancelledAt': null,
    'timezone': 'Asia/Shanghai',
  };

  final eventTime = apiResponse['eventTime'] != null
      ? EasyDateTime.tryParse(apiResponse['eventTime'] as String)
      : null;

  final cancelledAt = apiResponse['cancelledAt'] != null
      ? EasyDateTime.tryParse(apiResponse['cancelledAt'] as String)
      : null;

  final timezone = TimeZones.tryGet(apiResponse['timezone'] as String);

  print('  eventTime:   $eventTime');
  print('  cancelledAt: $cancelledAt');
  print('  timezone:    ${timezone?.name}');
}
