/// GP-03: Growth measurement validation, independent from UI and persistence.
class GrowthMeasurementValidator {
  const GrowthMeasurementValidator._();

  /// Accepts a single decimal separator (comma or dot), no grouping.
  static double? parseMeasurement(String raw) {
    // Reject excessively long input before parsing to avoid needless work.
    if (raw.length > 64) return null;
    final value = raw.trim().replaceAll(',', '.');
    // Limit precision to avoid silently rounding user-entered health data.
    final separator = value.indexOf('.');
    if (separator >= 0 && value.length - separator - 1 > 3) return null;
    if (value.isEmpty || value.split('.').length > 2) return null;
    final digits = value.replaceAll('.', '');
    if (digits.isEmpty || !digits.codeUnits.every((c) => c >= 48 && c <= 57)) {
      return null;
    }
    if (value.startsWith('.') || value.endsWith('.')) return null;
    final parsed = double.tryParse(value);
    return parsed != null && parsed.isFinite ? parsed : null;
  }

  static String? validateWeightGrams(num? grams) {
    if (grams == null || !grams.isFinite || grams <= 0 || grams > 200000) {
      return 'Ağırlık 0 ile 200000 gram arasında olmalıdır.';
    }
    return null;
  }

  /// UI records kilograms; bounds are enforced in grams consistently.
  static String? validateWeightKg(num? kilograms) =>
      validateWeightGrams(kilograms == null ? null : kilograms * 1000);

  static String? validateHeightCm(num? cm) {
    if (cm == null || !cm.isFinite || cm <= 0 || cm > 250) {
      return 'Boy 0 ile 250 cm arasında olmalıdır.';
    }
    return null;
  }

  static String? validateHeadCircumferenceCm(num? cm) {
    if (cm == null || !cm.isFinite || cm <= 0 || cm > 100) {
      return 'Baş çevresi 0 ile 100 cm arasında olmalıdır.';
    }
    return null;
  }

  static String? validateMeasurementDate(DateTime? date,
      {required DateTime birthDate, DateTime? today}) {
    if (date == null) return 'Ölçüm tarihi gereklidir.';
    final current = today ?? DateTime.now();
    final day = DateTime.utc(date.year, date.month, date.day);
    final born = DateTime.utc(birthDate.year, birthDate.month, birthDate.day);
    final now = DateTime.utc(current.year, current.month, current.day);
    if (day.isBefore(born)) return 'Ölçüm doğumdan önce olamaz.';
    if (day.isAfter(now)) return 'Ölçüm tarihi gelecekte olamaz.';
    return null;
  }
}
