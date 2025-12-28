part of 'easy_date_time.dart';

// ============================================================
// Date Utilities Extension
// ============================================================

/// Extension providing date utility methods for [EasyDateTime].
extension EasyDateTimeUtilities on EasyDateTime {
  /// Returns a new [EasyDateTime] with time set to 00:00:00.000.
  ///
  /// Useful for date-only comparisons or getting the start of a day.
  ///
  /// ```dart
  /// final now = EasyDateTime.now();  // 2025-12-01 14:30:00
  /// final date = now.dateOnly;       // 2025-12-01 00:00:00
  /// ```
  EasyDateTime get dateOnly => copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );

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
    // Get the first day of next month, then subtract 1 day
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final firstOfNextMonth =
        EasyDateTime(nextYear, nextMonth, 1, 0, 0, 0, 0, 0, location);

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

  /// Checks if this date has the same year, month, and day as [other].
  bool _isSameDay(EasyDateTime other) =>
      year == other.year && month == other.month && day == other.day;

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
