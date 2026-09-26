import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_ffsc/src/app.dart';
import 'package:flutter_test_ffsc/src/core/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> start(WidgetTester tester, Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
        child: const RecipesApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Waits for network images, then captures the screen.
  Future<void> shot(WidgetTester tester, String name) async {
    await Future<void>.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  testWidgets('screenshots', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    await start(tester, {
      'locale': 'fr',
      'favorites': ['pancakes', 'raspberry-cake'],
    });
    await shot(tester, '1_recettes');

    await tester.tap(find.byKey(const Key('recipe-card-pancakes')));
    await tester.pumpAndSettle();
    await shot(tester, '2_detail');

    await tester.scrollUntilVisible(
      find.byKey(const Key('add-to-shopping')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('add-to-shopping')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SnackBarAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farine'));
    await tester.pumpAndSettle();
    await shot(tester, '4_courses');

    await tester.tap(find.byKey(const Key('nav-favorites')));
    await tester.pumpAndSettle();
    await shot(tester, '3_favoris');

    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-en')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();
    await shot(tester, '5_settings_en_dark');

    await tester.tap(find.byKey(const Key('nav-recipes')));
    await tester.pumpAndSettle();
    await shot(tester, '6_recipes_en_dark');
  });
}
