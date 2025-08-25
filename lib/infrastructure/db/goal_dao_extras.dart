// GoalDao extras
import 'database.dart';

extension GoalDaoExtras on GoalDao {
  Stream<Goal?> watchByActivity(int activityId) {
    final q = (select(goals)..where((g) => g.activityId.equals(activityId))..limit(1));
    return q.watchSingleOrNull();
  }

  Future<Goal?> getByActivity(int activityId) {
    final q = (select(goals)..where((g) => g.activityId.equals(activityId))..limit(1));
    return q.getSingleOrNull();
  }
}
