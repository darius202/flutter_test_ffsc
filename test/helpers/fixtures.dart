import 'package:flutter_test_ffsc/src/data/recipe_repository.dart';
import 'package:flutter_test_ffsc/src/domain/localized_text.dart';
import 'package:flutter_test_ffsc/src/domain/recipe.dart';

LocalizedText t(String en, [String? fr]) =>
    LocalizedText({'en': en, 'fr': ?fr});

Ingredient ingredient(
  String en,
  double qty,
  IngredientUnit unit, {
  String? fr,
}) => Ingredient(name: t(en, fr), quantity: qty, unit: unit);

final pancakes = Recipe(
  id: 'pancakes',
  title: t('Fluffy pancakes', 'Pancakes moelleux'),
  description: t('Airy pancakes', 'Pancakes aériens'),
  imageUrl: 'https://images.example.com/pancakes',
  category: RecipeCategory.breakfast,
  durationMinutes: 25,
  difficulty: Difficulty.easy,
  servings: 4,
  ingredients: [
    ingredient('Flour', 250, IngredientUnit.g, fr: 'Farine'),
    ingredient('Eggs', 2, IngredientUnit.piece, fr: 'Œufs'),
  ],
  steps: [t('Mix', 'Mélanger'), t('Cook', 'Cuire')],
);

final pasta = Recipe(
  id: 'tomato-pasta',
  title: t('Tomato pasta', 'Pâtes à la tomate'),
  description: t('Comforting', 'Réconfortant'),
  imageUrl: 'https://images.example.com/pasta',
  category: RecipeCategory.main,
  durationMinutes: 20,
  difficulty: Difficulty.easy,
  servings: 2,
  ingredients: [
    ingredient('Spaghetti', 200, IngredientUnit.g),
    ingredient('Olive oil', 1.5, IngredientUnit.tbsp, fr: "Huile d'olive"),
  ],
  steps: [t('Boil', 'Bouillir')],
);

final cake = Recipe(
  id: 'raspberry-cake',
  title: t('Raspberry cake', 'Gâteau aux framboises'),
  description: t('Tender cake', 'Gâteau fondant'),
  imageUrl: 'https://images.example.com/cake',
  category: RecipeCategory.dessert,
  durationMinutes: 60,
  difficulty: Difficulty.medium,
  servings: 8,
  ingredients: [
    ingredient('Flour', 200, IngredientUnit.g, fr: 'Farine'),
    ingredient('Raspberries', 250, IngredientUnit.g, fr: 'Framboises'),
  ],
  steps: [t('Bake', 'Cuire')],
);

final testRecipes = [pancakes, pasta, cake];

class FakeRecipeRepository implements RecipeRepository {
  FakeRecipeRepository([List<Recipe>? recipes])
    : recipes = recipes ?? testRecipes;

  final List<Recipe> recipes;
  int fetchCount = 0;

  @override
  Future<List<Recipe>> fetchAll() async {
    fetchCount++;
    return recipes;
  }

  @override
  Future<Recipe?> fetchById(String id) async {
    for (final r in recipes) {
      if (r.id == id) return r;
    }
    return null;
  }
}

class FailingRecipeRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> fetchAll() => Future.error(Exception('boom'));

  @override
  Future<Recipe?> fetchById(String id) => Future.error(Exception('boom'));
}
