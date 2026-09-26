import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/recipe.dart';

abstract interface class RecipeRepository {
  Future<List<Recipe>> fetchAll();
  Future<Recipe?> fetchById(String id);
}

/// Reads the catalogue bundled with the app. Parsed once, then served from
/// memory so navigating between screens never re-decodes the JSON.
class AssetRecipeRepository implements RecipeRepository {
  AssetRecipeRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/recipes.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  Future<List<Recipe>>? _cache;

  @override
  Future<List<Recipe>> fetchAll() => _cache ??= _load();

  @override
  Future<Recipe?> fetchById(String id) async {
    for (final recipe in await fetchAll()) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  Future<List<Recipe>> _load() async {
    try {
      final raw = await _bundle.loadString(assetPath);
      return List.unmodifiable(parseRecipes(raw));
    } catch (_) {
      _cache = null; // allow a retry after a failure
      rethrow;
    }
  }

  static List<Recipe> parseRecipes(String raw) => [
        for (final item in jsonDecode(raw) as List<dynamic>)
          Recipe.fromJson(item as Map<String, dynamic>),
      ];
}
