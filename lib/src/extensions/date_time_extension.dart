import 'package:timezone/timezone.dart';

import '../easy_date_time.dart';
import '../easy_date_time_config.dart';

/// Extension on [DateTime] to convert to [EasyDateTime].
///
/// ```dart
/// final dt = DateTime.now();
/// final easyDt = dt.toEasyDateTime(location: getLocation('Asia/Tokyo'));
/// ```
extension DateTimeExtension on DateTime {
  /// Converts this [DateTime] to an [EasyDateTime] in the specified [location].
  ///
  /// If no [location] is provided, uses the global default timezone
  /// (set via [EasyDateTime.setDefaultLocation]) or the system's local timezone.
  ///
  /// ```dart
  /// final easyDt = DateTime.now().toEasyDateTime(
  ///   location: getLocation('Europe/London'),
  /// );
  /// ```
  EasyDateTime toEasyDateTime({Location? location}) {
    final loc = location ?? effectiveDefaultLocation;

    return EasyDateTime.fromDateTime(this, location: loc);
  }
}
