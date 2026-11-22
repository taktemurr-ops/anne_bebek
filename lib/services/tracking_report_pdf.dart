import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Toplu takip raporunu PDF olarak paylaşır/yazdırır (Premium).
/// Türkçe, Kiril ve Arapça harfler için Noto yazı tipleri indirilir; indirilemezse
/// Latin harfli dillerde temel yazı tipiyle (harfler sadeleştirilerek) oluşturulur.
class TrackingReportPdf {
  static String _latinSafe(String input) {
    const from = 'çğıöşüÇĞİÖŞÜ';
    const to = ['c', 'g', 'i', 'o', 's', 'u', 'C', 'G', 'I', 'O', 'S', 'U'];
    var r = input;
    for (var i = 0; i < from.length; i++) { r = r.replaceAll(from[i], to[i]); }
    return r;
  }

  /// [rtl] Arapça ve Farsça için sağdan sola yazım.
  /// Yazı tipi indirilemezse ve metin Latin dışı harf içeriyorsa false döner.
  static Future<bool> share(String title, String text, {bool rtl = false}) async {
    pw.ThemeData? theme;
    try {
      final base = await PdfGoogleFonts.notoSansRegular();
      final bold = await PdfGoogleFonts.notoSansBold();
      final arabic = await PdfGoogleFonts.notoNaskhArabicRegular();
      theme = pw.ThemeData.withFont(base: base, bold: bold, fontFallback: [arabic]);
    } catch (_) {
      if (RegExp(r'[^\u0000-ɏ\s•·–—“”’…]').hasMatch(text)) return false;
    }
    final body = theme == null ? _latinSafe(text) : text;
    final head = theme == null ? _latinSafe(title) : title;
    final doc = pw.Document(title: head, author: 'Anne & Bebek', theme: theme);
    final dir = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      textDirection: dir,
      build: (_) => [
        pw.Text(head, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        for (final line in body.split('\n'))
          pw.Padding(padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(line, style: const pw.TextStyle(fontSize: 10.5))),
      ],
    ));
    await Printing.sharePdf(bytes: await doc.save(), filename: 'anne_bebek_toplu_rapor.pdf');
    return true;
  }
}
