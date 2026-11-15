/// Measurement-only summaries. These are not WHO percentiles or diagnoses.
class GrowthPoint {
  final DateTime date;
  final double value;
  const GrowthPoint(this.date, this.value);
}

List<GrowthPoint> growthSeries(List<Map<String, String>> measurements, String field,
    {DateTime? now}) {
  final end = now ?? DateTime.now();
  final points = <GrowthPoint>[];
  for (final row in measurements) {
    final date = DateTime.tryParse(row['tarih'] ?? '');
    final value = double.tryParse((row[field] ?? '').trim().replaceAll(',', '.'));
    if (date == null || date.isAfter(end) || value == null ||
        !value.isFinite || value <= 0) {
      continue;
    }
    // Exclude implausible input errors, without interpreting growth clinically.
    final max = field == 'kilo' ? 100.0 : 250.0;
    if (value > max) {
      continue;
    }
    points.add(GrowthPoint(date, value));
  }
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}

String growthChange(List<GrowthPoint> points, String unit) {
  if (points.length < 2) return 'Değişim için en az iki ölçüm gerekli.';
  final delta = points.last.value - points.first.value;
  final prefix = delta > 0 ? '+' : '';
  return 'İlk-son farkı: $prefix${delta.toStringAsFixed(1)} $unit';
}

/// Chronological measurement history; does not infer clinical growth status.
class GrowthStats {
  final int count;
  final double first, last, minimum, maximum;
  final int elapsedDays;
  const GrowthStats(this.count, this.first, this.last, this.minimum, this.maximum, this.elapsedDays);
  double get change => last - first;
}

GrowthStats? growthStats(List<GrowthPoint> points) {
  if (points.isEmpty) return null;
  final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
  final values = sorted.map((e) => e.value);
  return GrowthStats(sorted.length, sorted.first.value, sorted.last.value,
      values.reduce((a, b) => a < b ? a : b),
      values.reduce((a, b) => a > b ? a : b),
      sorted.last.date.difference(sorted.first.date).inDays);
}
