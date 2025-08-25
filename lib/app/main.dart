import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../presentation/theme.dart';
import '../presentation/pages/activities_home_page.dart';
import '../presentation/pages/settings_page.dart';
import '../application/providers/settings_provider.dart';

class HabitsTimerApp extends ConsumerWidget {
  const HabitsTimerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Habits Timer',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      home: const ActivitiesHomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        SettingsPage.route: (_) => const SettingsPage(),
      },
    );
  }
}
