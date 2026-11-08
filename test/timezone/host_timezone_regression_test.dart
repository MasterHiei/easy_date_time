@TestOn('vm')
library;

import 'dart:io';

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    switch (Platform.environment['TZ']) {
      case 'UTC':
        expect(DateTime(2025, 3, 9, 2, 30).timeZoneOffset, Duration.zero);
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
}
