import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/l10n_extensions.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/shopping_item.dart';
import 'shopping_list_controller.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(shoppingListProvider);
    final remaining = ref.watch(remainingItemsProvider);
    final hasChecked = remaining < items.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navShopping),
        actions: [
          IconButton(
            key: const Key('clear-checked'),
            tooltip: l10n.clearChecked,
            onPressed: hasChecked
                ? () => ref.read(shoppingListProvider.notifier).clearChecked()
                : null,
            icon: const Icon(Icons.playlist_remove),
          ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_basket_outlined,
              title: l10n.shoppingEmpty,
              message: l10n.shoppingEmptyHint,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.itemsRemaining(remaining),
                      key: const Key('items-remaining'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) => _ShoppingTile(
                      key: ValueKey(items[index].key),
                      item: items[index],
                      index: index,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ShoppingTile extends ConsumerWidget {
  const _ShoppingTile({super.key, required this.item, required this.index});

  final ShoppingItem item;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = context.tr(item.name);
    final notifier = ref.read(shoppingListProvider.notifier);
    final theme = Theme.of(context);

    void remove() {
      notifier.remove(item.key);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.itemRemoved(name)),
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () => notifier.restore(item, index),
            ),
          ),
        );
    }

    return Dismissible(
      key: ValueKey('dismiss-${item.key}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => remove(),
      background: ColoredBox(
        color: theme.colorScheme.errorContainer,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
          ),
        ),
      ),
      child: CheckboxListTile(
        key: Key('shopping-item-${item.key}'),
        value: item.checked,
        onChanged: (_) => notifier.toggle(item.key),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          name,
          style: item.checked
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        subtitle: Text(formatAmount(item.quantity, item.unit, l10n)),
        secondary: IconButton(
          tooltip: l10n.removeItem(name),
          icon: const Icon(Icons.delete_outline),
          onPressed: remove,
        ),
      ),
    );
  }
}
