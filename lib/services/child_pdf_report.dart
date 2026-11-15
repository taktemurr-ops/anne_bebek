import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'child_journals.dart';
import 'child_profiles.dart';
import 'child_report.dart';

/// Creates an offline PDF from only the selected child's journal entries.
/// Standard PDF fonts do not include every Turkish glyph, so unsupported
/// characters are transliterated in this initial PDF export.
class ChildPdfReport {
  static String _pdfSafe(String input) {
    const from = 'çğıöşüÇĞİÖŞÜı';
    const to = ['c', 'g', 'i', 'o', 's', 'u', 'C', 'G', 'I', 'O', 'S', 'U', 'i'];
    var result = input;
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }

  static Future<Uint8List> build(ChildProfile child,
      List<ChildJournalEntry> entries, {DateTime? from}) async {
    final selected = ChildReport.select(entries, child.id, from: from);
    final doc = pw.Document(title: 'Cocuk saglik ozeti', author: 'Anne & Bebek');
    final summary = ChildReport.textReport(child, selected, from: from);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => [
        pw.Text('COCUK TAKIP RAPORU',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Text(_pdfSafe(summary), style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 12),
        pw.Text('Kisisel saglik verisi: yalnizca guvendiginiz kisilerle paylasin.',
          style: const pw.TextStyle(fontSize: 9)),
      ],
    ));
    return doc.save();
  }
}
