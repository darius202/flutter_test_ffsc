import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_ffsc/src/app.dart';
import 'package:flutter_test_ffsc/src/core/providers.dart';
import 'package:flutter_test_ffsc/src/data/recipe_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

/// Builds a [ProviderContainer] backed by in-memory preferences.
Future<ProviderContainer> createContainer({
  Map<String, Object> prefs = const {},
  RecipeRepository? repository,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      recipeRepositoryProvider.overrideWithValue(
        repository ?? FakeRecipeRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Pumps the whole app on a phone-sized screen at [location].
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  String location = '/recipes',
  Map<String, Object> prefs = const {},
  RecipeRepository? repository,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = await createContainer(prefs: prefs, repository: repository);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RecipesApp(initialLocation: location),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}
