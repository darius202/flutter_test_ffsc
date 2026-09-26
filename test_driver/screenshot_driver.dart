import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Regenerates the README screenshots on a connected device:
///
///   flutter drive --profile \
///     --driver=test_driver/screenshot_driver.dart \
///     --target=tool/screenshots_test.dart
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final file = File('docs/screenshots/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return true;
  },
);
