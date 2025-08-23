// Helper / extras for ActivityDao
// Adds watchAll() and getAll() + Riverpod providers

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'database.dart';
import '../../application/providers/providers.dart';

extension ActivityDaoExtras on ActivityDao {
  AppDatabase _root() {
    final dynamic self = this;
    try {
      final AppDatabase d = self.db as AppDatabase;
      return d;
    } catch (_) {}
    try {
      final AppDatabase d = self.attachedDatabase as AppDatabase;
      return d;
    } catch (_) {}
    throw StateError('ActivityDao does not expose db/attachedDatabase');
  }

  Stream<List<Activity>> watchAll() {
    final db = _root();
    return (db.select(db.activities)..orderBy([(t) => OrderingTerm(expression: t.id)])).watch();
  }

  Future<List<Activity>> getAll() {
    final db = _root();
    return (db.select(db.activities)..orderBy([(t) => OrderingTerm(expression: t.id)])).get();
  }
}

final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.activities)..orderBy([(t) => OrderingTerm(expression: t.id)])).watch();
});

final activitiesFutureProvider = FutureProvider<List<Activity>>((ref) async {
  final db = ref.watch(databaseProvider);
  return (db.select(db.activities)..orderBy([(t) => OrderingTerm(expression: t.id)])).get();
});
