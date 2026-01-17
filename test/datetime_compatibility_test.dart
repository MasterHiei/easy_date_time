import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

/// Tests for PR #7 changes: DateTime compatibility constants and static methods.
///
/// These tests verify that:
/// 1. Weekday and month constants match DateTime's constants
/// 2. Static configuration methods work correctly on EasyDateTime class
void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('DateTime Compatibility Constants', () {
    group('Weekday constants', () {
      test('monday matches DateTime.monday', () {
        expect(EasyDateTime.monday, DateTime.monday);
        expect(EasyDateTime.monday, 1);
      });

      test('tuesday matches DateTime.tuesday', () {
        expect(EasyDateTime.tuesday, DateTime.tuesday);
        expect(EasyDateTime.tuesday, 2);
      });

      test('wednesday matches DateTime.wednesday', () {
        expect(EasyDateTime.wednesday, DateTime.wednesday);
        expect(EasyDateTime.wednesday, 3);
      });

      test('thursday matches DateTime.thursday', () {
        expect(EasyDateTime.thursday, DateTime.thursday);
        expect(EasyDateTime.thursday, 4);
      });

      test('friday matches DateTime.friday', () {
        expect(EasyDateTime.friday, DateTime.friday);
        expect(EasyDateTime.friday, 5);
      });

      test('saturday matches DateTime.saturday', () {
        expect(EasyDateTime.saturday, DateTime.saturday);
        expect(EasyDateTime.saturday, 6);
      });

      test('sunday matches DateTime.sunday', () {
        expect(EasyDateTime.sunday, DateTime.sunday);
        expect(EasyDateTime.sunday, 7);
      });

      test('daysPerWeek matches DateTime.daysPerWeek', () {
        expect(EasyDateTime.daysPerWeek, DateTime.daysPerWeek);
        expect(EasyDateTime.daysPerWeek, 7);
      });

      test('weekday property returns correct constant', () {
        // 2025-12-01 is Monday
        final monday = EasyDateTime.utc(2025, 12, 1);
        expect(monday.weekday, EasyDateTime.monday);

        // 2025-12-07 is Sunday
        final sunday = EasyDateTime.utc(2025, 12, 7);
        expect(sunday.weekday, EasyDateTime.sunday);
      });
    });

    group('Month constants', () {
      test('january matches DateTime.january', () {
        expect(EasyDateTime.january, DateTime.january);
        expect(EasyDateTime.january, 1);
      });

      test('february matches DateTime.february', () {
        expect(EasyDateTime.february, DateTime.february);
        expect(EasyDateTime.february, 2);
      });

      test('march matches DateTime.march', () {
        expect(EasyDateTime.march, DateTime.march);
        expect(EasyDateTime.march, 3);
      });

      test('april matches DateTime.april', () {
        expect(EasyDateTime.april, DateTime.april);
        expect(EasyDateTime.april, 4);
      });

      test('may matches DateTime.may', () {
        expect(EasyDateTime.may, DateTime.may);
        expect(EasyDateTime.may, 5);
      });

      test('june matches DateTime.june', () {
        expect(EasyDateTime.june, DateTime.june);
        expect(EasyDateTime.june, 6);
      });

      test('july matches DateTime.july', () {
        expect(EasyDateTime.july, DateTime.july);
        expect(EasyDateTime.july, 7);
      });

      test('august matches DateTime.august', () {
        expect(EasyDateTime.august, DateTime.august);
        expect(EasyDateTime.august, 8);
      });

      test('september matches DateTime.september', () {
        expect(EasyDateTime.september, DateTime.september);
        expect(EasyDateTime.september, 9);
      });

      test('october matches DateTime.october', () {
        expect(EasyDateTime.october, DateTime.october);
        expect(EasyDateTime.october, 10);
      });

      test('november matches DateTime.november', () {
        expect(EasyDateTime.november, DateTime.november);
        expect(EasyDateTime.november, 11);
      });

      test('december matches DateTime.december', () {
        expect(EasyDateTime.december, DateTime.december);
        expect(EasyDateTime.december, 12);
      });

      test('monthsPerYear matches DateTime.monthsPerYear', () {
        expect(EasyDateTime.monthsPerYear, DateTime.monthsPerYear);
        expect(EasyDateTime.monthsPerYear, 12);
      });

      test('month property returns correct constant', () {
        final january = EasyDateTime.utc(2025, 1, 15);
        expect(january.month, EasyDateTime.january);

        final december = EasyDateTime.utc(2025, 12, 15);
        expect(december.month, EasyDateTime.december);
      });
    });
  });

  group('DateTime Interface Compliance', () {
    test('EasyDateTime is assignable to DateTime', () {
      final easyDt = EasyDateTime.utc(2025, 12, 1, 10, 30);
      // This should compile: EasyDateTime implements DateTime
      DateTime dt = easyDt;
      expect(dt.year, 2025);
      expect(dt.month, 12);
    });

    test('EasyDateTime works with functions accepting DateTime', () {
      // A function that accepts DateTime should accept EasyDateTime
      int extractYear(DateTime dt) => dt.year;

      final easyDt = EasyDateTime.utc(2025, 12, 1);
      expect(extractYear(easyDt), 2025);
    });

    test('EasyDateTime runtimeType shows it is an EasyDateTime', () {
      final easyDt = EasyDateTime.utc(2025, 12, 1, 10, 30);
      expect(easyDt.runtimeType.toString(), contains('EasyDateTime'));
    });

    test('List<DateTime> can contain EasyDateTime', () {
      final List<DateTime> dates = [
        DateTime.utc(2025, 1, 1),
        EasyDateTime.utc(2025, 2, 1),
        EasyDateTime.utc(2025, 3, 1),
      ];
      expect(dates.length, 3);
      expect(dates[1].runtimeType.toString(), contains('EasyDateTime'));
    });

    test('EasyDateTime maintains all DateTime properties', () {
      final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45, 123, 456);
      expect(dt.year, 2025);
      expect(dt.month, 6);
      expect(dt.day, 15);
      expect(dt.hour, 14);
      expect(dt.minute, 30);
      expect(dt.second, 45);
      expect(dt.millisecond, 123);
      expect(dt.microsecond, 456);
      expect(dt.isUtc, isTrue);
      expect(dt.weekday, isA<int>());
      expect(dt.millisecondsSinceEpoch, isA<int>());
      expect(dt.microsecondsSinceEpoch, isA<int>());
      expect(dt.timeZoneOffset, isA<Duration>());
      expect(dt.timeZoneName, isA<String>());
    });

    test('operator == handles DateTime comparison', () {
      final easy = EasyDateTime.utc(2025, 1, 1, 10, 0);
      final dart = DateTime.utc(2025, 1, 1, 10, 0);

      expect(easy == dart, isTrue);

      final dartLocal = DateTime(2025, 1, 1, 10, 0); // Local
      expect(easy == dartLocal, isFalse); // Different timezone type
    });
  });
}
