import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' show local;

/// Boundary and edge case tests for EasyDateTime.
///
/// Test categories:
/// - Date/Time component boundaries (year, month, day, time)
/// - Timezone boundaries (extreme offsets, conversions)
/// - DST transitions (gap, overlap, arithmetic, UTC consistency)
/// - Serialization boundaries (ISO 8601, JSON round-trip)
/// - copyWith edge cases (field updates, leap year handling)
void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Date Component Boundaries
  // ════════════════════════════════════════════════════════════════════════════

  group('Date boundaries', () {
    group('Year', () {
      test('EasyDateTime.utc(1, 1, 1) correctly represents year 1', () {
        final dt = EasyDateTime.utc(1, 1, 1);
        expect(dt.year, 1);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('EasyDateTime.utc(9999, 12, 31) correctly represents year 9999', () {
        final dt = EasyDateTime.utc(9999, 12, 31);
        expect(dt.year, 9999);
        expect(dt.month, 12);
        expect(dt.day, 31);
      });

      test(
          'adding 1 microsecond to 2025-12-31 23:59:59.999999 '
          'transitions to 2026-01-01 00:00:00.000000', () {
        final last = EasyDateTime.utc(2025, 12, 31, 23, 59, 59, 999, 999);
        final next = last + const Duration(microseconds: 1);

        expect(next.year, 2026);
        expect(next.month, 1);
        expect(next.day, 1);
        expect(next.hour, 0);
        expect(next.minute, 0);
        expect(next.second, 0);
      });

      test('1969-12-31 23:59:59 has negative millisecondsSinceEpoch', () {
        final dt = EasyDateTime.utc(1969, 12, 31, 23, 59, 59);
        expect(dt.millisecondsSinceEpoch, lessThan(0));
      });

      test(
          'subtracting 2 seconds from 1970-01-01 00:00:01 '
          'yields 1969-12-31 23:59:59', () {
        final after = EasyDateTime.utc(1970, 1, 1, 0, 0, 1);
        final before = after - const Duration(seconds: 2);

        expect(before.year, 1969);
        expect(before.month, 12);
        expect(before.day, 31);
        expect(before.hour, 23);
        expect(before.minute, 59);
        expect(before.second, 59);
      });

      test('1960-06-15 < 1970-06-15 comparison returns true', () {
        final y1960 = EasyDateTime.utc(1960, 6, 15);
        final y1970 = EasyDateTime.utc(1970, 6, 15);
        expect(y1960 < y1970, isTrue);
      });
    });

    group('Month', () {
      test('day 31 is valid for Jan, Mar, May, Jul, Aug, Oct, Dec', () {
        for (final m in [1, 3, 5, 7, 8, 10, 12]) {
          expect(EasyDateTime.utc(2025, m, 31).day, 31);
        }
      });

      test('day 30 is valid for Apr, Jun, Sep, Nov', () {
        for (final m in [4, 6, 9, 11]) {
          expect(EasyDateTime.utc(2025, m, 30).day, 30);
        }
      });

      test('Feb 28 is the last day in non-leap year 2025', () {
        final dt = EasyDateTime.utc(2025, 2, 28);
        expect(dt.month, 2);
        expect(dt.day, 28);
      });

      test('Feb 29 is valid in leap year 2024', () {
        final dt = EasyDateTime.utc(2024, 2, 29);
        expect(dt.month, 2);
        expect(dt.day, 29);
      });

      test('adding 1 day to Jan 31 yields Feb 1', () {
        final jan = EasyDateTime.utc(2025, 1, 31);
        final feb = jan + const Duration(days: 1);
        expect(feb.month, 2);
        expect(feb.day, 1);
      });
    });

    group('Time', () {
      test('00:00:00.000000 is correctly constructed (minimum time)', () {
        final dt = EasyDateTime.utc(2025, 1, 1, 0, 0, 0, 0, 0);
        expect(dt.hour, 0);
        expect(dt.minute, 0);
        expect(dt.second, 0);
        expect(dt.millisecond, 0);
        expect(dt.microsecond, 0);
      });

      test('23:59:59.999999 is correctly constructed (maximum time)', () {
        final dt = EasyDateTime.utc(2025, 1, 1, 23, 59, 59, 999, 999);
        expect(dt.hour, 23);
        expect(dt.minute, 59);
        expect(dt.second, 59);
        expect(dt.millisecond, 999);
        expect(dt.microsecond, 999);
      });

      test(
          'adding 1 microsecond to 23:59:59.999999 '
          'transitions to next day 00:00:00.000000', () {
        final end = EasyDateTime.utc(2025, 6, 15, 23, 59, 59, 999, 999);
        final next = end + const Duration(microseconds: 1);
        expect(next.day, 16);
        expect(next.hour, 0);
        expect(next.minute, 0);
        expect(next.microsecond, 0);
      });
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Timezone Boundaries
  // ════════════════════════════════════════════════════════════════════════════

  group('Timezone boundaries', () {
    test(
        'inLocation(Pacific/Kiritimati) converts 10:00 UTC '
        'to 00:00 next day (UTC+14)', () {
      final utc = EasyDateTime.utc(2025, 6, 15, 10, 0);
      final local = utc.inLocation(getLocation('Pacific/Kiritimati'));
      expect(local.day, 16);
      expect(local.hour, 0);
    });

    test(
        'inLocation(America/Anchorage) converts 10:00 UTC '
        'to 02:00 same day (UTC-8 during DST)', () {
      final utc = EasyDateTime.utc(2025, 6, 15, 10, 0);
      final local = utc.inLocation(getLocation('America/Anchorage'));
      expect(local.day, 15);
      expect(local.hour, 2);
    });

    test(
        'Tokyo 10:00 and NY equivalent have identical millisecondsSinceEpoch '
        'but different locationName', () {
      final tokyo = getLocation('Asia/Tokyo');
      final ny = getLocation('America/New_York');
      final dt1 = EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, tokyo);
      final dt2 = dt1.inLocation(ny);

      expect(dt1.isAtSameMomentAs(dt2), isTrue);
      expect(dt1.millisecondsSinceEpoch, dt2.millisecondsSinceEpoch);
      expect(dt1.locationName, isNot(dt2.locationName));
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // DST Transitions (2025 Data)
  // ════════════════════════════════════════════════════════════════════════════

  group('DST transitions', () {
    group('Spring Forward (gap times adjusted forward)', () {
      test(
          'NY 2025-03-09 02:30 is adjusted to 03:30 EDT '
          '(02:00-03:00 does not exist, offset becomes -04:00)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 9, 2, 30, 0, 0, 0, ny);
        expect(dt.hour, 3);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset, const Duration(hours: -4));
      });

      test(
          'London 2025-03-30 01:30 is adjusted to 02:30 BST '
          '(01:00-02:00 does not exist, offset becomes +01:00)', () {
        final london = getLocation('Europe/London');
        final dt = EasyDateTime(2025, 3, 30, 1, 30, 0, 0, 0, london);
        expect(dt.hour, 2);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset, const Duration(hours: 1));
      });

      test(
          'Paris 2025-03-30 02:30 is adjusted to 03:30 CEST '
          '(02:00-03:00 does not exist, offset becomes +02:00)', () {
        final paris = getLocation('Europe/Paris');
        final dt = EasyDateTime(2025, 3, 30, 2, 30, 0, 0, 0, paris);
        expect(dt.hour, 3);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset, const Duration(hours: 2));
      });

      test(
          'Sydney 2025-10-05 02:30 is adjusted to 03:30 AEDT '
          '(02:00-03:00 does not exist, offset becomes +11:00)', () {
        final sydney = getLocation('Australia/Sydney');
        final dt = EasyDateTime(2025, 10, 5, 2, 30, 0, 0, 0, sydney);
        expect(dt.hour, 3);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset, const Duration(hours: 11));
      });
    });

    group('Fall Back (overlap times resolved)', () {
      test(
          'NY 2025-11-02 01:30 resolves to EDT (first occurrence) '
          'with offset -04:00', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 1, 30, 0, 0, 0, ny);
        expect(dt.hour, 1);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset, const Duration(hours: -4));
      });

      test(
          'London 2025-10-26 01:30 resolves to GMT (second occurrence) '
          'with offset +00:00', () {
        final london = getLocation('Europe/London');
        final dt = EasyDateTime(2025, 10, 26, 1, 30, 0, 0, 0, london);
        expect(dt.hour, 1);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset, Duration.zero);
      });

      test(
          'Sydney 2025-04-06 02:30 resolves to AEST (second occurrence) '
          'with offset +10:00', () {
        final sydney = getLocation('Australia/Sydney');
        final dt = EasyDateTime(2025, 4, 6, 2, 30, 0, 0, 0, sydney);
        expect(dt.hour, 2);
        expect(dt.minute, 30);
        expect(dt.timeZoneOffset, const Duration(hours: 10));
      });
    });

    group('Cross-DST arithmetic', () {
      test(
          'adding 2 hours to NY 01:30 EST on Spring Forward day '
          'yields 04:30 EDT (skipping non-existent 02:00-03:00)', () {
        final ny = getLocation('America/New_York');
        final before = EasyDateTime(2025, 3, 9, 1, 30, 0, 0, 0, ny);
        final after = before + const Duration(hours: 2);
        expect(after.hour, 4);
        expect(after.minute, 30);
        expect(after.timeZoneOffset, const Duration(hours: -4));
      });

      test(
          'difference between 01:00 and 04:00 on Spring Forward day '
          'is 2 hours (not 3) due to DST gap', () {
        final ny = getLocation('America/New_York');
        final t1 = EasyDateTime(2025, 3, 9, 1, 0, 0, 0, 0, ny);
        final t2 = EasyDateTime(2025, 3, 9, 4, 0, 0, 0, 0, ny);
        expect(t2.difference(t1).inHours, 2);
      });
    });

    group('UTC consistency through DST', () {
      test(
          'timeZoneOffset changes from -05:00 (EST) to -04:00 (EDT) '
          'at NY Spring Forward boundary', () {
        final ny = getLocation('America/New_York');
        final before = EasyDateTime(2025, 3, 9, 1, 59, 0, 0, 0, ny);
        final after = EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, ny);
        expect(before.timeZoneOffset, const Duration(hours: -5));
        expect(after.timeZoneOffset, const Duration(hours: -4));
      });

      test(
          'millisecondsSinceEpoch difference between 01:59:59.999 EST '
          'and 03:00:00.000 EDT is exactly 1 millisecond', () {
        final ny = getLocation('America/New_York');
        final last = EasyDateTime(2025, 3, 9, 1, 59, 59, 999, 0, ny);
        final first = EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, ny);
        expect(first.millisecondsSinceEpoch - last.millisecondsSinceEpoch, 1);
      });

      test(
          'toUtc() converts 01:00 EST to 06:00 UTC, '
          'and 03:00 EDT to 07:00 UTC', () {
        final ny = getLocation('America/New_York');
        expect(EasyDateTime(2025, 3, 9, 1, 0, 0, 0, 0, ny).toUtc().hour, 6);
        expect(EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, ny).toUtc().hour, 7);
      });
    });

    group('Non-DST timezones (constant offset year-round)', () {
      test(
          'Tokyo maintains +09:00 offset on US Spring Forward '
          'and Fall Back dates', () {
        final tokyo = getLocation('Asia/Tokyo');
        expect(
          EasyDateTime(2025, 3, 9, 12, 0, 0, 0, 0, tokyo).timeZoneOffset,
          const Duration(hours: 9),
        );
        expect(
          EasyDateTime(2025, 11, 2, 12, 0, 0, 0, 0, tokyo).timeZoneOffset,
          const Duration(hours: 9),
        );
      });

      test(
          'Shanghai maintains +08:00 offset on EU Spring Forward '
          'and Fall Back dates', () {
        final shanghai = getLocation('Asia/Shanghai');
        expect(
          EasyDateTime(2025, 3, 30, 12, 0, 0, 0, 0, shanghai).timeZoneOffset,
          const Duration(hours: 8),
        );
        expect(
          EasyDateTime(2025, 10, 26, 12, 0, 0, 0, 0, shanghai).timeZoneOffset,
          const Duration(hours: 8),
        );
      });
    });

    group('format() during DST', () {
      test('format("HH:mm") outputs "03:30" for NY 03:30 EDT', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 9, 3, 30, 0, 0, 0, ny);
        expect(dt.format('HH:mm'), '03:30');
      });

      test('format("HH:mm") outputs "01:30" for NY 01:30 overlap time', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 1, 30, 0, 0, 0, ny);
        expect(dt.format('HH:mm'), '01:30');
      });

      test('format("hh:mm a") outputs "12:30 AM" for London 00:30 before DST',
          () {
        final dt = EasyDateTime(2025, 3, 30, 0, 30, 0, 0, 0, TimeZones.london);
        expect(dt.format('hh:mm a'), '12:30 AM');
      });
    });

    group('Calendar day arithmetic across DST', () {
      test(
          'tomorrow preserves local time across Spring Forward '
          '(NY 2025-03-09 00:00 → 2025-03-10 00:00)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 9, 0, 0, 0, 0, 0, ny);
        final result = dt.tomorrow;

        expect(result.day, 10);
        expect(result.hour, 0);
        expect(result.minute, 0);
      });

      test(
          'tomorrow preserves local time across Fall Back '
          '(NY 2025-11-02 00:00 → 2025-11-03 00:00)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 0, 0, 0, 0, 0, ny);
        final result = dt.tomorrow;

        expect(result.day, 3);
        expect(result.hour, 0);
        expect(result.minute, 0);
      });

      test(
          'yesterday preserves local time across Spring Forward '
          '(NY 2025-03-10 00:00 → 2025-03-09 00:00)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 10, 0, 0, 0, 0, 0, ny);
        final result = dt.yesterday;

        expect(result.day, 9);
        expect(result.hour, 0);
        expect(result.minute, 0);
      });

      test(
          'yesterday preserves local time across Fall Back '
          '(NY 2025-11-03 00:00 → 2025-11-02 00:00)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 3, 0, 0, 0, 0, 0, ny);
        final result = dt.yesterday;

        expect(result.day, 2);
        expect(result.hour, 0);
        expect(result.minute, 0);
      });

      test(
          'addCalendarDays preserves local time across Spring Forward '
          '(NY 2025-03-08 12:30 +2 days → 2025-03-10 12:30)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 8, 12, 30, 0, 0, 0, ny);
        final result = dt.addCalendarDays(2);

        expect(result.day, 10);
        expect(result.hour, 12);
        expect(result.minute, 30);
      });

      test(
          'subtractCalendarDays preserves local time across Fall Back '
          '(NY 2025-11-03 12:30 -1 day → 2025-11-02 12:30)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 3, 12, 30, 0, 0, 0, ny);
        final result = dt.subtractCalendarDays(1);

        expect(result.day, 2);
        expect(result.hour, 12);
        expect(result.minute, 30);
      });

      test(
          'add(Duration) differs from addCalendarDays on Spring Forward day '
          '(physical vs calendar day semantics)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 9, 0, 0, 0, 0, 0, ny);

        final physical = dt.add(const Duration(days: 1));
        final calendar = dt.addCalendarDays(1);

        // Physical: adds 24 hours → lands at 01:00 (DST offset)
        expect(physical.hour, 1);

        // Calendar: preserves local time → stays at 00:00
        expect(calendar.hour, 0);

        // Both should be on March 10
        expect(physical.day, 10);
        expect(calendar.day, 10);
      });

      test(
          'add(Duration) differs from addCalendarDays on Fall Back day '
          '(physical vs calendar day semantics)', () {
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 0, 0, 0, 0, 0, ny);

        final physical = dt.add(const Duration(days: 1));
        final calendar = dt.addCalendarDays(1);

        // Physical: adds 24 hours → lands at 23:00 same day (25-hour day)
        expect(physical.day, 2);
        expect(physical.hour, 23);

        // Calendar: preserves local time → next day at 00:00
        expect(calendar.day, 3);
        expect(calendar.hour, 0);
      });
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Arithmetic Edge Cases
  // ════════════════════════════════════════════════════════════════════════════

  group('Arithmetic edge cases', () {
    test('adding Duration.zero preserves the original instant', () {
      final dt = EasyDateTime.utc(2025, 6, 15, 10, 0);
      final result = dt + Duration.zero;
      expect(result.isAtSameMomentAs(dt), isTrue);
    });

    test('subtracting 10 years (3650 days) changes year from 2025 to 2015', () {
      final dt = EasyDateTime.utc(2025, 6, 15);
      final past = dt - const Duration(days: 365 * 10);
      expect(past.year, 2015);
    });

    test('adding 1 microsecond increments microsecond field by 1', () {
      final dt = EasyDateTime.utc(2025, 6, 15, 10, 0, 0, 0, 0);
      final next = dt + const Duration(microseconds: 1);
      expect(next.microsecond, 1);
      expect(next.difference(dt).inMicroseconds, 1);
    });

    test('1001ms is correctly compared as after 1000ms', () {
      final dt1 = EasyDateTime.fromMillisecondsSinceEpoch(1000);
      final dt2 = EasyDateTime.fromMillisecondsSinceEpoch(1001);
      expect(dt1.isBefore(dt2), isTrue);
      expect(dt2.difference(dt1).inMilliseconds, 1);
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Comparison Edge Cases
  // ════════════════════════════════════════════════════════════════════════════

  group('Comparison edge cases', () {
    test('two identical UTC times are equal and have same hashCode', () {
      final dt1 = EasyDateTime.utc(2025, 6, 15, 10, 0);
      final dt2 = EasyDateTime.utc(2025, 6, 15, 10, 0);
      expect(dt1 == dt2, isTrue);
      expect(dt1.hashCode, dt2.hashCode);
    });

    test('list.sort() orders dates chronologically using compareTo', () {
      final list = [
        EasyDateTime.utc(2025, 6, 16),
        EasyDateTime.utc(2025, 6, 14),
        EasyDateTime.utc(2025, 6, 15),
      ];
      list.sort();
      expect(list.map((d) => d.day).toList(), [14, 15, 16]);
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Serialization Edge Cases
  // ════════════════════════════════════════════════════════════════════════════

  group('Serialization edge cases', () {
    test('toIso8601String preserves millisecond precision', () {
      final dt = EasyDateTime.utc(2025, 6, 15, 10, 30, 45, 123, 456);
      final restored = EasyDateTime.fromIso8601String(dt.toIso8601String());
      expect(restored.millisecond, 123);
    });

    test('toIso8601String includes +09:00 offset for Tokyo timezone', () {
      final tokyo = getLocation('Asia/Tokyo');
      final dt = EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, tokyo);
      expect(
        dt.toIso8601String(),
        anyOf(contains('+09:00'), contains('+0900')),
      );
    });

    test('ISO 8601 round-trip preserves the original instant', () {
      final original = EasyDateTime.utc(2025, 6, 15, 10, 30, 45, 123);
      final restored =
          EasyDateTime.fromIso8601String(original.toIso8601String());
      expect(restored.isAtSameMomentAs(original), isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // copyWith Edge Cases
  // ════════════════════════════════════════════════════════════════════════════

  group('copyWith edge cases', () {
    test('copyWith updates all specified fields correctly', () {
      final dt = EasyDateTime.utc(2025, 1, 1);
      final m = dt.copyWith(
        year: 2026,
        month: 12,
        day: 31,
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 999,
        microsecond: 999,
      );
      expect(m.year, 2026);
      expect(m.month, 12);
      expect(m.day, 31);
      expect(m.hour, 23);
      expect(m.minute, 59);
      expect(m.second, 59);
      expect(m.millisecond, 999);
      expect(m.microsecond, 999);
    });

    test('copyWith with no arguments returns equivalent instance', () {
      final dt = EasyDateTime.utc(2025, 6, 15, 10, 30);
      final same = dt.copyWith();
      expect(same.isAtSameMomentAs(dt), isTrue);
    });

    test('copyWith(location: Tokyo) changes location but preserves time values',
        () {
      final dt = EasyDateTime.utc(2025, 6, 15, 10, 0);
      final tokyo = getLocation('Asia/Tokyo');
      final m = dt.copyWith(location: tokyo);
      expect(m.locationName, 'Asia/Tokyo');
      expect(m.hour, 10);
    });

    test(
        'copyWithClamped clamps Feb 29 2024 to Feb 28 when year changed to 2025',
        () {
      final leap = EasyDateTime(2024, 2, 29, 12, 0);
      final clamped = leap.copyWithClamped(year: 2025);
      expect(clamped.month, 2);
      expect(clamped.day, 28);
    });

    test('copyWith overflows Feb 29 2024 to Mar 1 when year changed to 2025',
        () {
      final leap = EasyDateTime(2024, 2, 29, 12, 0);
      final overflow = leap.copyWith(year: 2025);
      expect(overflow.month, 3);
      expect(overflow.day, 1);
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Global Configuration Edge Cases
  // ════════════════════════════════════════════════════════════════════════════

  group('Global configuration edge cases', () {
    test('clearDefaultLocation does not throw when no default is set', () {
      EasyDateTime.clearDefaultLocation();
      EasyDateTime.clearDefaultLocation();
      expect(EasyDateTime.now().location, local);
    });

    test('setDefaultLocation and clearDefaultLocation cycle works correctly',
        () {
      final tokyo = getLocation('Asia/Tokyo');
      EasyDateTime.setDefaultLocation(tokyo);
      expect(EasyDateTime.getDefaultLocation()!.name, 'Asia/Tokyo');

      EasyDateTime.clearDefaultLocation();
      expect(EasyDateTime.getDefaultLocation(), isNull);
    });

    test(
        'new instances use default location when set '
        '(Tokyo as default yields Asia/Tokyo locationName)', () {
      final tokyo = getLocation('Asia/Tokyo');
      EasyDateTime.setDefaultLocation(tokyo);
      expect(EasyDateTime(2025, 6, 15, 10, 0).locationName, 'Asia/Tokyo');
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Parsing Edge Cases
  // ════════════════════════════════════════════════════════════════════════════

  group('Parsing edge cases', () {
    test('parsing "2025-02-30" overflows to 2025-03-02 (DateTime behavior)',
        () {
      final dt = EasyDateTime.parse('2025-02-30');
      expect(dt.month, 3);
      expect(dt.day, 2);
    });

    test('tryParse accepts slash format "2025/12/01"', () {
      final dt = EasyDateTime.tryParse('2025/12/01');
      expect(dt, isNotNull);
      expect(dt!.year, 2025);
      expect(dt.month, 12);
      expect(dt.day, 1);
    });

    test('tryParse accepts slash format with time "2025/12/01 10:30:00"', () {
      final dt = EasyDateTime.tryParse('2025/12/01 10:30:00');
      expect(dt, isNotNull);
      expect(dt!.hour, 10);
      expect(dt.minute, 30);
    });

    test(
        'parse accepts ISO 8601 variants: date-only, with T, with Z, with offset',
        () {
      expect(EasyDateTime.parse('2025-12-01').year, 2025);
      expect(EasyDateTime.parse('2025-12-01T10:30:00').hour, 10);
      expect(EasyDateTime.parse('2025-12-01T10:30:00Z').locationName, 'UTC');
      expect(EasyDateTime.parse('2025-12-01T10:30:00+09:00'), isNotNull);
    });

    test('tryParse handles very long input efficiently (<100ms)', () {
      final input = '2025-01-01${' ' * 10000}';
      final start = DateTime.now();
      final result = EasyDateTime.tryParse(input);
      final elapsed = DateTime.now().difference(start);
      expect(elapsed.inMilliseconds, lessThan(100));
      expect(result, isNotNull);
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Format Edge Cases
  // ════════════════════════════════════════════════════════════════════════════

  group('Format edge cases', () {
    test('unclosed quote in format pattern is treated as literal text', () {
      final dt = EasyDateTime(2025, 1, 1, 12, 0, 0);
      expect(dt.format("'Hello world"), 'Hello world');
    });

    test('empty quotes in format pattern produce empty string', () {
      final dt = EasyDateTime(2025, 1, 1, 12, 0, 0);
      expect(dt.format("''"), '');
    });

    test('quoted tokens in format pattern are not interpreted', () {
      final dt = EasyDateTime(2025, 1, 1, 12, 0, 0);
      expect(dt.format("'yyyy'"), 'yyyy');
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Precision Edge Cases
  // ════════════════════════════════════════════════════════════════════════════

  group('Precision edge cases', () {
    test('toUtc and inLocation roundtrip preserves microsecond precision', () {
      final now = EasyDateTime.now();
      final utc = now.toUtc();
      final back = utc.inLocation(now.location);
      expect(back.microsecondsSinceEpoch, now.microsecondsSinceEpoch);
      expect(back.isAtSameMomentAs(now), isTrue);
    });
  });
}
