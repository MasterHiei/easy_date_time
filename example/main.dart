// ignore_for_file: avoid_print
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  print('=== EasyDateTime Example ===\n');

  // Initialize timezone database for IANA support.
  EasyDateTime.initializeTimeZone();

  // Create instance using system local timezone or global default.
  final now = EasyDateTime.now();
  print('Current time (Local): $now');

  // Create instance in specific IANA location.
  final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
  print('Tokyo time (Asia/Tokyo): $tokyo');

  // Convert between locations while preserving the instant.
  final newYork = tokyo.inLocation(TimeZones.newYork);
  print('New York time (America/New_York): $newYork');
  print('Is same moment: ${tokyo.isAtSameMomentAs(newYork)}');

  // Parse ISO 8601 string while preserving original offset and local time.
  final parsed = EasyDateTime.parse('2026-01-18T10:30:00+08:00');
  print('\nParsed: 2026-01-18T10:30:00+08:00');
  print('Hour: ${parsed.hour}');
  print('Location: ${parsed.locationName}');

  // Arithmetic operations via Duration extensions.
  final tomorrow = now + 1.days;
  print('\nTomorrow: ${tomorrow.format('yyyy-MM-dd')}');

  // Formatting using predefined patterns or custom strings.
  print('\nFormatting:');
  print('ISO Date: ${tokyo.format(DateTimeFormats.isoDate)}');
  print('Custom: ${tokyo.format('yyyy-MM-dd HH:mm')}');
}
