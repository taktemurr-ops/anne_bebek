import 'dart:math' as math;

/// WHO/CDC LMS transformation. Reference tables MUST be separately verified
/// and matched to indicator, sex and age before any clinical-facing display.
class LmsParameters {
  final double l;
  final double m;
  final double s;
  const LmsParameters(this.l, this.m, this.s);
}

double? lmsZScore(double measurement, LmsParameters reference) {
  if (!measurement.isFinite || measurement <= 0 ||
      !reference.l.isFinite || !reference.m.isFinite ||
      !reference.s.isFinite || reference.m <= 0 || reference.s <= 0) { return null; }
  final ratio = measurement / reference.m;
  final z = reference.l.abs() < 1e-10
      ? math.log(ratio) / reference.s
      : (math.pow(ratio, reference.l) - 1) / (reference.l * reference.s);
  return z.isFinite ? z.toDouble() : null;
}

/// Standard normal CDF approximation (Abramowitz-Stegun 7.1.26).
/// Returns 0..100, not a clinical interpretation.
double? normalPercentile(double? z) {
  if (z == null || !z.isFinite) return null;
  final x = z.abs() / math.sqrt2;
  final t = 1 / (1 + 0.3275911 * x);
  final erf = 1 - (((((1.061405429 * t - 1.453152027) * t)
    + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * math.exp(-x*x);
  final cdf = z >= 0 ? (1 + erf) / 2 : (1 - erf) / 2;
  return (cdf * 100).clamp(0.0, 100.0);
}
