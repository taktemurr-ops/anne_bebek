import '../i18n/i18n.dart';
import 'child_journals.dart';
import 'child_profiles.dart';
import 'child_growth_summary.dart';

/// Spreadsheet-safe CSV export of user-entered measurements, not WHO data.
String exportChildMeasurementsCsv(ChildProfile child, List<ChildJournalEntry> entries) {
  final categories = ['Kilo (kg)', 'Boy (cm)', 'Baş çevresi (cm)'];
  final records = <ChildJournalEntry>[];
  final birth = DateTime(child.birthDate.year, child.birthDate.month, child.birthDate.day);
  for (final category in categories) {
    records.addAll(measurementHistory(entries.where((e) => e.childId == child.id).toList(), category)
      .where((e) {
        final day = DateTime(e.at.year, e.at.month, e.at.day);
        return !day.isBefore(birth) && !day.isAfter(DateTime.now());
      }));
  }
  records.sort((a, b) { final date = a.at.compareTo(b.at); return date != 0 ? date : a.id.compareTo(b.id); });
  String cell(String value) {
    // Prevent spreadsheet formula execution when pasted/imported.
    final safe = value.trimLeft().startsWith(RegExp(r'[=+@\-]')) ? "'$value" : value;
    return '"${safe.replaceAll('"', '""')}"';
  }
  final rows = <String>[t('Çocuk;Tarih;Yaş (gün);Ölçüm;Değer;Not')];
  for (final e in records) {
    final day = DateTime(e.at.year, e.at.month, e.at.day);
    final date = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    rows.add([child.name, date, day.difference(birth).inDays.toString(), e.category, e.value!.toStringAsFixed(2), e.note].map(cell).join(';'));
  }
  return '\uFEFF${rows.join('\r\n')}\r\n';
}
