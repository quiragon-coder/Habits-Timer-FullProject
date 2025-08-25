Ajout colonne `minutes_per_month` dans la table goals (nullable).

### 1) Déclarer la colonne dans le modèle Drift

Dans `lib/infrastructure/db/database.dart`, dans `class Goals extends Table`, ajoutez :
```dart
IntColumn get minutesPerMonth => integer().nullable()();
```

### 2) Incrémenter la version de schéma
```dart
@override
int get schemaVersion => <ANCIENNE_VALEUR> + 1;
```

### 3) Migration
Dans la `MigrationStrategy` de la base (méthode `onUpgrade`), ajoutez :
```dart
onUpgrade: (migrator, from, to) async {
  if (from < <NOUVELLE_VALEUR>) {
    await migrator.addColumn(goals, goals.minutesPerMonth);
  }
}
```

> Alternative si vous gérez vos migrations manuellement :
```dart
await customStatement('ALTER TABLE goals ADD COLUMN minutes_per_month INTEGER;');
```

Le code du wizard gère **dynamiquement** la présence ou non de la colonne :
- Si la colonne existe, on insère `minutes_per_month`.
- Sinon, on n'insère pas cette valeur (et rien ne casse).
