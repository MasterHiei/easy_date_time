/// Units of time for [EasyDateTime.startOf] and [EasyDateTime.endOf].
///
/// Used to truncate or extend a datetime to the boundary of a time unit.
///
/// ```dart
/// final dt = EasyDateTime(2025, 6, 15, 14, 30, 45);
///
/// dt.startOf(DateTimeUnit.day);   // 2025-06-15 00:00:00
/// dt.endOf(DateTimeUnit.month);   // 2025-06-30 23:59:59.999999
/// ```
enum DateTimeUnit {
  /// Year boundary.
  year,

  /// Month boundary.
  month,

  /// Week boundary (ISO 8601: weeks start on Monday).
  week,

  /// Day boundary.
  day,

  /// Hour boundary.
  hour,

  /// Minute boundary.
  minute,

  /// Second boundary.
  second,
}
