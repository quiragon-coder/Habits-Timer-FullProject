# Objectifs mensuels (sans modification DB)

- Stockage dans `SharedPreferences` via `monthly_goals_provider.dart`
- Clé: `monthly_goal_minutes_<activityId>`
- UI: Dans la **GoalProgressCard**, bouton **Définir/Modifier mois** pour saisir un objectif en **heures/mois**
- Affichage: la carte utilise `currentMonthStatsProvider(activityId)` pour comparer *minutes réalisées* vs *objectif mensuel (minutes)*

## Fichiers inclus

- `lib/application/providers/monthly_goals_provider.dart`
- `lib/presentation/widgets/goal_progress_card.dart` (patch)
- `lib/presentation/pages/activities_home_page.dart` (patch insert minimal)
- `lib/presentation/widgets/new_activity_sheet.dart` (patch insert minimal)
- `lib/application/services/background_rescheduler.dart` (petit fix `Constraints(...)`)

## Intégration

1. Copie ces fichiers par-dessus ceux du projet.
2. Pas de migration DB.
3. Lance l'app, ouvre une activité → dans *Objectifs*, clique **Définir mois** pour saisir un objectif mensuel.
