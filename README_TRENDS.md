# Page Tendances (semaines & mois)

Nouveaux fichiers :
- `lib/application/providers/trends_provider.dart`
- `lib/presentation/widgets/trends_chart.dart`
- `lib/presentation/pages/stats_trends_page.dart`

## Utilisation
Depuis une page d'activité, ouvrez :
```dart
Navigator.of(context).push(MaterialPageRoute(
  builder: (_) => StatsTrendsPage(activityId: activity.id, activityName: activity.name),
));
```

Les providers s'appuient sur `dailyTotalsProvider(...)` pour agréger :
- 8 dernières semaines (lundi→dimanche),
- 12 derniers mois.

Les écarts semaine/mois utilisent le widget `DeltaChip` existant.
