import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/recipe.dart';
import '../recipes/recipes_providers.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => Set.unmodifiable(
    ref.watch(preferencesRepositoryProvider).readFavorites(),
  );

  Future<void> toggle(String recipeId) {
    final next = {...state};
    if (!next.remove(recipeId)) next.add(recipeId);
    state = Set.unmodifiable(next);
    return ref.read(preferencesRepositoryProvider).writeFavorites(state);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

/// Per-recipe flag: a card only rebuilds when *its* favorite status changes.
final isFavoriteProvider = Provider.autoDispose.family<bool, String>(
  (ref, id) => ref.watch(favoritesProvider.select((ids) => ids.contains(id))),
);

final favoriteRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final ids = ref.watch(favoritesProvider);
  return ref
      .watch(recipesProvider)
      .whenData(
        (recipes) => [
          for (final r in recipes)
            if (ids.contains(r.id)) r,
        ],
      );
});
