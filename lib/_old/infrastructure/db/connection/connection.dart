// lib/infrastructure/db/connection/connection.dart
// Exports the right connection based on platform at compile-time.
export 'connection_native.dart' if (dart.library.html) 'connection_web.dart';
