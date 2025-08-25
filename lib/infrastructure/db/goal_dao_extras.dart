import 'package:drift/drift.dart';
import 'database.dart';

extension GoalDaoExtras on GoalDao {
  // Legacy alias kept for compatibility with existing code
  Stream<List<Goal>> watchByActivity(int activityId) => watchByActivityId(activityId);

  Stream<List<Goal>> watchByActivityId(int activityId) {
    final d = attachedDatabase;
    return (d.select(d.goals)..where((g) => g.activityId.equals(activityId))).watch();
  }

  Stream<Goal?> watchSingleByActivityId(int activityId) =>
      watchByActivityId(activityId).map((rows) => rows.isEmpty ? null : rows.first);

  Future<Goal?> getSingleByActivityId(int activityId) async {
    final d = attachedDatabase;
    final rows = await (d.select(d.goals)..where((g) => g.activityId.equals(activityId))).get();
    return rows.isEmpty ? null : rows.first;
  }
}
