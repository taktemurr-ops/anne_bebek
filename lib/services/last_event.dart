// Ana ekrandaki "en son ne zaman?" özeti: hızlı kayıtlar arasında belirli bir
// türün en yeni kaydından bu yana geçen süre.

Duration? sinceLastEvent(List<Map<String, String>> events, String type, DateTime now) {
  DateTime? last;
  for (final e in events) {
    if (e['tur'] != type) continue;
    final t = DateTime.tryParse(e['zaman'] ?? '');
    if (t == null || t.isAfter(now)) continue;
    if (last == null || t.isAfter(last)) last = t;
  }
  return last == null ? null : now.difference(last);
}

/// Kısa süre metni: "45 dk", "2 sa 10 dk", "3 gün".
String shortAgo(Duration d) {
  if (d.inDays >= 1) return '${d.inDays} gün';
  if (d.inHours >= 1) return '${d.inHours} sa ${d.inMinutes % 60} dk';
  return '${d.inMinutes} dk';
}
