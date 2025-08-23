// lib/infrastructure/db/connection/connection_web.dart
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openConnection() {
  // IndexedDB + sql.js on Web
  return WebDatabase('habits_timer_web');
}
