import 'package:timezone/timezone.dart';

import 'easy_date_time_init.dart';
import 'exceptions/exceptions.dart';

Location? _globalDefaultLocation;

/// Gets the effective default location for EasyDateTime operations.
///
/// Priority:
/// 1. User-set global default (via [EasyDateTime.setDefaultLocation])
/// 2. The configured `timezone` package local location
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

  // Configured local location. The timezone package does not detect devices.
  return local;
}

// ============================================================
// Internal API for EasyDateTime static methods
// ============================================================

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
