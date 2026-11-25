import 'package:flutter/material.dart' hide Text;
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/services.dart';
import '../services/child_growth_export.dart';
import '../services/cdc_who_reference_csv.dart';
import 'dart:math' as math;
import '../services/child_journals.dart';
import '../services/child_profiles.dart';
import '../services/secure_health_store.dart';
import '../services/child_growth_summary.dart';

/// Historical measurements for an additional child. This is NOT a WHO percentile chart.
class ChildGrowthTrendsPage extends StatefulWidget {
  final ChildProfile child;
  const ChildGrowthTrendsPage({super.key, required this.child});
  @override State<ChildGrowthTrendsPage> createState() => _ChildGrowthTrendsPageState();
}
class _ChildGrowthTrendsPageState extends State<ChildGrowthTrendsPage> {
  List<ChildJournalEntry> entries = [];
  String? error;
  bool loading = true;
  final Map<String, List<CdcWhoRow>> whoReferences = {};
  String? whoMessage;
  // Dönem filtresi: null = tümü.
  int? periodMonths;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final all = decodeChildJournal(await SecureHealthStore.read('child_journal_entries_v59'));
      if (mounted) setState(() { entries = all.where((e) => e.childId == widget.child.id).toList(); error = null; });
    } catch (_) {
      if (mounted) setState(() => error = 'Ölçümler okunamadı. Veriler korunuyor.');
    } finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> _importWhoCsv() async {
    final sex = widget.child.sex == 'male' ? 1 : widget.child.sex == 'female' ? 2 : null;
    if (sex == null) {
      setState(() => whoMessage = 'Önce çocuk profilinde cinsiyet bilgisini belirtin.');
      return;
    }
    final choice = await showDialog<String>(context: context, builder: (ctx) => SimpleDialog(
      title: const Text('Resmî WHO CSV türü'),
      children: [for (final name in const ['Kilo (kg)', 'Boy (cm)', 'Baş çevresi (cm)'])
        SimpleDialogOption(onPressed: () => Navigator.pop(ctx, name), child: Text(name))],
    ));
    if (choice == null) return;
    try {
      final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
      final csv = clipboard?.text ?? '';
      final rows = CdcWhoReferenceCsv.parse(csv, expectedSex: sex);
      if (!mounted) return;
      setState(() {
        whoReferences[choice] = rows;
        whoMessage = '$choice: 25 aylık referans okundu. CSV kaynağının CDC/WHO olduğundan emin olun.';
      });
    } catch (_) {
      if (mounted) setState(() => whoMessage = 'CSV doğrulanamadı. CDC/WHO 0–24 ay LMS CSV dosyasının tam içeriğini kopyalayın.');
    }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.child.name} · Büyüme geçmişi'), actions: [
      IconButton(tooltip: t('WHO CSV referansı yükle'), icon: const Icon(Icons.upload_file_outlined), onPressed: _importWhoCsv),
      IconButton(tooltip: t('Ölçümleri CSV olarak kopyala'), icon: const Icon(Icons.copy_all_outlined), onPressed: loading || error != null ? null : () async {
        final csv = exportChildMeasurementsCsv(widget.child, entries);
        await Clipboard.setData(ClipboardData(text: csv));
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ölçüm CSV verisi panoya kopyalandı.')));
      }),
    ]),
    body: loading ? const Center(child: CircularProgressIndicator()) :
      error != null ? Center(child: Text(error!)) : ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(
          whoReferences.isEmpty
              ? 'WHO persentili için doğrulanmış CDC/WHO 0–24 ay CSV dosyaları gereklidir. Üstteki yükleme simgesiyle resmi CSV içeriğini panodan içe aktarabilirsiniz. Referans yüklenmeden persentil hesaplanmaz.'
              : 'Yüklenen referanslar yalnızca bu ekran açıkken tutulur. 0–24 ay aylık WHO persentilleri bilgi amaçlıdır; tıbbi değerlendirme değildir.'))),
        if (whoMessage != null) Padding(padding: const EdgeInsets.all(8), child: Text(whoMessage!)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: SegmentedButton<int>(
          key: const ValueKey('growth_period'),
          segments: const [
            ButtonSegment(value: 0, label: Text('Tümü')),
            ButtonSegment(value: 3, label: Text('3 ay')),
            ButtonSegment(value: 6, label: Text('6 ay')),
            ButtonSegment(value: 12, label: Text('12 ay')),
          ],
          selected: {periodMonths ?? 0},
          onSelectionChanged: (v) => setState(() => periodMonths = v.first == 0 ? null : v.first),
        )),
        for (final category in const ['Kilo (kg)', 'Boy (cm)', 'Baş çevresi (cm)'])
          _MeasurementSection(category: category,
            entries: growthEntriesInPeriod(entries, periodMonths, DateTime.now()),
            child: widget.child, reference: whoReferences[category]),
      ]),
  );
}
class _MeasurementSection extends StatelessWidget {
  final String category;
  final List<ChildJournalEntry> entries;
  final ChildProfile child;
  final List<CdcWhoRow>? reference;
  const _MeasurementSection({required this.category, required this.entries, required this.child, this.reference});
  @override Widget build(BuildContext context) {
    final data = measurementHistory(entries, category);
    final delta = measurementChange(entries, category);
    final interval = latestGrowthInterval(entries, category);
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(category, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (data.isEmpty) const Text('Henüz ölçüm kaydı yok.'),
        if (delta != null) Text('İlk–son ölçüm farkı: ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}'),
        if (interval != null) Text('Son iki farklı ölçüm günü: ${interval.days} gün · değişim: ${interval.change >= 0 ? '+' : ''}${interval.change.toStringAsFixed(2)} · 30 güne ölçeklenmiş: ${interval.changePer30Days.toStringAsFixed(2)}'),
        if (interval != null) const Text('30 günlük değer yalnızca matematiksel karşılaştırmadır; büyüme tahmini veya tıbbi yorum değildir.'),
        if (data.length >= 2) ...[
          const SizedBox(height: 12),
          SizedBox(height: 160, width: double.infinity,
            child: CustomPaint(painter: _MeasurementChart(
              points: data.map((e) => _ChartPoint(e.at, e.value!)).toList(),
              color: Theme.of(context).colorScheme.primary))),
          const SizedBox(height: 6),
          Text('Soldan sağa: ${_date(data.first.at)} – ${_date(data.last.at)}',
            style: Theme.of(context).textTheme.bodySmall),
        ],
        for (final e in data.reversed.take(20)) Padding(padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(child: Text('${e.at.day.toString().padLeft(2, '0')}.${e.at.month.toString().padLeft(2, '0')}.${e.at.year}')),
            Text(e.value!.toStringAsFixed(2)),
            if (reference != null) ...[
              const SizedBox(width: 8),
              Builder(builder: (_) {
                final months = (e.at.year - child.birthDate.year) * 12 + e.at.month - child.birthDate.month - (e.at.day < child.birthDate.day ? 1 : 0);
                final p = months >= 0 && months <= 24 && !e.at.isBefore(child.birthDate)
                    ? CdcWhoReferenceCsv.percentileAtCompletedMonth(reference!, months, e.value!) : null;
                return Text(p == null ? '—' : 'P${p.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodySmall);
              }),
            ],
          ])),
        if (data.length > 20) Text('Son 20 ölçüm gösteriliyor (toplam ${data.length}).'),
      ])));
  }
}

