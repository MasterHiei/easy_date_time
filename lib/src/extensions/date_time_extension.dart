import 'package:timezone/timezone.dart';

import '../easy_date_time.dart';
import '../easy_date_time_config.dart';

/// Extension on [DateTime] to convert to [EasyDateTime].
///
/// ```dart
/// final dt = DateTime.utc(2026, 1, 18, 2, 30);
/// final easyDt = dt.toEasyDateTime(location: getLocation('Asia/Tokyo'));
/// ```
extension DateTimeExtension on DateTime {
  /// Converts this [DateTime] to an [EasyDateTime] in the specified [location].
  ///
  /// If no [location] is provided, uses the global default timezone
  /// (set via [EasyDateTime.setDefaultLocation]) or the configured local
  /// location.
  ///
  /// ```dart
  /// final easyDt = DateTime.utc(2026, 1, 18, 2, 30).toEasyDateTime(
  ///   location: getLocation('Europe/London'),
  /// );
  /// ```
  EasyDateTime toEasyDateTime({Location? location}) {
    final loc = location ?? effectiveDefaultLocation;

    return EasyDateTime.fromDateTime(this, location: loc);
  }
}
