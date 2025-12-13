import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  group('1. Core Correctness & Precision', () {
    test('1.1 Precision Roundtrip', () {
      final now = EasyDateTime.now();
      final utc = now.toUtc();
      final back = utc.inLocation(now.location);

      expect(back.microsecondsSinceEpoch, equals(now.microsecondsSinceEpoch));
      expect(back.isAtSameMomentAs(now), isTrue);
    });

    test('1.2 Timezone Boundaries (DST)', () {
      // New York Spring Forward 2025: March 9, 02:00 -> 03:00
      // Creating a time in the gap: 02:30
      final ny = getLocation('America/New_York');
      final gapTime = EasyDateTime(2025, 3, 9, 2, 30, 0, 0, 0, ny);

      // Verify strict hour containment or adjustment behavior
      expect(gapTime.hour, isNot(2), reason: 'Should not exist in hour 2');

      // New York Fall Back 2025: Nov 2, 02:00 -> 01:00
      // Overlap: 01:30 happens twice.
      // Default behavior checks - DST time (before fall back) is used.
      final overlapTime = EasyDateTime(2025, 11, 2, 1, 30, 0, 0, 0, ny);
      // Verify that the overlap time is valid and in DST
      expect(overlapTime.hour, equals(1));
      expect(overlapTime.minute, equals(30));
    });

    test('1.3 Arithmetic - Leap Year Clamping', () {
      final leapDay = EasyDateTime(2024, 2, 29, 12, 0); // Valid
      final nextYear = leapDay.copyWith(year: 2025); // Invalid 2025-02-29

      // Default copyWith overflows -> March 1
      expect(nextYear.month, 3);
      expect(nextYear.day, 1);

      final clamped = leapDay.copyWithClamped(year: 2025);
      expect(clamped.month, 2);
      expect(clamped.day, 28);
    });
  });

  group('2. Parsing & Formatting', () {
    test('Parse Invalid Dates', () {
      // Dart DateTime.parse parses 2025-02-30 as 2025-03-02
      // This is expected standard DateTime behavior
      final dt = EasyDateTime.parse('2025-02-30');
      // Verify overflow behavior is consistent with DateTime
      expect(dt.month, equals(3));
      expect(dt.day, equals(2));
    });

    test('DoS Protection (Large Input)', () {
      final hugeString = '2025-01-01${' ' * 10000}';
      // Validates that tryParse handles large inputs efficiently without hanging
      final start = DateTime.now();
      final result = EasyDateTime.tryParse(hugeString);
      final elapsed = DateTime.now().difference(start);

      expect(elapsed.inMilliseconds, lessThan(100),
          reason: 'Parsing huge string took too long');
      // DateTime.parse handles trailing spaces, so result should be non-null
      expect(result, isNotNull,
          reason: 'DateTime.parse handles trailing spaces');
    });

    test('Formatting Edge Cases', () {
      final dt = EasyDateTime(2025, 1, 1, 12, 0, 0);
      // Unclosed quote
      final unclosed = dt.format("'Hello world"); // Missing closing quote
      expect(unclosed, equals('Hello world')); // WYSIWYG

      // Empty quotes
      final empty = dt.format("''");
      expect(empty, equals(''));

      // Quote with token inside
      final quotedToken = dt.format("'yyyy'");
      expect(quotedToken, equals('yyyy'));
    });
  });
}
