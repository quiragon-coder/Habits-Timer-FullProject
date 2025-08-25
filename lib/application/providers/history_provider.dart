// History provider that returns sessions with their pauses attached.
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../infrastructure/db/database.dart';
import 'providers.dart';

class SessionWithPauses {
  final Session session;
  final List<Pause> pauses;
  SessionWithPauses(this.session, this.pauses);
}

final recentHistoryWithPausesProvider = FutureProvider.family<List<SessionWithPauses>, int>((ref, activityId) async {
  final db = ref.read(databaseProvider);

  // Last 50 sessions (desc by start)
  final sessions = await (db.select(db.sessions)
        ..where((s) => s.activityId.equals(activityId))
        ..orderBy([(t) => drift.OrderingTerm.desc(t.startUtc)])
        ..limit(50))
      .get();

  if (sessions.isEmpty) return const [];

  final sessionIds = sessions.map((s) => s.id).toList();
  final pausesRows = await (db.select(db.pauses)..where((p) => p.sessionId.isIn(sessionIds))).get();

  final pausesBySession = <int, List<Pause>>{};
  for (final p in pausesRows) {
    pausesBySession.putIfAbsent(p.sessionId, () => []).add(p);
  }

  return [
    for (final s in sessions) SessionWithPauses(s, pausesBySession[s.id] ?? const []),
  ];
});
