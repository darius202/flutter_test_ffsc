import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/l10n_extensions.dart';
import 'favorites_controller.dart';

/// Heart toggle. Watches only this recipe's flag, so toggling one favorite
/// rebuilds this single button instead of the whole list.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.recipeId,
    this.filledBackground = false,
  });

  final String recipeId;
  final bool filledBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(recipeId));
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      key: Key('favorite-$recipeId'),
      style: filledBackground
          ? IconButton.styleFrom(
              backgroundColor: scheme.surface.withValues(alpha: 0.85),
            )
          : null,
      isSelected: isFavorite,
      tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
      icon: const Icon(Icons.favorite_border),
      selectedIcon: Icon(Icons.favorite, color: scheme.primary),
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(recipeId),
    );
  }
}
