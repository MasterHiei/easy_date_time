library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

/// Tests for PR #7 changes: DateTime compatibility constants and static methods.
///
/// These tests verify that:
/// 1. Weekday and month constants match DateTime's constants.
/// 2. Static configuration methods work correctly on EasyDateTime class.
void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('DateTime Compatibility Constants', () {
    group('Weekday constants', () {
      final constants = [
        (
          name: 'monday',
          actual: EasyDateTime.monday,
          expected: DateTime.monday,
        ),
        (
          name: 'tuesday',
          actual: EasyDateTime.tuesday,
          expected: DateTime.tuesday,
        ),
        (
          name: 'wednesday',
          actual: EasyDateTime.wednesday,
          expected: DateTime.wednesday,
        ),
        (
          name: 'thursday',
          actual: EasyDateTime.thursday,
          expected: DateTime.thursday,
        ),
        (
          name: 'friday',
          actual: EasyDateTime.friday,
          expected: DateTime.friday,
        ),
        (
          name: 'saturday',
          actual: EasyDateTime.saturday,
          expected: DateTime.saturday,
        ),
        (
          name: 'sunday',
          actual: EasyDateTime.sunday,
          expected: DateTime.sunday,
        ),
        (
          name: 'daysPerWeek',
          actual: EasyDateTime.daysPerWeek,
          expected: DateTime.daysPerWeek,
        ),
      ];

      for (final constant in constants) {
        test('${constant.name} matches DateTime', () {
          expect(constant.actual, constant.expected);
        });
      }

      test('weekday property returns correct constant', () {
        final monday = EasyDateTime.utc(2025, 12, 1);
        expect(monday.weekday, EasyDateTime.monday);

        final sunday = EasyDateTime.utc(2025, 12, 7);
        expect(sunday.weekday, EasyDateTime.sunday);
      });
    });

    group('Month constants', () {
      final constants = [
        (
          name: 'january',
          actual: EasyDateTime.january,
          expected: DateTime.january,
        ),
        (
          name: 'february',
          actual: EasyDateTime.february,
          expected: DateTime.february,
        ),
        (name: 'march', actual: EasyDateTime.march, expected: DateTime.march),
        (name: 'april', actual: EasyDateTime.april, expected: DateTime.april),
        (name: 'may', actual: EasyDateTime.may, expected: DateTime.may),
        (name: 'june', actual: EasyDateTime.june, expected: DateTime.june),
        (name: 'july', actual: EasyDateTime.july, expected: DateTime.july),
        (
          name: 'august',
          actual: EasyDateTime.august,
          expected: DateTime.august,
        ),
        (
          name: 'september',
          actual: EasyDateTime.september,
          expected: DateTime.september,
        ),
        (
          name: 'october',
          actual: EasyDateTime.october,
          expected: DateTime.october,
        ),
        (
          name: 'november',
          actual: EasyDateTime.november,
          expected: DateTime.november,
        ),
        (
          name: 'december',
          actual: EasyDateTime.december,
          expected: DateTime.december,
        ),
        (
          name: 'monthsPerYear',
          actual: EasyDateTime.monthsPerYear,
          expected: DateTime.monthsPerYear,
        ),
      ];

      for (final constant in constants) {
        test('${constant.name} matches DateTime', () {
          expect(constant.actual, constant.expected);
        });
      }

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
      // EasyDateTime implements DateTime.
      DateTime dt = easyDt;
      expect(dt.year, 2025);
      expect(dt.month, 12);
    });

    test('EasyDateTime works with functions accepting DateTime', () {
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

    test('epoch factories preserve the requested UTC instant', () {
      const milliseconds = 1_735_689_600_123;
      const microseconds = milliseconds * Duration.microsecondsPerMillisecond;

      final fromMilliseconds = EasyDateTime.fromMillisecondsSinceEpoch(
        milliseconds,
        isUtc: true,
      );
      final fromSeconds = EasyDateTime.fromSecondsSinceEpoch(
        milliseconds ~/ Duration.millisecondsPerSecond,
        isUtc: true,
      );
      final fromMicroseconds = EasyDateTime.fromMicrosecondsSinceEpoch(
        microseconds,
        isUtc: true,
      );

      expect(fromMilliseconds.microsecondsSinceEpoch, microseconds);
      expect(fromMicroseconds.microsecondsSinceEpoch, microseconds);
      expect(
        fromSeconds.microsecondsSinceEpoch,
        (milliseconds ~/ Duration.millisecondsPerSecond) *
            Duration.microsecondsPerSecond,
      );
      expect(fromMilliseconds.isUtc, isTrue);
      expect(fromSeconds.isUtc, isTrue);
      expect(fromMicroseconds.isUtc, isTrue);
    });

    test('DateTime-typed copyWith returns a core DateTime', () {
      DateTime value = EasyDateTime.utc(2025, 12, 1, 10, 30);

      final copied = value.copyWith(isUtc: false);

      expect(copied, isA<DateTime>());
      expect(copied, isNot(isA<EasyDateTime>()));
      expect(copied.isUtc, isFalse);
      expect(copied.year, 2025);
      expect(copied.hour, 10);
    });

    test('operator == handles DateTime comparison', () {
      final easy = EasyDateTime.utc(2025, 1, 1, 10, 0);
      final dart = DateTime.utc(2025, 1, 1, 10, 0);

      expect(easy == dart, isTrue);

      final dartLocal = DateTime(
        2025,
        1,
        1,
        10,
        0,
      ); // This creates a local DateTime.
      expect(easy == dartLocal, isFalse); // Timezones differ.
    });
  });
}
