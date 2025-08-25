# Menu 'Tendances' sur la liste des activités

Ce script ajoute un menu overflow (⋮) sur chaque entrée de la liste d'activités.
Le menu ouvre la page **StatsTrendsPage** pour l'activité correspondante.

## Étapes
1) Placez ce dossier à la **racine du projet**.
2) Exécutez :
```bash
dart run tool/patch_trends_menu.dart
```
3) Lancez :
```bash
flutter run
```

Le patch :
- Ajoute l'import `import './stats_trends_page.dart';` si absent.
- Remplace `return ActivityTile(...)` par un `Stack` contenant le `ActivityTile` et un `PopupMenuButton` positionné en haut à droite.
