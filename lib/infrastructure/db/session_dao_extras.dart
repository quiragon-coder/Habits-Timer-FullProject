// Helper / extras for SessionDao
import 'database.dart';

extension SessionDaoExtras on SessionDao {
  Stream<List<Session>> watchByActivity(int activityId) {
    final q = (select(sessions)..where((s) => s.activityId.equals(activityId))..orderBy([(t) => OrderingTerm.desc(t.startUtc)]));
    return q.watch();
  }

  Future<List<Session>> recentByActivity(int activityId, {int limit = 50}) {
    final q = (select(sessions)..where((s) => s.activityId.equals(activityId))..orderBy([(t) => OrderingTerm.desc(t.startUtc)])..limit(limit));
    return q.get();
  }
}
