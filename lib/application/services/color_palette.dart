import 'dart:ui' show Color;
import 'package:flutter/painting.dart' show HSLColor;

/// --- Color helpers --------------------------------------------------------

String colorToHex(Color c) =>
    '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

Color colorFromHex(String hex) {
  var s = hex.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  final v = int.parse(s, radix: 16);
  return Color(v);
}

String shiftHexLightness(String hex, double amount) {
  final base = colorFromHex(hex);
  final hsl = HSLColor.fromColor(base);
  final shifted = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return colorToHex(shifted.toColor());
}

/// Small convenience class for palettes based on a single base color.
class ActivityPalette {
  final String baseHex;
  const ActivityPalette(this.baseHex);

  Color get baseColor => colorFromHex(baseHex);

  /// Returns a new hex string with a lightness delta (-1..+1).
  String tone(double lightnessDelta) => shiftHexLightness(baseHex, lightnessDelta);

  /// Generate N colors from darker -> lighter around the base.
  List<Color> heatmapScale({int steps = 5}) {
    final deltas = <double>[-0.30, -0.15, 0.0, 0.15, 0.30];
    final picked = steps <= deltas.length ? deltas.sublist(0, steps) : deltas;
    return picked.map((d) => colorFromHex(tone(d))).toList();
  }
}

/// Backward-compat shim: some pages call a top-level `heatmapScale(...)`.
List<Color> heatmapScale(ActivityPalette palette, {int steps = 5}) =>
    palette.heatmapScale(steps: steps);

List<String> buildPalette(String baseHex) => [
  shiftHexLightness(baseHex, -0.15),
  baseHex,
  shiftHexLightness(baseHex, 0.15),
];
