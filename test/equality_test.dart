library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  group('Equality and Comparison', () {
    group('operator == (Strict Equality)', () {
      test('returns true for identical UTC instances', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        expect(dt1 == dt2, isTrue);
      });

      test('returns true for identical parsed instances', () {
        final parsed1 = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final parsed2 = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        expect(parsed1 == parsed2, isTrue);
      });

      test('returns false for different moments', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 31);
        expect(dt1 == dt2, isFalse);
      });

      test(
        'returns false for same moment with different timezone kind (UTC vs Local)',
        () {
          final dt1 = EasyDateTime.utc(2025, 12, 1, 9, 0);
          final tokyo = getLocation('Asia/Tokyo');
          final dt2 = EasyDateTime(2025, 12, 1, 18, 0, 0, 0, 0, tokyo);

          // 09:00 UTC equals 18:00 Tokyo.
          expect(dt1.isAtSameMomentAs(dt2), isTrue);
          // Timezones differ.
          expect(dt1 == dt2, isFalse);
        },
      );

      test('returns true comparing with equivalent DateTime (UTC)', () {
        final easyDt = EasyDateTime.utc(2025, 12, 1, 10, 30, 0);
        final dt = DateTime.utc(2025, 12, 1, 10, 30, 0);
        expect(easyDt == dt, isTrue);
      });

      test(
        'returns false comparing with DateTime of different kind (Local vs UTC)',
        () {
          final easyDt = EasyDateTime.utc(2025, 12, 1, 10, 30, 0);
          final dt = DateTime(2025, 12, 1, 10, 30, 0); // Local time.
          expect(easyDt == dt, isFalse);
        },
      );
    });

    group('hashCode', () {
      test('returns same value for equal objects (Strict Equality)', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        expect(dt1.hashCode, dt2.hashCode);
      });

      test('differs for different moments', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 31);
        expect(dt1.hashCode, isNot(dt2.hashCode));
      });

      // The current implementation of `operator ==` only checks `isUtc` and `microsecondsSinceEpoch`.
      // It does NOT compare the `location` field for non-UTC instances.
      // Therefore, two instances representing the same moment in different non-UTC timezones
      // (e.g., Shanghai and Tokyo) are considered equal.
      // This test verifies this specific behavior and ensures hashCode consistency.
      test(
        'hashCode is identical for same moment in different non-UTC timezones',
        () {
          // 10:30 Shanghai (+8) equals 11:30 Tokyo (+9) equals 02:30 UTC.
          final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
          final tokyo = EasyDateTime.parse('2025-12-01T11:30:00+09:00');

          expect(shanghai == tokyo, isTrue);
          expect(shanghai.hashCode, tokyo.hashCode);
        },
      );
    });

    group('isAtSameMomentAs', () {
      test('ignores timezone difference', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 0, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final dt2 = EasyDateTime(2025, 12, 1, 9, 0, 0, 0, 0, tokyo);

        expect(dt1.isAtSameMomentAs(dt2), isTrue);
      });

      test('distinguishes different moments', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 0, 0);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 0, 0, 0, 1);
        expect(dt1.isAtSameMomentAs(dt2), isFalse);
      });
    });

    group('Comparison Operators', () {
      test('operator < returns true when strictly before', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);
        expect(dt1 < dt2, true);
        expect(dt2 < dt1, false);
      });

      test('operator > returns true when strictly after', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        expect(dt1 > dt2, true);
        expect(dt2 > dt1, false);
      });

      test('operator <= returns true when before or equal', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        expect(dt1 <= dt2, true);
      });

      test('operator >= returns true when after or equal', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        expect(dt1 >= dt2, true);
      });
    });

    group('Comparison Methods', () {
      test('isBefore() checks if strictly before', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);
        expect(dt1.isBefore(dt2), isTrue);
        expect(dt2.isBefore(dt1), isFalse);
        expect(dt1.isBefore(dt1), isFalse);
      });

      test('isAfter() checks if strictly after', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        expect(dt1.isAfter(dt2), isTrue);
        expect(dt2.isAfter(dt1), isFalse);
        expect(dt1.isAfter(dt1), isFalse);
      });
    });

    group('compareTo', () {
      test('returns correct ordering', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);
        expect(dt1.compareTo(dt2) < 0, true);
        expect(dt2.compareTo(dt1) > 0, true);
        expect(dt1.compareTo(dt1), 0);
      });
    });
  });
}
