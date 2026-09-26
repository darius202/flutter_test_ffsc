import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../domain/localized_text.dart';
import '../domain/recipe.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get languageCode => Localizations.localeOf(this).languageCode;

  /// Resolves bundled content in the current UI language.
  String tr(LocalizedText text) => text.resolve(languageCode);
}

extension RecipeCategoryL10n on RecipeCategory {
  String label(AppLocalizations l10n) => switch (this) {
    RecipeCategory.breakfast => l10n.categoryBreakfast,
    RecipeCategory.starter => l10n.categoryStarter,
    RecipeCategory.main => l10n.categoryMain,
    RecipeCategory.dessert => l10n.categoryDessert,
  };
}

extension DifficultyL10n on Difficulty {
  String label(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasy,
    Difficulty.medium => l10n.difficultyMedium,
    Difficulty.hard => l10n.difficultyHard,
  };
}

extension IngredientUnitL10n on IngredientUnit {
  String label(AppLocalizations l10n) => switch (this) {
    IngredientUnit.g => l10n.unitG,
    IngredientUnit.kg => l10n.unitKg,
    IngredientUnit.ml => l10n.unitMl,
    IngredientUnit.l => l10n.unitL,
    IngredientUnit.tbsp => l10n.unitTbsp,
    IngredientUnit.tsp => l10n.unitTsp,
    IngredientUnit.piece => l10n.unitPiece,
    IngredientUnit.pinch => l10n.unitPinch,
  };
}

/// Formats a quantity for humans: at most two decimals, no trailing zeros and
/// the decimal separator of [locale] (`1.5` in English, `1,5` in French).
String formatQuantity(double quantity, String locale) =>
    NumberFormat('#,##0.##', locale).format(quantity);

/// "250 g", "2 tbsp", or just "2" for countable items.
String formatAmount(
  double quantity,
  IngredientUnit unit,
  AppLocalizations l10n,
) {
  final amount = formatQuantity(quantity, l10n.localeName);
  final unitLabel = unit.label(l10n);
  return unitLabel.isEmpty ? amount : '$amount $unitLabel';
}
