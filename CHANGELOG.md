# Changelog

Toutes les évolutions notables du projet sont documentées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), versions selon [SemVer](https://semver.org/lang/fr/).

## [1.2.0] - 2026-09-26

Mise au niveau production.

### Ajouté
- Suite de tests : 35 tests unitaires (domaine, repositories, providers), 17 tests de widgets, 3 tests d'intégration.
- Test de performance d'intégration (FrameTiming : p90 build et raster sous 16 ms en profile).
- Vérification automatique des guidelines d'accessibilité (tap targets, libellés) dans les tests de widgets.
- CI GitHub Actions : format, analyse stricte, tests avec couverture, tests d'intégration sur émulateur Android, build APK et GitHub Release sur tag.
- Script de génération des captures d'écran (`test_driver/screenshots_test.dart`).
- Écran « À propos » avec licences open source.
- README complet et ce CHANGELOG.

### Modifié
- Images redimensionnées côté CDN et décodées à la taille d'affichage (`cacheWidth`), avec des largeurs par paliers.
- Rebuilds ciblés via `select()` : favoris par carte, badge de la liste de courses.
- Lints renforcés (`strict-casts`, `strict-raw-types`, `prefer_const_*`, `require_trailing_commas`…).
- Bouton retour lisible au-dessus des photos sombres.

### Corrigé
- Permission `INTERNET` manquante dans le manifeste release Android (images absentes dans l'APK).
- Langues FR/EN déclarées dans `Info.plist` pour iOS.

## [1.1.0] - 2026-09-19

Internationalisation et personnalisation.

### Ajouté
- Support français et anglais (`gen-l10n`, fichiers ARB, pluriels ICU), UI et contenu des recettes.
- Écran Réglages : langue (appareil / FR / EN) et thème (système / clair / sombre), persistés.
- Liste de courses : ajout depuis une recette, fusion des ingrédients identiques, cocher, suppression avec annulation, badge de navigation.
- Portions ajustables avec recalcul des quantités et formatage selon la langue.

### Modifié
- Navigation migrée vers `go_router` (`StatefulShellRoute`) : état conservé par onglet.

## [1.0.0] - 2026-09-12

Première version.

### Ajouté
- Catalogue de 10 recettes chargé depuis un asset JSON (repository + cache mémoire).
- Écran liste avec recherche (insensible aux accents) et filtres par catégorie.
- Écran détail avec image Hero, ingrédients et étapes.
- Favoris persistés (`shared_preferences`).
- Gestion d'état Riverpod + hooks, thème Material 3 clair/sombre.

[1.2.0]: https://github.com/darius202/flutter_test_ffsc/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/darius202/flutter_test_ffsc/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/darius202/flutter_test_ffsc/releases/tag/v1.0.0
