/// Calendar-based pregnancy estimates from the first day of the last period.
/// Not a diagnosis or a substitute for a clinician's dating scan.
class PregnancyTimeline {
  final int elapsedDays;
  const PregnancyTimeline(this.elapsedDays);
  int get week => elapsedDays ~/ 7;
  int get dayOfWeek => elapsedDays % 7;
  int get daysUntilEstimatedDueDate => 280 - elapsedDays;
  double get progress => (elapsedDays / 280).clamp(0.0, 1.0);
  String get trimester => elapsedDays < 98 ? '1. trimester' : elapsedDays < 196 ? '2. trimester' : '3. trimester';
}

PregnancyTimeline? pregnancyTimeline(DateTime lastPeriod, DateTime now) {
  // Calendar dates, not elapsed 24-hour periods, so time-of-day does not shift weeks.
  final first = DateTime.utc(lastPeriod.year, lastPeriod.month, lastPeriod.day);
  final today = DateTime.utc(now.year, now.month, now.day);
  final days = today.difference(first).inDays;
  if (days < 0 || days > 294) return null;
  return PregnancyTimeline(days);
}

String pregnancyWeekNote(int week) {
  if (week < 4) return 'Erken dönem: gebelik testi ve takip planı için sağlık uzmanına danışabilirsin.';
  if (week < 13) return 'İlk trimester: kontroller, beslenme ve kullandığın ilaçlar hakkında doktorunla görüş.';
  if (week < 28) return 'İkinci trimester: düzenli kontrolleri ve doktorunun önerdiği taramaları takip et.';
  if (week < 37) return 'Üçüncü trimester: doğum planını ve hastane hazırlıklarını gözden geçir.';
  return 'Doğuma yakın dönem: doğum belirtileri ve başvuru planını sağlık ekibinle netleştir.';
}
