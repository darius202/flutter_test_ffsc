import 'package:flutter/foundation.dart';

import 'localized_text.dart';
import 'recipe.dart';

@immutable
class ShoppingItem {
  const ShoppingItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.checked = false,
  });

  factory ShoppingItem.fromIngredient(Ingredient ingredient) => ShoppingItem(
    name: ingredient.name,
    quantity: ingredient.quantity,
    unit: ingredient.unit,
  );

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    name: LocalizedText.fromJson(json['name']),
    quantity: (json['quantity'] as num).toDouble(),
    unit: IngredientUnit.values.byName(json['unit'] as String),
    checked: json['checked'] as bool? ?? false,
  );

  final LocalizedText name;
  final double quantity;
  final IngredientUnit unit;
  final bool checked;

  /// Two items with the same key are the same product and can be merged.
  String get key =>
      '${name.resolve(LocalizedText.fallbackLanguage).toLowerCase()}|${unit.name}';

  ShoppingItem copyWith({double? quantity, bool? checked}) => ShoppingItem(
    name: name,
    quantity: quantity ?? this.quantity,
    unit: unit,
    checked: checked ?? this.checked,
  );

  Map<String, dynamic> toJson() => {
    'name': name.toJson(),
    'quantity': quantity,
    'unit': unit.name,
    'checked': checked,
  };

  @override
  bool operator ==(Object other) =>
      other is ShoppingItem &&
      other.name == name &&
      other.quantity == quantity &&
      other.unit == unit &&
      other.checked == checked;

  @override
  int get hashCode => Object.hash(name, quantity, unit, checked);
}

/// Adds [ingredients] to [items], summing quantities of identical products.
/// A product that was already checked is unchecked since more is needed.
List<ShoppingItem> mergeIngredients(
  List<ShoppingItem> items,
  Iterable<Ingredient> ingredients,
) {
  final byKey = {for (final item in items) item.key: item};
  for (final ingredient in ingredients) {
    final incoming = ShoppingItem.fromIngredient(ingredient);
    final existing = byKey[incoming.key];
    byKey[incoming.key] = existing == null
        ? incoming
        : existing.copyWith(
            quantity: existing.quantity + incoming.quantity,
            checked: false,
          );
  }
  return List.unmodifiable(byKey.values);
}
