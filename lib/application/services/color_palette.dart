import 'dart:ui';

/// Simple HSL helpers
HSLColor _toHsl(Color c) => HSLColor.fromColor(c);

Color _withLightness(Color c, double l) {
  final hsl = _toHsl(c);
  return hsl.withLightness(l.clamp(0.0, 1.0)).toColor();
}

Color _lighten(Color c, [double amount = .12]) {
  final hsl = _toHsl(c);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darken(Color c, [double amount = .12]) {
  final hsl = _toHsl(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

/// Flutter 3.22 deprecates withOpacity; use withValues to avoid precision loss.
extension ColorCompat on Color {
  Color a(double alpha) => withValues(alpha: alpha.clamp(0.0, 1.0));
}

class ActivityPalette {
  final Color main;
  final Color light;
  final Color lighter;
  final Color dark;
  final Color darker;

  const ActivityPalette({
    required this.main,
    required this.light,
    required this.lighter,
    required this.dark,
    required this.darker,
  });

  /// Return a tone for [t] in [0..1] (0 => lighter, 1 => darker).
  Color tone(double t) {
    if (t <= 0) return lighter;
    if (t >= 1) return darker;
    // smooth lerp between lighter -> main -> darker
    if (t < 0.5) {
      final k = t / 0.5;
      return Color.lerp(lighter, main, k)!;
    } else {
      final k = (t - 0.5) / 0.5;
      return Color.lerp(main, darker, k)!;
    }
  }

  /// Transparent fill based on main color.
  Color fill([double alpha = 0.15]) => main.a(alpha);
}

ActivityPalette buildPaletteFromInt(int? colorInt, {Color? fallback}) {
  final base = (colorInt != null) ? Color(colorInt) : (fallback ?? const Color(0xFF6750A4)); // M3 purple
  return ActivityPalette(
    main: base,
    light: _lighten(base, .18),
    lighter: _lighten(base, .30),
    dark: _darken(base, .14),
    darker: _darken(base, .26),
  );
}
