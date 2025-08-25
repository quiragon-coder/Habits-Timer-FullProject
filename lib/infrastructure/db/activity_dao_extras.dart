import 'package:drift/drift.dart' as drift;
import 'database.dart';

extension ActivityDaoExtras on ActivityDao {
  AppDatabase get db => attachedDatabase;

  Stream<List<Activity>> watchAll() {
    final q = (db.select(db.activities)
      ..orderBy([(t) => drift.OrderingTerm(expression: t.id)]));
    return q.watch();
  }

  Future<List<Activity>> getAll() {
    final q = (db.select(db.activities)
      ..orderBy([(t) => drift.OrderingTerm(expression: t.id)]));
    return q.get();
  }

  Future<Activity?> findById(int id) {
    final q = (db.select(db.activities)..where((a) => a.id.equals(id))..limit(1));
    return q.getSingleOrNull();
  }

  Future<int> updateActivityData(ActivitiesCompanion companion) {
    return (db.update(db.activities)..where((a) => a.id.equals(companion.id.value))).write(companion);
  }

  Future<void> deleteActivityCascade(int activityId) async {
    final sess = await (db.select(db.sessions)..where((s) => s.activityId.equals(activityId))).get();
    for (final s in sess) {
      await (db.delete(db.pauses)..where((p) => p.sessionId.equals(s.id))).go();
    }
    await (db.delete(db.sessions)..where((s) => s.activityId.equals(activityId))).go();
    try {
      await (db.delete(db.goals)..where((g) => g.activityId.equals(activityId))).go();
    } catch (_) {}
    await (db.delete(db.activities)..where((a) => a.id.equals(activityId))).go();
  }
}
