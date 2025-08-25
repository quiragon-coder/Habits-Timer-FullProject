// lib/infrastructure/db/database.dart
// Drift database: Android/iOS (SQLite) + Web (IndexedDB via sql.js) using conditional connection.
// Includes ActivityDao.watchAll() and proper Value(...) usage in GoalDao.

import 'package:drift/drift.dart';

// IMPORTANT: We only import the platform-specific connection through this shim.
// Make sure you have these files created (I sent them earlier):
//   lib/infrastructure/db/connection/connection.dart
//   lib/infrastructure/db/connection/connection_native.dart
//   lib/infrastructure/db/connection/connection_web.dart
import 'connection/connection.dart' show openConnection;

part 'database.g.dart';

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get createdAtUtc => integer()(); // seconds since epoch (UTC)
}

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId => integer().references(Activities, #id)();
  IntColumn get startUtc => integer()(); // seconds (UTC)
  IntColumn get endUtc => integer().nullable()(); // seconds (UTC), null if running
  TextColumn get note => text().nullable()();
}

class Pauses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  IntColumn get startUtc => integer()(); // seconds (UTC)
  IntColumn get endUtc => integer().nullable()(); // seconds (UTC), null if still paused
}

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId => integer().references(Activities, #id)();
  IntColumn get minutesPerWeek => integer().withDefault(const Constant(0))(); // 0 = unset
  IntColumn get daysPerWeek => integer().withDefault(const Constant(0))();
  IntColumn get minutesPerDay => integer().nullable()(); // optional
}

@DriftDatabase(
  tables: [Activities, Sessions, Pauses, Goals],
  daos: [ActivityDao, SessionDao, PauseDao, GoalDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await m.createTable(goals);
          }
        },
      );

  /// Ensure we have at least one default activity for first boot.
  Future<int> ensureDefaultActivity() async {
    final all = await select(activities).get();
    if (all.isEmpty) {
      return into(activities).insert(ActivitiesCompanion.insert(
        name: 'Dessin',
        emoji: const Value('🎨'),
        color: const Value('blue'),
        createdAtUtc: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
      ));
    }
    return all.first.id;
  }
}

@DriftAccessor(tables: [Activities])
class ActivityDao extends DatabaseAccessor<AppDatabase> with _$ActivityDaoMixin {
  ActivityDao(super.db);

  Future<int> insertActivity(ActivitiesCompanion data) => into(activities).insert(data);
  Future<List<Activity>> getAll() => select(activities).get();

  /// Stream all activities (ordered by creation)
  Stream<List<Activity>> watchAll() {
    return (select(activities)..orderBy([(t) => OrderingTerm.asc(t.createdAtUtc)])).watch();
  }
}

@DriftAccessor(tables: [Sessions, Pauses])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Future<int> startSession({required int activityId, required int startUtc}) {
    return into(sessions).insert(SessionsCompanion.insert(
      activityId: activityId, startUtc: startUtc));
  }

  Future<void> stopSession({required int sessionId, required int endUtc}) async {
    await (update(sessions)..where((s) => s.id.equals(sessionId)))
        .write(SessionsCompanion(endUtc: Value(endUtc)));
  }

  Future<List<Session>> recentSessionsForActivity(int activityId, {int limit = 20}) {
    return (select(sessions)
          ..where((s) => s.activityId.equals(activityId))
          ..orderBy([(s) => OrderingTerm(expression: s.startUtc, mode: OrderingMode.desc)])
          ..limit(limit))
        .get();
  }
}

@DriftAccessor(tables: [Pauses])
class PauseDao extends DatabaseAccessor<AppDatabase> with _$PauseDaoMixin {
  PauseDao(super.db);

  Future<int> startPause({required int sessionId, required int startUtc}) {
    return into(pauses).insert(PausesCompanion.insert(sessionId: sessionId, startUtc: startUtc));
  }

  Future<void> endLastOpenPause({required int sessionId, required int endUtc}) async {
    final open = await (select(pauses)
          ..where((p) => p.sessionId.equals(sessionId) & p.endUtc.isNull())
          ..orderBy([(p) => OrderingTerm(expression: p.startUtc, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
    if (open != null) {
      await (update(pauses)..where((p) => p.id.equals(open.id)))
          .write(PausesCompanion(endUtc: Value(endUtc)));
    }
  }

  Future<List<Pause>> pausesForSession(int sessionId) {
    return (select(pauses)..where((p) => p.sessionId.equals(sessionId))).get();
  }
}

@DriftAccessor(tables: [Goals])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  Future<Goal?> forActivity(int activityId) async {
    return (select(goals)..where((g) => g.activityId.equals(activityId))).getSingleOrNull();
  }

  Future<int> upsertGoal({
    required int activityId,
    required int minutesPerWeek,
    required int daysPerWeek,
    int? minutesPerDay,
  }) async {
    final existing = await forActivity(activityId);
    if (existing == null) {
      return into(goals).insert(GoalsCompanion.insert(
        activityId: activityId,
        minutesPerWeek: Value(minutesPerWeek),
        daysPerWeek: Value(daysPerWeek),
        minutesPerDay: Value(minutesPerDay),
      ));
    } else {
      await (update(goals)..where((g) => g.activityId.equals(activityId))).write(GoalsCompanion(
        minutesPerWeek: Value(minutesPerWeek),
        daysPerWeek: Value(daysPerWeek),
        minutesPerDay: Value(minutesPerDay),
      ));
      return existing.id;
    }
  }
}
