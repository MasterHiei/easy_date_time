import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  group('EasyDateTime Arithmetic', () {
    group('Arithmetic Methods', () {
      test('add() shifts date forward by duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 0);
        final result = dt.add(const Duration(hours: 2));

        expect(result.hour, 12);
      });

      test('subtract() shifts date backward by duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 0);
        final result = dt.subtract(const Duration(days: 1));

        expect(result.day, 30);
      });

      test('difference() returns Duration between two dates', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 0);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 12, 0);

        expect(dt2.difference(dt1), const Duration(hours: 2));
      });
    });

    group('Operators', () {
      test('operator + shifts date forward by duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1);
        final result = dt + const Duration(days: 1);

        expect(result.day, 2); // Dec 2
      });

      test('operator - shifts date backward by duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1);
        final result = dt - const Duration(days: 1);

        expect(result.day, 30); // Nov 30
      });

      test('operator < returns true if receiver is strictly before argument',
          () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 < dt2, true);
        expect(dt2 < dt1, false);
      });

      test('operator > returns true if receiver is strictly after argument',
          () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1 > dt2, true);
        expect(dt2 > dt1, false);
      });

      test('operator <= returns true if receiver is before or same as argument',
          () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        final dt3 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 <= dt2, true);
        expect(dt1 <= dt3, true);
        expect(dt3 <= dt1, false);
      });

      test('operator >= returns true if receiver is after or same as argument',
          () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        final dt3 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 >= dt2, true);
        expect(dt1 >= dt3, true);
        expect(dt2 >= dt1, false);
      });

      test('operator == returns true for identical moment and timezone', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1 == dt2, true);
      });

      test(
          'operator == returns false for same moment with different isUtc (strict equality)',
          () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 9, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final dt2 = EasyDateTime(2025, 12, 1, 18, 0, 0, 0, 0, tokyo);

        // Same moment in time, but different isUtc - should be NOT equal
        // (matches DateTime.== semantics)
        expect(dt1.isAtSameMomentAs(dt2), true);
        expect(dt1 == dt2, false);
      });

      test('operator == matches hashCode consistency', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        expect(dt1 == dt2, isTrue);
      });

      test(
          'operator == ignores location differences if isUtc matches (standard equality)',
          () {
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final copy = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        expect(shanghai == copy, isTrue);
      });

      test('operator == returns false for different moments', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 31);
        expect(dt1 == dt2, isFalse);
      });

      test('Set treats equal objects as duplicates', () {
        final dt1 = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final dt2 =
            EasyDateTime.parse('2025-12-01T10:30:00+08:00'); // Valid copy
        final set = <EasyDateTime>{dt1, dt2};
        expect(set.length, 1);
      });

      test('operator == returns true comparing with equivalent DateTime (UTC)',
          () {
        final easyDt = EasyDateTime.utc(2025, 12, 1, 10, 30, 0);
        final dt = DateTime.utc(2025, 12, 1, 10, 30, 0);

        expect(easyDt == dt, isTrue);
      });

      test(
          'operator == returns false comparing with DateTime of different kind (Local vs UTC)',
          () {
        final easyDt = EasyDateTime.utc(2025, 12, 1, 10, 30, 0);
        final dt = DateTime(2025, 12, 1, 10, 30, 0); // local time

        // Different isUtc means not equal (even if microsecondsSinceEpoch matches)
        expect(easyDt == dt, isFalse);
      });
    });

    group('Comparison Methods', () {
      test('isBefore() checks if before', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1.isBefore(dt2), true);
        expect(dt2.isBefore(dt1), false);
      });

      test('isAfter() checks if after', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1.isAfter(dt2), true);
        expect(dt2.isAfter(dt1), false);
      });

      test('isAtSameMomentAs() ignores timezone difference', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 0, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final dt2 = EasyDateTime(2025, 12, 1, 9, 0, 0, 0, 0, tokyo);

        expect(dt1.isAtSameMomentAs(dt2), true);
      });

      test('compareTo() returns correct ordering', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);
        final dt3 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1.compareTo(dt2) < 0, true);
        expect(dt2.compareTo(dt1) > 0, true);
        expect(dt1.compareTo(dt3), 0);
      });
    });
  });
}
