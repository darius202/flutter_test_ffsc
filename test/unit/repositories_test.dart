import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_ffsc/src/data/preferences_repository.dart';
import 'package:flutter_test_ffsc/src/data/recipe_repository.dart';
import 'package:flutter_test_ffsc/src/domain/shopping_item.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fixtures.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

const _json = '''
[
  {"id": "a", "title": {"en": "A"}, "description": "d", "image": "https://i/a",
   "category": "main", "duration": 5, "difficulty": "easy", "servings": 1,
   "ingredients": [], "steps": []},
  {"id": "b", "title": {"en": "B"}, "description": "d", "image": "https://i/b",
   "category": "starter", "duration": 5, "difficulty": "easy", "servings": 1,
   "ingredients": [], "steps": []}
]
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetRecipeRepository', () {
    late MockAssetBundle bundle;
    late AssetRecipeRepository repository;

    setUp(() {
      bundle = MockAssetBundle();
      repository = AssetRecipeRepository(bundle: bundle);
    });

    test('parses the bundled catalogue and caches it', () async {
      when(() => bundle.loadString(any())).thenAnswer((_) async => _json);

      final first = await repository.fetchAll();
      final second = await repository.fetchAll();

      expect(first.map((r) => r.id), ['a', 'b']);
      expect(identical(first, second), isTrue);
      verify(() => bundle.loadString('assets/data/recipes.json')).called(1);
    });

    test('finds a recipe by id, or returns null', () async {
      when(() => bundle.loadString(any())).thenAnswer((_) async => _json);

      expect((await repository.fetchById('b'))?.id, 'b');
      expect(await repository.fetchById('missing'), isNull);
    });

    test('can retry after a loading failure', () async {
      var calls = 0;
      when(() => bundle.loadString(any())).thenAnswer((_) async {
        if (calls++ == 0) throw const FormatException('corrupted');
        return _json;
      });

      await expectLater(repository.fetchAll(), throwsFormatException);
      expect(await repository.fetchAll(), hasLength(2));
    });

    test('the real bundled catalogue is valid', () async {
      final recipes = await AssetRecipeRepository().fetchAll();
      expect(recipes.length, greaterThanOrEqualTo(10));
      expect(recipes.map((r) => r.id).toSet(), hasLength(recipes.length));
      for (final r in recipes) {
        expect(r.title.values.keys, containsAll(['fr', 'en']), reason: r.id);
        expect(r.ingredients, isNotEmpty, reason: r.id);
      }
    });
  });

  group('PreferencesRepository', () {
    Future<PreferencesRepository> create([Map<String, Object> values = const {}]) async {
      SharedPreferences.setMockInitialValues(values);
      return PreferencesRepository(await SharedPreferences.getInstance());
    }

    test('persists favorites', () async {
      final repo = await create();
      expect(repo.readFavorites(), isEmpty);
      await repo.writeFavorites({'b', 'a'});
      expect(repo.readFavorites(), {'a', 'b'});
    });

    test('persists the shopping list', () async {
      final repo = await create();
      final items = mergeIngredients(const [], pancakes.ingredients);
      await repo.writeShoppingList(items);
      expect(repo.readShoppingList(), items);
    });

    test('recovers from a corrupted shopping list', () async {
      final repo = await create({PreferencesRepository.shoppingKey: '{not json'});
      expect(repo.readShoppingList(), isEmpty);
    });

    test('persists theme and locale, with sensible defaults', () async {
      final repo = await create({PreferencesRepository.themeKey: 'unknown'});
      expect(repo.readThemeMode(), ThemeMode.system);
      expect(repo.readLocale(), isNull);

      await repo.writeThemeMode(ThemeMode.dark);
      await repo.writeLocale(const Locale('fr'));
      expect(repo.readThemeMode(), ThemeMode.dark);
      expect(repo.readLocale(), const Locale('fr'));

      await repo.writeLocale(null);
      expect(repo.readLocale(), isNull);
    });
  });
}
