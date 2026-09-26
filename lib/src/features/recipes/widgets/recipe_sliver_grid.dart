import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/recipe.dart';
import 'recipe_card.dart';

/// Lazily built grid: cards (and their images) are only created when they
/// scroll into view. A fixed item extent lets the viewport lay out without
/// measuring children, which keeps scrolling cheap.
class RecipeSliverGrid extends StatelessWidget {
  const RecipeSliverGrid({super.key, required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 520,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: RecipeCard.imageHeight + 72 * textScale + 8,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return RecipeCard(
            key: ValueKey(recipe.id),
            recipe: recipe,
            onTap: () => context.push('/recipes/${recipe.id}'),
          );
        },
      ),
    );
  }
}
