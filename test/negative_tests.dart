import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('Negative test cases - parse() error handling', () {
    test('parse() throws FormatException on completely invalid input', () {
      expect(
        () => EasyDateTime.parse('not-a-valid-date-at-all'),
        throwsFormatException,
      );
    });

    test('parse() throws FormatException on empty string', () {
      expect(
        () => EasyDateTime.parse(''),
        throwsFormatException,
      );
    });

    test('parse() throws FormatException on whitespace only', () {
      expect(
        () => EasyDateTime.parse('   '),
        throwsFormatException,
      );
    });

    test('parse() throws FormatException on nonsense input', () {
      expect(
        () => EasyDateTime.parse('🎄🎅🎁'),
        throwsFormatException,
      );
    });
  });

  group('Negative test cases - tryParse() safe handling', () {
    test('tryParse() safely handles empty string', () {
      expect(EasyDateTime.tryParse(''), isNull);
    });

    test('tryParse() safely handles whitespace only', () {
      expect(EasyDateTime.tryParse('   '), isNull);
    });

    test('tryParse() safely handles invalid input', () {
      expect(EasyDateTime.tryParse('not-a-date'), isNull);
    });

    test('tryParse() safely handles emoji', () {
      expect(EasyDateTime.tryParse('🎄'), isNull);
    });

    test('tryParse() safely handles null-like strings', () {
      expect(EasyDateTime.tryParse('null'), isNull);
    });

    test('tryParse() safely handles very long strings', () {
      final longString = 'x' * 200;
      expect(EasyDateTime.tryParse(longString), isNull);
    });
  });

  group('Negative test cases - constructor validation', () {
    test('constructor with invalid month 0 rolls backward', () {
      // Dart automatically rolls backward to December of previous year
      final dt = EasyDateTime(2025, 0, 1);
      expect(dt.year, equals(2024));
      expect(dt.month, equals(12));
      expect(dt.day, equals(1));
    });

    test('constructor with invalid month 13 rolls forward', () {
      // Dart automatically rolls forward to January of next year
      final dt = EasyDateTime(2025, 13, 1);
      expect(dt.year, equals(2026));
      expect(dt.month, equals(1));
      expect(dt.day, equals(1));
    });

    test('constructor with invalid day 0 rolls to previous month', () {
      final dt = EasyDateTime(2025, 1, 0);
      expect(dt.month, equals(12));
      expect(dt.year, equals(2024));
      expect(dt.day, equals(31));
    });

    test('constructor with invalid day 32 rolls forward', () {
      final dt = EasyDateTime(2025, 1, 32);
      expect(dt.month, equals(2));
      expect(dt.day, equals(1));
    });

    test('constructor with invalid hour 24 rolls forward', () {
      final dt = EasyDateTime(2025, 1, 1, 24);
      expect(dt.day, equals(2));
      expect(dt.hour, equals(0));
    });

    test('constructor with invalid minute 60 rolls forward', () {
      final dt = EasyDateTime(2025, 1, 1, 0, 60);
      expect(dt.hour, equals(1));
      expect(dt.minute, equals(0));
    });

    test('constructor with invalid second 60 rolls forward', () {
      final dt = EasyDateTime(2025, 1, 1, 0, 0, 60);
      expect(dt.minute, equals(1));
      expect(dt.second, equals(0));
    });

    test('constructor with negative microsecond rolls backward', () {
      // Dart automatically rolls backward to previous day
      final dt = EasyDateTime(2025, 1, 1, 0, 0, 0, 0, -1);
      expect(dt.day, equals(31));
      expect(dt.year, equals(2024));
    });

    test('constructor with Feb 29 on non-leap year rolls forward', () {
      // Dart automatically rolls forward to March 1 instead of throwing
      final dt = EasyDateTime(2023, 2, 29); // 2023 is not a leap year
      expect(dt.month, equals(3)); // Rolls to March
      expect(dt.day, equals(1)); // Day 1
    });
  });

  group('Negative test cases - invalid timezone', () {
    test('getLocation throws on invalid timezone identifier', () {
      expect(
        () => getLocation('Invalid/Timezone'),
        throwsException,
      );
    });

    test('getLocation throws on empty timezone string', () {
      expect(
        () => getLocation(''),
        throwsException,
      );
    });

    test('getLocation throws on partial timezone name', () {
      expect(
        () => getLocation('Asia'), // Missing specific location
        throwsException,
      );
    });
  });

  group('Negative test cases - boundary values', () {
    test('very large year values', () {
      final dt = EasyDateTime(9999, 12, 31, 23, 59, 59);
      expect(dt.year, equals(9999));
    });

    test('minimum year values', () {
      final dt = EasyDateTime(1, 1, 1, 0, 0, 0);
      expect(dt.year, equals(1));
    });

    test('February 29 on leap year 2024 is valid', () {
      final dt = EasyDateTime(2024, 2, 29); // 2024 is a leap year
      expect(dt.day, equals(29));
    });

    test('December 31 at 23:59:59', () {
      final dt = EasyDateTime(2025, 12, 31, 23, 59, 59);
      expect(dt.month, equals(12));
      expect(dt.day, equals(31));
      expect(dt.hour, equals(23));
      expect(dt.minute, equals(59));
      expect(dt.second, equals(59));
    });

    test('January 1 at 00:00:00', () {
      final dt = EasyDateTime(2025, 1, 1, 0, 0, 0);
      expect(dt.month, equals(1));
      expect(dt.day, equals(1));
      expect(dt.hour, equals(0));
      expect(dt.minute, equals(0));
      expect(dt.second, equals(0));
    });
  });

  group('Negative test cases - null safety', () {
    test('now() without explicit location uses default or local', () {
      final now = EasyDateTime.now();
      expect(now, isNotNull);
      expect(now.location, isNotNull);
    });

    test('fromDateTime with null location uses default', () {
      final dt = EasyDateTime.fromDateTime(DateTime.now());
      expect(dt, isNotNull);
      expect(dt.location, isNotNull);
    });

    test('inLocation returns non-null EasyDateTime', () {
      final tokyo = EasyDateTime.now(location: getLocation('Asia/Tokyo'));
      final london = tokyo.inLocation(getLocation('Europe/London'));
      expect(london, isNotNull);
      expect(london.location.name, equals('Europe/London'));
    });

    test('isAtSameMoment works across timezones', () {
      final tokyo =
          EasyDateTime(2025, 6, 15, 20, 0, 0, 0, 0, getLocation('Asia/Tokyo'));
      final london = tokyo.inLocation(getLocation('Europe/London'));

      expect(tokyo.isAtSameMomentAs(london), isTrue);
    });
  });

  group('Negative test cases - immutability', () {
    test('modifying returned date does not affect original', () {
      final original = EasyDateTime(2025, 1, 1, 10, 30);
      final modified = original + Duration(days: 1);

      expect(original.day, equals(1));
      expect(modified.day, equals(2));
    });

    test('arithmetic operations return new instances', () {
      final dt1 = EasyDateTime(2025, 1, 1);
      final dt2 = dt1 + Duration(days: 1);

      expect(identical(dt1, dt2), isFalse);
    });

    test('timezone conversion returns new instance', () {
      final tokyo = EasyDateTime.now(location: getLocation('Asia/Tokyo'));
      final london = tokyo.inLocation(getLocation('Europe/London'));

      expect(identical(tokyo, london), isFalse);
    });
  });

  group('Negative test cases - crossing month boundaries', () {
    test('adding days crosses month boundary', () {
      final endOfMonth = EasyDateTime(2025, 1, 31);
      final nextMonth = endOfMonth + Duration(days: 1);
      expect(nextMonth.month, equals(2));
      expect(nextMonth.day, equals(1));
    });

    test('subtracting days crosses month boundary backward', () {
      final firstOfMonth = EasyDateTime(2025, 2, 1);
      final lastOfPrevMonth = firstOfMonth - Duration(days: 1);
      expect(lastOfPrevMonth.month, equals(1));
      expect(lastOfPrevMonth.day, equals(31));
    });

    test('adding days crosses year boundary', () {
      final endOfYear = EasyDateTime(2025, 12, 31);
      final nextYear = endOfYear + Duration(days: 1);
      expect(nextYear.year, equals(2026));
      expect(nextYear.month, equals(1));
      expect(nextYear.day, equals(1));
    });
  });

  group('Performance test cases', () {
    test('parse() performance on valid ISO 8601', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        EasyDateTime.parse('2025-12-01T10:30:00Z');
      }
      stopwatch.stop();

      // Should be fast - parsing 1000 times in under 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('now() performance', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        EasyDateTime.now();
      }
      stopwatch.stop();

      // Creating 10000 instances should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Edge cases for isToday/isTomorrow/isYesterday', () {
    test('isToday is false for future dates', () {
      final today = EasyDateTime.now();
      final tomorrow = today + Duration(days: 1);
      expect(tomorrow.isToday, isFalse);
    });

    test('isTomorrow is false for today', () {
      final today = EasyDateTime.now();
      expect(today.isTomorrow, isFalse);
    });

    test('isYesterday is false for today', () {
      final today = EasyDateTime.now();
      expect(today.isYesterday, isFalse);
    });

    test('isToday is based on local timezone date', () {
      // isToday compares against "today" in the instance's timezone
      // So if we get now() in Tokyo, isToday should be true
      final tokyo = EasyDateTime.now(location: getLocation('Asia/Tokyo'));
      expect(tokyo.isToday, isTrue);

      // Converting to another timezone doesn't change isToday result
      // because isToday uses the instance's own timezone for comparison
      final utc = tokyo.toUtc();
      expect(utc.isToday, isTrue); // Same moment, also today in UTC
    });
  });
}
