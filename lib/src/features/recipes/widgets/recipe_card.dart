import 'package:flutter/material.dart';

import '../../../core/l10n_extensions.dart';
import '../../../core/widgets/recipe_image.dart';
import '../../../domain/recipe.dart';
import '../../favorites/favorite_button.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap});

  static const imageHeight = 170.0;

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final title = context.tr(recipe.title);
    final difficulty = recipe.difficulty.label(l10n);

    return Card(
      child: Stack(
        children: [
          // The whole card is announced as one button by screen readers,
          // the favorite toggle stays a separate, focusable control.
          Semantics(
            button: true,
            label: l10n.recipeCardSemantics(title, recipe.durationMinutes, difficulty),
            child: ExcludeSemantics(
              child: InkWell(
                key: Key('recipe-card-${recipe.id}'),
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: imageHeight,
                      child: RecipeImage(recipe: recipe, heroTag: 'recipe-${recipe.id}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          _RecipeMeta(
                            minutes: recipe.durationMinutes,
                            difficulty: difficulty,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: FavoriteButton(recipeId: recipe.id, filledBackground: true),
          ),
        ],
      ),
    );
  }
}

class _RecipeMeta extends StatelessWidget {
  const _RecipeMeta({required this.minutes, required this.difficulty});

  final int minutes;
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Icons.schedule, size: 16, color: color),
        const SizedBox(width: 4),
        Text(context.l10n.durationMinutes(minutes), style: style),
        const SizedBox(width: 16),
        Icon(Icons.signal_cellular_alt, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(child: Text(difficulty, style: style, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
