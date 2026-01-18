library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
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
    });
  });
}
