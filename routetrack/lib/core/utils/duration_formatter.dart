String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  if (h > 0) return '${h}h ${m}m';
  return '${d.inMinutes}m';
}

String formatDurationHHMM(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '$h:$m';
}
