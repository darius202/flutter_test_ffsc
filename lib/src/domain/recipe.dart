import 'package:flutter/foundation.dart';

import 'localized_text.dart';

enum RecipeCategory { breakfast, starter, main, dessert }

enum Difficulty { easy, medium, hard }

enum IngredientUnit { g, kg, ml, l, tbsp, tsp, piece, pinch }

T _parseEnum<T extends Enum>(List<T> values, Object? raw) {
  for (final value in values) {
    if (value.name == raw) return value;
  }
  throw FormatException('Unknown value "$raw" for $T');
}

@immutable
class Ingredient {
  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    name: LocalizedText.fromJson(json['name']),
    quantity: (json['quantity'] as num).toDouble(),
    unit: _parseEnum(IngredientUnit.values, json['unit']),
  );

  final LocalizedText name;
  final double quantity;
  final IngredientUnit unit;

  /// Returns this ingredient with its quantity multiplied by [factor].
  Ingredient scaled(double factor) {
    if (factor <= 0) throw ArgumentError.value(factor, 'factor', 'must be > 0');
    return Ingredient(name: name, quantity: quantity * factor, unit: unit);
  }

  @override
  bool operator ==(Object other) =>
      other is Ingredient &&
      other.name == name &&
      other.quantity == quantity &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(name, quantity, unit);
}

@immutable
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.durationMinutes,
    required this.difficulty,
    required this.servings,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    title: LocalizedText.fromJson(json['title']),
    description: LocalizedText.fromJson(json['description']),
    imageUrl: json['image'] as String,
    category: _parseEnum(RecipeCategory.values, json['category']),
    durationMinutes: json['duration'] as int,
    difficulty: _parseEnum(Difficulty.values, json['difficulty']),
    servings: json['servings'] as int,
    ingredients: [
      for (final i in json['ingredients'] as List<dynamic>)
        Ingredient.fromJson(i as Map<String, dynamic>),
    ],
    steps: [
      for (final s in json['steps'] as List<dynamic>) LocalizedText.fromJson(s),
    ],
  );

  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final String imageUrl;
  final RecipeCategory category;
  final int durationMinutes;
  final Difficulty difficulty;
  final int servings;
  final List<Ingredient> ingredients;
  final List<LocalizedText> steps;

  /// Ingredients adjusted for [targetServings] instead of [servings].
  List<Ingredient> ingredientsFor(int targetServings) {
    if (targetServings < 1) {
      throw ArgumentError.value(
        targetServings,
        'targetServings',
        'must be >= 1',
      );
    }
    final factor = targetServings / servings;
    return [for (final i in ingredients) i.scaled(factor)];
  }

  /// Image URL resized server-side to [width] physical pixels, so the device
  /// never downloads or decodes more pixels than it displays.
  String imageUrlForWidth(int width) {
    final uri = Uri.parse(imageUrl);
    return uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            'w': '$width',
            'q': '70',
            'auto': 'format',
            'fit': 'crop',
          },
        )
        .toString();
  }

  @override
  bool operator ==(Object other) => other is Recipe && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
