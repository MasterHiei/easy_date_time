import 'package:timezone/timezone.dart';

import 'easy_date_time_init.dart';
import 'exceptions/exceptions.dart';

Location? _globalDefaultLocation;

/// Sets the global default timezone for all [EasyDateTime] operations.
///
/// This is **optional**. If not set, [EasyDateTime] uses the system's
/// local timezone.
///
/// ```dart
/// setDefaultLocation(TimeZones.shanghai);
/// final now = EasyDateTime.now(); // Shanghai time
/// ```
void setDefaultLocation(Location? location) {
  _globalDefaultLocation = location;
}

/// Gets the current global default timezone.
///
/// Returns `null` if no default has been set.
Location? getDefaultLocation() => _globalDefaultLocation;

/// Clears the global default timezone.
///
/// After calling this, [EasyDateTime] will use the system's local timezone.
void clearDefaultLocation() {
  _globalDefaultLocation = null;
}

/// Gets the effective default location for EasyDateTime operations.
///
/// Priority:
/// 1. User-set global default (via [setDefaultLocation])
/// 2. System local timezone
///
/// **Throws [TimeZoneNotInitializedException]** if [initializeTimeZone]
/// has not been called.
Location get effectiveDefaultLocation {
  // Check initialization first
  if (!isTimeZoneInitialized) {
    throw TimeZoneNotInitializedException(
      'Timezone database not initialized. '
      'Call initializeTimeZone() at app startup before using EasyDateTime.',
    );
  }

  // User-set global default takes priority
  if (_globalDefaultLocation != null) {
    return _globalDefaultLocation!;
  }

  // System local timezone
  return local;
}
