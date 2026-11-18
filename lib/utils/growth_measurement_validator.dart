/// GP-03: Growth measurement validation, independent from UI and persistence.
class GrowthMeasurementValidator {
  const GrowthMeasurementValidator._();

  /// Accepts a single decimal separator (comma or dot), no grouping.
  static double? parseMeasurement(String raw) {
    // Only ordinary ASCII spaces may surround a measurement. Unicode format
    // characters and invisible separators must not silently change health data.
    if (raw.length > 64) return null;
    final normalized = raw.replaceAll(',', '.');
    final match = RegExp(r'^ *([0-9]+(?:\\.[0-9]{1,3})?) *$')
        .firstMatch(normalized);
    if (match == null) return null;
    final parsed = double.tryParse(match.group(1)!);
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
    if (born.isAfter(now)) return 'Doğum tarihi gelecekte olamaz.';
    if (day.isBefore(born)) return 'Ölçüm doğumdan önce olamaz.';
    if (day.isAfter(now)) return 'Ölçüm tarihi gelecekte olamaz.';
    return null;
  }
}
