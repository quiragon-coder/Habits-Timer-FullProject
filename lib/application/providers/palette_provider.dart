import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import 'unified_providers.dart' show databaseProvider;
import '../services/color_palette.dart';

final activityPaletteProvider = FutureProvider.family<ActivityPalette, int>((ref, activityId) async {
  final db = ref.watch(databaseProvider);
  final row = await (db.select(db.activities)..where((a) => a.id.equals(activityId))).getSingleOrNull();
  return buildPaletteFromInt(row?.color);
});

/// When no specific activity, a global palette
final globalPaletteProvider = Provider<ActivityPalette>((ref) {
  // Could read from settings or theme; we use theme-like default
  return buildPaletteFromInt(null);
});
