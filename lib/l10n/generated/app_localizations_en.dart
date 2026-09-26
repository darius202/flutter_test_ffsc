// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Recipes';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navSettings => 'Settings';

  @override
  String get searchHint => 'Search a recipe or an ingredient';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryBreakfast => 'Breakfast';

  @override
  String get categoryStarter => 'Starters';

  @override
  String get categoryMain => 'Mains';

  @override
  String get categoryDessert => 'Desserts';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String recipeCardSemantics(String title, int minutes, String difficulty) {
    return '$title, $minutes minutes, $difficulty';
  }

  @override
  String recipeImageSemantics(String title) {
    return 'Photo of $title';
  }

  @override
  String recipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
      zero: 'No recipe',
    );
    return '$_temp0';
  }

  @override
  String get noResults => 'No recipe matches your search.';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get errorLoading => 'Something went wrong while loading the recipes.';

  @override
  String get retry => 'Retry';

  @override
  String get recipeNotFound => 'This recipe does not exist.';

  @override
  String get backToRecipes => 'Back to recipes';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get steps => 'Steps';

  @override
  String stepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get decreaseServings => 'Fewer servings';

  @override
  String get increaseServings => 'More servings';

  @override
  String get addToShoppingList => 'Add to shopping list';

  @override
  String addedToShoppingList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients added',
      one: '1 ingredient added',
    );
    return '$_temp0';
  }

  @override
  String get viewShoppingList => 'View';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get favoritesEmptyHint => 'Tap the heart on a recipe to find it here.';

  @override
  String get shoppingEmpty => 'Your shopping list is empty';

  @override
  String get shoppingEmptyHint =>
      'Add the ingredients of a recipe from its page.';

  @override
  String get clearChecked => 'Remove checked items';

  @override
  String itemRemoved(String name) {
    return '$name removed';
  }

  @override
  String get undo => 'Undo';

  @override
  String removeItem(String name) {
    return 'Remove $name';
  }

  @override
  String itemsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items left',
      one: '1 item left',
      zero: 'Everything is bought',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'A production-ready Flutter showcase: Riverpod, go_router, hooks, i18n, accessibility and automated tests.';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get licenses => 'Open-source licenses';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'tbsp';

  @override
  String get unitTsp => 'tsp';

  @override
  String get unitPiece => '';

  @override
  String get unitPinch => 'pinch';
}
