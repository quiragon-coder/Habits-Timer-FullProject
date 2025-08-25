import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../../infrastructure/db/goal_dao_extras.dart';
import 'unified_providers.dart' show databaseProvider;

/// Stream du goal principal d'une activité (ou null).
final goalByActivitySelectProvider = StreamProvider.family<Goal?, int>((ref, activityId) {
  final db = ref.watch(databaseProvider);
  return db.goalDao.watchByActivity(activityId).map((rows) => rows.isEmpty ? null : rows.first);
});
