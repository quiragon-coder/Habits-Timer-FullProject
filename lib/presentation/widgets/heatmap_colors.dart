import 'package:flutter/material.dart';
import '../../application/services/color_palette.dart';

/// Backward-compat: many places call a top-level `heatmapScale(...)`.
/// Keep this shim so you don't have to refactor older code.
List<Color> heatmapScale(ActivityPalette palette, {int steps = 5}) =>
    palette.heatmapScale(steps: steps);

/// Namespaced helper if you prefer class access.
class HeatmapColors {
  static List<Color> scale(ActivityPalette palette, {int steps = 5}) =>
      palette.heatmapScale(steps: steps);
}
