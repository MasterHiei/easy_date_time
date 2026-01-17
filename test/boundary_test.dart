import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' show local;

/// Boundary and edge case tests for EasyDateTime.
void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('Date Component Boundaries', () {
    group('Year', () {
      test('should accept minimum year 1', () {
        final dt = EasyDateTime.utc(1, 1, 1);
        expect(dt.year, 1);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('should accept maximum year 9999', () {
        final dt = EasyDateTime.utc(9999, 12, 31);
        expect(dt.year, 9999);
        expect(dt.month, 12);
        expect(dt.day, 31);
      });

      test(
          'should transition from 2025-12-31 to 2026-01-01 when adding 1 microsecond',
          () {
        // Arrange
        final last = EasyDateTime.utc(2025, 12, 31, 23, 59, 59, 999, 999);

        // Act
        final next = last + const Duration(microseconds: 1);

        // Assert
        expect(next.year, 2026);
        expect(next.month, 1);
        expect(next.day, 1);
        expect(next.hour, 0);
        expect(next.minute, 0);
        expect(next.second, 0);
      });

      test('should allow negative millisecondsSinceEpoch (Pre-1970)', () {
        // Arrange & Act
        final dt = EasyDateTime.utc(1969, 12, 31, 23, 59, 59);

        // Assert
        expect(dt.millisecondsSinceEpoch, lessThan(0));
      });

      test('should correctly subtract across the epoch boundary', () {
        // Arrange
        final after = EasyDateTime.utc(1970, 1, 1, 0, 0, 1);

        // Act
        final before = after - const Duration(seconds: 2);

        // Assert
        expect(before.year, 1969);
        expect(before.month, 12);
        expect(before.day, 31);
        expect(before.hour, 23);
        expect(before.minute, 59);
        expect(before.second, 59);
      });
    });

    group('Month', () {
      test('should accept 31 days for valid months', () {
        for (final m in [1, 3, 5, 7, 8, 10, 12]) {
          expect(EasyDateTime.utc(2025, m, 31).day, 31,
              reason: 'Month $m should have 31 days');
        }
      });

      test('should accept 30 days for valid months', () {
        for (final m in [4, 6, 9, 11]) {
          expect(EasyDateTime.utc(2025, m, 30).day, 30,
              reason: 'Month $m should have 30 days');
        }
      });

      test('should handle February in non-leap year (28 days)', () {
        final dt = EasyDateTime.utc(2025, 2, 28);
        expect(dt.month, 2);
        expect(dt.day, 28);
      });

      test('should handle February in leap year (29 days)', () {
        final dt = EasyDateTime.utc(2024, 2, 29);
        expect(dt.month, 2);
        expect(dt.day, 29);
      });

      test('should transition Jan 31 + 1 day to Feb 1', () {
        final jan = EasyDateTime.utc(2025, 1, 31);
        final feb = jan + const Duration(days: 1);
        expect(feb.month, 2);
        expect(feb.day, 1);
      });
    });

    group('Time', () {
      test('should accept minimum time 00:00:00.000000', () {
        final dt = EasyDateTime.utc(2025, 1, 1, 0, 0, 0, 0, 0);
        expect(dt.hour, 0);
        expect(dt.minute, 0);
        expect(dt.second, 0);
        expect(dt.millisecond, 0);
        expect(dt.microsecond, 0);
      });

      test('should accept maximum time 23:59:59.999999', () {
        final dt = EasyDateTime.utc(2025, 1, 1, 23, 59, 59, 999, 999);
        expect(dt.hour, 23);
        expect(dt.minute, 59);
        expect(dt.second, 59);
        expect(dt.millisecond, 999);
        expect(dt.microsecond, 999);
      });

      test('should transition day when adding 1 microsecond to max time', () {
        final end = EasyDateTime.utc(2025, 6, 15, 23, 59, 59, 999, 999);
        final next = end + const Duration(microseconds: 1);
        expect(next.day, 16);
        expect(next.hour, 0);
      });
    });

    group('Constructor Rolling', () {
      test('should roll backward for month 0', () {
        final dt = EasyDateTime(2025, 0, 1);
        expect(dt.year, equals(2024));
        expect(dt.month, equals(12));
        expect(dt.day, equals(1));
      });

      test('should roll forward for month 13', () {
        final dt = EasyDateTime(2025, 13, 1);
        expect(dt.year, equals(2026));
        expect(dt.month, equals(1));
        expect(dt.day, equals(1));
      });

      test('should roll backward for day 0', () {
        final dt = EasyDateTime(2025, 1, 0);
        expect(dt.year, equals(2024));
        expect(dt.month, equals(12));
        expect(dt.day, equals(31));
      });

      test('should roll forward for day 32', () {
        final dt = EasyDateTime(2025, 1, 32);
        expect(dt.month, equals(2));
        expect(dt.day, equals(1));
      });

      test('should roll forward for hour 24', () {
        final dt = EasyDateTime(2025, 1, 1, 24);
        expect(dt.day, equals(2));
        expect(dt.hour, equals(0));
      });

      test('should roll forward for minute 60', () {
        final dt = EasyDateTime(2025, 1, 1, 0, 60);
        expect(dt.hour, 1);
        expect(dt.minute, 0);
      });

      test('should roll forward for second 60', () {
        final dt = EasyDateTime(2025, 1, 1, 0, 0, 60);
        expect(dt.minute, 1);
        expect(dt.second, 0);
      });

      test('should roll backward for negative microsecond', () {
        final dt = EasyDateTime(2025, 1, 1, 0, 0, 0, 0, -1);
        expect(dt.year, 2024);
        expect(dt.month, 12);
        expect(dt.day, 31);
      });

      test('should roll invalid leap day on non-leap year to Mar 1', () {
        final dt = EasyDateTime(2023, 2, 29);
        expect(dt.month, equals(3));
        expect(dt.day, equals(1));
      });

      test('should transition month boundary when adding days', () {
        final endOfMonth = EasyDateTime(2025, 1, 31);
        final nextMonth = endOfMonth + Duration(days: 1);
        expect(nextMonth.month, 2);
        expect(nextMonth.day, 1);
      });

      test('should transition month boundary backward when subtracting days',
          () {
        final firstOfMonth = EasyDateTime(2025, 2, 1);
        final prevMonth = firstOfMonth - Duration(days: 1);
        expect(prevMonth.month, 1);
        expect(prevMonth.day, 31);
      });

      test('should transition year boundary when adding days', () {
        final endOfYear = EasyDateTime(2025, 12, 31);
        final nextYear = endOfYear + Duration(days: 1);
        expect(nextYear.year, 2026);
        expect(nextYear.month, 1);
        expect(nextYear.day, 1);
      });
    });
  });

  group('Timezone Boundaries', () {
    test('should convert across date line (UTC+14)', () {
      // Arrange
      final utc = EasyDateTime.utc(2025, 6, 15, 10, 0);

      // Act
      final local = utc.inLocation(getLocation('Pacific/Kiritimati'));

      // Assert
      expect(local.day, 16);
      expect(local.hour, 0);
    });

    test('should convert across dst offset (UTC-8)', () {
      // Arrange
      final utc = EasyDateTime.utc(2025, 6, 15, 10, 0);

      // Act
      final local = utc.inLocation(getLocation('America/Anchorage'));

      // Assert
      expect(local.day, 15);
      expect(local.hour, 2);
    });

    test(
        'should maintain instant equality but different locationName across timezones',
        () {
      // Arrange
      final tokyo = getLocation('Asia/Tokyo');
      final ny = getLocation('America/New_York');
      final dt1 = EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, tokyo);

      // Act
      final dt2 = dt1.inLocation(ny);

      // Assert
      expect(dt1.isAtSameMomentAs(dt2), isTrue);
      expect(dt1.millisecondsSinceEpoch, dt2.millisecondsSinceEpoch);
      expect(dt1.locationName, isNot(dt2.locationName));
    });
  });

  group('DST Transitions', () {
    group('Spring Forward (Gap)', () {
      test('should skip/adjust gap time (NY 02:30 -> 03:30 EDT)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 9, 2, 30, 0, 0, 0, ny);
        expect(dt.hour, 3);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset.inHours, -4);
      });

      test('should skip/adjust gap time (London 01:30 -> 02:30 BST)', () {
        final london = getLocation('Europe/London');
        final dt = EasyDateTime(2025, 3, 30, 1, 30, 0, 0, 0, london);
        expect(dt.hour, 2);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset.inHours, 1);
      });

      test('should skip/adjust gap time (Paris 02:30 -> 03:30 CEST)', () {
        final paris = getLocation('Europe/Paris');
        final dt = EasyDateTime(2025, 3, 30, 2, 30, 0, 0, 0, paris);
        expect(dt.hour, 3);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset.inHours, 2);
      });

      test('should skip/adjust gap time (Sydney 02:30 -> 03:30 AEDT)', () {
        final sydney = getLocation('Australia/Sydney');
        final dt = EasyDateTime(2025, 10, 5, 2, 30, 0, 0, 0, sydney);
        expect(dt.hour, 3);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset.inHours, 11);
      });
    });

    group('Fall Back (Overlap)', () {
      test('should resolve to first occurrence (EDT) for NY 01:30', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 1, 30, 0, 0, 0, ny);
        expect(dt.hour, 1);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset.inHours, -4);
      });

      test('should resolve to second occurrence (GMT) for London 01:30', () {
        final london = getLocation('Europe/London');
        final dt = EasyDateTime(2025, 10, 26, 1, 30, 0, 0, 0, london);
        expect(dt.hour, 1);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset.inHours, 0); // GMT is +0
      });

      test('should resolve to second occurrence (AEST) for Sydney 02:30', () {
        final sydney = getLocation('Australia/Sydney');
        final dt = EasyDateTime(2025, 4, 6, 2, 30, 0, 0, 0, sydney);
        expect(dt.hour, 2);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset.inHours, 10);
      });
    });

    group('Cross-DST Arithmetic', () {
      test(
          'should yield 2 hr physical difference for 3 calendar hours across gap',
          () {
        final ny = getLocation('America/New_York');
        final t1 = EasyDateTime(2025, 3, 9, 1, 0, 0, 0, 0, ny);
        final t2 = EasyDateTime(2025, 3, 9, 4, 0, 0, 0, 0, ny);
        expect(t2.difference(t1).inHours, 2);
      });

      test('should adding 2 hours to 01:30 EST arrive at 04:30 EDT across gap',
          () {
        final ny = getLocation('America/New_York');
        final before = EasyDateTime(2025, 3, 9, 1, 30, 0, 0, 0, ny);
        final after = before + const Duration(hours: 2);
        expect(after.hour, 4);
        expect(after.minute, 30);
        expect(after.timeZoneOffset.inHours, -4);
      });
    });

    group('UTC Consistency', () {
      test('should change offset correctly from -5 to -4 at transition', () {
        final ny = getLocation('America/New_York');
        final before = EasyDateTime(2025, 3, 9, 1, 59, 0, 0, 0, ny);
        final after = EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, ny);
        expect(before.timeZoneOffset.inHours, -5);
        expect(after.timeZoneOffset.inHours, -4);
      });

      test('should show 1ms difference between 01:59:59.999 and 03:00:00.000',
          () {
        final ny = getLocation('America/New_York');
        final last = EasyDateTime(2025, 3, 9, 1, 59, 59, 999, 0, ny);
        final first = EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, ny);
        expect(first.millisecondsSinceEpoch - last.millisecondsSinceEpoch, 1);
      });

      test('toUtc should convert EST/EDT correctly', () {
        final ny = getLocation('America/New_York');
        expect(EasyDateTime(2025, 3, 9, 1, 0, 0, 0, 0, ny).toUtc().hour,
            6); // 1+5=6
        expect(EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, ny).toUtc().hour,
            7); // 3+4=7
      });
    });

    group('Constant Offset Regions', () {
      test('Tokyo should maintain +09:00 year round', () {
        final tokyo = getLocation('Asia/Tokyo');
        expect(
          EasyDateTime(2025, 3, 9, 12, 0, 0, 0, 0, tokyo)
              .timeZoneOffset
              .inHours,
          9,
        );
        expect(
          EasyDateTime(2025, 11, 2, 12, 0, 0, 0, 0, tokyo)
              .timeZoneOffset
              .inHours,
          9,
        );
      });

      test('Shanghai should maintain +08:00 year round', () {
        final shanghai = getLocation('Asia/Shanghai');
        expect(
          EasyDateTime(2025, 3, 30, 12, 0, 0, 0, 0, shanghai)
              .timeZoneOffset
              .inHours,
          8,
        );
        expect(
          EasyDateTime(2025, 10, 26, 12, 0, 0, 0, 0, shanghai)
              .timeZoneOffset
              .inHours,
          8,
        );
      });
    });

    group('Calendar Arithmetic', () {
      test('tomorrow should preserve local time across Spring Forward', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 9, 0, 0, 0, 0, 0, ny);
        final result = dt.tomorrow;
        expect(result.day, 10);
        expect(result.hour, 0);
      });

      test('tomorrow should preserve local time across Fall Back', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 0, 0, 0, 0, 0, ny);
        final result = dt.tomorrow;
        expect(result.day, 3);
        expect(result.hour, 0);
      });

      test('yesterday should preserve local time across Spring Forward', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 10, 0, 0, 0, 0, 0, ny);
        final result = dt.yesterday;
        expect(result.day, 9);
        expect(result.hour, 0);
      });

      test('yesterday should preserve local time across Fall Back', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 3, 0, 0, 0, 0, 0, ny);
        final result = dt.yesterday;
        expect(result.day, 2);
        expect(result.hour, 0);
      });

      test('addCalendarDays should preserve local time', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 8, 12, 30, 0, 0, 0, ny);
        final result = dt.addCalendarDays(2);
        expect(result.day, 10);
        expect(result.hour, 12);
        expect(result.minute, 30);
      });

      test('subtractCalendarDays should preserve local time', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 3, 12, 30, 0, 0, 0, ny);
        final result = dt.subtractCalendarDays(1);
        expect(result.day, 2);
        expect(result.hour, 12);
        expect(result.minute, 30);
      });

      test('add(Duration) vs addCalendarDays on Spring Forward', () {
        final ny = getLocation('America/New_York');
        // Duration adds 24 real hours, causing a shift in local time hour
        // Calendar adds "1 day" preserving local time hour
        final dt = EasyDateTime(2025, 3, 9, 0, 0, 0, 0, 0, ny);
        final physical = dt.add(const Duration(days: 1));
        final calendar = dt.addCalendarDays(1);

        expect(physical.hour, 1); // shifted
        expect(calendar.hour, 0); // preserved
      });

      test('add(Duration) vs addCalendarDays on Fall Back', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 0, 0, 0, 0, 0, ny);
        final physical = dt.add(const Duration(days: 1));
        final calendar = dt.addCalendarDays(1);

        // 25-hour day
        expect(physical.day, 2); // Still same day after 24 hours
        expect(physical.hour, 23);

        expect(calendar.day, 3); // Next day
        expect(calendar.hour, 0);
      });
    });
  });

  group('Comparison and Sorting', () {
    test('should consider two identical UTC times as equal', () {
      final dt1 = EasyDateTime.utc(2025, 6, 15, 10, 0);
      final dt2 = EasyDateTime.utc(2025, 6, 15, 10, 0);
      expect(dt1 == dt2, isTrue);
      expect(dt1.hashCode, dt2.hashCode);
    });

    test('should sort dates chronologically', () {
      final list = [
        EasyDateTime.utc(2025, 6, 16),
        EasyDateTime.utc(2025, 6, 14),
        EasyDateTime.utc(2025, 6, 15),
      ];
      list.sort();
      expect(list.map((d) => d.day).toList(), [14, 15, 16]);
    });
  });

  group('Serialization', () {
    test('should preserve precision in ISO 8601 roundtrip', () {
      final dt = EasyDateTime.utc(2025, 6, 15, 10, 30, 45, 123, 456);
      final restored = EasyDateTime.fromIso8601String(dt.toIso8601String());
      expect(restored.millisecond, 123);
      expect(restored.microsecond, 456);
    });

    test('should include offset in ISO 8601 string', () {
      final tokyo = getLocation('Asia/Tokyo');
      final dt = EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, tokyo);
      expect(
        dt.toIso8601String(),
        anyOf(contains('+09:00'), contains('+0900')),
      );
    });

    test('should preserve instant in roundtrip', () {
      final original = EasyDateTime.utc(2025, 6, 15, 10, 30);
      final restored =
          EasyDateTime.fromIso8601String(original.toIso8601String());
      expect(restored.isAtSameMomentAs(original), isTrue);
    });
  });

  group('copyWith', () {
    test('should update specified fields', () {
      final dt = EasyDateTime.utc(2025, 1, 1);
      final m = dt.copyWith(
          year: 2026,
          month: 12,
          day: 31,
          hour: 23,
          minute: 59,
          second: 59,
          millisecond: 999,
          microsecond: 999);
      expect(m.year, 2026);
      expect(m.month, 12);
      expect(m.day, 31);
      expect(m.hour, 23);
      expect(m.minute, 59);
      expect(m.second, 59);
      expect(m.millisecond, 999);
      expect(m.microsecond, 999);
    });

    test('should return equivalent instance if no arguments', () {
      final dt = EasyDateTime.utc(2025, 6, 15);
      final same = dt.copyWith();
      expect(same.isAtSameMomentAs(dt), isTrue);
    });

    test('should update location while preserving local component values', () {
      final dt = EasyDateTime.utc(2025, 6, 15, 10, 0);
      final tokyo = getLocation('Asia/Tokyo');
      final m = dt.copyWith(location: tokyo);
      expect(m.locationName, 'Asia/Tokyo');
      expect(m.hour, 10);
    });

    group('copyWithClamped', () {
      test('should clamp Feb 29 to Feb 28 when changing to non-leap year', () {
        final leap = EasyDateTime(2024, 2, 29, 12, 0);
        final clamped = leap.copyWithClamped(year: 2025);
        expect(clamped.month, 2);
        expect(clamped.day, 28);
      });

      test('should overflow to Mar 1 when using standard copyWith', () {
        final leap = EasyDateTime(2024, 2, 29, 12, 0);
        final overflow = leap.copyWith(year: 2025);
        expect(overflow.month, 3);
        expect(overflow.day, 1);
      });
    });
  });

  group('Global Configuration', () {
    test('should allow clearing default location safely', () {
      EasyDateTime.clearDefaultLocation();
      EasyDateTime.clearDefaultLocation();
      expect(EasyDateTime.now().location, local);
    });

    test('should correctly cycle setDefaultLocation', () {
      final tokyo = getLocation('Asia/Tokyo');
      EasyDateTime.setDefaultLocation(tokyo);
      expect(EasyDateTime.getDefaultLocation()!.name, 'Asia/Tokyo');

      EasyDateTime.clearDefaultLocation();
      expect(EasyDateTime.getDefaultLocation(), isNull);
    });

    test('should apply default location to new instances', () {
      final tokyo = getLocation('Asia/Tokyo');
      EasyDateTime.setDefaultLocation(tokyo);
      expect(EasyDateTime(2025, 6, 15, 10, 0).locationName, 'Asia/Tokyo');
    });
  });

  group('Misc Edge Cases', () {
    test('adding Duration.zero should preserve instant', () {
      final dt = EasyDateTime.utc(2025, 6, 15);
      final result = dt + Duration.zero;
      expect(result.isAtSameMomentAs(dt), isTrue);
    });

    test('subtracting large duration should work', () {
      final dt = EasyDateTime.utc(2025, 6, 15);
      final past = dt - const Duration(days: 3650);
      expect(past.year, 2015);
    });

    test('adding 1 microsecond should increment appropriately', () {
      final dt = EasyDateTime.utc(2025, 6, 15, 10, 0, 0, 0, 0);
      final next = dt + const Duration(microseconds: 1);
      expect(next.microsecond, 1);
    });

    test('unclosed quote in format should be treated as literal', () {
      final dt = EasyDateTime(2025, 1, 1, 12, 0, 0);
      expect(dt.format("'Hello world"), 'Hello world');
    });

    test('empty quotes in format should be empty', () {
      final dt = EasyDateTime(2025, 1, 1, 12, 0, 0);
      expect(dt.format("''"), '');
    });

    test('quoted tokens should be literal', () {
      final dt = EasyDateTime(2025, 1, 1, 12, 0, 0);
      expect(dt.format("'yyyy'"), 'yyyy');
    });

    test('toUtc and inLocation roundtrip should preserve microsecond precision',
        () {
      final now = EasyDateTime.now();
      final utc = now.toUtc();
      final back = utc.inLocation(now.location);
      expect(back.microsecondsSinceEpoch, now.microsecondsSinceEpoch);
      expect(back.isAtSameMomentAs(now), isTrue);
    });
  });
}
