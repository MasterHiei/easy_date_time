/// Cross-API workflows that mirror common package use.
library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(EasyDateTime.initializeTimeZone);

  tearDown(EasyDateTime.clearDefaultLocation);

  group('User workflows', () {
    test('app startup default location drives construction and now()', () {
      EasyDateTime.setDefaultLocation(TimeZones.shanghai);

      final meeting = EasyDateTime(2025, 12, 7, 10, 30);
      final now = EasyDateTime.now();

      expect(meeting.locationName, 'Asia/Shanghai');
      expect(now.locationName, 'Asia/Shanghai');
    });

    test('API fixed-offset value survives JSON roundtrip', () {
      const options = EasyParseOptions(
        mode: EasyParseMode.compatible,
        offsetResolution: OffsetResolution.fixed,
      );
      final original = EasyDateTime.parse(
        '2025-12-07T10:30:00+08:00',
        options: options,
      );

      final restored = EasyDateTime.fromIso8601String(
        original.toIso8601String(),
        options: options,
      );

      expect(restored.isAtSameMomentAs(original), isTrue);
      expect(restored.locationName, 'UTC+08:00');
      expect(restored.hour, 10);
    });

    test(
      'calendar scheduling distinguishes local days from 24-hour durations',
      () {
        final beforeDst = EasyDateTime(
          2025,
          3,
          9,
          0,
          0,
          0,
          0,
          0,
          TimeZones.newYork,
        );

        final calendar = beforeDst.addCalendarDays(1);
        final physical = beforeDst.add(const Duration(days: 1));

        expect(calendar.hour, 0);
        expect(physical.hour, 1);
        expect(calendar.isAtSameMomentAs(physical), isFalse);
      },
    );

    test('DateTime interop preserves an instant through timezone storage', () {
      final upstream = DateTime.utc(2025, 12, 7, 12);
      final tokyo = upstream.toEasyDateTime(location: TimeZones.tokyo);
      final restored = EasyDateTime.fromMillisecondsSinceEpoch(
        tokyo.millisecondsSinceEpoch,
        location: TimeZones.tokyo,
      );
      DateTime downstream = restored.toDateTime();

      expect(restored.isAtSameMomentAs(tokyo), isTrue);
      expect(restored.hour, 21);
      expect(downstream.toUtc(), upstream);
    });
  });
}
