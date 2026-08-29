library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' show TZDateTime;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  test('fixed +11:00 input preserves its numeric offset', () {
    final dt = EasyDateTime.parse('2025-10-05T02:15:00+11:00');

    expect(dt.timeZoneOffset, const Duration(hours: 11));
  });

  test('Lord Howe distinguishes calendar days from 24-hour durations', () {
    final lordHowe = getLocation('Australia/Lord_Howe');
    final beforeTransition = EasyDateTime(2025, 10, 5, 0, 0, 0, 0, 0, lordHowe);

    final calendarDay = beforeTransition.addCalendarDays(1);
    final physicalDay = beforeTransition.add(const Duration(days: 1));

    final expectedCalendarDay = TZDateTime(lordHowe, 2025, 10, 6);
    expect(
      calendarDay.microsecondsSinceEpoch,
      expectedCalendarDay.microsecondsSinceEpoch,
    );
    expect(calendarDay.hour, 0);
    expect(calendarDay.minute, 0);
    expect(physicalDay.day, 6);
    expect(physicalDay.hour, 0);
    expect(physicalDay.minute, 30);
    expect(
      physicalDay.microsecondsSinceEpoch -
          beforeTransition.microsecondsSinceEpoch,
      const Duration(days: 1).inMicroseconds,
    );
  });

  test('gap and overlap construction follows timezone package resolution', () {
    final newYork = getLocation('America/New_York');
    final cases = [
      (name: 'gap', month: 3, day: 9, hour: 2, minute: 30),
      (name: 'overlap', month: 11, day: 2, hour: 1, minute: 30),
    ];

    for (final c in cases) {
      final expected = TZDateTime(
        newYork,
        2025,
        c.month,
        c.day,
        c.hour,
        c.minute,
      );
      final actual = EasyDateTime(
        2025,
        c.month,
        c.day,
        c.hour,
        c.minute,
        0,
        0,
        0,
        newYork,
      );

      expect(actual.microsecondsSinceEpoch, expected.microsecondsSinceEpoch);
      expect(actual.hour, expected.hour, reason: c.name);
      expect(actual.minute, expected.minute, reason: c.name);
      expect(actual.timeZoneOffset, expected.timeZoneOffset, reason: c.name);
    }
  });

  test('inLocation preserves the instant while changing local fields', () {
    final shanghai = EasyDateTime(
      2025,
      12,
      7,
      20,
      0,
      0,
      0,
      0,
      TimeZones.shanghai,
    );

    final newYork = shanghai.inLocation(TimeZones.newYork);

    expect(newYork.microsecondsSinceEpoch, shanghai.microsecondsSinceEpoch);
    expect(newYork.locationName, 'America/New_York');
    expect(newYork.hour, 7);
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

  test(
    'region resolution for +05:45 maps to Asia/Kathmandu at given instant',
    () {
      final dt = EasyDateTime.parse(
        '2026-06-01T08:00:00+05:45',
        options: const EasyParseOptions(
          offsetResolution: OffsetResolution.region,
        ),
      );

      expect(dt.timeZoneOffset, const Duration(hours: 5, minutes: 45));
      expect(dt.locationName, 'Asia/Kathmandu');
    },
  );
}
