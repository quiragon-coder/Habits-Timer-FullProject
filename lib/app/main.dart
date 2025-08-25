import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../presentation/theme.dart';
import '../presentation/pages/app_scaffold.dart';

void main() {
  // ⬇️ Riverpod doit entourer toute l'app
  runApp(const ProviderScope(child: HabitsTimerApp()));
}

class HabitsTimerApp extends StatelessWidget {
  const HabitsTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits Timer',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const AppScaffold(),
    );
  }
}
