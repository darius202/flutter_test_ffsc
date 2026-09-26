import 'package:flutter/foundation.dart';

import 'recipe.dart';

/// Criteria used to narrow down the recipe catalogue.
@immutable
class RecipeFilter {
  const RecipeFilter({this.query = '', this.category});

  final String query;
  final RecipeCategory? category;

  bool get isEmpty => query.trim().isEmpty && category == null;

  RecipeFilter copyWith({
    String? query,
    RecipeCategory? Function()? category,
  }) => RecipeFilter(
    query: query ?? this.query,
    category: category != null ? category() : this.category,
  );

  /// Returns the recipes matching this filter. The search is case and accent
  /// insensitive and looks at the title and the ingredients in every language.
  List<Recipe> apply(List<Recipe> recipes) {
    final needle = normalize(query.trim());
    return [
      for (final recipe in recipes)
        if ((category == null || recipe.category == category) &&
            (needle.isEmpty || _matches(recipe, needle)))
          recipe,
    ];
  }

  static bool _matches(Recipe recipe, String needle) {
    final haystack = [
      ...recipe.title.values.values,
      for (final i in recipe.ingredients) ...i.name.values.values,
    ];
    return haystack.any((text) => normalize(text).contains(needle));
  }

  static const _accents = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'á': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'í': 'i',
    'ô': 'o',
    'ö': 'o',
    'ó': 'o',
    'œ': 'oe',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ú': 'u',
  };

  @visibleForTesting
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final char in input.toLowerCase().split('')) {
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is RecipeFilter &&
      other.query == query &&
      other.category == category;

  @override
  int get hashCode => Object.hash(query, category);
}
