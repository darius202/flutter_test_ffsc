import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/l10n_extensions.dart';
import '../../core/widgets/recipe_image.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/recipe.dart';
import '../favorites/favorite_button.dart';
import '../shopping/shopping_list_controller.dart';
import 'recipes_providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref.watch(recipeProvider(recipeId)).when(
          data: (recipe) => recipe == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: EmptyState(
                    icon: Icons.no_food,
                    title: l10n.recipeNotFound,
                    action: FilledButton(
                      onPressed: () => context.go('/recipes'),
                      child: Text(l10n.backToRecipes),
                    ),
                  ),
                )
              : _RecipeDetailView(recipe: recipe),
          loading: () => const Scaffold(body: LoadingState()),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: ErrorState(onRetry: () => ref.invalidate(recipeProvider(recipeId))),
          ),
        );
  }
}

class _RecipeDetailView extends HookConsumerWidget {
  const _RecipeDetailView({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final servings = useState(recipe.servings);
    final ingredients = useMemoized(
      () => recipe.ingredientsFor(servings.value),
      [servings.value],
    );
    final title = context.tr(recipe.title);

    Future<void> addToShoppingList() async {
      await ref.read(shoppingListProvider.notifier).addIngredients(ingredients);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.addedToShoppingList(ingredients.length)),
            action: SnackBarAction(
              label: l10n.viewShoppingList,
              onPressed: () => context.go('/shopping'),
            ),
          ),
        );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            actions: [
              FavoriteButton(recipeId: recipe.id, filledBackground: true),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: RecipeImage(
                recipe: recipe,
                heroTag: 'recipe-${recipe.id}',
                semanticLabel: l10n.recipeImageSemantics(title),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverList.list(
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.headlineMedium),
                ),
                const SizedBox(height: 8),
                Text(context.tr(recipe.description), style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.schedule, size: 18),
                      label: Text(l10n.durationMinutes(recipe.durationMinutes)),
                    ),
                    Chip(
                      avatar: const Icon(Icons.signal_cellular_alt, size: 18),
                      label: Text(recipe.difficulty.label(l10n)),
                    ),
                    Chip(
                      avatar: const Icon(Icons.category_outlined, size: 18),
                      label: Text(recipe.category.label(l10n)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(l10n.ingredients),
                _ServingsStepper(servings: servings),
              ],
            ),
          ),
          SliverList.builder(
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: const Icon(Icons.circle, size: 8),
                title: Text(context.tr(ingredient.name)),
                trailing: Text(
                  formatAmount(ingredient.quantity, ingredient.unit, l10n),
                  key: Key('ingredient-amount-$index'),
                  style: theme.textTheme.bodyLarge,
                ),
              );
            },
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverList.list(
              children: [
                FilledButton.icon(
                  key: const Key('add-to-shopping'),
                  onPressed: addToShoppingList,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(l10n.addToShoppingList),
                ),
                const SizedBox(height: 24),
                _SectionTitle(l10n.steps),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 32),
            sliver: SliverList.builder(
              itemCount: recipe.steps.length,
              itemBuilder: (context, index) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: CircleAvatar(
                  radius: 16,
                  child: Semantics(
                    label: l10n.stepNumber(index + 1),
                    child: ExcludeSemantics(child: Text('${index + 1}')),
                  ),
                ),
                title: Text(context.tr(recipe.steps[index])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      );
}

class _ServingsStepper extends StatelessWidget {
  const _ServingsStepper({required this.servings});

  static const min = 1;
  static const max = 20;

  final ValueNotifier<int> servings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = servings.value;
    return Row(
      children: [
        IconButton.outlined(
          key: const Key('servings-decrease'),
          tooltip: l10n.decreaseServings,
          onPressed: value > min ? () => servings.value-- : null,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(
              l10n.servingsCount(value),
              key: const Key('servings-label'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton.outlined(
          key: const Key('servings-increase'),
          tooltip: l10n.increaseServings,
          onPressed: value < max ? () => servings.value++ : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
