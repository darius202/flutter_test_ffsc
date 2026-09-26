import 'package:integration_test/integration_test_driver.dart';

/// Driver used to collect performance reports:
///
///   flutter drive --profile \
///     --driver=test_driver/perf_driver.dart \
///     --target=integration_test/app_test.dart
///
/// Frame timings are written to `build/integration_response_data.json`.
Future<void> main() => integrationDriver();
