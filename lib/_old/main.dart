import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'presentation/theme.dart';
import 'presentation/pages/activities_home_page.dart';

void main() {
  runApp(const ProviderScope(child: HabitsTimerApp()));
}

class HabitsTimerApp extends StatelessWidget {
  const HabitsTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits Timer',
      theme: appTheme,
      home: const ActivitiesHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
