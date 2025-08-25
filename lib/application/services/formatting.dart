String formatHours(double h) {
  final s = h.toStringAsFixed(1);
  return s.endsWith('.0') ? '${s.substring(0, s.length - 2)} h' : '$s h';
}

String formatSignedHours(double h) {
  final sign = h >= 0 ? '+' : '−';
  final absVal = h.abs().toStringAsFixed(1);
  final trimmed = absVal.endsWith('.0') ? absVal.substring(0, absVal.length - 2) : absVal;
  return '$sign$trimmed h';
}

String formatDurationHuman(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}
