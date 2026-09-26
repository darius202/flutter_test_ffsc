import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/recipe.dart';
import '../../domain/recipe_filter.dart';

final recipesProvider = FutureProvider<List<Recipe>>(
  (ref) => ref.watch(recipeRepositoryProvider).fetchAll(),
);

final recipeProvider = FutureProvider.autoDispose.family<Recipe?, String>(
  (ref, id) => ref.watch(recipeRepositoryProvider).fetchById(id),
);

class RecipeFilterNotifier extends Notifier<RecipeFilter> {
  @override
  RecipeFilter build() => const RecipeFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setCategory(RecipeCategory? category) =>
      state = state.copyWith(category: () => category);

  void reset() => state = const RecipeFilter();
}

final recipeFilterProvider =
    NotifierProvider<RecipeFilterNotifier, RecipeFilter>(RecipeFilterNotifier.new);

/// Recipes after search and category filtering. Only recomputed when the
/// catalogue or the filter actually change.
final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final filter = ref.watch(recipeFilterProvider);
  return ref.watch(recipesProvider).whenData(filter.apply);
});
