import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/recipe.dart';
import '../../domain/shopping_item.dart';

class ShoppingListNotifier extends Notifier<List<ShoppingItem>> {
  @override
  List<ShoppingItem> build() =>
      ref.watch(preferencesRepositoryProvider).readShoppingList();

  Future<void> addIngredients(Iterable<Ingredient> ingredients) =>
      _save(mergeIngredients(state, ingredients));

  Future<void> toggle(String key) => _save([
    for (final item in state)
      item.key == key ? item.copyWith(checked: !item.checked) : item,
  ]);

  Future<void> remove(String key) => _save([
    for (final item in state)
      if (item.key != key) item,
  ]);

  /// Re-inserts an item removed by mistake (used by the "undo" snackbar).
  Future<void> restore(ShoppingItem item, int index) {
    final next = [...state]..insert(index.clamp(0, state.length), item);
    return _save(next);
  }

  Future<void> clearChecked() => _save([
    for (final item in state)
      if (!item.checked) item,
  ]);

  Future<void> _save(List<ShoppingItem> items) {
    state = List.unmodifiable(items);
    return ref.read(preferencesRepositoryProvider).writeShoppingList(state);
  }
}

final shoppingListProvider =
    NotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(
      ShoppingListNotifier.new,
    );

/// Number of items still to buy, shown as a badge in the navigation bar.
final remainingItemsProvider = Provider<int>(
  (ref) => ref.watch(
    shoppingListProvider.select(
      (items) => items.where((i) => !i.checked).length,
    ),
  ),
);
