import 'package:timezone/timezone.dart';

import 'easy_date_time_init.dart';
import 'exceptions/exceptions.dart';

Location? _globalDefaultLocation;

/// Sets the global default timezone for all [EasyDateTime] operations.
///
/// **Deprecated**: Use [EasyDateTime.setDefaultLocation] instead.
///
/// This is **optional**. If not set, [EasyDateTime] uses the system's
/// local timezone.
///
/// ```dart
/// EasyDateTime.setDefaultLocation(TimeZones.shanghai);
/// final now = EasyDateTime.now(); // Shanghai time
/// ```
@Deprecated(
  'Use EasyDateTime.setDefaultLocation() instead. '
  'This function will be removed in v0.4.0.',
)
void setDefaultLocation(Location? location) {
  _globalDefaultLocation = location;
}

/// Gets the current global default timezone.
///
/// **Deprecated**: Use [EasyDateTime.getDefaultLocation] instead.
///
/// Returns `null` if no default has been set.
@Deprecated(
  'Use EasyDateTime.getDefaultLocation() instead. '
  'This function will be removed in v0.4.0.',
)
Location? getDefaultLocation() => _globalDefaultLocation;

/// Clears the global default timezone.
///
/// **Deprecated**: Use [EasyDateTime.clearDefaultLocation] instead.
///
/// After calling this, [EasyDateTime] will use the system's local timezone.
@Deprecated(
  'Use EasyDateTime.clearDefaultLocation() instead. '
  'This function will be removed in v0.4.0.',
)
void clearDefaultLocation() {
  _globalDefaultLocation = null;
}

/// Gets the effective default location for EasyDateTime operations.
///
/// Priority:
/// 1. User-set global default (via [EasyDateTime.setDefaultLocation])
/// 2. System local timezone
///
/// **Throws [TimeZoneNotInitializedException]** if [EasyDateTime.initializeTimeZone]
/// has not been called.
Location get effectiveDefaultLocation {
  // Check initialization first
  if (!internalIsTimeZoneInitialized) {
    throw TimeZoneNotInitializedException(
      'Timezone database not initialized. '
      'Call EasyDateTime.initializeTimeZone() at app startup before using EasyDateTime.',
    );
  }

  // User-set global default takes priority
  if (_globalDefaultLocation != null) {
    return _globalDefaultLocation!;
  }

  // System local timezone
  return local;
}

// ============================================================
// Internal API for EasyDateTime static methods
// ============================================================
// These functions are used by EasyDateTime's static methods to avoid
// triggering deprecation warnings internally.

/// Internal: Sets the global default location.
void internalSetDefaultLocation(Location? location) {
  _globalDefaultLocation = location;
}

/// Internal: Gets the current global default location.
Location? internalGetDefaultLocation() => _globalDefaultLocation;

/// Internal: Clears the global default location.
void internalClearDefaultLocation() {
  _globalDefaultLocation = null;
}
