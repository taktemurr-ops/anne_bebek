import 'who_lms_math.dart';

/// A validated age-indexed LMS reference series. This module deliberately does
/// not ship unverified WHO numbers; load only an independently verified source.
enum GrowthIndicator { weightForAge, lengthHeightForAge, headCircumferenceForAge }
enum ReferenceSex { female, male }

class AgeLmsPoint {
  final int ageDays;
  final LmsParameters parameters;
  const AgeLmsPoint(this.ageDays, this.parameters);
}

class GrowthPercentileResult {
  final int ageDays;
  final double zScore;
  final double percentile;
  const GrowthPercentileResult(this.ageDays, this.zScore, this.percentile);
}

class WhoReferenceSeries {
  final GrowthIndicator indicator;
  final ReferenceSex sex;
  final String source;
  final List<AgeLmsPoint> points;

  WhoReferenceSeries({required this.indicator, required this.sex,
    required this.source, required List<AgeLmsPoint> points})
      : points = List.unmodifiable(points) {
    if (source.trim().isEmpty || this.points.isEmpty) {
      throw ArgumentError('Reference provenance and points are required');
    }
    int? previous;
    for (final point in this.points) {
      if (point.ageDays < 0 || (previous != null && point.ageDays <= previous)) {
        throw ArgumentError('Reference ages must be unique and increasing');
      }
      final p = point.parameters;
      if (!p.l.isFinite || !p.m.isFinite || p.m <= 0 ||
          !p.s.isFinite || p.s <= 0) {
        throw ArgumentError('Invalid LMS reference parameters');
      }
      previous = point.ageDays;
    }
  }

  /// Interpolate only between supplied reference ages; never extrapolate.
  LmsParameters? atAge(int ageDays) {
    if (ageDays < points.first.ageDays || ageDays > points.last.ageDays) return null;
    for (var i = 0; i < points.length; i++) {
      final current = points[i];
      if (current.ageDays == ageDays) return current.parameters;
      if (current.ageDays > ageDays) {
        final previous = points[i - 1];
        final t = (ageDays - previous.ageDays) / (current.ageDays - previous.ageDays);
        final a = previous.parameters, b = current.parameters;
        return LmsParameters(a.l + (b.l - a.l) * t,
          a.m + (b.m - a.m) * t, a.s + (b.s - a.s) * t);
      }
    }
    return null;
  }

  GrowthPercentileResult? evaluate({required DateTime birthDate,
      required DateTime measuredAt, required double measurement}) {
    final birth = DateTime.utc(birthDate.year, birthDate.month, birthDate.day);
    final measured = DateTime.utc(measuredAt.year, measuredAt.month, measuredAt.day);
    final days = measured.difference(birth).inDays;
    final parameters = atAge(days);
    if (parameters == null) return null;
    final z = lmsZScore(measurement, parameters);
    final percentile = normalPercentile(z);
    if (z == null || percentile == null) return null;
    return GrowthPercentileResult(days, z, percentile);
  }
}
