// ignore_for_file: avoid_print

import 'package:easy_date_time/easy_date_time.dart';

/// Demonstrates the high-performance [EasyDateTimeFormatter].
///
/// Run: dart run example/lib/core/formatter_example.dart
///
/// Unlike [EasyDateTime.format] which parses the pattern on every call,
/// [EasyDateTimeFormatter] parses the pattern once during initialization.
/// This provides significant performance benefits in loops or hot paths.
void main() {
  // Initialize timezone database
  EasyDateTime.initializeTimeZone();

  // 1. Create a formatter (compiles the pattern once)
  // This is efficient for reusing the same pattern multiple times
  final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm:ss');

  // 2. Create some dates
  final now = EasyDateTime.now();
  final tomorrow = now.add(const Duration(days: 1));
  final nextWeek = now.add(const Duration(days: 7));

  final dates = [now, tomorrow, nextWeek];

  print('Formatting ${dates.length} dates with pre-compiled formatter:');

  // 3. Use the formatter in a loop or hot path
  for (final date in dates) {
    print(formatter.format(date));
  }
}
