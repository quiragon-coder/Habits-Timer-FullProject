// PATCH: add watchAll() in ActivityDao with proper imports and usage.
import 'package:drift/drift.dart';
import 'database.dart';

extension ActivityDaoWatch on ActivityDao {
  Stream<List<Activity>> watchAll() {
    return (select(activities)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAtUtc, mode: OrderingMode.asc)]))
        .watch();
  }
}
