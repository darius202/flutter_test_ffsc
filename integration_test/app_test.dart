import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_ffsc/src/app.dart';
import 'package:flutter_test_ffsc/src/core/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Starts the real app (real bundled catalogue, real router, real images)
/// with fresh, in-memory preferences so every run is deterministic.
Future<void> startApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'locale': 'en'});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const RecipesApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> search(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('search-field')), text);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('search a recipe, scale it and build the shopping list', (tester) async {
    await startApp(tester);
    expect(find.text('10 recipes'), findsOneWidget);

    await search(tester, 'pasta');
    expect(find.text('1 recipe'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recipe-card-tomato-pasta')));
    await tester.pumpAndSettle();
    expect(find.text('Tomato pasta'), findsOneWidget);
    expect(find.text('4 servings'), findsOneWidget);
    expect(find.text('400 g'), findsOneWidget);

    // Cook for two instead of four: quantities are halved.
    await tester.tap(find.byKey(const Key('servings-decrease')));
    await tester.tap(find.byKey(const Key('servings-decrease')));
    await tester.pumpAndSettle();
    expect(find.text('200 g'), findsOneWidget);

    final addButton = find.byKey(const Key('add-to-shopping'));
    await tester.scrollUntilVisible(addButton, 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.text('4 ingredients added'), findsOneWidget);

    // Follow the snackbar action to the shopping tab.
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(find.text('Spaghetti'), findsOneWidget);
    expect(find.text('4 items left'), findsOneWidget);

    await tester.tap(find.text('Spaghetti'));
    await tester.pumpAndSettle();
    expect(find.text('3 items left'), findsOneWidget);

    await tester.tap(find.byKey(const Key('clear-checked')));
    await tester.pumpAndSettle();
    expect(find.text('Spaghetti'), findsNothing);
  });

  testWidgets('favorite a recipe and use the app in French', (tester) async {
    await startApp(tester);

    await tester.tap(find.byKey(const Key('favorite-pancakes')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-favorites')));
    await tester.pumpAndSettle();
    expect(find.text('Fluffy pancakes'), findsOneWidget);
    expect(find.text('No favorites yet'), findsNothing);

    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-fr')));
    await tester.pumpAndSettle();
    expect(find.text('Langue'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-favorites')));
    await tester.pumpAndSettle();
    expect(find.text('Pancakes moelleux'), findsOneWidget);

    // Unfavorite from the favorites tab: the empty state appears in French.
    await tester.tap(find.byKey(const Key('favorite-pancakes')));
    await tester.pumpAndSettle();
    expect(find.text("Aucun favori pour l'instant"), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('about-tile')));
    await tester.pumpAndSettle();
    expect(find.text('Version 1.2.0'), findsOneWidget);
  });

  testWidgets('scrolling the catalogue stays smooth', (tester) async {
    await startApp(tester);
    final list = find.byType(Scrollable).first;

    final timings = <FrameTiming>[];
    void collect(List<FrameTiming> batch) => timings.addAll(batch);
    SchedulerBinding.instance.addTimingsCallback(collect);
    addTearDown(() => SchedulerBinding.instance.removeTimingsCallback(collect));

    for (var i = 0; i < 3; i++) {
      await tester.fling(list, const Offset(0, -1200), 2500);
      await tester.pumpAndSettle();
      await tester.fling(list, const Offset(0, 1200), 2500);
      await tester.pumpAndSettle();
    }
    // The engine reports timings in batches, at least once per second.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    await tester.pump();

    final report = FrameReport(timings);
    binding.reportData = {'scrolling_summary': report.toJson()};
    debugPrint('Scrolling performance: ${report.toJson()}');

    expect(timings, isNotEmpty);
    expect(tester.takeException(), isNull);
    // Frame budgets are only meaningful in profile/release builds:
    //   flutter drive --profile --driver=test_driver/perf_driver.dart     //     --target=integration_test/app_test.dart
    if (kProfileMode || kReleaseMode) {
      expect(report.p90Build, lessThan(16), reason: '90% of frames built in < 16 ms');
      expect(report.p90Raster, lessThan(16), reason: '90% of frames rasterized in < 16 ms');
    }
  });
}

class FrameReport {
  FrameReport(List<FrameTiming> timings)
      : _build = _sorted(timings.map((t) => t.buildDuration)),
        _raster = _sorted(timings.map((t) => t.rasterDuration));

  final List<double> _build;
  final List<double> _raster;

  static List<double> _sorted(Iterable<Duration> durations) =>
      durations.map((d) => d.inMicroseconds / 1000).toList()..sort();

  static double _percentile(List<double> values, double p) =>
      values.isEmpty ? 0 : values[((values.length - 1) * p).round()];

  double get p90Build => _percentile(_build, 0.9);
  double get p90Raster => _percentile(_raster, 0.9);

  Map<String, Object> toJson() => {
        'frames': _build.length,
        'p90_build_ms': p90Build,
        'p90_raster_ms': p90Raster,
        'max_build_ms': _build.isEmpty ? 0 : _build.last,
        'max_raster_ms': _raster.isEmpty ? 0 : _raster.last,
      };
}
