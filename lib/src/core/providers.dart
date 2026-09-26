import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/preferences_repository.dart';
import '../data/recipe_repository.dart';

/// Overridden in `main()` once the instance is loaded, and in tests.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(ref.watch(sharedPreferencesProvider)),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => AssetRecipeRepository(),
);
