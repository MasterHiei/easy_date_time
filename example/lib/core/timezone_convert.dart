// ignore_for_file: avoid_print

/// Timezone Conversion Example
///
/// Demonstrates: converting between timezones.
/// Run: dart run example/lib/core/timezone_convert.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Timezone Conversion ===\n');

  // --------------------------------------------------------
  // inLocation() - Convert to specific timezone
  // --------------------------------------------------------
  print('inLocation():');
  final shanghai =
      EasyDateTime(2025, 12, 7, 20, 0, 0, 0, 0, TimeZones.shanghai);
  final tokyo = shanghai.inLocation(TimeZones.tokyo);
  final newYork = shanghai.inLocation(TimeZones.newYork);
  final london = shanghai.inLocation(TimeZones.london);

  print('  Original: Shanghai ${shanghai.hour}:00');
  print('  → Tokyo:   ${tokyo.hour}:00');
  print('  → New York: ${newYork.hour}:00 (Day ${newYork.day})');
  print('  → London:  ${london.hour}:00');
  print('');

  // --------------------------------------------------------
  // toUtc() - Convert to UTC
  // --------------------------------------------------------
  print('toUtc():');
  final utc = shanghai.toUtc();
  print('  Shanghai ${shanghai.hour}:00 → UTC ${utc.hour}:00');
  print('');

  // --------------------------------------------------------
  // toLocal() - Convert to system local
  // --------------------------------------------------------
  print('toLocal():');
  final local = shanghai.toLocal();
  print('  Shanghai ${shanghai.hour}:00 → Local ${local.hour}:00');
  print('');

  // --------------------------------------------------------
  // Verify same moment
  // --------------------------------------------------------
  print('Same moment verification:');
  print(
      '  shanghai.isAtSameMomentAs(tokyo):   ${shanghai.isAtSameMomentAs(tokyo)}');
  print(
      '  shanghai.isAtSameMomentAs(newYork): ${shanghai.isAtSameMomentAs(newYork)}');
  print(
      '  shanghai.isAtSameMomentAs(utc):     ${shanghai.isAtSameMomentAs(utc)}');
  print('');

  // --------------------------------------------------------
  // Practical example: Meeting across timezones
  // --------------------------------------------------------
  print('Practical: Meeting scheduler');
  final meetingUtc = EasyDateTime.utc(2025, 12, 15, 14, 0);
  print('  Meeting: ${meetingUtc.toIso8601String()}');
  print('');
  print('  Participant times:');
  print('    Tokyo:     ${meetingUtc.inLocation(TimeZones.tokyo).hour}:00');
  print('    Shanghai:  ${meetingUtc.inLocation(TimeZones.shanghai).hour}:00');
  print('    London:    ${meetingUtc.inLocation(TimeZones.london).hour}:00');
  print('    New York:  ${meetingUtc.inLocation(TimeZones.newYork).hour}:00');
}
