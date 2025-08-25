import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../../infrastructure/db/goal_dao_extras.dart'; // <- bring extension methods into scope
import 'unified_providers.dart' show goalDaoProvider;

/// StreamProvider qui renvoie le premier Goal d'une activité (ou null s'il n'y en a pas).
final goalSingleProvider = StreamProvider.family<Goal?, int>((ref, activityId) {
  final dao = ref.watch(goalDaoProvider);
  // Uses GoalDaoExtras.watchByActivity (returns Stream<Goal?>)
  return dao.watchByActivity(activityId);
});
