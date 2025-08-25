# Notifications système hebdo / mensuelles

## Weekly
- Programmées avec `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime` → répétition chaque semaine.
- Par défaut, **dimanche** à l’heure choisie dans les réglages.

## Monthly
- Programmées **une fois** le **dernier jour du mois** à l’heure choisie.
- À replanifier (le pack ajoute des boutons) — on peut aussi reprogrammer au démarrage de l’app si nécessaire.

## IDs & Canaux
- daily: channel `habits_daily`, id base 100000 + activityId
- weekly: channel `habits_weekly`, id base 110000 + activityId
- monthly: channel `habits_monthly`, id base 120000 + activityId

## Limitations
- Android peut ne pas restaurer les alarmes après reboot. Solution: replanifier au lancement, ou ajouter un BootReceiver.
- iOS ne permet pas de définir “dernier jour du mois” de manière répétée — d’où l’approche one-shot + replanification.
