import 'package:timezone/timezone.dart';

final _fixedOffsetLocationCache = <int, Location>{};

/// Builds a synthetic fixed-offset [Location] with a stable UTC-style name.
Location fixedOffsetLocation(Duration offset) {
  final offsetMinutes = offset.inMinutes;

  return _fixedOffsetLocationCache.putIfAbsent(offsetMinutes, () {
    final name = _formatFixedOffsetLocationName(offset);
    final zone = offsetMinutes == 0
        ? TimeZone.UTC
        : TimeZone(offset, isDst: false, abbreviation: name);

    return Location(name, const [], const [], [zone]);
  });
}

String _formatFixedOffsetLocationName(Duration offset) {
  if (offset == Duration.zero) {
    return 'UTC';
  }

  final totalMinutes = offset.inMinutes;
  final sign = totalMinutes >= 0 ? '+' : '-';
  final absMinutes = totalMinutes.abs();
  final hours = absMinutes ~/ 60;
  final minutes = absMinutes % 60;

  return 'UTC$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}
