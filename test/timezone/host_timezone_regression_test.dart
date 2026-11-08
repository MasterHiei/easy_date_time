@TestOn('vm')
library;

import 'dart:io';

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    switch (Platform.environment['TZ']) {
      case 'UTC':
        expect(DateTime(2025, 3, 9, 2, 30).timeZoneOffset, Duration.zero);
      case 'America/New_York':
        expect(
          DateTime(2025, 3, 9, 1, 59).timeZoneOffset,
          const Duration(hours: -5),
        );
        expect(
          DateTime(2025, 3, 9, 3).timeZoneOffset,
          const Duration(hours: -4),
        );
      case 'Pacific/Kiritimati':
        expect(
          DateTime(1994, 12, 30, 12).timeZoneOffset,
          const Duration(hours: -10),
        );
        expect(
          DateTime(1995, 1, 1, 12).timeZoneOffset,
          const Duration(hours: 14),
        );
    }
    EasyDateTime.initializeTimeZone();
  });

  setUp(() {
    final originalDefault = EasyDateTime.getDefaultLocation();
    addTearDown(() => EasyDateTime.setDefaultLocation(originalDefault));
    EasyDateTime.setDefaultLocation(TimeZones.utc);
  });

  test('parses unoffset time without host DST adjustment', () {
    final date = EasyDateTime.parse('2025-03-09T02:30:00');
    expect(date.isAtSameMomentAs(DateTime.utc(2025, 3, 9, 2, 30)), isTrue);
    expect(date.location, TimeZones.utc);
    expect((date.hour, date.minute), (2, 30));
  });

  test('parses a date that was skipped in the host timezone', () {
    final date = EasyDateTime.fromIso8601String('1994-12-31');
    expect(date.isAtSameMomentAs(DateTime.utc(1994, 12, 31)), isTrue);
    expect(date.location, TimeZones.utc);
    expect((date.year, date.month, date.day, date.hour), (1994, 12, 31, 0));
  });

  for (final (input, milliseconds) in [
    ('-271821-04-20T00:00:00', -8640000000000000),
    ('+275760-09-13T00:00:00', 8640000000000000),
  ]) {
    test('parses UTC endpoint $input independently of the host', () {
      expect(
        EasyDateTime.tryParse(input)?.millisecondsSinceEpoch,
        milliseconds,
      );
      expect(
        EasyDateTime.tryParse(
          input,
          options: const EasyParseOptions(),
        )?.millisecondsSinceEpoch,
        milliseconds,
      );
    });
  }

  test('calculates the UTC month length across a host date skip', () {
    expect(EasyDateTime.utc(1994, 12).daysInMonth, 31);
  });

  test('clamps to the UTC month end across a host date skip', () {
    final date = EasyDateTime.utc(1994, 12).copyWithClamped(day: 31);
    expect(date.toIso8601String(), '1994-12-31T00:00:00.000Z');
  });

  test('validates a UTC date that was skipped in the host timezone', () {
    final date = EasyDateTime.parse(
      '1994-12-31T12:00:00Z',
      options: const EasyParseOptions(mode: EasyParseMode.isoStrict),
    );
    expect(date.toIso8601String(), '1994-12-31T12:00:00.000Z');
  });

  test('preserves host interpretation when a target location is explicit', () {
    const input = '2025-03-09T02:30:00';
    final tokyo = TimeZones.tokyo;
    final expected = tz.TZDateTime.from(DateTime.parse(input), tokyo);
    final actual = EasyDateTime.parse(input, location: tokyo);
    expect(actual.isAtSameMomentAs(expected), isTrue);
    expect(actual.toIso8601String(), expected.toIso8601String());
    expect(actual.location, tokyo);
  });
}
