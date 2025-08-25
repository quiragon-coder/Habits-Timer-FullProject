import 'package:drift/drift.dart' as drift;
import 'database.dart';

/// Helpers complémentaires pour ActivityDao.
extension ActivityDaoExtras on ActivityDao {
  /// Supprime une activité et TOUT ce qui s’y rattache (sessions, pauses, goals).
  Future<void> deleteActivityCascade(int activityId) async {
    await db.transaction(() async {
      // Récupère toutes les sessions de l’activité
      final sessionsRows = await (db.select(db.sessions)
        ..where((s) => s.activityId.equals(activityId)))
          .get();

      if (sessionsRows.isNotEmpty) {
        final sessionIds = sessionsRows.map((s) => s.id).toList();
        // Supprimer d’abord les pauses rattachées aux sessions
        await (db.delete(db.pauses)..where((p) => p.sessionId.isIn(sessionIds))).go();
        // Puis les sessions
        await (db.delete(db.sessions)..where((s) => s.id.isIn(sessionIds))).go();
      }

      // Supprimer les goals de l’activité
      await (db.delete(db.goals)..where((g) => g.activityId.equals(activityId))).go();

      // Enfin l’activité
      await (db.delete(db.activities)..where((a) => a.id.equals(activityId))).go();
    });
  }

  /// Stream de toutes les activités, triées par id croissant (compatible avec tous les schémas).
  Stream<List<Activity>> watchAll() {
    return (db.select(db.activities)
      ..orderBy([(t) => drift.OrderingTerm.asc(t.id)]))
        .watch();
  }

  /// Une activité par id (nullable)
  Future<Activity?> findById(int id) {
    return (db.select(db.activities)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }
}
