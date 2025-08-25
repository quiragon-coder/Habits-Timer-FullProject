import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app/main.dart' show HabitsTimerApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: HabitsTimerApp()));
}
