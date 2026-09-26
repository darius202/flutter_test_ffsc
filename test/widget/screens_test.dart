import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_ffsc/src/data/preferences_repository.dart';
import 'package:flutter_test_ffsc/src/features/favorites/favorites_controller.dart';
import 'package:flutter_test_ffsc/src/features/shopping/shopping_list_controller.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

/// Rebuilds the field (which starts the debounce timer), then lets it elapse.
Future<void> settleSearch(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
}

void main() {
  group('Recipe list screen', () {
    testWidgets('shows every recipe with its metadata', (tester) async {
      await pumpApp(tester);

      expect(find.text('Recipes'), findsWidgets);
      expect(find.text('3 recipes'), findsOneWidget);
      expect(find.text('Fluffy pancakes'), findsOneWidget);
      expect(find.text('Tomato pasta'), findsOneWidget);
      expect(find.text('25 min'), findsOneWidget);
    });

    testWidgets('search is debounced and filters the list', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byKey(const Key('search-field')), 'pasta');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('3 recipes'), findsOneWidget, reason: 'still debouncing');

      await settleSearch(tester);
      expect(find.text('1 recipe'), findsOneWidget);
      expect(find.text('Tomato pasta'), findsOneWidget);
      expect(find.text('Fluffy pancakes'), findsNothing);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('3 recipes'), findsOneWidget);
    });

    testWidgets('empty state resets the filters', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byKey(const Key('search-field')), 'pizza');
      await settleSearch(tester);
      expect(find.text('No recipe matches your search.'), findsOneWidget);

      await tester.tap(find.text('Reset filters'));
      await tester.pumpAndSettle();
      expect(find.text('3 recipes'), findsOneWidget);
      expect(find.text('pizza'), findsNothing, reason: 'field cleared too');
    });

    testWidgets('category chips filter the list', (tester) async {
      await pumpApp(tester);
      final dessert = find.byKey(const Key('category-dessert'));

      await tester.ensureVisible(dessert);
      await tester.pumpAndSettle();
      await tester.tap(dessert);
      await tester.pumpAndSettle();

      expect(find.text('1 recipe'), findsOneWidget);
      expect(find.text('Raspberry cake'), findsOneWidget);
      expect(find.text('Tomato pasta'), findsNothing);
    });

    testWidgets('shows an error with a retry button', (tester) async {
      await pumpApp(tester, repository: FailingRecipeRepository());

      expect(find.text('Something went wrong while loading the recipes.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('toggling a favorite updates the heart', (tester) async {
      final container = await pumpApp(tester);
      final heart = find.byKey(const Key('favorite-pancakes'));

      expect(find.descendant(of: heart, matching: find.byIcon(Icons.favorite_border)), findsOneWidget);
      await tester.tap(heart);
      await tester.pumpAndSettle();

      expect(container.read(favoritesProvider), {'pancakes'});
      expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    });
  });

  group('Recipe detail screen', () {
    testWidgets('scales ingredients with the servings stepper', (tester) async {
      await pumpApp(tester, location: '/recipes/tomato-pasta');

      expect(find.text('2 servings'), findsOneWidget);
      expect(find.text('200 g'), findsOneWidget);
      expect(find.text('1.5 tbsp'), findsOneWidget);

      await tester.tap(find.byKey(const Key('servings-increase')));
      await tester.pumpAndSettle();
      expect(find.text('3 servings'), findsOneWidget);
      expect(find.text('300 g'), findsOneWidget);
      expect(find.text('2.25 tbsp'), findsOneWidget);

      await tester.tap(find.byKey(const Key('servings-decrease')));
      await tester.tap(find.byKey(const Key('servings-decrease')));
      await tester.pumpAndSettle();
      expect(find.text('1 serving'), findsOneWidget);
      final decrease = tester.widget<IconButton>(find.byKey(const Key('servings-decrease')));
      expect(decrease.onPressed, isNull, reason: 'cannot go below one serving');
    });

    testWidgets('adds ingredients to the shopping list', (tester) async {
      final container = await pumpApp(tester, location: '/recipes/pancakes');

      await tester.ensureVisible(find.byKey(const Key('add-to-shopping')));
      await tester.tap(find.byKey(const Key('add-to-shopping')));
      await tester.pump();

      expect(find.text('2 ingredients added'), findsOneWidget);
      expect(container.read(shoppingListProvider), hasLength(2));
    });

    testWidgets('shows a not-found state for unknown ids', (tester) async {
      await pumpApp(tester, location: '/recipes/unknown');
      expect(find.text('This recipe does not exist.'), findsOneWidget);
    });
  });

  group('Shopping list screen', () {
    testWidgets('checks, removes with undo and clears items', (tester) async {
      final container = await pumpApp(tester, location: '/shopping');
      expect(find.text('Your shopping list is empty'), findsOneWidget);

      await container.read(shoppingListProvider.notifier).addIngredients(pancakes.ingredients);
      await tester.pumpAndSettle();
      expect(find.text('2 items left'), findsOneWidget);
      // Badge in the navigation bar.
      expect(find.descendant(of: find.byType(Badge), matching: find.text('2')), findsOneWidget);

      await tester.tap(find.text('Flour'));
      await tester.pumpAndSettle();
      expect(find.text('1 item left'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove Eggs'));
      await tester.pumpAndSettle();
      expect(find.text('Eggs'), findsNothing);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Eggs'), findsOneWidget);

      await tester.tap(find.byKey(const Key('clear-checked')));
      await tester.pumpAndSettle();
      expect(find.text('Flour'), findsNothing);
      expect(container.read(shoppingListProvider), hasLength(1));
    });
  });

  group('Favorites and settings', () {
    testWidgets('favorites tab lists saved recipes', (tester) async {
      await pumpApp(
        tester,
        location: '/favorites',
        prefs: {PreferencesRepository.favoritesKey: ['raspberry-cake']},
      );
      expect(find.text('Raspberry cake'), findsOneWidget);
      expect(find.text('Tomato pasta'), findsNothing);
    });

    testWidgets('switching language translates the UI and the content', (tester) async {
      await pumpApp(tester, location: '/settings');
      expect(find.text('Language'), findsOneWidget);

      await tester.tap(find.byKey(const Key('language-fr')));
      await tester.pumpAndSettle();
      expect(find.text('Langue'), findsOneWidget);
      expect(find.text('Réglages'), findsWidgets);

      await tester.tap(find.byKey(const Key('nav-recipes')));
      await tester.pumpAndSettle();
      expect(find.text('Pâtes à la tomate'), findsOneWidget);
      expect(find.text('3 recettes'), findsOneWidget);
    });
  });

  group('Accessibility', () {
    for (final location in ['/recipes', '/recipes/pancakes', '/shopping', '/settings']) {
      testWidgets('$location meets tap target and labelling guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpApp(tester, location: location);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('recipe cards expose a descriptive label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);

      expect(
        find.bySemanticsLabel('Fluffy pancakes, 25 minutes, Easy'),
        findsOneWidget,
      );
      expect(find.byTooltip('Add to favorites'), findsWidgets);
      handle.dispose();
    });
  });
}
