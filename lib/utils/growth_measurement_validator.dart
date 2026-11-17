/// GP-03: Growth measurement validation, independent from UI and persistence.
class GrowthMeasurementValidator {
  const GrowthMeasurementValidator._();

  /// Parses Turkish or dot-decimal measurement input without silently
  /// accepting grouping separators, exponents or non-finite numbers.
  static double? parseMeasurement(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (!RegExp(r'^\\d+(?:\\.\\d+)?
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
).hasMatch(normalized)) return null;
    final value = double.tryParse(normalized);
    return value != null && value.isFinite ? value : null;
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
