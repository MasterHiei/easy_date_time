// ignore_for_file: avoid_print

/// Formatting Example
///
/// Demonstrates: various output formats using format() method.
/// Run: dart run example/lib/core/formatting.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Formatting ===\n');

  final dt = EasyDateTime(2025, 12, 7, 14, 30, 45, 123, 456, TimeZones.tokyo);

  print('DateTime: $dt\n');

  // --------------------------------------------------------
  // Built-in formats (existing methods)
  // --------------------------------------------------------
  print('Built-in formats:');
  print('  toString():        $dt');
  print('  toIso8601String(): ${dt.toIso8601String()}');
  print('  toDateString():    ${dt.toDateString()}');
  print('  toTimeString():    ${dt.toTimeString()}');
  print('');

  // --------------------------------------------------------
  // Custom format patterns with format() method
  // --------------------------------------------------------
  print('Custom format patterns:');
  print("  format('yyyy-MM-dd'):           ${dt.format('yyyy-MM-dd')}");
  print("  format('dd/MM/yyyy'):           ${dt.format('dd/MM/yyyy')}");
  print("  format('MM/dd/yyyy'):           ${dt.format('MM/dd/yyyy')}");
  print("  format('yyyy/MM/dd'):           ${dt.format('yyyy/MM/dd')}");
  print("  format('HH:mm:ss'):             ${dt.format('HH:mm:ss')}");
  print("  format('hh:mm a'):              ${dt.format('hh:mm a')}");
  print("  format('HH:mm:ss.SSS'):         ${dt.format('HH:mm:ss.SSS')}");
  print("  format('yyyy-MM-dd HH:mm:ss'): ${dt.format('yyyy-MM-dd HH:mm:ss')}");
  print('');

  // --------------------------------------------------------
  // Predefined format constants
  // --------------------------------------------------------
  print('Predefined DateTimeFormats:');
  print('  isoDate:     ${dt.format(DateTimeFormats.isoDate)}');
  print('  isoTime:     ${dt.format(DateTimeFormats.isoTime)}');
  print('  isoDateTime: ${dt.format(DateTimeFormats.isoDateTime)}');
  print('  rfc2822:     ${dt.format(DateTimeFormats.rfc2822)}');
  print('  time12Hour:  ${dt.format(DateTimeFormats.time12Hour)}');
  print('  time24Hour:  ${dt.format(DateTimeFormats.time24Hour)}');
  print('');

  // --------------------------------------------------------
  // Escaped literal text in patterns
  // --------------------------------------------------------
  print('Escaped literal text:');
  print(
      "  format(\"yyyy-MM-dd'T'HH:mm:ss\"): ${dt.format("yyyy-MM-dd'T'HH:mm:ss")}");
  print(
      "  format(\"'Date:' yyyy-MM-dd\"):    ${dt.format("'Date:' yyyy-MM-dd")}");
  print("  format('yyyy年MM月dd日'):         ${dt.format('yyyy年MM月dd日')}");
  print('');

  // --------------------------------------------------------
  // DateTime properties (for reference)
  // --------------------------------------------------------
  print('Properties:');
  print('  year:        ${dt.year}');
  print('  month:       ${dt.month}');
  print('  day:         ${dt.day}');
  print('  hour:        ${dt.hour}');
  print('  minute:      ${dt.minute}');
  print('  second:      ${dt.second}');
  print('  millisecond: ${dt.millisecond}');
  print('  weekday:     ${dt.weekday}');
  print('  locationName: ${dt.locationName}');
}
