// ignore_for_file: avoid_print

/// DateTime Compatibility Example
///
/// Demonstrates: EasyDateTime interoperability with DateTime APIs.
/// Run: dart run example/lib/core/datetime_compatibility.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== DateTime Compatibility ===\n');

  // --------------------------------------------------------
  // EasyDateTime implements DateTime
  // --------------------------------------------------------
  print('EasyDateTime implements DateTime:');
  final easyDt = EasyDateTime.now(location: TimeZones.tokyo);

  // Can be assigned to DateTime variable
  DateTime dt = easyDt;
  print('  Assigned to DateTime: $dt');

  // Works with functions expecting DateTime
  final year = extractYear(easyDt);
  print('  extractYear(easyDt): $year');
  final coreCopy = dt.copyWith(isUtc: false);
  print('  DateTime-typed copyWith returns: ${coreCopy.runtimeType}');
  print('');

  // --------------------------------------------------------
  // Can be stored in List<DateTime>
  // --------------------------------------------------------
  print('List<DateTime> with mixed types:');
  final List<DateTime> dates = [
    DateTime.utc(2025, 1, 1),
    EasyDateTime.utc(2025, 2, 1),
    EasyDateTime(2025, 3, 1, 0, 0, 0, 0, 0, TimeZones.tokyo),
  ];
  for (final d in dates) {
    print('  ${d.runtimeType}: $d');
  }
  print('');

  // --------------------------------------------------------
  // Works with sorting and comparison
  // --------------------------------------------------------
  print('Sorting mixed DateTime list:');
  dates.sort((a, b) => a.compareTo(b));
  for (final d in dates) {
    print('  $d');
  }
}

/// Example function that accepts standard DateTime
int extractYear(DateTime dt) => dt.year;
