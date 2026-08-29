// ignore_for_file: avoid_print

/// intl Integration Example
///
/// Demonstrates: Using EasyDateTime with intl package for locale-aware formatting.
/// Run: dart run example/lib/integrations/intl_example.dart
library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  EasyDateTime.initializeTimeZone();

  // Initialize locale data for non-English locales
  await initializeDateFormatting();

  print('=== intl Integration ===\n');

  final dt = EasyDateTime.now(location: TimeZones.tokyo);
  print('EasyDateTime: $dt\n');

  // --------------------------------------------------------
  // EasyDateTime works directly with DateFormat
  // --------------------------------------------------------
  print('DateFormat with EasyDateTime:');
  print('  yMMMMd (en): ${DateFormat.yMMMMd('en').format(dt)}');
  print('  yMMMMd (ja): ${DateFormat.yMMMMd('ja').format(dt)}');
  print('  yMMMMd (zh): ${DateFormat.yMMMMd('zh').format(dt)}');
  print('  yMMMMd (ko): ${DateFormat.yMMMMd('ko').format(dt)}');
  print('');

  // --------------------------------------------------------
  // Custom patterns
  // --------------------------------------------------------
  print('Custom patterns:');
  print('  EEEE (en):    ${DateFormat('EEEE', 'en').format(dt)}');
  print('  EEEE (ja):    ${DateFormat('EEEE', 'ja').format(dt)}');
  print('  MMMM (zh):    ${DateFormat('MMMM', 'zh').format(dt)}');
  print('');

  // --------------------------------------------------------
  // Full date and time
  // --------------------------------------------------------
  print('Full date and time:');
  print('  en: ${DateFormat.yMMMMEEEEd('en').add_jms().format(dt)}');
  print('  ja: ${DateFormat.yMMMMEEEEd('ja').add_jms().format(dt)}');
  print('');

  // --------------------------------------------------------
  // Why EasyDateTime works with intl
  // --------------------------------------------------------
  print('Why it works:');
  print('  EasyDateTime implements DateTime interface');
  print('  DateFormat.format() accepts DateTime parameter');
  print('  → EasyDateTime can be supplied directly');
}
