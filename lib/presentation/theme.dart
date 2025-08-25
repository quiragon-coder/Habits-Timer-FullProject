import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
  scaffoldBackgroundColor: const Color(0xFFF6F5FA),
  textTheme: const TextTheme().apply(
    bodyColor: Color(0xFF1F2937),
    displayColor: Color(0xFF1F2937),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  dividerTheme: const DividerThemeData(space: 24, thickness: .5),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1), brightness: Brightness.dark),
  scaffoldBackgroundColor: const Color(0xFF0B1220),
  cardTheme: CardThemeData(
    color: const Color(0xFF111827),
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  dividerTheme: const DividerThemeData(space: 24, thickness: .5),
);
