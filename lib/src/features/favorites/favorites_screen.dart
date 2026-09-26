import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/l10n_extensions.dart';
import '../../core/widgets/state_views.dart';
import '../recipes/recipes_providers.dart';
import '../recipes/widgets/recipe_sliver_grid.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favorites = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(title: Text(l10n.navFavorites)),
          ...favorites.when(
            skipLoadingOnReload: true,
            data: (recipes) => [
              if (recipes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.favorite_border,
                    title: l10n.favoritesEmpty,
                    message: l10n.favoritesEmptyHint,
                  ),
                )
              else
                RecipeSliverGrid(recipes: recipes),
            ],
            loading: () => const [
              SliverFillRemaining(hasScrollBody: false, child: LoadingState()),
            ],
            error: (_, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorState(
                  onRetry: () => ref.invalidate(recipesProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
