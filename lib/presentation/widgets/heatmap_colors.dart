import 'package:flutter/material.dart';
import '../../application/services/color_palette.dart';

/// Return 5 tones for a heatmap (0..4)
List<Color> heatmapScale(ActivityPalette p) => <Color>[
  p.tone(0.95), // very light
  p.tone(0.70),
  p.tone(0.50),
  p.tone(0.30),
  p.tone(0.10), // near dark
];
