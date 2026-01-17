part of 'easy_date_time.dart';

// ============================================================
// Date Utilities Extension
// ============================================================

/// Extension providing date utility methods for [EasyDateTime].
extension EasyDateTimeUtilities on EasyDateTime {
  // ============================================================
  // Day Operations
  // ============================================================

  /// Returns a new [EasyDateTime] with time set to 00:00:00.000.
  ///
  /// Useful for date-only comparisons or getting the start of a day.
  ///
  /// ```dart
  /// final now = EasyDateTime.now();  // 2025-12-01 14:30:00
  /// final date = now.dateOnly;       // 2025-12-01 00:00:00
  /// ```
  EasyDateTime get dateOnly =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  /// Alias for [dateOnly]. Returns start of the day (00:00:00.000).
  ///
  /// ```dart
  /// final dayStart = EasyDateTime.now().startOfDay;
  /// ```
  EasyDateTime get startOfDay => dateOnly;

  /// Returns end of the day (23:59:59.999999).
  ///
  /// ```dart
  /// final dayEnd = EasyDateTime.now().endOfDay;
  /// ```
  EasyDateTime get endOfDay => copyWith(
    hour: 23,
    minute: 59,
    second: 59,
    millisecond: 999,
    microsecond: 999,
  );

  // ============================================================
  // Month Operations
  // ============================================================

  /// Returns the first day of the current month at 00:00:00.
  ///
  /// ```dart
  /// final dt = EasyDateTime(2025, 12, 15);
  /// final monthStart = dt.startOfMonth;  // 2025-12-01 00:00:00
  /// ```
  EasyDateTime get startOfMonth => copyWith(
    day: 1,
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );

  /// Returns the last day of the current month at 23:59:59.999999.
  ///
  /// Correctly handles months with different lengths and leap years.
  ///
  /// ```dart
  /// final dt = EasyDateTime(2025, 2, 15);
  /// final monthEnd = dt.endOfMonth;  // 2025-02-28 23:59:59.999999
  /// ```
  EasyDateTime get endOfMonth {
    // Get the first day of next month, then subtract 1 microsecond
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final firstOfNextMonth = EasyDateTime(
      nextYear,
      nextMonth,
      1,
      0,
      0,
      0,
      0,
      0,
      location,
    );

    return firstOfNextMonth.subtract(const Duration(microseconds: 1));
  }

  // ============================================================
  // Calendar Day Arithmetic
  // ============================================================

  /// Adds [days] calendar days to this datetime, preserving the time of day.
  ///
  /// Unlike [add] with `Duration(days: N)` which adds exactly N×24 hours,
  /// this method adds calendar days while keeping the same local time.
  /// This is DST-safe: on days with 23 or 25 hours, the time is preserved.
  ///
  /// ```dart
  /// // DST spring forward (2025-03-09 in New York, 23-hour day):
  /// final dt = EasyDateTime(2025, 3, 9, 0, 0, location: ny);
  ///
  /// dt.addCalendarDays(1);       // 2025-03-10 00:00 ✓ (same time)
  /// dt.add(Duration(days: 1));   // 2025-03-10 01:00   (24h later)
  /// ```
  ///
  /// Handles month/year overflow automatically:
  /// ```dart
  /// EasyDateTime(2025, 1, 31).addCalendarDays(1);  // 2025-02-01
  /// EasyDateTime(2025, 12, 31).addCalendarDays(1); // 2026-01-01
  /// ```
  EasyDateTime addCalendarDays(int days) => copyWith(day: day + days);

  /// Subtracts [days] calendar days from this datetime, preserving the time.
  ///
  /// Unlike [subtract] with `Duration(days: N)` which subtracts exactly
  /// N×24 hours, this method subtracts calendar days while keeping the
  /// same local time. This is DST-safe.
  ///
  /// ```dart
  /// // DST fall back (2025-11-02 in New York, 25-hour day):
  /// final dt = EasyDateTime(2025, 11, 3, 0, 0, location: ny);
  ///
  /// dt.subtractCalendarDays(1);     // 2025-11-02 00:00 ✓ (same time)
  /// dt.subtract(Duration(days: 1)); // 2025-11-02 01:00   (24h earlier)
  /// ```
  EasyDateTime subtractCalendarDays(int days) => copyWith(day: day - days);

  // ============================================================
  // Relative Day Getters
  // ============================================================

  /// Returns the next calendar day at the same local time.
  ///
  /// Uses calendar day arithmetic, not physical time. On DST boundary days,
  /// the time of day is preserved even though the day may have 23 or 25 hours.
  ///
  /// Equivalent to `addCalendarDays(1)`.
  ///
  /// ```dart
  /// final tomorrow = EasyDateTime.now().tomorrow;
  /// ```
  EasyDateTime get tomorrow => addCalendarDays(1);

