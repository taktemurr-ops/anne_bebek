import 'who_lms_math.dart';
import 'who_reference_series.dart';

/// A separately supplied, provenance-labelled MONTHLY reference table.
/// Do not confuse completed months with days; never extrapolate missing months.
class WhoMonthlyReference {
  final GrowthIndicator indicator;
  final ReferenceSex sex;
  final String source;
  final Map<int, LmsParameters> byMonth;
  WhoMonthlyReference._(this.indicator, this.sex, this.source, this.byMonth);

  static WhoMonthlyReference parse({required String csv,
      required GrowthIndicator indicator, required ReferenceSex sex,
      required String source}) {
    final uri = Uri.tryParse(source);
    if (uri == null || uri.scheme != 'https' ||
        !{'www.who.int', 'cdn.who.int'}.contains(uri.host)) {
      throw const FormatException('WHO kaynak bağlantısı gerekli');
    }
    final points = <int, LmsParameters>{};
    var previous = -1;
    for (final (index, raw) in csv.split(RegExp(r'\r?\n')).indexed) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final parts = line.split(',').map((e) => e.trim()).toList();
      if (parts.length != 4) throw FormatException('Satır ${index + 1}: 4 alan gerekli');
      if (parts.first.toLowerCase() == 'month') continue;
      final month = int.tryParse(parts[0]);
      final l = double.tryParse(parts[1]);
      final m = double.tryParse(parts[2]);
      final s = double.tryParse(parts[3]);
      if (month == null || month < 0 || month > 60 || month <= previous ||
          l == null || !l.isFinite || m == null || !m.isFinite || m <= 0 ||
          s == null || !s.isFinite || s <= 0) {
        throw FormatException('Satır ${index + 1}: geçersiz LMS');
      }
      points[month] = LmsParameters(l, m, s);
      previous = month;
    }
    if (!points.containsKey(0)) throw const FormatException('0. ay referansı eksik');
    return WhoMonthlyReference._(indicator, sex, source, Map.unmodifiable(points));
  }

  /// Exact completed-month evaluation only. No invented interpolation.
  GrowthPercentileResult? evaluate({required int completedMonths,
      required double measurement}) {
    final lms = byMonth[completedMonths];
    if (lms == null) return null;
    final z = lmsZScore(measurement, lms);
    final percentile = normalPercentile(z);
    if (z == null || percentile == null) return null;
    return GrowthPercentileResult(completedMonths, z, percentile);
  }
}
