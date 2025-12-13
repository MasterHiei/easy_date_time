/// User Scenario Tests
///
/// Simulates real user workflows to ensure core scenarios are properly tested.
/// Each scenario represents a common use case that developers encounter
/// when working with date/time in production applications.
library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('Scenario 1: Flutter App Startup', () {
    test('gets current time after initialization', () {
      // User: calls EasyDateTime.initializeTimeZone() in main(), then gets current time
      final now = EasyDateTime.now();

      expect(now, isNotNull);
      expect(now.year, greaterThanOrEqualTo(2024));
    });

    test('sets global default timezone', () {
      // User: sets app default timezone to Shanghai for a China-focused app
      EasyDateTime.setDefaultLocation(TimeZones.shanghai);
      final now = EasyDateTime.now();

      expect(now.locationName, 'Asia/Shanghai');
    });
  });

  group('Scenario 2: API Response Handling', () {
    test('parses backend ISO 8601 datetime with timezone offset', () {
      // Backend returns: "2025-12-07T10:30:00+08:00"
      // User expects: hour=10, not converted to local time
      const apiResponse = '2025-12-07T10:30:00+08:00';
      final dt = EasyDateTime.parse(apiResponse);

      expect(dt.hour, 10);
      expect(dt.minute, 30);
    });

    test('parses backend UTC datetime', () {
      // Backend returns: "2025-12-07T02:30:00Z"
      const apiResponse = '2025-12-07T02:30:00Z';
      final dt = EasyDateTime.parse(apiResponse);

      expect(dt.hour, 2);
      expect(dt.locationName, 'UTC');
    });

    test('returns null for invalid input (tryParse)', () {
      // User: safely handles potentially invalid input from API
      const invalidInput = 'not-a-date';
      final dt = EasyDateTime.tryParse(invalidInput);

      expect(dt, isNull);
    });

    test('JSON serialization roundtrip', () {
      // User: uses with json_serializable or manual JSON encoding
      final original = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
      final json = original.toIso8601String();
      final restored = EasyDateTime.fromIso8601String(json);

      expect(restored.isAtSameMomentAs(original), isTrue);
    });
  });

  group('Scenario 3: E-Commerce App - Promotion Time Handling', () {
    test('checks if promotion has started', () {
      // User: determines if current time is after promotion start
      final promotionStart = EasyDateTime(2020, 1, 1, 0, 0);
      final now = EasyDateTime.now();

      expect(now.isAfter(promotionStart), isTrue);
    });

    test('calculates remaining time until promotion ends', () {
      // User: shows countdown timer for promotion end
      final promotionEnd = EasyDateTime(2099, 12, 31, 23, 59, 59);
      final now = EasyDateTime.now();
      final remaining = promotionEnd.difference(now);

      expect(remaining.inDays, greaterThan(0));
    });

    test('checks if today is a promotion day', () {
      // User: shows special UI for today's promotions
      final now = EasyDateTime.now();

      expect(now.isToday, isTrue);
      expect(now.isTomorrow, isFalse);
      expect(now.isYesterday, isFalse);
    });
  });

  group('Scenario 4: Calendar App - Date Operations', () {
    test('gets start and end of a day', () {
      // User: queries events within a specific day
      final dt = EasyDateTime(2025, 12, 7, 15, 30);

      final startOfDay = dt.startOfDay;
      final endOfDay = dt.endOfDay;

      expect(startOfDay.hour, 0);
      expect(startOfDay.minute, 0);
      expect(endOfDay.hour, 23);
      expect(endOfDay.minute, 59);
      expect(endOfDay.second, 59);
    });

    test('gets first and last day of month', () {
      // User: shows monthly calendar view
      final dt = EasyDateTime(2025, 2, 15);

      final startOfMonth = dt.startOfMonth;
      final endOfMonth = dt.endOfMonth;

      expect(startOfMonth.day, 1);
      expect(endOfMonth.day, 28); // 2025 February is not a leap year
    });

    test('navigates to tomorrow and yesterday', () {
      // User: implements day navigation in calendar
      final today = EasyDateTime(2025, 12, 7, 10, 30);

      final tomorrow = today.tomorrow;
      final yesterday = today.yesterday;

      expect(tomorrow.day, 8);
      expect(yesterday.day, 6);
    });

    test('adds duration for scheduling', () {
      // User: schedules a meeting 2.5 hours from now
      final dt = EasyDateTime(2025, 12, 7, 10, 0);
      final later = dt + const Duration(hours: 2, minutes: 30);

      expect(later.hour, 12);
      expect(later.minute, 30);
    });
  });

  group('Scenario 5: International App - Timezone Conversion', () {
    test('converts local time to another timezone', () {
      // User: in Shanghai, wants to know corresponding time in New York
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

      // Shanghai 20:00 = UTC 12:00 = New York 07:00 (EST winter time)
      expect(newYork.hour, 7);
      expect(shanghai.isAtSameMomentAs(newYork), isTrue);
    });

    test('converts to UTC for API requests', () {
      // User: sends UTC time to backend regardless of local timezone
      final tokyo = EasyDateTime(
        2025,
        12,
        7,
        21,
        0,
        0,
        0,
        0,
        TimeZones.tokyo,
      );
      final utc = tokyo.toUtc();

      expect(utc.hour, 12); // Tokyo 21:00 = UTC 12:00
      expect(utc.locationName, 'UTC');
    });
  });

  group('Scenario 6: Data Storage and Comparison', () {
    test('gets timestamp for database storage', () {
      // User: stores datetime as integer in SQLite/shared_preferences
      final dt = EasyDateTime.utc(2025, 1, 1, 0, 0);
      final timestamp = dt.millisecondsSinceEpoch;

      // Can store to database
      expect(timestamp, isPositive);

      // Can restore from database
      final restored = EasyDateTime.fromMillisecondsSinceEpoch(timestamp);
      expect(restored.isAtSameMomentAs(dt), isTrue);
    });

    test('compares two datetimes', () {
      // User: sorts events by time or checks order
      final earlier = EasyDateTime(2025, 12, 7, 10, 0);
      final later = EasyDateTime(2025, 12, 7, 11, 0);

      expect(earlier < later, isTrue);
      expect(later > earlier, isTrue);
      expect(earlier <= later, isTrue);
      expect(later >= earlier, isTrue);
    });

    test('checks datetime equality', () {
      // User: checks if two events are at the same time
      final dt1 = EasyDateTime.utc(2025, 12, 7, 10, 30);
      final dt2 = EasyDateTime.utc(2025, 12, 7, 10, 30);

      expect(dt1 == dt2, isTrue);
    });
  });

  group('Scenario 7: Standard DateTime Interoperability', () {
    test('converts from DateTime', () {
      // User: has existing DateTime from third-party library
      final stdDt = DateTime(2025, 12, 7, 10, 30);
      final easyDt = stdDt.toEasyDateTime();

      expect(easyDt.year, 2025);
      expect(easyDt.month, 12);
      expect(easyDt.day, 7);
    });

    test('converts back to DateTime', () {
      // User: needs DateTime for third-party library that doesn't support EasyDateTime
      final easyDt = EasyDateTime(2025, 12, 7, 10, 30);
      final stdDt = easyDt.toDateTime();

      expect(stdDt, isA<DateTime>());
      expect(stdDt.year, 2025);
    });
  });

  group('Scenario 8: Partial Field Modification with copyWith', () {
    test('modifies time while preserving date', () {
      // User: reschedules meeting to different time on same day
      final dt = EasyDateTime(2025, 12, 7, 10, 30);
      final newDt = dt.copyWith(hour: 15, minute: 45);

      expect(newDt.day, 7); // Date unchanged
      expect(newDt.hour, 15); // Time changed
      expect(newDt.minute, 45);
    });

    test('modifies date while preserving time', () {
      // User: moves recurring meeting to different date
      final dt = EasyDateTime(2025, 12, 7, 10, 30);
      final newDt = dt.copyWith(month: 6, day: 15);

      expect(newDt.month, 6);
      expect(newDt.day, 15);
      expect(newDt.hour, 10); // Time unchanged
    });
  });

  group('Scenario 9: Formatting for Display', () {
    test('gets date string for UI', () {
      // User: displays date in list item or header
      final dt = EasyDateTime(2025, 12, 7, 10, 30);
      final dateStr = dt.toDateString();

      expect(dateStr, '2025-12-07');
    });

    test('gets time string for UI', () {
      // User: displays time in schedule view
      final dt = EasyDateTime(2025, 12, 7, 10, 30, 45);
      final timeStr = dt.toTimeString();

      expect(timeStr, '10:30:45');
    });

    test('gets ISO 8601 string for API', () {
      // User: sends datetime to backend in standard format
      final dt = EasyDateTime.utc(2025, 12, 7, 10, 30);
      final isoStr = dt.toIso8601String();

      expect(isoStr, contains('2025-12-07'));
      expect(isoStr, contains('10:30'));
    });
  });

  group('Scenario 10: Error Handling', () {
    test('throws exception for invalid date format', () {
      // User: handles parsing errors from user input
      expect(
        () => EasyDateTime.parse('invalid-date'),
        throwsA(isA<InvalidDateFormatException>()),
      );
    });

    test('throws exception for invalid timezone', () {
      // User: handles invalid timezone from configuration
      expect(
        () => getLocation('Invalid/Zone'),
        throwsA(isA<tz.LocationNotFoundException>()),
      );
    });
  });

  group('Scenario 11: Leap Year and Month Boundary Handling', () {
    test('handles leap year February correctly', () {
      // User: schedules recurring event on Feb 29
      final leapYear = EasyDateTime(2024, 2, 29);
      expect(leapYear.day, 29);

      // Moving to non-leap year with copyWithClamped
      final nextYear = leapYear.copyWithClamped(year: 2025);
      expect(nextYear.day, 28); // Clamped to Feb 28
    });

    test('handles month-end overflow with copyWith', () {
      // User: moves event from Jan 31 to February
      final jan31 = EasyDateTime(2025, 1, 31);
      final feb = jan31.copyWith(month: 2);

      // Standard copyWith allows overflow (like DateTime)
      expect(feb.month, 3); // Overflows to March 3
    });

    test('handles month-end with copyWithClamped', () {
      // User: wants safe month navigation without overflow
      final jan31 = EasyDateTime(2025, 1, 31);
      final feb = jan31.copyWithClamped(month: 2);

      expect(feb.month, 2);
      expect(feb.day, 28); // Clamped to last day of February
    });
  });
}
