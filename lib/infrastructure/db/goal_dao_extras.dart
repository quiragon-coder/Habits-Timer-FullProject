import 'database.dart';

extension GoalDaoExtras on GoalDao {
  AppDatabase get _db {
    final self = this as dynamic;
    final maybeDb = (self.db ?? self.attachedDatabase);
    return maybeDb as AppDatabase;
  }

  /// Stream all goals for a given activity id.
  Stream<List<Goal>> watchByActivityId(int activityId) {
    return (_db.select(_db.goals)..where((g) => g.activityId.equals(activityId))).watch();
  }

  /// Backward-compatible alias: returns the FIRST goal (or null) as a stream.
  Stream<Goal?> watchByActivity(int activityId) {
    return watchByActivityId(activityId).map((list) => list.isEmpty ? null : list.first);
  }

  /// Get a single goal (first or null) for an activity id.
  Future<Goal?> findByActivityId(int activityId) async {
    final list = await (_db.select(_db.goals)..where((g) => g.activityId.equals(activityId))).get();
    return list.isEmpty ? null : list.first;
  }
}