  /// Returns the previous calendar day at the same local time.
  ///
  /// Uses calendar day arithmetic, not physical time. On DST boundary days,
  /// the time of day is preserved even though the day may have 23 or 25 hours.
  ///
  /// Equivalent to `subtractCalendarDays(1)`.
  ///
  /// ```dart
  /// final yesterday = EasyDateTime.now().yesterday;
  /// ```
  EasyDateTime get yesterday => subtractCalendarDays(1);

  /// Returns `true` if this date is today (ignoring time).
  ///
  /// ```dart
  /// if (appointment.isToday) {
  ///   print('You have an appointment today!');
  /// }
  /// ```
  bool get isToday => _isSameDay(EasyDateTime.now(location: location));

  /// Returns `true` if this date is tomorrow (ignoring time).
  bool get isTomorrow =>
      _isSameDay(EasyDateTime.now(location: location).tomorrow);

  /// Returns `true` if this date is yesterday (ignoring time).
  bool get isYesterday =>
      _isSameDay(EasyDateTime.now(location: location).yesterday);

  // ============================================================
  // Date Properties
  // ============================================================

  /// Returns the day of year (1-366) for this date.
  ///
  /// January 1st is day 1, December 31st is day 365 (or 366 in leap years).
  ///
  /// ```dart
  /// EasyDateTime(2025, 1, 1).dayOfYear;   // 1
  /// EasyDateTime(2025, 12, 31).dayOfYear; // 365
  /// EasyDateTime(2024, 12, 31).dayOfYear; // 366 (leap year)
  /// ```
  int get dayOfYear {
    final firstDayOfYear = EasyDateTime(year, 1, 1, 0, 0, 0, 0, 0, location);

    return dateOnly.difference(firstDayOfYear).inDays + 1;
  }

  /// Returns the ISO 8601 week number (1-53) for this date.
  ///
  /// Week 1 is the week containing the first Thursday of the year
  /// (equivalently, the week containing January 4th).
  /// Monday is considered the first day of the week.
  ///
  /// Note: Dates near year boundaries may belong to the previous
  /// or next year's week numbering.
  ///
  /// ```dart
  /// EasyDateTime(2025, 1, 1).weekOfYear;   // 1
  /// EasyDateTime(2024, 12, 30).weekOfYear; // 1 (belongs to 2025 W1)
  /// EasyDateTime(2020, 12, 31).weekOfYear; // 53
  /// ```
  int get weekOfYear {
    // ISO 8601: Week 1 contains the first Thursday of the year
    // (equivalently, contains January 4th)
    final jan4 = EasyDateTime(year, 1, 4, 0, 0, 0, 0, 0, location);
    final jan4Weekday = jan4.weekday; // 1=Mon, 7=Sun

    // Find Monday of week 1
    final week1Monday = jan4.dateOnly.subtract(Duration(days: jan4Weekday - 1));

    // Days from week 1 Monday to this date
    final daysFromWeek1 = dateOnly.difference(week1Monday).inDays;

    if (daysFromWeek1 < 0) {
      // This date is before week 1 of current year
      // It belongs to the last week of the previous year
      return EasyDateTime(year - 1, 12, 31, 0, 0, 0, 0, 0, location).weekOfYear;
    }

    final weekNumber = (daysFromWeek1 ~/ 7) + 1;

    if (weekNumber > 52) {
      // Check if this belongs to week 1 of next year
      final nextYearJan4 = EasyDateTime(
        year + 1,
        1,
        4,
        0,
        0,
        0,
        0,
        0,
        location,
      );
      final nextYearWeek1Monday = nextYearJan4.dateOnly.subtract(
        Duration(days: nextYearJan4.weekday - 1),
      );
      if (!dateOnly.isBefore(nextYearWeek1Monday)) {
        return 1;
      }
    }

    return weekNumber;
  }

  /// Returns the number of days in the current month.
  ///
  /// Correctly handles February in leap years.
  ///
  /// ```dart
  /// EasyDateTime(2025, 1, 15).daysInMonth;  // 31
  /// EasyDateTime(2025, 2, 15).daysInMonth;  // 28
  /// EasyDateTime(2024, 2, 15).daysInMonth;  // 29 (leap year)
  /// EasyDateTime(2025, 4, 15).daysInMonth;  // 30
  /// ```
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Returns `true` if the current year is a leap year.
  ///
  /// A year is a leap year if:
  /// - It is divisible by 4, AND
  /// - It is NOT divisible by 100, OR it is divisible by 400.
  ///
  /// ```dart
  /// EasyDateTime(2024, 6, 15).isLeapYear;  // true
  /// EasyDateTime(2025, 6, 15).isLeapYear;  // false
  /// EasyDateTime(2000, 6, 15).isLeapYear;  // true  (divisible by 400)
  /// EasyDateTime(1900, 6, 15).isLeapYear;  // false (divisible by 100)
  /// ```
  bool get isLeapYear => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Returns `true` if this date is a weekend day (Saturday or Sunday).
  ///
  /// ```dart
  /// EasyDateTime(2025, 1, 4).isWeekend;  // true  (Saturday)
  /// EasyDateTime(2025, 1, 5).isWeekend;  // true  (Sunday)
  /// EasyDateTime(2025, 1, 6).isWeekend;  // false (Monday)
  /// ```
  bool get isWeekend => weekday >= DateTime.saturday;

