// lib/infrastructure/db/connection/connection_native.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnection() {
  // SQLite on Android/iOS/desktop
  return driftDatabase(name: 'habits_timer.db');
}
