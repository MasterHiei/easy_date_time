/// Extension on [int] to create [Duration] more easily.
///
/// Provides intuitive syntax for creating durations.
///
/// ```dart
/// final duration = 2.days + 3.hours + 30.minutes;
/// final oneWeek = 1.weeks;
/// final halfSecond = 500.milliseconds;
/// ```
extension DurationExtension on int {
  /// Creates a [Duration] of this many weeks.
  Duration get weeks => Duration(days: this * 7);

  /// Creates a [Duration] of this many days.
  Duration get days => Duration(days: this);

  /// Creates a [Duration] of this many hours.
  Duration get hours => Duration(hours: this);

  /// Creates a [Duration] of this many minutes.
  Duration get minutes => Duration(minutes: this);

  /// Creates a [Duration] of this many seconds.
  Duration get seconds => Duration(seconds: this);

  /// Creates a [Duration] of this many milliseconds.
  Duration get milliseconds => Duration(milliseconds: this);

  /// Creates a [Duration] of this many microseconds.
  Duration get microseconds => Duration(microseconds: this);
}