  /// Returns `true` if this date is a weekday (Monday through Friday).
  ///
  /// ```dart
  /// EasyDateTime(2025, 1, 6).isWeekday;  // true  (Monday)
  /// EasyDateTime(2025, 1, 4).isWeekday;  // false (Saturday)
  /// ```
  bool get isWeekday => weekday < DateTime.saturday;

  /// Returns the quarter of the year (1-4).
  ///
  /// - Q1: January - March (months 1-3)
  /// - Q2: April - June (months 4-6)
  /// - Q3: July - September (months 7-9)
  /// - Q4: October - December (months 10-12)
  ///
  /// ```dart
  /// EasyDateTime(2025, 1, 15).quarter;   // 1
  /// EasyDateTime(2025, 4, 15).quarter;   // 2
  /// EasyDateTime(2025, 7, 15).quarter;   // 3
  /// EasyDateTime(2025, 10, 15).quarter;  // 4
  /// ```
  int get quarter => (month - 1) ~/ 3 + 1;

  // ============================================================
  // Time Query Properties
  // ============================================================

  /// Returns `true` if this datetime is before the current time.
  ///
  /// Compares using the same timezone as this datetime instance to ensure
  /// consistent behavior across timezones.
  ///
  /// ```dart
  /// final lastYear = EasyDateTime(2024, 1, 1);
  /// print(lastYear.isPast);  // true
  ///
  /// final nextYear = EasyDateTime(2030, 1, 1);
  /// print(nextYear.isPast);  // false
  /// ```
  bool get isPast => isBefore(EasyDateTime.now(location: location));

  /// Returns `true` if this datetime is after the current time.
  ///
  /// Compares using the same timezone as this datetime instance to ensure
  /// consistent behavior across timezones.
  ///
  /// ```dart
  /// final nextYear = EasyDateTime(2030, 1, 1);
  /// print(nextYear.isFuture);  // true
  ///
  /// final lastYear = EasyDateTime(2024, 1, 1);
  /// print(lastYear.isFuture);  // false
  /// ```
  bool get isFuture => isAfter(EasyDateTime.now(location: location));

  /// Returns `true` if this datetime falls within the current week.
  ///
  /// Week boundaries follow ISO 8601 (Monday = first day, Sunday = last day).
  /// Uses the same timezone as this datetime instance.
  ///
  /// ```dart
  /// final now = EasyDateTime.now();
  /// print(now.isThisWeek);  // true
  ///
  /// final lastMonth = EasyDateTime.now().subtractCalendarDays(30);
  /// print(lastMonth.isThisWeek);  // false
  /// ```
  bool get isThisWeek {
    final now = EasyDateTime.now(location: location);
    final weekStart = now.startOf(DateTimeUnit.week);
    final weekEnd = now.endOf(DateTimeUnit.week);

    return !isBefore(weekStart) && !isAfter(weekEnd);
  }

  /// Returns `true` if this datetime falls within the current month.
  ///
  /// Compares year and month values. Uses the same timezone as this datetime.
  ///
  /// ```dart
  /// final now = EasyDateTime.now();
  /// print(now.isThisMonth);  // true
  ///
  /// final lastYear = EasyDateTime(2024, 1, 1);
  /// print(lastYear.isThisMonth);  // false
  /// ```
  bool get isThisMonth {
    final now = EasyDateTime.now(location: location);

    return year == now.year && month == now.month;
  }

  /// Returns `true` if this datetime falls within the current year.
  ///
  /// Compares only the year value. Uses the same timezone as this datetime.
  ///
  /// ```dart
  /// final now = EasyDateTime.now();
  /// print(now.isThisYear);  // true
  ///
  /// final lastYear = EasyDateTime(2024, 1, 1);
  /// print(lastYear.isThisYear);  // false
  /// ```
  bool get isThisYear => year == EasyDateTime.now(location: location).year;

  /// Checks if this date has the same year, month, and day as [other].
  bool _isSameDay(EasyDateTime other) =>
      year == other.year && month == other.month && day == other.day;

  // ============================================================
  // String Conversion
  // ============================================================

  /// Returns a date-only string in YYYY-MM-DD format.
  ///
  /// ```dart
  /// final dateStr = EasyDateTime.now().toDateString();  // '2025-12-01'
  /// ```
  String toDateString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');

    return '$y-$m-$d';
  }

  /// Returns a time-only string in HH:MM:SS format.
  ///
  /// ```dart
  /// final timeStr = EasyDateTime.now().toTimeString();  // '14:30:00'
  /// ```
  String toTimeString() {
    final h = hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');
    final s = second.toString().padLeft(2, '0');

    return '$h:$min:$s';
  }
}
