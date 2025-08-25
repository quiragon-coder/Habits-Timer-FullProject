# WorkManager — Replanification en arrière-plan (Android)

## 1) pubspec.yaml
Ajoute :
```yaml
dependencies:
  workmanager: ^0.5.1
```

Puis :
```
flutter pub get
```

## 2) Initialiser WorkManager au démarrage
Dans `main.dart` (avant `runApp(...)`), ajoute :
```dart
import 'package:workmanager/workmanager.dart';
import 'application/services/background_rescheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackgroundRescheduler(); // enregistre la tâche périodique (24h)
  runApp(const HabitsTimerApp());
}
```

> La tâche périodique persiste après redémarrage Android et exécutera un **callback Dart headless** pour replanifier les notifications (quotidien / hebdo / mensuel) en se basant sur les réglages stockés et la **liste d'activités mise en cache**.

## 3) Mise en cache des activités
Le widget `StartupRescheduler` met à jour `SharedPreferences` avec `activities_cache`.  
Garde ce widget en haut de la page d’accueil pour que le cache reste frais.

## 4) Permissions & manif
- Pas de permission spéciale WorkManager.  
- Les permissions notif et récepteurs boot sont gérés séparément (voir précédents packs).

## 5) Tester
- Lance l’app au moins une fois pour enregistrer la tâche périodique.
- Redémarre l’appareil : la tâche restera programmée par WorkManager et s’exécutera **sans ouverture de l’app**.
