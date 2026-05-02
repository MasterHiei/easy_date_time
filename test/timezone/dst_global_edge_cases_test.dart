library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  test('Lord Howe half-hour DST shift remains correct', () {
    final dt = EasyDateTime.parse('2025-10-05T02:15:00+11:00');

    expect(dt.timeZoneOffset, const Duration(hours: 11));
  });

  test('Chatham +12:45 offset fixed mode remains +12:45', () {
    final dt = EasyDateTime.parse(
      '2026-02-01T09:00:00+12:45',
      options: const EasyParseOptions(offsetResolution: OffsetResolution.fixed),
    );

    expect(dt.timeZoneOffset, const Duration(hours: 12, minutes: 45));
    expect(dt.locationName, 'UTC+12:45');
  });

  test('Marquesas -09:30 offset fixed mode remains -09:30', () {
    final dt = EasyDateTime.parse(
      '2026-06-01T08:00:00-09:30',
      options: const EasyParseOptions(offsetResolution: OffsetResolution.fixed),
    );

    expect(dt.timeZoneOffset, const Duration(hours: -9, minutes: -30));
    expect(dt.locationName, 'UTC-09:30');
  });

  test('Kiritimati +14 fixed mode remains +14:00', () {
    final dt = EasyDateTime.parse(
      '2026-06-01T08:00:00+14:00',
      options: const EasyParseOptions(offsetResolution: OffsetResolution.fixed),
    );

    expect(dt.timeZoneOffset, const Duration(hours: 14));
    expect(dt.locationName, 'UTC+14:00');
  });

  test('region resolution for +05:45 maps to Asia/Kathmandu at given instant', () {
    final dt = EasyDateTime.parse(
      '2026-06-01T08:00:00+05:45',
      options: const EasyParseOptions(offsetResolution: OffsetResolution.region),
    );

    expect(dt.timeZoneOffset, const Duration(hours: 5, minutes: 45));
    expect(dt.locationName, 'Asia/Kathmandu');
  });
}
