/// Entité représentant une session (brute, venant de la DB).
class SessionEntity {
  final int id;
  final int activityId;
  final DateTime startUtc;
  final DateTime? endUtc;
  final String? note;

  SessionEntity({
    required this.id,
    required this.activityId,
    required this.startUtc,
    this.endUtc,
    this.note,
  });
}

/// Entité représentant une pause au sein d’une session.
class PauseEntity {
  final int id;
  final int sessionId;
  final DateTime startUtc;
  final DateTime? endUtc;

  PauseEntity({
    required this.id,
    required this.sessionId,
    required this.startUtc,
    this.endUtc,
  });
}
