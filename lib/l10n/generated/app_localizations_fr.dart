// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Recettes';

  @override
  String get navRecipes => 'Recettes';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navShopping => 'Courses';

  @override
  String get navSettings => 'Réglages';

  @override
  String get searchHint => 'Rechercher une recette ou un ingrédient';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get categoryAll => 'Toutes';

  @override
  String get categoryBreakfast => 'Petit-déj';

  @override
  String get categoryStarter => 'Entrées';

  @override
  String get categoryMain => 'Plats';

  @override
  String get categoryDessert => 'Desserts';

  @override
  String get filterByCategory => 'Filtrer par catégorie';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String servingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String recipeCardSemantics(String title, int minutes, String difficulty) {
    return '$title, $minutes minutes, $difficulty';
  }

  @override
  String recipeImageSemantics(String title) {
    return 'Photo de $title';
  }

  @override
  String recipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes',
      one: '1 recette',
      zero: 'Aucune recette',
    );
    return '$_temp0';
  }

  @override
  String get noResults => 'Aucune recette ne correspond à votre recherche.';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String get errorLoading =>
      'Une erreur est survenue lors du chargement des recettes.';

  @override
  String get retry => 'Réessayer';

  @override
  String get recipeNotFound => 'Cette recette n\'existe pas.';

  @override
  String get backToRecipes => 'Retour aux recettes';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get steps => 'Étapes';

  @override
  String stepNumber(int number) {
    return 'Étape $number';
  }

  @override
  String get decreaseServings => 'Moins de personnes';

  @override
  String get increaseServings => 'Plus de personnes';

  @override
  String get addToShoppingList => 'Ajouter aux courses';

  @override
  String addedToShoppingList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients ajoutés',
      one: '1 ingrédient ajouté',
    );
    return '$_temp0';
  }

  @override
  String get viewShoppingList => 'Voir';

  @override
  String get favoritesEmpty => 'Aucun favori pour l\'instant';

  @override
  String get favoritesEmptyHint =>
      'Touchez le cœur d\'une recette pour la retrouver ici.';

  @override
  String get shoppingEmpty => 'Votre liste de courses est vide';

  @override
  String get shoppingEmptyHint =>
      'Ajoutez les ingrédients d\'une recette depuis sa fiche.';

  @override
  String get clearChecked => 'Supprimer les articles cochés';

  @override
  String itemRemoved(String name) {
    return '$name supprimé';
  }

  @override
  String get undo => 'Annuler';

  @override
  String removeItem(String name) {
    return 'Supprimer $name';
  }

  @override
  String itemsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles restants',
      one: '1 article restant',
      zero: 'Tout est acheté',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Langue de l\'appareil';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get about => 'À propos';

  @override
  String get aboutDescription =>
      'Une vitrine Flutter prête pour la production : Riverpod, go_router, hooks, i18n, accessibilité et tests automatisés.';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get licenses => 'Licences open source';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'c. à s.';

  @override
  String get unitTsp => 'c. à c.';

  @override
  String get unitPiece => '';

  @override
  String get unitPinch => 'pincée';
}
