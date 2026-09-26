import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/l10n_extensions.dart';
import '../shopping/shopping_list_controller.dart';

/// Bottom navigation hosting the four tabs. Each tab keeps its own navigation
/// stack and scroll position thanks to `StatefulShellRoute.indexedStack`.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            key: const Key('nav-recipes'),
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu),
            label: l10n.navRecipes,
          ),
          NavigationDestination(
            key: const Key('nav-favorites'),
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.navFavorites,
          ),
          NavigationDestination(
            key: const Key('nav-shopping'),
            icon: const _ShoppingIcon(selected: false),
            selectedIcon: const _ShoppingIcon(selected: true),
            label: l10n.navShopping,
          ),
          NavigationDestination(
            key: const Key('nav-settings'),
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

/// Only this icon listens to the shopping list, so adding an item does not
/// rebuild the whole navigation bar.
class _ShoppingIcon extends ConsumerWidget {
  const _ShoppingIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(remainingItemsProvider);
    return Badge.count(
      count: remaining,
      isLabelVisible: remaining > 0,
      child: Icon(
        selected ? Icons.shopping_basket : Icons.shopping_basket_outlined,
      ),
    );
  }
}
