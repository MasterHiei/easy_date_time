import 'package:easy_date_time/easy_date_time.dart';

import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('EasyDateTimeFormatter', () {
    test('formats simple tokens correctly', () {
      final formatter = EasyDateTimeFormatter('yyyy-MM-dd');
      final dt = EasyDateTime(2025, 12, 1);
      expect(formatter.format(dt), '2025-12-01');
    });

    test('formats time tokens correctly', () {
      final formatter = EasyDateTimeFormatter('HH:mm:ss');
      final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
      expect(formatter.format(dt), '14:30:45');
    });

    test('reuses formatter instance for multiple dates', () {
      final formatter = EasyDateTimeFormatter('yyyy-MM-dd');
      final dt1 = EasyDateTime(2025, 1, 1);
      final dt2 = EasyDateTime(2025, 12, 31);

      expect(formatter.format(dt1), '2025-01-01');
      expect(formatter.format(dt2), '2025-12-31');
    });

    test('handles escaped text', () {
      final formatter = EasyDateTimeFormatter("'Date:' yyyy-MM-dd");
      final dt = EasyDateTime(2025, 12, 1);
      expect(formatter.format(dt), 'Date: 2025-12-01');
    });

    test('handles complicated pattern', () {
      final formatter = EasyDateTimeFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS 'Z'");
      final dt = EasyDateTime(2025, 6, 15, 14, 30, 45, 123);
      expect(formatter.format(dt), '2025-06-15T14:30:45.123 Z');
    });

    test('handles literal characters mixed with tokens', () {
      final formatter = EasyDateTimeFormatter('yyyy/MM/dd HH:mm');
      final dt = EasyDateTime(2025, 6, 15, 14, 30);
      expect(formatter.format(dt), '2025/06/15 14:30');
    });

    test('handles 12-hour format with AM/PM', () {
      final formatter = EasyDateTimeFormatter('hh:mm a');
      final dtAM = EasyDateTime(2025, 6, 15, 9, 30);
      final dtPM = EasyDateTime(2025, 6, 15, 14, 30);

      expect(formatter.format(dtAM), '09:30 AM');
      expect(formatter.format(dtPM), '02:30 PM');
    });

    test('handles timezone awareness (same moment, different representation)',
        () {
      final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');

      // UTC
      final utc = EasyDateTime.utc(2025, 1, 1, 0, 0); // 00:00 UTC
      // NY (-5)
      final ny = utc.inLocation(TimeZones.newYork); // 19:00 Previous Day

      expect(formatter.format(utc), '2025-01-01 00:00');
      expect(formatter.format(ny), '2024-12-31 19:00');
    });

    test('handles empty pattern', () {
      final formatter = EasyDateTimeFormatter('');
      final dt = EasyDateTime(2025, 1, 1);
      expect(formatter.format(dt), '');
    });

    test('handles pattern with no tokens', () {
      final formatter = EasyDateTimeFormatter('No Token');
      final dt = EasyDateTime(2025, 1, 1);
      expect(formatter.format(dt), 'No Token');
    });

    test('replaces tokens in literal text unless escaped', () {
      // 's' is a token for seconds. 't', 'e', 'x', 't' are not tokens.
      final formatter = EasyDateTimeFormatter('test');
      final dt = EasyDateTime(2025, 1, 1, 10, 30, 05);
      expect(formatter.format(dt), 'te5t'); // s -> 5
    });

    test('handles unclosed quote (WYSIWYG)', () {
      final formatter = EasyDateTimeFormatter("'Unclosed");
      final dt = EasyDateTime(2025, 1, 1);
      expect(formatter.format(dt), 'Unclosed');
    });

    test('handles unpadded 12-hour format (h token)', () {
      final formatter = EasyDateTimeFormatter('h:m:s a');
      final dtMorning = EasyDateTime(2025, 6, 15, 9, 5, 3);
      final dtAfternoon = EasyDateTime(2025, 6, 15, 14, 30, 45);
      final dtMidnight = EasyDateTime(2025, 6, 15, 0, 0, 0);
      final dtNoon = EasyDateTime(2025, 6, 15, 12, 0, 0);

      expect(formatter.format(dtMorning), '9:5:3 AM');
      expect(formatter.format(dtAfternoon), '2:30:45 PM');
      expect(formatter.format(dtMidnight), '12:0:0 AM'); // midnight = 12 AM
      expect(formatter.format(dtNoon), '12:0:0 PM'); // noon = 12 PM
    });

    test('handles unpadded minute and second tokens (m, s)', () {
      final formatter = EasyDateTimeFormatter('H:m:s');
      final dt = EasyDateTime(2025, 1, 1, 5, 3, 7);
      expect(formatter.format(dt), '5:3:7');
    });

    test('handles default token branch for unknown tokens', () {
      // Single characters that are not tokens should pass through
      // Note: X is a token (timezone), so we use other letters
      final formatter = EasyDateTimeFormatter('QWZ');
      final dt = EasyDateTime(2025, 1, 1);
      expect(formatter.format(dt), 'QWZ');
    });

    // Validates that all tokens are correctly formatted in various scenarios
    group('Comprehensive Token Formatting', () {
      test('formats weekday (EEE) and month (MMM) tokens', () {
        final formatter = EasyDateTimeFormatter('EEE, MMM d');
        // 2025-12-01 is Monday
        final dt = EasyDateTime(2025, 12, 1);
        expect(formatter.format(dt), 'Mon, Dec 1');
      });

      test('formats timezone tokens (UTC)', () {
        final formatter = EasyDateTimeFormatter('xxxxx xxxx xx X');
        final dt = EasyDateTime.utc(2025, 1, 1);

        // xxxxx: +00:00, xxxx: +0000, xx: +00, X: Z
        expect(formatter.format(dt), '+00:00 +0000 +00 Z');
      });

      test('formats timezone tokens (Positive Offset)', () {
        final formatter = EasyDateTimeFormatter('xxxxx xxxx xx X');
        final location = TimeZones.shanghai; // +08:00
        final dt = EasyDateTime(2025, 1, 1).inLocation(location);

        // xxxxx: +08:00, xxxx: +0800, xx: +08, X: +0800
        expect(formatter.format(dt), '+08:00 +0800 +08 +0800');
      });

      test('formats timezone tokens (Negative Offset)', () {
        final formatter = EasyDateTimeFormatter('xxxxx xxxx xx X');
        final location = TimeZones.newYork; // -05:00 in Jan
        final dt = EasyDateTime(2025, 1, 1).inLocation(location);

        // xxxxx: -05:00, xxxx: -0500, xx: -05, X: -0500
        expect(formatter.format(dt), '-05:00 -0500 -05 -0500');
      });

      test('formats timezone tokens (Minutes Offset)', () {
        final formatter = EasyDateTimeFormatter('xxxxx xxxx xx');
        final location = TimeZones.mumbai; // +05:30
        final dt = EasyDateTime(2025, 1, 1).inLocation(location);

        // xxxxx: +05:30, xxxx: +0530, xx: +0530
        expect(formatter.format(dt), '+05:30 +0530 +0530');
      });

      test('formats short timezone offset with minutes', () {
        final formatter = EasyDateTimeFormatter('xx');
        final location = TimeZones.mumbai; // +05:30
        final dt = EasyDateTime(2025, 1, 1).inLocation(location);
        expect(formatter.format(dt), '+0530');
      });

      test('formats millisecond tokens (S, SSS)', () {
        final formatter = EasyDateTimeFormatter('S SSS');
        final dt = EasyDateTime(2025, 1, 1, 0, 0, 0, 5);

        expect(formatter.format(dt), '5 005');
      });
    });
  });

  group('EasyDateTime.format() (Extension)', () {
    test('formats simple tokens', () {
      final dt = EasyDateTime(2025, 12, 1);
      expect(dt.format('yyyy-MM-dd'), '2025-12-01');
    });

    test('formats timezone tokens', () {
      final dt = EasyDateTime.utc(2025, 1, 1);
      // Extension logic duplicate of Formatter, validating it works too
      expect(dt.format('xxxxx xxxx xx X'), '+00:00 +0000 +00 Z');
    });

    test('handles 12-hour format', () {
      final dt = EasyDateTime(2025, 6, 15, 14, 30);
      expect(dt.format('hh:mm a'), '02:30 PM');
    });

    test('handles literals', () {
      final dt = EasyDateTime(2025, 1, 1);
      expect(dt.format("'Date:' yyyy"), 'Date: 2025');
    });

    test('handles unknown tokens', () {
      final dt = EasyDateTime(2025, 1, 1);
      expect(dt.format('QWZ'), 'QWZ');
    });

    test('formats short timezone offset with minutes', () {
      final dt =
          EasyDateTime(2025, 1, 1).inLocation(TimeZones.mumbai); // +05:30
      expect(dt.format('xx'), '+0530');
    });
  });

  group('Named Constructors', () {
    test('isoDate() formats for API date fields', () {
      final formatter = EasyDateTimeFormatter.isoDate();
      final dt = EasyDateTime(2025, 12, 15);

      expect(formatter.format(dt), '2025-12-15');
      expect(formatter.pattern, 'yyyy-MM-dd');
    });

    test('isoTime() formats for time displays', () {
      final formatter = EasyDateTimeFormatter.isoTime();
      final dt = EasyDateTime(2025, 12, 15, 14, 30, 45);

      expect(formatter.format(dt), '14:30:45');
    });

    test('isoDateTime() formats for ISO timestamps', () {
      final formatter = EasyDateTimeFormatter.isoDateTime();
      final dt = EasyDateTime(2025, 12, 15, 14, 30, 45);

      expect(formatter.format(dt), '2025-12-15T14:30:45');
    });

    test('rfc2822() formats for email headers', () {
      final formatter = EasyDateTimeFormatter.rfc2822();
      final dt = EasyDateTime.utc(2025, 12, 15, 14, 30, 45);

      final result = formatter.format(dt);

      expect(result, contains('Mon, 15 Dec 2025'));
      expect(result, contains('14:30:45'));
    });

    test('time12Hour() formats AM/PM time', () {
      final formatter = EasyDateTimeFormatter.time12Hour();
      final morning = EasyDateTime(2025, 12, 15, 9, 30);
      final afternoon = EasyDateTime(2025, 12, 15, 14, 30);

      expect(formatter.format(morning), '09:30 AM');
      expect(formatter.format(afternoon), '02:30 PM');
    });

    test('time24Hour() formats 24-hour time', () {
      final formatter = EasyDateTimeFormatter.time24Hour();
      final dt = EasyDateTime(2025, 12, 15, 14, 30);

      expect(formatter.format(dt), '14:30');
    });

    test('named constructors share cached instances', () {
      final f1 = EasyDateTimeFormatter.isoDate();
      final f2 = EasyDateTimeFormatter.isoDate();
      final f3 = EasyDateTimeFormatter(DateTimeFormats.isoDate);

      expect(identical(f1, f2), isTrue);
      expect(identical(f1, f3), isTrue);
    });
  });

  group('Pattern Composition', () {
    test('combineFormatters() merges two patterns', () {
      final dateFormatter = EasyDateTimeFormatter.isoDate();
      final timeFormatter = EasyDateTimeFormatter(' HH:mm:ss');

      final combined = dateFormatter.combineFormatters(timeFormatter);
      final dt = EasyDateTime(2025, 12, 15, 14, 30, 45);

      expect(combined.format(dt), '2025-12-15 14:30:45');
      expect(combined.pattern, 'yyyy-MM-dd HH:mm:ss');
    });

    test('addPattern() appends to existing pattern', () {
      final dateFormatter = EasyDateTimeFormatter('yyyyMMdd_HHmmss');
      final withExtension = dateFormatter.addPattern("'.log'");
      final dt = EasyDateTime(2025, 12, 15, 14, 30, 45);

      expect(withExtension.format(dt), '20251215_143045.log');
    });

    test('combined formatters share cached instances', () {
      final f1 = EasyDateTimeFormatter.isoDate();
      final f2 = EasyDateTimeFormatter(' HH:mm');
      final combined1 = f1.combineFormatters(f2);
      final combined2 = f1.combineFormatters(f2);

      expect(identical(combined1, combined2), isTrue);
    });

    test('clearCache() removes all cached formatters', () {
      // Create some formatters
      final f1 = EasyDateTimeFormatter('yyyy-MM-dd');
      final f2 = EasyDateTimeFormatter('HH:mm:ss');

      // Clear cache
      EasyDateTimeFormatter.clearCache();

      // New formatters should be different instances
      final f3 = EasyDateTimeFormatter('yyyy-MM-dd');
      final f4 = EasyDateTimeFormatter('HH:mm:ss');

      expect(identical(f1, f3), isFalse);
      expect(identical(f2, f4), isFalse);
    });

    test('clearCache() allows formatter to be recreated', () {
      final original = EasyDateTimeFormatter.isoDate();
      final dt = EasyDateTime(2025, 12, 15);

      // Verify original works
      expect(original.format(dt), '2025-12-15');

      // Clear and recreate
      EasyDateTimeFormatter.clearCache();
      final recreated = EasyDateTimeFormatter.isoDate();

      // Recreated should work identically
      expect(recreated.format(dt), '2025-12-15');
      expect(identical(original, recreated), isFalse);
    });
  });
}
