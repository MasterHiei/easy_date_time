// ignore_for_file: avoid_print

/// Formatting Example
///
/// Demonstrates: various output formats.
/// Run: dart run example/08_formatting.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  initializeTimeZone();

  print('=== Formatting ===\n');

  final dt = EasyDateTime(2025, 12, 7, 14, 30, 45, 123, 456, TimeZones.tokyo);

  print('DateTime: $dt\n');

  // --------------------------------------------------------
  // Built-in formats
  // --------------------------------------------------------
  print('Built-in formats:');
  print('  toString():        $dt');
  print('  toIso8601String(): ${dt.toIso8601String()}');
  print('  toDateString():    ${dt.toDateString()}');
  print('  toTimeString():    ${dt.toTimeString()}');
  print('  toJson():          ${dt.toIso8601String()}');
  print('');

  // --------------------------------------------------------
  // Properties for custom formatting
  // --------------------------------------------------------
  print('Properties for custom formatting:');
  print('  year:        ${dt.year}');
  print('  month:       ${dt.month}');
  print('  day:         ${dt.day}');
  print('  hour:        ${dt.hour}');
  print('  minute:      ${dt.minute}');
  print('  second:      ${dt.second}');
  print('  millisecond: ${dt.millisecond}');
  print('  microsecond: ${dt.microsecond}');
  print('  weekday:     ${dt.weekday}');
  print('  locationName: ${dt.locationName}');
  print('  timeZoneOffset: ${dt.timeZoneOffset}');
  print('');

  // --------------------------------------------------------
  // Custom formatting examples
  // --------------------------------------------------------
  print('Custom formatting:');
  print('  YYYY/MM/DD: ${dt.year}/${_pad(dt.month)}/${_pad(dt.day)}');
  print('  DD-MM-YYYY: ${_pad(dt.day)}-${_pad(dt.month)}-${dt.year}');
  print('  HH:MM:      ${_pad(dt.hour)}:${_pad(dt.minute)}');
  print(
      '  12-hour:    ${_to12Hour(dt.hour)}:${_pad(dt.minute)} ${_amPm(dt.hour)}');
}

String _pad(int n) => n.toString().padLeft(2, '0');

int _to12Hour(int hour) {
  final h = hour % 12;

  return h == 0 ? 12 : h;
}

String _amPm(int hour) => hour < 12 ? 'AM' : 'PM';
