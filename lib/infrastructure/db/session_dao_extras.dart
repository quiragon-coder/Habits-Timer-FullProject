import 'package:drift/drift.dart' as drift;
import 'database.dart';

extension SessionDaoExtras on SessionDao {
  AppDatabase get db => attachedDatabase;

  Stream<List<Session>> watchByActivity(int activityId) {
    final q = (db.select(db.sessions)
      ..where((s) => s.activityId.equals(activityId))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.startUtc)]));
    return q.watch();
  }

  Future<List<Session>> recentByActivity(int activityId, {int limit = 50}) {
    final q = (db.select(db.sessions)
      ..where((s) => s.activityId.equals(activityId))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.startUtc)])
      ..limit(limit));
    return q.get();
  }
}
