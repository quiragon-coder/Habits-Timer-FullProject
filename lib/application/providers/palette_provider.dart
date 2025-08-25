import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/color_palette.dart';
import 'unified_providers.dart' show databaseProvider;

/// Palette par défaut globale (Material seed violet).
final globalPaletteProvider = Provider<ActivityPalette>((ref) {
  return const ActivityPalette('#6750A4');
});

/// Hex color stockée sur l'activité (ou fallback).
final activityColorHexProvider = FutureProvider.family<String, int>((ref, activityId) async {
  final db = ref.watch(databaseProvider);
  final a = await (db.select(db.activities)..where((t) => t.id.equals(activityId))).getSingle();
  return a.color ?? '#6750A4';
});

/// Palette dérivée de la couleur de l'activité.
final activityPaletteProvider = FutureProvider.family<ActivityPalette, int>((ref, activityId) async {
  final hex = await ref.watch(activityColorHexProvider(activityId).future);
  return ActivityPalette(hex);
});
