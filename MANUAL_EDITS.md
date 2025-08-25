
# Remplacements rapides (copier-coller)

## A) withOpacity -> withValues
Dans ces fichiers:
- `lib/presentation/pages/heatmap_overview_page.dart` (lignes ~93–98)
- `lib/presentation/widgets/goal_card.dart` (~73, ~108)
- `lib/presentation/widgets/mini_heatmap_section.dart` (~69–74)

Remplacez **chaque** appel:
```dart
color.withOpacity(0.20)
```
par
```dart
color.withValues(alpha: 0.20)
```

> Astuce recherche/remplacement : motif `\.withOpacity\(([^)]+)\)` → remplacement `.withValues(alpha: \1)`

## B) SettingsPage (Radio déprécié)
Option rapide (garder l'écran tel quel):
- Ajoutez juste au-dessus des lignes signalées :
```dart
// ignore: deprecated_member_use
```

Option propre (migration UI):
- Dites-moi "go Settings modernisé" et je vous envoie un fichier `settings_page.dart` basé sur `SegmentedButton<ThemeMode>` qui remplace les Radios.

## C) Drift web déprécié
En tête de `lib/infrastructure/db/connection/connection_web.dart` ajoutez:
```dart
// ignore_for_file: deprecated_member_use
```
(migration vers `drift/wasm.dart` possible plus tard).
