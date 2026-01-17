import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('Calendar Properties', () {
    group('dayOfYear', () {
      test('returns 1 for January 1st', () {
        expect(EasyDateTime(2025, 1, 1).dayOfYear, 1);
      });

      test('returns 365 for December 31st in non-leap year', () {
        expect(EasyDateTime(2025, 12, 31).dayOfYear, 365);
      });

      test('returns 366 for December 31st in leap year', () {
        expect(EasyDateTime(2024, 12, 31).dayOfYear, 366);
      });

      test('handles mid-year dates correctly', () {
        // June 15, 2025:
        // Jan=31, Feb=28, Mar=31, Apr=30, May=31, Jun 1-15=15
        // Total: 31+28+31+30+31+15 = 166
        expect(EasyDateTime(2025, 6, 15).dayOfYear, 166);
      });

      test('handles February 29th in leap year', () {
        expect(EasyDateTime(2024, 2, 29).dayOfYear, 60);
      });

      test('handles March 1st difference between leap and non-leap', () {
        // March 1st in leap year: 31 (Jan) + 29 (Feb) + 1 = 61
        expect(EasyDateTime(2024, 3, 1).dayOfYear, 61);
        // March 1st in non-leap year: 31 (Jan) + 28 (Feb) + 1 = 60
        expect(EasyDateTime(2025, 3, 1).dayOfYear, 60);
      });

      test('preserves timezone', () {
        final dt = EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, TimeZones.tokyo);
        expect(dt.dayOfYear, 166);
      });
    });

    group('weekOfYear (ISO 8601)', () {
      test('returns 1 for dates in first week', () {
        // 2025-01-01 is Wednesday, week 1 starts 2024-12-30 (Mon)
        expect(EasyDateTime(2025, 1, 1).weekOfYear, 1);
        expect(EasyDateTime(2025, 1, 5).weekOfYear, 1);
      });

      test('returns correct week for mid-year dates', () {
        // 2025-06-15 is Sunday, calculate expected week
        expect(EasyDateTime(2025, 6, 15).weekOfYear, 24);
      });

      test('handles year boundary - date belongs to next year week 1', () {
        // 2024-12-30 is Monday, this is week 1 of 2025
        expect(EasyDateTime(2024, 12, 30).weekOfYear, 1);
        expect(EasyDateTime(2024, 12, 31).weekOfYear, 1);
      });

      test('handles year boundary - date belongs to previous year last week',
          () {
        // 2021-01-01 is Friday. Week 53 of 2020 ends on 2021-01-03 (Sun)
        expect(EasyDateTime(2021, 1, 1).weekOfYear, 53);
        expect(EasyDateTime(2021, 1, 3).weekOfYear, 53);
        expect(
            EasyDateTime(2021, 1, 4).weekOfYear, 1); // Monday, week 1 of 2021
      });

      test('handles week 53 in years with 53 weeks', () {
        // 2020 has 53 weeks (starts on Wednesday, leap year)
        expect(EasyDateTime(2020, 12, 28).weekOfYear, 53);
        expect(EasyDateTime(2020, 12, 31).weekOfYear, 53);
      });

      test('returns 52 for last week in years with 52 weeks', () {
        // 2019 has 52 weeks
        expect(EasyDateTime(2019, 12, 29).weekOfYear, 52);
      });

      test('preserves timezone', () {
        final dt = EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, TimeZones.newYork);
        expect(dt.weekOfYear, 24);
      });

      test('handles 2019-12-30 (Week 1 of 2020)', () {
        // 2020 starts on Wed. 2019-12-30 is Mon.
        // Jan 4 2020 is Sat. Week 1 2020 starts Mon Dec 30 2019.
        expect(EasyDateTime(2019, 12, 30).weekOfYear, 1);
      });

      test('handles 2021-01-01 (Week 53 of 2020)', () {
        // 2020 had 53 weeks.
        expect(EasyDateTime(2021, 1, 1).weekOfYear, 53);
      });
    });

    group('daysInMonth', () {
      test('returns 31 for months with 31 days', () {
        // January, March, May, July, August, October, December
        expect(EasyDateTime(2025, 1, 15).daysInMonth, 31);
        expect(EasyDateTime(2025, 3, 15).daysInMonth, 31);
        expect(EasyDateTime(2025, 5, 15).daysInMonth, 31);
        expect(EasyDateTime(2025, 7, 15).daysInMonth, 31);
        expect(EasyDateTime(2025, 8, 15).daysInMonth, 31);
        expect(EasyDateTime(2025, 10, 15).daysInMonth, 31);
        expect(EasyDateTime(2025, 12, 15).daysInMonth, 31);
      });

      test('returns 30 for months with 30 days', () {
        // April, June, September, November
        expect(EasyDateTime(2025, 4, 15).daysInMonth, 30);
        expect(EasyDateTime(2025, 6, 15).daysInMonth, 30);
        expect(EasyDateTime(2025, 9, 15).daysInMonth, 30);
        expect(EasyDateTime(2025, 11, 15).daysInMonth, 30);
      });

      test('returns 28 for February in common years', () {
        expect(EasyDateTime(2025, 2, 15).daysInMonth, 28);
        expect(EasyDateTime(2023, 2, 15).daysInMonth, 28);
        expect(EasyDateTime(2100, 2, 15).daysInMonth, 28); // Century non-leap
      });

      test('returns 29 for February in leap years', () {
        expect(EasyDateTime(2024, 2, 15).daysInMonth, 29);
        expect(EasyDateTime(2000, 2, 15).daysInMonth, 29); // Century leap
        expect(EasyDateTime(2400, 2, 15).daysInMonth, 29); // Century leap
      });

      test('returns correct value when called on first day of month', () {
        expect(EasyDateTime(2025, 2, 1).daysInMonth, 28);
        expect(EasyDateTime(2024, 2, 1).daysInMonth, 29);
      });

      test('returns correct value when called on last day of month', () {
        expect(EasyDateTime(2025, 1, 31).daysInMonth, 31);
        expect(EasyDateTime(2025, 2, 28).daysInMonth, 28);
        expect(EasyDateTime(2024, 2, 29).daysInMonth, 29);
      });

      test('preserves timezone', () {
        final dt =
            EasyDateTime(2025, 2, 15, 10, 0, 0, 0, 0, TimeZones.shanghai);
        expect(dt.daysInMonth, 28);
      });
    });

    group('isLeapYear', () {
      test('returns true for years divisible by 4', () {
        expect(EasyDateTime(2024, 6, 15).isLeapYear, isTrue);
        expect(EasyDateTime(2028, 6, 15).isLeapYear, isTrue);
        expect(EasyDateTime(2032, 6, 15).isLeapYear, isTrue);
      });

      test('returns false for years not divisible by 4', () {
        expect(EasyDateTime(2025, 6, 15).isLeapYear, isFalse);
        expect(EasyDateTime(2023, 6, 15).isLeapYear, isFalse);
        expect(EasyDateTime(2021, 6, 15).isLeapYear, isFalse);
      });

      test('returns false for century years not divisible by 400', () {
        expect(EasyDateTime(1900, 6, 15).isLeapYear, isFalse);
        expect(EasyDateTime(2100, 6, 15).isLeapYear, isFalse);
        expect(EasyDateTime(2200, 6, 15).isLeapYear, isFalse);
        expect(EasyDateTime(2300, 6, 15).isLeapYear, isFalse);
      });

      test('returns true for century years divisible by 400', () {
        expect(EasyDateTime(1600, 6, 15).isLeapYear, isTrue);
        expect(EasyDateTime(2000, 6, 15).isLeapYear, isTrue);
        expect(EasyDateTime(2400, 6, 15).isLeapYear, isTrue);
      });

      test('returns correct value regardless of month or day', () {
        // Same year, different dates should return same result
        expect(EasyDateTime(2024, 1, 1).isLeapYear, isTrue);
        expect(EasyDateTime(2024, 12, 31).isLeapYear, isTrue);
        expect(EasyDateTime(2025, 1, 1).isLeapYear, isFalse);
        expect(EasyDateTime(2025, 12, 31).isLeapYear, isFalse);
      });

      test('preserves timezone', () {
        final dt = EasyDateTime(2024, 6, 15, 10, 0, 0, 0, 0, TimeZones.tokyo);
        expect(dt.isLeapYear, isTrue);
      });
    });

    group('isWeekend', () {
      test('returns true for Saturday', () {
        expect(EasyDateTime(2025, 1, 4).isWeekend, isTrue); // Saturday
        expect(EasyDateTime(2025, 1, 11).isWeekend, isTrue); // Saturday
      });

      test('returns true for Sunday', () {
        expect(EasyDateTime(2025, 1, 5).isWeekend, isTrue); // Sunday
        expect(EasyDateTime(2025, 1, 12).isWeekend, isTrue); // Sunday
      });

      test('returns false for weekdays', () {
        expect(EasyDateTime(2025, 1, 6).isWeekend, isFalse); // Monday
        expect(EasyDateTime(2025, 1, 7).isWeekend, isFalse); // Tuesday
        expect(EasyDateTime(2025, 1, 8).isWeekend, isFalse); // Wednesday
        expect(EasyDateTime(2025, 1, 9).isWeekend, isFalse); // Thursday
        expect(EasyDateTime(2025, 1, 10).isWeekend, isFalse); // Friday
      });

      test('returns correct value at day boundaries', () {
        // Start of Saturday
        expect(
          EasyDateTime(2025, 1, 4, 0, 0, 0, 0, 0).isWeekend,
          isTrue,
        );
        // End of Friday
        expect(
          EasyDateTime(2025, 1, 3, 23, 59, 59, 999, 999).isWeekend,
          isFalse,
        );
      });

      test('preserves timezone', () {
        final dt = EasyDateTime(2025, 1, 4, 10, 0, 0, 0, 0, TimeZones.newYork);
        expect(dt.isWeekend, isTrue);
      });
    });

    group('isWeekday', () {
      test('returns true for Monday through Friday', () {
        expect(EasyDateTime(2025, 1, 6).isWeekday, isTrue); // Monday
        expect(EasyDateTime(2025, 1, 7).isWeekday, isTrue); // Tuesday
        expect(EasyDateTime(2025, 1, 8).isWeekday, isTrue); // Wednesday
        expect(EasyDateTime(2025, 1, 9).isWeekday, isTrue); // Thursday
        expect(EasyDateTime(2025, 1, 10).isWeekday, isTrue); // Friday
      });

      test('returns false for Saturday', () {
        expect(EasyDateTime(2025, 1, 4).isWeekday, isFalse);
        expect(EasyDateTime(2025, 1, 11).isWeekday, isFalse);
      });

      test('returns false for Sunday', () {
        expect(EasyDateTime(2025, 1, 5).isWeekday, isFalse);
        expect(EasyDateTime(2025, 1, 12).isWeekday, isFalse);
      });

      test('isWeekend and isWeekday are mutually exclusive', () {
        // Test a complete week (2025-01-06 Mon to 2025-01-12 Sun)
        for (var day = 6; day <= 12; day++) {
          final dt = EasyDateTime(2025, 1, day);
          expect(
            dt.isWeekend != dt.isWeekday,
            isTrue,
            reason:
                'Jan $day: isWeekend=${dt.isWeekend}, isWeekday=${dt.isWeekday}',
          );
        }
      });

      test('preserves timezone', () {
        final dt = EasyDateTime(2025, 1, 6, 10, 0, 0, 0, 0, TimeZones.shanghai);
        expect(dt.isWeekday, isTrue);
      });
    });

    group('quarter', () {
      test('returns 1 for January, February, March', () {
        expect(EasyDateTime(2025, 1, 1).quarter, 1);
        expect(EasyDateTime(2025, 1, 31).quarter, 1);
        expect(EasyDateTime(2025, 2, 15).quarter, 1);
        expect(EasyDateTime(2025, 3, 31).quarter, 1);
      });

      test('returns 2 for April, May, June', () {
        expect(EasyDateTime(2025, 4, 1).quarter, 2);
        expect(EasyDateTime(2025, 5, 15).quarter, 2);
        expect(EasyDateTime(2025, 6, 30).quarter, 2);
      });

      test('returns 3 for July, August, September', () {
        expect(EasyDateTime(2025, 7, 1).quarter, 3);
        expect(EasyDateTime(2025, 8, 15).quarter, 3);
        expect(EasyDateTime(2025, 9, 30).quarter, 3);
      });

      test('returns 4 for October, November, December', () {
        expect(EasyDateTime(2025, 10, 1).quarter, 4);
        expect(EasyDateTime(2025, 11, 15).quarter, 4);
        expect(EasyDateTime(2025, 12, 31).quarter, 4);
      });

      test('handles quarter boundaries correctly', () {
        // Q1/Q2 boundary
        expect(EasyDateTime(2025, 3, 31, 23, 59, 59).quarter, 1);
        expect(EasyDateTime(2025, 4, 1, 0, 0, 0).quarter, 2);
        // Q2/Q3 boundary
        expect(EasyDateTime(2025, 6, 30, 23, 59, 59).quarter, 2);
        expect(EasyDateTime(2025, 7, 1, 0, 0, 0).quarter, 3);
        // Q3/Q4 boundary
        expect(EasyDateTime(2025, 9, 30, 23, 59, 59).quarter, 3);
        expect(EasyDateTime(2025, 10, 1, 0, 0, 0).quarter, 4);
        // Q4/Q1 boundary (year change)
        expect(EasyDateTime(2025, 12, 31, 23, 59, 59).quarter, 4);
        expect(EasyDateTime(2026, 1, 1, 0, 0, 0).quarter, 1);
      });

      test('returns correct value regardless of day or time', () {
        // Same month, different times should return same quarter
        expect(EasyDateTime(2025, 6, 1, 0, 0, 0).quarter, 2);
        expect(EasyDateTime(2025, 6, 30, 23, 59, 59).quarter, 2);
      });

      test('preserves timezone', () {
        final dt =
            EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, TimeZones.shanghai);
        expect(dt.quarter, 2);
      });
    });

    group('isDst', () {
      test('returns true during summer in DST-observing timezone', () {
        // New York observes DST: EDT from March to November
        final summer =
            EasyDateTime(2025, 7, 15, 12, 0, 0, 0, 0, TimeZones.newYork);
        expect(summer.isDst, isTrue);
      });

      test('returns false during winter in DST-observing timezone', () {
        // New York: EST in winter (no DST)
        final winter =
            EasyDateTime(2025, 1, 15, 12, 0, 0, 0, 0, TimeZones.newYork);
        expect(winter.isDst, isFalse);
      });

      test('returns false for UTC', () {
        final utc = EasyDateTime.utc(2025, 7, 15, 12, 0);
        expect(utc.isDst, isFalse);
      });

      test('returns false for timezones that do not observe DST', () {
        // China (Asia/Shanghai) does not observe DST
        final shanghai =
            EasyDateTime(2025, 7, 15, 12, 0, 0, 0, 0, TimeZones.shanghai);
        expect(shanghai.isDst, isFalse);

        // Japan (Asia/Tokyo) does not observe DST
        final tokyo =
            EasyDateTime(2025, 7, 15, 12, 0, 0, 0, 0, TimeZones.tokyo);
        expect(tokyo.isDst, isFalse);
      });

      test('handles DST transition boundaries correctly', () {
        // 2025 US DST starts: March 9, 2:00 AM -> 3:00 AM
        // Just before transition (1:59 AM EST)
        final beforeDst =
            EasyDateTime(2025, 3, 9, 1, 59, 0, 0, 0, TimeZones.newYork);
        expect(beforeDst.isDst, isFalse);

        // After transition (3:00 AM EDT)
        final afterDst =
            EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, TimeZones.newYork);
        expect(afterDst.isDst, isTrue);

        // 2025 US DST ends: November 2, 2:00 AM -> 1:00 AM
        // Just before fall back (still EDT)
        final beforeFallBack =
            EasyDateTime(2025, 11, 2, 0, 30, 0, 0, 0, TimeZones.newYork);
        expect(beforeFallBack.isDst, isTrue);

        // After fall back (EST)
        final afterFallBack =
            EasyDateTime(2025, 11, 2, 3, 0, 0, 0, 0, TimeZones.newYork);
        expect(afterFallBack.isDst, isFalse);
      });
    });

    group('isPast', () {
      test('returns true for dates in the past', () {
        final pastDate = EasyDateTime(2020, 1, 1);
        expect(pastDate.isPast, isTrue);
      });

      test('returns false for dates in the future', () {
        final futureDate = EasyDateTime(2100, 1, 1);
        expect(futureDate.isPast, isFalse);
      });

      test('returns true for historical dates', () {
        final historical = EasyDateTime(2020, 6, 15);
        expect(historical.isPast, isTrue);
      });

      test('maintains timezone context when comparing', () {
        // A past date in Tokyo should still be past
        final pastTokyo =
            EasyDateTime(2020, 1, 1, 12, 0, 0, 0, 0, TimeZones.tokyo);
        expect(pastTokyo.isPast, isTrue);
      });
    });

    group('isFuture', () {
      test('returns true for dates in the future', () {
        final futureDate = EasyDateTime(2100, 1, 1);
        expect(futureDate.isFuture, isTrue);
      });

      test('returns false for dates in the past', () {
        final pastDate = EasyDateTime(2020, 1, 1);
        expect(pastDate.isFuture, isFalse);
      });

      test('maintains timezone context when comparing', () {
        // A future date in Shanghai should still be future
        final futureShanghai =
            EasyDateTime(2100, 1, 1, 12, 0, 0, 0, 0, TimeZones.shanghai);
        expect(futureShanghai.isFuture, isTrue);
      });

      test('isPast and isFuture are mutually exclusive for non-current times',
          () {
        final past = EasyDateTime(2020, 1, 1);
        final future = EasyDateTime(2100, 1, 1);

        expect(past.isPast, isTrue);
        expect(past.isFuture, isFalse);
        expect(future.isPast, isFalse);
        expect(future.isFuture, isTrue);
      });
    });

    group('isThisWeek', () {
      test('returns true for dates within current week', () {
        final now = EasyDateTime.now();
        expect(now.isThisWeek, isTrue);
      });

      test('returns false for dates in previous weeks', () {
        // 30 days ago is definitely not this week
        final pastWeek = EasyDateTime.now().subtractCalendarDays(30);
        expect(pastWeek.isThisWeek, isFalse);
      });

      test('returns false for dates in future weeks', () {
        // 30 days from now is definitely not this week
        final futureWeek = EasyDateTime.now().addCalendarDays(30);
        expect(futureWeek.isThisWeek, isFalse);
      });

      test('includes both Monday and Sunday of the week', () {
        // Fixed reference: 2025-06-18 is Wednesday
        // Week runs from Monday 2025-06-16 to Sunday 2025-06-22
        final wednesday = EasyDateTime(2025, 6, 18, 12, 0);
        final monday = EasyDateTime(2025, 6, 16, 0, 0);
        final sunday = EasyDateTime(2025, 6, 22, 23, 59);
        final previousSunday = EasyDateTime(2025, 6, 15, 23, 59);
        final nextMonday = EasyDateTime(2025, 6, 23, 0, 0);

        // Same week dates (relative to wednesday's week)
        final weekStart = wednesday.startOf(DateTimeUnit.week);
        final weekEnd = wednesday.endOf(DateTimeUnit.week);

        // Monday and Sunday are within the week boundaries
        expect(!monday.isBefore(weekStart) && !monday.isAfter(weekEnd), isTrue);
        expect(!sunday.isBefore(weekStart) && !sunday.isAfter(weekEnd), isTrue);

        // Previous Sunday and next Monday are outside
        expect(previousSunday.isBefore(weekStart), isTrue);
        expect(nextMonday.isAfter(weekEnd), isTrue);
      });

      test('maintains timezone context', () {
        final now = EasyDateTime.now(location: TimeZones.tokyo);
        expect(now.isThisWeek, isTrue);
      });
    });

    group('isThisMonth', () {
      test('returns true for dates within current month', () {
        final now = EasyDateTime.now();
        expect(now.isThisMonth, isTrue);
      });

      test('returns true for first day of current month', () {
        final now = EasyDateTime.now();
        final firstOfMonth = EasyDateTime(now.year, now.month, 1);
        expect(firstOfMonth.isThisMonth, isTrue);
      });

      test('returns true for last day of current month', () {
        final now = EasyDateTime.now();
        final lastOfMonth = now.endOfMonth.dateOnly;
        expect(lastOfMonth.isThisMonth, isTrue);
      });

      test('returns false for previous month', () {
        final now = EasyDateTime.now();
        final previousMonth = now.month == 1
            ? EasyDateTime(now.year - 1, 12, 15)
            : EasyDateTime(now.year, now.month - 1, 15);
        expect(previousMonth.isThisMonth, isFalse);
      });

      test('returns false for next month', () {
        final now = EasyDateTime.now();
        final nextMonth = now.month == 12
            ? EasyDateTime(now.year + 1, 1, 15)
            : EasyDateTime(now.year, now.month + 1, 15);
        expect(nextMonth.isThisMonth, isFalse);
      });

      test('returns false for same month in different year', () {
        final now = EasyDateTime.now();
        final sameMonthLastYear = EasyDateTime(now.year - 1, now.month, 15);
        expect(sameMonthLastYear.isThisMonth, isFalse);
      });

      test('maintains timezone context', () {
        final now = EasyDateTime.now(location: TimeZones.newYork);
        expect(now.isThisMonth, isTrue);
      });
    });

    group('isThisYear', () {
      test('returns true for dates within current year', () {
        final now = EasyDateTime.now();
        expect(now.isThisYear, isTrue);
      });

      test('returns true for first day of current year', () {
        final now = EasyDateTime.now();
        final firstOfYear = EasyDateTime(now.year, 1, 1);
        expect(firstOfYear.isThisYear, isTrue);
      });

      test('returns true for last day of current year', () {
        final now = EasyDateTime.now();
        final lastOfYear = EasyDateTime(now.year, 12, 31);
        expect(lastOfYear.isThisYear, isTrue);
      });

      test('returns false for previous year', () {
        final now = EasyDateTime.now();
        final previousYear = EasyDateTime(now.year - 1, 6, 15);
        expect(previousYear.isThisYear, isFalse);
      });

      test('returns false for next year', () {
        final now = EasyDateTime.now();
        final nextYear = EasyDateTime(now.year + 1, 6, 15);
        expect(nextYear.isThisYear, isFalse);
      });

      test('maintains timezone context', () {
        final now = EasyDateTime.now(location: TimeZones.shanghai);
        expect(now.isThisYear, isTrue);
      });
    });
  });
}
