import 'child_journals.dart';
import 'child_profiles.dart';

/// A non-diagnostic summary of only the selected child's saved records.
class ChildReport {
  static List<ChildJournalEntry> select(List<ChildJournalEntry> all,
      String childId, {DateTime? from, DateTime? to, String? category}) {
    final result = all.where((e) => e.childId == childId &&
      (from == null || !e.at.isBefore(from)) &&
      (to == null || !e.at.isAfter(to)) &&
      (category == null || category == 'Tümü' || e.category == category)).toList();
    result.sort((a, b) => b.at.compareTo(a.at));
    return result;
  }

  static Map<String, int> counts(List<ChildJournalEntry> entries) {
    final result = <String, int>{};
    for (final e in entries) {
      result.update(e.category, (n) => n + 1, ifAbsent: () => 1);
    }
    return result;
  }

  static String date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  /// Spreadsheet-compatible UTF-8 CSV; all fields are escaped, and leading
  /// formula characters are neutralized to prevent spreadsheet injection.
  static String _csvCell(Object? value) {
    var text = value?.toString() ?? '';
    if (text.isNotEmpty && '=+-@\t\r'.contains(text[0])) text = "'$text";
    return '"${text.replaceAll('"', '""')}"';
  }

  static String csvReport(ChildProfile child, List<ChildJournalEntry> entries) {
    final b = StringBuffer('\uFEFFTarih,Çocuk,Kategori,Ölçüm,Not\r\n');
    for (final e in select(entries, child.id)) {
      b.writeln([date(e.at), child.name, e.category, e.value, e.note]
          .map(_csvCell).join(','));
    }
    return b.toString();
  }

  /// Only observed numeric values are returned; this is not a growth percentile.
  static Map<String, List<ChildJournalEntry>> numericSeries(
      List<ChildJournalEntry> entries) {
    final result = <String, List<ChildJournalEntry>>{};
    for (final e in entries) {
      if (e.value == null || !e.value!.isFinite) continue;
      result.putIfAbsent(e.category, () => []).add(e);
    }
    for (final list in result.values) {
      list.sort((a, b) => a.at.compareTo(b.at));
    }
    return result;
  }

  static String textReport(ChildProfile child, List<ChildJournalEntry> entries,
      {DateTime? from, DateTime? to}) {
    final selected = select(entries, child.id, from: from, to: to);
    final b = StringBuffer()
      ..writeln('ÇOCUK TAKİP ÖZETİ')
      ..writeln('Ad: ${child.name}')
      ..writeln('Doğum: ${date(child.birthDate)}')
      ..writeln('Kayıt aralığı: ${from == null ? "Tüm tarihler" : date(from)} – ${to == null ? "Bugüne kadar" : date(to)}')
      ..writeln('Toplam kayıt: ${selected.length}')
      ..writeln();
    for (final entry in counts(selected).entries) {
      b.writeln('${entry.key}: ${entry.value} kayıt');
    }
    b.writeln('\nKAYITLAR');
    if (selected.isEmpty) b.writeln('Bu aralıkta kayıt bulunmuyor.');
    for (final e in selected) {
      b.writeln('${date(e.at)} | ${e.category}'
          '${e.value == null ? "" : " | ${e.value}"} | ${e.note}');
    }
    b.writeln('\nBilgilendirme: Kullanıcının girdiği kayıtların özetidir. '
      'Tanı, aşı uygunluğu veya tıbbi değerlendirme değildir.');
    return b.toString();
  }
}
