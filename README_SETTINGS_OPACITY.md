# Settings modernisé + remplacement withOpacity

## 1) Remplacer la page Réglages
Copiez ce fichier dans votre projet (il écrasera l'ancien) :
- `lib/presentation/pages/settings_page.dart`

Il utilise `SegmentedButton<ThemeMode>` et `SwitchListTile` (aucune API dépréciée).  
Il dépend de `settingsProvider` avec:
- `AppSettings.themeMode` (get)
- `AppSettings.hapticsEnabled` (get)
- `SettingsController.setTheme(ThemeMode)`
- `SettingsController.setHaptics(bool)`

Ces méthodes existent déjà dans votre `settings_provider.dart`.

## 2) Remplacer `.withOpacity(x)` par `.withValues(alpha: x)`

### Option automatique (recommandé)
Depuis la racine du projet :
```powershell
# Windows (PowerShell)
.\scripts\fix_opacity.ps1
```
ou
```bash
# macOS / Linux
dart run tool/fix_opacity.dart
```

Le script parcourt `lib/**` et convertit toutes les occurrences.

### Option manuelle (si vous préférez)
Dans les fichiers listés par l'analyseur, remplacez à la main :
- `color.withOpacity(0.2)` -> `color.withValues(alpha: 0.2)`

## 3) Vérification
```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```
Vous devriez ne plus voir d'avertissement `deprecated_member_use` pour `withOpacity` ou les Radios.