String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

class _ChartPoint {
  final DateTime at;
  final double value;
  const _ChartPoint(this.at, this.value);
}

/// Draws only the measurements entered by the user. No reference ranges.
class _MeasurementChart extends CustomPainter {
  final List<_ChartPoint> points;
  final Color color;
  const _MeasurementChart({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.width <= 0 || size.height <= 0) return;
    final sorted = [...points]..sort((a, b) => a.at.compareTo(b.at));
    final minV = sorted.map((p) => p.value).reduce(math.min);
    final maxV = sorted.map((p) => p.value).reduce(math.max);
    final minT = sorted.first.at.millisecondsSinceEpoch;
    final maxT = sorted.last.at.millisecondsSinceEpoch;
    final rangeV = maxV - minV;
    final rangeT = maxT - minT;
    const inset = 12.0;
    final width = math.max(0.0, size.width - inset * 2);
    final height = math.max(0.0, size.height - inset * 2);
    Offset position(_ChartPoint p) => Offset(
      inset + (rangeT == 0 ? 0.5 : (p.at.millisecondsSinceEpoch - minT) / rangeT) * width,
      inset + (rangeV == 0 ? 0.5 : 1 - (p.value - minV) / rangeV) * height,
    );
    final axis = Paint()..color = color.withAlpha(45)..strokeWidth = 1;
    canvas.drawLine(Offset(inset, inset + height), Offset(inset + width, inset + height), axis);
    final line = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke;
    final path = Path()..moveTo(position(sorted.first).dx, position(sorted.first).dy);
    for (final point in sorted.skip(1)) {
      final offset = position(point);
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(path, line);
    final dot = Paint()..color = color..style = PaintingStyle.fill;
    for (final point in sorted) { canvas.drawCircle(position(point), 3, dot); }
  }

  @override
  bool shouldRepaint(covariant _MeasurementChart oldDelegate) =>
    oldDelegate.color != color || oldDelegate.points.length != points.length ||
    !_samePoints(oldDelegate.points, points);

  bool _samePoints(List<_ChartPoint> a, List<_ChartPoint> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].at != b[i].at || a[i].value != b[i].value) return false;
    }
    return true;
  }
}
