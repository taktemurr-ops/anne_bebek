import 'who_lms_math.dart';

/// Parses the CDC-published WHO 0–24 month LMS CSV files.
/// Source: https://www.cdc.gov/growthcharts/who-data-files.htm
/// These CSV files represent WHO standards, not the CDC 2000 charts.
/// Age values are month midpoints (1.5 represents completed month 1).
class CdcWhoRow {
  final int completedMonth;
  final LmsParameters lms;
  const CdcWhoRow(this.completedMonth, this.lms);
}

class CdcWhoReferenceCsv {
  /// Fails closed on malformed, duplicate or out-of-range data.
  static List<CdcWhoRow> parse(String csv, {required int expectedSex}) {
    if (expectedSex != 1 && expectedSex != 2) {
      throw const FormatException('Cinsiyet kodu 1 veya 2 olmalı');
    }
    final lines = csv.replaceAll('\r', '').split('\n')
        .where((line) => line.trim().isNotEmpty).toList();
    if (lines.length < 2) throw const FormatException('CSV boş');
    final headers = lines.first.split(',').map((v) => v.trim().replaceAll('"', '').toLowerCase()).toList();
    int column(List<String> candidates) {
      for (final name in candidates) {
        final i = headers.indexOf(name);
        if (i >= 0) return i;
      }
      throw FormatException('CSV sütunu eksik: ${candidates.first}');
    }
    final sexCol = column(['sex']);
    final ageCol = column(['agemos', 'age']);
    final lCol = column(['l']);
    final mCol = column(['m']);
    final sCol = column(['s']);
    final rows = <CdcWhoRow>[];
    final used = <int>{};
    for (var n = 1; n < lines.length; n++) {
      final cells = lines[n].split(',').map((v) => v.trim().replaceAll('"', '')).toList();
      if (cells.length != headers.length) throw FormatException('Satır ${n + 1}: sütun sayısı yanlış');
      final sex = int.tryParse(cells[sexCol]);
      final age = double.tryParse(cells[ageCol]);
      final l = double.tryParse(cells[lCol]);
      final m = double.tryParse(cells[mCol]);
      final s = double.tryParse(cells[sCol]);
      // Official CDC WHO CSV exports may contain both sexes in one file.
      // Ignore rows for the other sex, but never accept invalid sex codes.
      if (sex != 1 && sex != 2) {
        throw FormatException('Satır ${n + 1}: geçersiz cinsiyet kodu');
      }
      if (sex != expectedSex) continue;
      if (age == null || !age.isFinite ||
          l == null || !l.isFinite || m == null || !m.isFinite || m <= 0 ||
          s == null || !s.isFinite || s <= 0) {
        throw FormatException('Satır ${n + 1}: geçersiz LMS veya cinsiyet');
      }
      // CDC labels monthly reference values at the midpoint of each month.
      final month = age == 0 ? 0 : (age - 0.5).round();
      if (month < 0 || month > 24 || (age != 0 && (age - month - 0.5).abs() > 0.00001) || !used.add(month)) {
        throw FormatException('Satır ${n + 1}: ay eksik/tekrarlı/aralık dışı');
      }
      rows.add(CdcWhoRow(month, LmsParameters(l, m, s)));
    }
    rows.sort((a, b) => a.completedMonth.compareTo(b.completedMonth));
    if (rows.isEmpty || rows.first.completedMonth != 0) {
      throw const FormatException('Doğum referansı eksik');
    }
    if (rows.length != 25 || anyMissingMonth(rows)) {
      throw const FormatException('WHO 0–24 ay referansının 25 ayı da bulunmalı');
    }
    return List.unmodifiable(rows);
  }

  static bool anyMissingMonth(List<CdcWhoRow> rows) =>
      rows.length != 25 || List.generate(25, (i) => i).any((i) => rows[i].completedMonth != i);

  static double? percentileAtCompletedMonth(List<CdcWhoRow> rows, int month, double value) {
    for (final row in rows) {
      if (row.completedMonth == month) return normalPercentile(lmsZScore(value, row.lms));
    }
    return null;
  }
}
