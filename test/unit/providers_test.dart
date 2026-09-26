import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_ffsc/src/core/l10n_extensions.dart';
import 'package:flutter_test_ffsc/src/core/providers.dart';
import 'package:flutter_test_ffsc/src/core/widgets/recipe_image.dart';
import 'package:flutter_test_ffsc/src/data/preferences_repository.dart';
import 'package:flutter_test_ffsc/src/domain/recipe.dart';
import 'package:flutter_test_ffsc/src/features/favorites/favorites_controller.dart';
import 'package:flutter_test_ffsc/src/features/recipes/recipes_providers.dart';
import 'package:flutter_test_ffsc/src/features/settings/settings_controller.dart';
import 'package:flutter_test_ffsc/src/features/shopping/shopping_list_controller.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('recipes providers', () {
    test('filteredRecipesProvider reacts to the filter', () async {
      final container = await createContainer();
      await container.read(recipesProvider.future);

      expect(container.read(filteredRecipesProvider).value, testRecipes);

      container.read(recipeFilterProvider.notifier)
        ..setQuery('cake')
        ..setCategory(RecipeCategory.dessert);
      expect(container.read(filteredRecipesProvider).value, [cake]);

      container.read(recipeFilterProvider.notifier).reset();
      expect(container.read(filteredRecipesProvider).value, hasLength(3));
    });

    test('the catalogue is fetched only once across screens', () async {
      final repo = FakeRecipeRepository();
      final container = await createContainer(repository: repo);
      await container.read(recipesProvider.future);
      container.read(favoriteRecipesProvider);
      container.read(recipeFilterProvider.notifier).setQuery('x');
      expect(repo.fetchCount, 1);
    });
  });

  group('FavoritesNotifier', () {
    test('toggles and persists favorites', () async {
      final container = await createContainer();
      final notifier = container.read(favoritesProvider.notifier);

      await notifier.toggle('pasta');
      expect(container.read(favoritesProvider), {'pasta'});
      expect(
        container.read(preferencesRepositoryProvider).readFavorites(),
        {'pasta'},
      );

      await notifier.toggle('pasta');
      expect(container.read(favoritesProvider), isEmpty);
    });

    test('restores favorites and exposes favorite recipes', () async {
      final container = await createContainer(
        prefs: {PreferencesRepository.favoritesKey: ['raspberry-cake']},
      );
      await container.read(recipesProvider.future);

      expect(container.read(isFavoriteProvider('raspberry-cake')), isTrue);
      expect(container.read(isFavoriteProvider('pancakes')), isFalse);
      expect(container.read(favoriteRecipesProvider).value, [cake]);
    });
  });

  group('ShoppingListNotifier', () {
    test('adds, merges and counts remaining items', () async {
      final container = await createContainer();
      final notifier = container.read(shoppingListProvider.notifier);

      await notifier.addIngredients(pancakes.ingredients);
      await notifier.addIngredients(cake.ingredients);

      expect(container.read(shoppingListProvider), hasLength(3));
      expect(container.read(remainingItemsProvider), 3);

      final flourKey = container.read(shoppingListProvider).first.key;
      await notifier.toggle(flourKey);
      expect(container.read(remainingItemsProvider), 2);

      await notifier.clearChecked();
      expect(container.read(shoppingListProvider), hasLength(2));
    });

    test('removes and restores an item at its position', () async {
      final container = await createContainer();
      final notifier = container.read(shoppingListProvider.notifier);
      await notifier.addIngredients(pancakes.ingredients);

      final removed = container.read(shoppingListProvider).first;
      await notifier.remove(removed.key);
      expect(container.read(shoppingListProvider), isNot(contains(removed)));

      await notifier.restore(removed, 0);
      expect(container.read(shoppingListProvider).first, removed);
    });

    test('state survives an app restart', () async {
      final container = await createContainer();
      await container.read(shoppingListProvider.notifier).addIngredients(pasta.ingredients);

      final restored = container.read(preferencesRepositoryProvider).readShoppingList();
      expect(restored, container.read(shoppingListProvider));
    });
  });

  group('SettingsNotifier', () {
    test('changes and persists theme and locale', () async {
      final container = await createContainer();
      final notifier = container.read(settingsProvider.notifier);
      expect(container.read(settingsProvider), const AppSettings());

      await notifier.setThemeMode(ThemeMode.dark);
      await notifier.setLocale(const Locale('fr'));

      expect(
        container.read(settingsProvider),
        const AppSettings(themeMode: ThemeMode.dark, locale: Locale('fr')),
      );
      final repo = container.read(preferencesRepositoryProvider);
      expect(repo.readThemeMode(), ThemeMode.dark);
      expect(repo.readLocale(), const Locale('fr'));
    });
  });

  group('formatting helpers', () {
    test('formatQuantity uses the locale decimal separator', () {
      expect(formatQuantity(1.5, 'en'), '1.5');
      expect(formatQuantity(1.5, 'fr'), '1,5');
      expect(formatQuantity(62.5, 'en'), '62.5');
      expect(formatQuantity(2, 'en'), '2');
      expect(formatQuantity(1 / 3, 'en'), '0.33');
    });

    test('image widths are bucketed to reuse cache entries', () {
      expect(RecipeImage.bucketWidth(100, 2), 200);
      expect(RecipeImage.bucketWidth(360, 3), 1080);
      expect(RecipeImage.bucketWidth(180, 2.75), 600);
      expect(RecipeImage.bucketWidth(2000, 3), 1080);
    });
  });
}
