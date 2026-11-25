import 'package:flutter/material.dart' hide Text;
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../services/child_pdf_report.dart';
import '../services/child_backup.dart';
import '../services/child_profiles.dart';
import '../services/child_journals.dart';
import '../services/child_report.dart';
import '../services/secure_health_store.dart';

class ChildReportPage extends StatefulWidget {
  final ChildProfile child;
  const ChildReportPage({super.key, required this.child});
  @override
  State<ChildReportPage> createState() => _ChildReportPageState();
}

class _ChildReportPageState extends State<ChildReportPage> {
  List<ChildJournalEntry> _entries = [];
  bool _loading = true;
  String? _error;
  String _category = 'Tümü';
  int _days = 30;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final value = decodeChildJournal(await SecureHealthStore.read('child_journal_entries_v59'));
      if (mounted) setState(() => _entries = value);
    } catch (_) {
      if (mounted) setState(() => _error = 'Kayıtlar okunamadı; hiçbir veri değiştirilmedi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final from = _days == 0 ? null : DateTime.now().subtract(Duration(days: _days));
    final own = ChildReport.select(_entries, widget.child.id, from: from);
    final filtered = ChildReport.select(own, widget.child.id, category: _category);
    final categories = ['Tümü', ...ChildReport.counts(own).keys];
    final report = ChildReport.textReport(widget.child, filtered, from: from);
    return Scaffold(appBar: AppBar(title: Text('${widget.child.name} · Doktor özeti')),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
      ListView(padding: const EdgeInsets.all(16), children: [
        if (_error != null) Card(child: ListTile(title: Text(_error!),
          trailing: TextButton(onPressed: _load, child: const Text('Tekrar dene')))),
        if (_error == null) ...[
          const Text('Yalnızca seçilen çocuğun kayıtları gösterilir. Veriler cihazınızda kalır; kopyalama işlemi panoya aktarır.'),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(isExpanded: true, initialValue: _days,
            decoration: InputDecoration(labelText: t('Tarih aralığı')),
            items: const [DropdownMenuItem(value: 7, child: Text('Son 7 gün')),
              DropdownMenuItem(value: 30, child: Text('Son 30 gün')),
              DropdownMenuItem(value: 90, child: Text('Son 90 gün')),
              DropdownMenuItem(value: 0, child: Text('Tüm kayıtlar'))],
            onChanged: (v) { if (v != null) setState(() { _days = v; _category = 'Tümü'; }); }),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(isExpanded: true, key: ValueKey('${_days}_${categories.join("|")}'),
            initialValue: categories.contains(_category) ? _category : 'Tümü',
            decoration: InputDecoration(labelText: t('Kategori')),
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) { if (v != null) setState(() => _category = v); }),
          const SizedBox(height: 16),
          Card(child: ListTile(title: const Text('Seçili kayıt sayısı'),
            subtitle: Text('${filtered.length} kayıt · ${ChildReport.counts(filtered).length} kategori'))),
          FilledButton.icon(onPressed: () async {
            await Clipboard.setData(ClipboardData(text: report));
            if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Özet panoya kopyalandı. Paylaşmadan önce kişisel bilgileri kontrol edin.'))); }
          }, icon: const Icon(Icons.copy), label: const Text('Doktor özetini kopyala')),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: () async {
            final csv = ChildReport.csvReport(widget.child, filtered);
            await Clipboard.setData(ClipboardData(text: csv));
            if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CSV verileri panoya kopyalandı. Bir tablo uygulamasına yapıştırabilirsiniz.'))); }
          }, icon: const Icon(Icons.table_chart_outlined), label: const Text('Kayıtları CSV olarak kopyala')),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: () async {
            final approved = await showDialog<bool>(context: context, builder: (dialogContext) =>
              AlertDialog(title: const Text('Kişisel sağlık verisi'),
                content: const Text('Yedek metni çocuğun kişisel sağlık bilgilerini içerir. Panoya kopyalanan içerik diğer uygulamalar tarafından okunabilir. Devam edilsin mi?'),
                actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Vazgeç')),
                  FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Kopyala'))]));
            if (approved != true || !context.mounted) return;
            final backup = ChildBackup.exportJson(widget.child, _entries);
            await Clipboard.setData(ClipboardData(text: backup));
            if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Seçilen çocuğun JSON yedeği panoya kopyalandı. Güvenli bir yerde saklayın.'))); }
          }, icon: const Icon(Icons.backup_outlined), label: const Text('Çocuk kayıtlarını JSON olarak yedekle')),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: () async {
            try {
              final bytes = await ChildPdfReport.build(widget.child, filtered, from: from);
              await Printing.sharePdf(bytes: bytes,
                filename: 'cocuk_raporu_${widget.child.id}.pdf');
            } catch (_) {
              if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF olusturulamadi veya paylasilamadi. Veriler degistirilmedi.'))); }
            }
          }, icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Doktor raporunu PDF olarak paylas')),
          const Text('PDF ciktisinda Turkce karakterler Latin harflerine donusturulur. Rapor tani amacli degildir.'),
          const SizedBox(height: 12),
          if (ChildReport.numericSeries(filtered).isNotEmpty) ...[
            const Text('Ölçüm geçmişi (tanısal değerlendirme değildir)', style: TextStyle(fontWeight: FontWeight.bold)),
            for (final series in ChildReport.numericSeries(filtered).entries)
              Card(child: ListTile(
                title: Text(series.key),
                subtitle: Text('İlk: ${ChildReport.date(series.value.first.at)} · ${series.value.first.value}  |  Son: ${ChildReport.date(series.value.last.at)} · ${series.value.last.value}'),
                trailing: Text('${series.value.length} ölçüm'),
              )),
          ],
          SelectableText(report),
        ],
      ]));
  }
}
