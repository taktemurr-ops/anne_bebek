/// Tarif adımlarındaki süreyi bulur: "10 dakika", "12–15 dakika", "1 saat",
/// "1,5 saat". Aralıkta üst sınır alınır (yemek eksik pişmesin diye).
/// Süre yoksa null döner.
int? stepMinutes(String step) {
  final text = step.toLowerCase();
  int? best;
  final minute = RegExp(r'(\d+)(?:\s*[–-]\s*(\d+))?\s*(?:dakika|dk\b)');
  for (final m in minute.allMatches(text)) {
    final v = int.parse(m.group(2) ?? m.group(1)!);
    if (best == null || v > best) best = v;
  }
  final hour = RegExp(r'(\d+(?:,\d+)?)(?:\s*[–-]\s*(\d+(?:,\d+)?))?\s*saat');
  for (final m in hour.allMatches(text)) {
    final raw = (m.group(2) ?? m.group(1)!).replaceAll(',', '.');
    final v = (double.parse(raw) * 60).round();
    if (best == null || v > best) best = v;
  }
  if (best == null || best <= 0 || best > 24 * 60) return null;
  return best;
}

/// mm:ss ya da s:mm:ss biçimi.
String formatCountdown(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}
