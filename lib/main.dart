import 'package:flutter/material.dart';
import '../presentation/pages/app_scaffold.dart';

void main() {
  runApp(const HabitsTimerApp());
}

class HabitsTimerApp extends StatelessWidget {
  const HabitsTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppScaffold(),
    );
  }
}
