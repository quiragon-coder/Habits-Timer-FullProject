
# Nettoyage des infos/warnings restants

## 1) withOpacity déprécié → withValues
Remplacez partout:
```dart
color.withOpacity(0.2)   // ❌
```
par
```dart
color.withValues(alpha: 0.2)  // ✅
```

Fichiers mentionnés:
- lib/presentation/pages/heatmap_overview_page.dart (lignes ~93–98)
- lib/presentation/widgets/goal_card.dart (lignes ~73, 108)
- lib/presentation/widgets/mini_heatmap_section.dart (lignes ~69–74)

## 2) Radio deprecated (SettingsPage)
Flutter M3 pousse vers `RadioGroup`. Si vous voulez rester simple, ajoutez une ligne au-dessus des props dépréciées:
```dart
// ignore: deprecated_member_use
```
Sinon, remplacez par un `SegmentedButton<ThemeMode>` ou `DropdownButton<ThemeMode>`.

## 3) Drift web deprecated
Dans `lib/infrastructure/db/connection/connection_web.dart`, en tête du fichier :
```dart
// ignore_for_file: deprecated_member_use
```
(La migration vers `drift/wasm.dart` est plus longue – on peut la planifier plus tard.)

## 4) if sans accolades
Ajoutez des `{}` autour des statements simples signalés (par ex. dans GoalProgressCard).

## 5) Variables inutilisées / null-aware inutiles
- Supprimé dans HomePage: la variable est maintenant utilisée pour désactiver Play/Pause.
- Pour d’autres cas similaires, supprimez la variable ou utilisez-la; remplacez `x?.y` quand `x` ne peut pas être nul.
