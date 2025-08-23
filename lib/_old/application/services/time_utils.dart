import '../../infrastructure/db/database.dart';

Duration _overlap(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
  final start = aStart.isAfter(bStart) ? aStart : bStart;
  final end = aEnd.isBefore(bEnd) ? aEnd : bEnd;
  if (end.isBefore(start)) return Duration.zero;
  return end.difference(start);
}

/// Computes effective duration of a session in [rangeStart, rangeEnd),
/// excluding overlaps with pauses.
Duration effectiveOverlapDuration(
  DateTime sessionStart,
  DateTime sessionEnd,
  List<Pause> pauses,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final total = _overlap(sessionStart, sessionEnd, rangeStart, rangeEnd);
  if (total == Duration.zero) return Duration.zero;
  Duration paused = Duration.zero;
  for (final p in pauses) {
    final pStart = DateTime.fromMillisecondsSinceEpoch(p.startUtc * 1000, isUtc: true);
    final int pauseEndSec = p.endUtc ?? (sessionEnd.millisecondsSinceEpoch ~/ 1000);
    final pEnd = DateTime.fromMillisecondsSinceEpoch(pauseEndSec * 1000, isUtc: true);
    paused += _overlap(pStart, pEnd, rangeStart, rangeEnd);
  }
  final eff = total - paused;
  return eff.isNegative ? Duration.zero : eff;
}

String formatHm(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
