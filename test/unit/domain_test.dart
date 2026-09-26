import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_ffsc/src/domain/localized_text.dart';
import 'package:flutter_test_ffsc/src/domain/recipe.dart';
import 'package:flutter_test_ffsc/src/domain/recipe_filter.dart';
import 'package:flutter_test_ffsc/src/domain/shopping_item.dart';

import '../helpers/fixtures.dart';

void main() {
  group('LocalizedText', () {
    test('resolves the requested language', () {
      expect(t('Flour', 'Farine').resolve('fr'), 'Farine');
    });

    test('falls back to English, then to the first translation', () {
      expect(t('Flour', 'Farine').resolve('de'), 'Flour');
      expect(const LocalizedText({'it': 'Farina'}).resolve('fr'), 'Farina');
      expect(const LocalizedText({}).resolve('fr'), isEmpty);
    });

    test('rejects invalid JSON', () {
      expect(() => LocalizedText.fromJson(42), throwsFormatException);
    });
  });

  group('Recipe', () {
    test('parses from JSON', () {
      final recipe = Recipe.fromJson(const {
        'id': 'x',
        'title': {'en': 'X', 'fr': 'Xfr'},
        'description': 'plain string',
        'image': 'https://img.test/x',
        'category': 'dessert',
        'duration': 10,
        'difficulty': 'hard',
        'servings': 2,
        'ingredients': [
          {'name': {'en': 'Sugar'}, 'quantity': 100, 'unit': 'g'},
        ],
        'steps': [
          {'en': 'Do it'},
        ],
      });

      expect(recipe.category, RecipeCategory.dessert);
      expect(recipe.difficulty, Difficulty.hard);
      expect(recipe.description.resolve('fr'), 'plain string');
      expect(recipe.ingredients.single.quantity, 100.0);
      expect(recipe.ingredients.single.unit, IngredientUnit.g);
    });

    test('throws on an unknown category', () {
      expect(
        () => Recipe.fromJson(const {'id': 'x', 'title': 'x', 'description': 'x', 'image': 'x', 'category': 'snack'}),
        throwsFormatException,
      );
    });

    test('scales ingredient quantities to the number of servings', () {
      final forEight = pancakes.ingredientsFor(8); // recipe is for 4
      expect(forEight.map((i) => i.quantity), [500, 4]);

      final forOne = pancakes.ingredientsFor(1);
      expect(forOne.first.quantity, 62.5);
    });

    test('refuses less than one serving', () {
      expect(() => pancakes.ingredientsFor(0), throwsArgumentError);
    });

    test('builds a resized image URL and keeps existing parameters', () {
      final recipe = Recipe(
        id: 'r',
        title: t('r'),
        description: t('r'),
        imageUrl: 'https://img.test/photo?ixid=abc',
        category: RecipeCategory.main,
        durationMinutes: 1,
        difficulty: Difficulty.easy,
        servings: 1,
        ingredients: const [],
        steps: const [],
      );
      final uri = Uri.parse(recipe.imageUrlForWidth(600));
      expect(uri.queryParameters, containsPair('w', '600'));
      expect(uri.queryParameters, containsPair('ixid', 'abc'));
      expect(uri.queryParameters, containsPair('auto', 'format'));
    });
  });

  group('RecipeFilter', () {
    test('an empty filter returns everything', () {
      expect(const RecipeFilter().apply(testRecipes), testRecipes);
      expect(const RecipeFilter(query: '  ').isEmpty, isTrue);
    });

    test('matches titles case-insensitively in any language', () {
      expect(const RecipeFilter(query: 'PASTA').apply(testRecipes), [pasta]);
      expect(const RecipeFilter(query: 'gâteau').apply(testRecipes), [cake]);
    });

    test('ignores accents', () {
      expect(const RecipeFilter(query: 'pates').apply(testRecipes), [pasta]);
      expect(RecipeFilter.normalize('Œufs Épicés'), 'oeufs epices');
    });

    test('matches ingredients', () {
      expect(const RecipeFilter(query: 'farine').apply(testRecipes), [pancakes, cake]);
    });

    test('filters by category and combines with the query', () {
      expect(
        const RecipeFilter(category: RecipeCategory.dessert).apply(testRecipes),
        [cake],
      );
      expect(
        const RecipeFilter(query: 'flour', category: RecipeCategory.breakfast)
            .apply(testRecipes),
        [pancakes],
      );
    });

    test('copyWith can clear the category', () {
      const filter = RecipeFilter(query: 'a', category: RecipeCategory.main);
      final cleared = filter.copyWith(category: () => null);
      expect(cleared.category, isNull);
      expect(cleared.query, 'a');
    });
  });

  group('Shopping list merge', () {
    test('sums quantities of the same product and unit', () {
      final once = mergeIngredients(const [], pancakes.ingredients);
      final twice = mergeIngredients(once, cake.ingredients);

      final flour = twice.firstWhere((i) => i.name.resolve('en') == 'Flour');
      expect(flour.quantity, 450);
      expect(twice, hasLength(3)); // flour, eggs, raspberries
    });

    test('keeps different units apart and unchecks re-added items', () {
      final checked = [
        ShoppingItem.fromIngredient(ingredient('Flour', 1, IngredientUnit.kg))
            .copyWith(checked: true),
      ];
      final merged = mergeIngredients(checked, [
        ingredient('Flour', 1, IngredientUnit.kg),
        ingredient('Flour', 100, IngredientUnit.g),
      ]);
      expect(merged, hasLength(2));
      expect(merged.first.quantity, 2);
      expect(merged.first.checked, isFalse);
    });

    test('round-trips through JSON', () {
      final item = ShoppingItem.fromIngredient(pasta.ingredients.last)
          .copyWith(checked: true);
      expect(ShoppingItem.fromJson(item.toJson()), item);
    });
  });
}
