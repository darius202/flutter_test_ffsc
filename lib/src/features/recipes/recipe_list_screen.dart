import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/l10n_extensions.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/recipe.dart';
import 'recipes_providers.dart';
import 'widgets/recipe_sliver_grid.dart';

class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recipes = ref.watch(filteredRecipesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(title: Text(l10n.appTitle)),
          const SliverToBoxAdapter(child: _SearchField()),
          const SliverToBoxAdapter(child: _CategoryChips()),
          ...recipes.when(
            skipLoadingOnReload: true,
            data: (list) => [
              SliverToBoxAdapter(child: _ResultCount(count: list.length)),
              if (list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: l10n.noResults,
                    action: OutlinedButton(
                      onPressed: () => ref.read(recipeFilterProvider.notifier).reset(),
                      child: Text(l10n.resetFilters),
                    ),
                  ),
                )
              else
                RecipeSliverGrid(recipes: list),
            ],
            loading: () => const [
              SliverFillRemaining(hasScrollBody: false, child: LoadingState()),
            ],
            error: (_, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorState(onRetry: () => ref.invalidate(recipesProvider)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Search box with a 300 ms debounce: the list is filtered once the user
/// pauses typing rather than on every keystroke.
class _SearchField extends HookConsumerWidget {
  const _SearchField();

  static const debounce = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = useTextEditingController(
      text: ref.read(recipeFilterProvider).query,
    );
    final text = useValueListenable(controller).text;

    // Keep the field in sync when the filter is reset from elsewhere.
    ref.listen(recipeFilterProvider.select((f) => f.query), (_, next) {
      if (next != controller.text) controller.text = next;
    });

    useEffect(() {
      if (text == ref.read(recipeFilterProvider).query) return null;
      final timer = Timer(debounce, () {
        ref.read(recipeFilterProvider.notifier).setQuery(text);
      });
      return timer.cancel;
    }, [text]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        key: const Key('search-field'),
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.clearSearch,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    ref.read(recipeFilterProvider.notifier).setQuery('');
                  },
                ),
        ),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(recipeFilterProvider.select((f) => f.category));
    final notifier = ref.read(recipeFilterProvider.notifier);

    Widget chip(RecipeCategory? category, String label) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            key: Key('category-${category?.name ?? 'all'}'),
            label: Text(label),
            selected: selected == category,
            onSelected: (_) => notifier.setCategory(category),
          ),
        );

    return Semantics(
      container: true,
      label: l10n.filterByCategory,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            chip(null, l10n.categoryAll),
            for (final c in RecipeCategory.values) chip(c, c.label(l10n)),
          ],
        ),
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        // Announced by screen readers whenever the number of results changes.
        child: Semantics(
          liveRegion: true,
          child: Text(
            context.l10n.recipesFound(count),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      );
}
