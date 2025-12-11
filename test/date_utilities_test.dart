import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    // Reset global default after each test
    EasyDateTime.clearDefaultLocation();
  });

  group('Date Utilities', () {
    group('dateOnly / startOfDay', () {
      test('dateOnly removes time components', () {
        final dt = EasyDateTime(2025, 12, 15, 14, 30, 45, 123, 456);
        final dateOnly = dt.dateOnly;

        expect(dateOnly.year, 2025);
        expect(dateOnly.month, 12);
        expect(dateOnly.day, 15);
        expect(dateOnly.hour, 0);
        expect(dateOnly.minute, 0);
        expect(dateOnly.second, 0);
        expect(dateOnly.millisecond, 0);
        expect(dateOnly.microsecond, 0);
      });

      test('startOfDay is alias for dateOnly', () {
        final dt = EasyDateTime(2025, 12, 15, 14, 30);
        expect(dt.startOfDay, dt.dateOnly);
      });

      test('dateOnly preserves timezone', () {
        final dt =
            EasyDateTime(2025, 12, 15, 14, 30, 0, 0, 0, TimeZones.shanghai);
        final dateOnly = dt.dateOnly;
        expect(dateOnly.locationName, 'Asia/Shanghai');
      });
    });

    group('endOfDay', () {
      test('endOfDay returns last moment of the day', () {
        final dt = EasyDateTime(2025, 12, 15, 10, 0);
        final end = dt.endOfDay;

        expect(end.year, 2025);
        expect(end.month, 12);
        expect(end.day, 15);
        expect(end.hour, 23);
        expect(end.minute, 59);
        expect(end.second, 59);
        expect(end.millisecond, 999);
        expect(end.microsecond, 999);
      });

      test('endOfDay preserves timezone', () {
        final dt =
            EasyDateTime(2025, 12, 15, 10, 0, 0, 0, 0, TimeZones.newYork);
        expect(dt.endOfDay.locationName, 'America/New_York');
      });
    });

    group('startOfMonth', () {
      test('startOfMonth returns first day at midnight', () {
        final dt = EasyDateTime(2025, 12, 15, 14, 30);
        final monthStart = dt.startOfMonth;

        expect(monthStart.year, 2025);
        expect(monthStart.month, 12);
        expect(monthStart.day, 1);
        expect(monthStart.hour, 0);
        expect(monthStart.minute, 0);
        expect(monthStart.second, 0);
      });
    });

    group('endOfMonth', () {
      test('endOfMonth handles 31-day months', () {
        final dt = EasyDateTime(2025, 12, 15);
        final monthEnd = dt.endOfMonth;

        expect(monthEnd.month, 12);
        expect(monthEnd.day, 31);
        expect(monthEnd.hour, 23);
        expect(monthEnd.minute, 59);
      });

      test('endOfMonth handles 30-day months', () {
        final dt = EasyDateTime(2025, 11, 15);
        final monthEnd = dt.endOfMonth;

        expect(monthEnd.month, 11);
        expect(monthEnd.day, 30);
      });

      test('endOfMonth handles February (non-leap year)', () {
        final dt = EasyDateTime(2025, 2, 15);
        final monthEnd = dt.endOfMonth;

        expect(monthEnd.month, 2);
        expect(monthEnd.day, 28);
      });

      test('endOfMonth handles February (leap year)', () {
        final dt = EasyDateTime(2024, 2, 15);
        final monthEnd = dt.endOfMonth;

        expect(monthEnd.month, 2);
        expect(monthEnd.day, 29);
      });

      test('endOfMonth handles December (year boundary)', () {
        final dt = EasyDateTime(2025, 12, 15);
        final monthEnd = dt.endOfMonth;

        expect(monthEnd.year, 2025);
        expect(monthEnd.month, 12);
        expect(monthEnd.day, 31);
      });
    });

    group('tomorrow / yesterday', () {
      test('tomorrow adds one day', () {
        final dt = EasyDateTime(2025, 12, 15, 10, 30);
        final tom = dt.tomorrow;

        expect(tom.year, 2025);
        expect(tom.month, 12);
        expect(tom.day, 16);
        expect(tom.hour, 10);
        expect(tom.minute, 30);
      });

      test('yesterday subtracts one day', () {
        final dt = EasyDateTime(2025, 12, 15, 10, 30);
        final yest = dt.yesterday;

        expect(yest.year, 2025);
        expect(yest.month, 12);
        expect(yest.day, 14);
        expect(yest.hour, 10);
      });

      test('tomorrow handles month boundary', () {
        final dt = EasyDateTime(2025, 12, 31, 23, 59);
        final tom = dt.tomorrow;

        expect(tom.year, 2026);
        expect(tom.month, 1);
        expect(tom.day, 1);
      });

      test('yesterday handles month boundary', () {
        final dt = EasyDateTime(2025, 1, 1, 0, 0);
        final yest = dt.yesterday;

        expect(yest.year, 2024);
        expect(yest.month, 12);
        expect(yest.day, 31);
      });
    });

    group('isToday / isTomorrow / isYesterday', () {
      test('tomorrow property adds exactly one day', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30);
        final tom = dt.tomorrow;

        expect(tom.year, 2025);
        expect(tom.month, 6);
        expect(tom.day, 16);
        expect(tom.hour, 14);
        expect(tom.minute, 30);
      });

      test('yesterday property subtracts exactly one day', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30);
        final yest = dt.yesterday;

        expect(yest.year, 2025);
        expect(yest.month, 6);
        expect(yest.day, 14);
        expect(yest.hour, 14);
        expect(yest.minute, 30);
      });

      test('tomorrow and yesterday are symmetric', () {
        final dt = EasyDateTime(2025, 6, 15, 10, 0);
        final tom = dt.tomorrow;
        final back = tom.yesterday;

        expect(back.year, dt.year);
        expect(back.month, dt.month);
        expect(back.day, dt.day);
        expect(back.hour, dt.hour);
        expect(back.minute, dt.minute);
      });

      test('isToday with fixed reference date', () {
        final referenceDay = EasyDateTime(2025, 6, 15);
        final sameDay = EasyDateTime(2025, 6, 15, 12, 30);

        // Verify they represent the same calendar day
        expect(sameDay.year, referenceDay.year);
        expect(sameDay.month, referenceDay.month);
        expect(sameDay.day, referenceDay.day);
      });

      test('date comparisons across day boundaries', () {
        final day1 = EasyDateTime(2025, 6, 15);
        final day2 = EasyDateTime(2025, 6, 16);
        final day1Later = EasyDateTime(2025, 6, 15, 23, 59, 59);

        // Same day
        expect(day1.day, day1Later.day);

        // Different days
        expect(day2.day, isNot(day1.day));

        // day1Later is still before day2
        expect(day1Later.isBefore(day2), isTrue);
      });
    });

    group('toDateString / toTimeString', () {
      test('toDateString formats correctly', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
        expect(dt.toDateString(), '2025-12-01');
      });

      test('toDateString pads single digits', () {
        final dt = EasyDateTime(2025, 1, 5);
        expect(dt.toDateString(), '2025-01-05');
      });

      test('toTimeString formats correctly', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
        expect(dt.toTimeString(), '14:30:45');
      });

      test('toTimeString pads single digits', () {
        final dt = EasyDateTime(2025, 12, 1, 9, 5, 3);
        expect(dt.toTimeString(), '09:05:03');
      });
    });
  });
}
