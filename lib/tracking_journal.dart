import 'utils/dialog_helpers.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/secure_health_store.dart';
import 'services/daily_analytics.dart';
import 'services/period_comparison.dart';
import 'services/fever_log.dart' show pregnancyReadingWarning;

/// Local journal using platform-protected secure storage; no cloud sync.
class TrackingJournalPage extends StatefulWidget {
  final bool pregnancy;
  const TrackingJournalPage({super.key, this.pregnancy = false});
  @override
  State<TrackingJournalPage> createState() => _TrackingJournalPageState();
}

class _TrackingJournalPageState extends State<TrackingJournalPage> {
  static const _feedingTypes = ['Emzirme', 'Mama', 'Ek gıda', 'Süt sağma'];
  static const _pregnancyTypes = ['Kilo', 'Tansiyon', 'Kan şekeri', 'Belirti', 'Kontrol / tetkik', 'Not'];
  final List<Map<String, dynamic>> _entries = [];
  String _type = 'Emzirme';
  bool _loading = true;
  bool _showLastSevenDays = false;
  String get _key => widget.pregnancy ? 'pregnancy_journal_v5' : 'baby_feeding_journal_v5';
  List<String> get _types => widget.pregnancy ? _pregnancyTypes : _feedingTypes;

  @override
  void initState() {
    super.initState();
    _type = _types.first;
    _load();
  }

  Future<void> _load() async {
    final parsed = decodeJournal(await SecureHealthStore.read(_key));
    if (!mounted) return;
    setState(() { _entries.addAll(parsed); _loading = false; });
  }

  Future<void> _save() async {
    await SecureHealthStore.write(_key, jsonEncode(_entries));
  }

  Future<void> _add() async {
    final quantity = TextEditingController();
    final quantity2 = TextEditingController();
    final note = TextEditingController();
    String type = _type;
    String side = 'Belirtilmedi';
    DateTime date = DateTime.now();
    final result = await showDialogAndDispose<Map<String, dynamic>>(disposables: [quantity, quantity2, note],
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: Text(widget.pregnancy ? 'Gebelik kaydı ekle' : 'Beslenme kaydı ekle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(initialValue: type, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Kayıt türü'),
            items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) { if (v != null) update(() => type = v); }),
          if (type == 'Emzirme') DropdownButtonFormField<String>(initialValue: side,
            decoration: const InputDecoration(labelText: 'Taraf'),
            items: ['Belirtilmedi', 'Sol', 'Sağ', 'Her ikisi']
              .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) { if (v != null) update(() => side = v); }),
          if (_numericType(type)) TextField(controller: quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: _unitLabel(type))),
          if (type == 'Tansiyon') TextField(key: const Key('journal_amount2'), controller: quantity2,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Küçük tansiyon (mmHg)')),
          TextField(controller: note, maxLength: 500,
            decoration: InputDecoration(labelText: type == 'Ek gıda' ? 'Besin / porsiyon / gözlem' : 'Açıklama (isteğe bağlı)')),
          OutlinedButton.icon(icon: const Icon(Icons.calendar_today),
            label: Text('${date.day}.${date.month}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'),
            onPressed: () async {
              final d = await showDatePicker(context: ctx, initialDate: date,
                firstDate: DateTime(2000), lastDate: DateTime.now());
              if (d == null || !ctx.mounted) return;
              final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(date));
              if (t != null) update(() => date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
            }),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            final amount = double.tryParse(quantity.text.trim().replaceAll(',', '.'));
            if (_numericType(type) && !validJournalAmount(type, amount)) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Geçerli bir ${_unitLabel(type).toLowerCase()} girin.')));
              return;
            }
            final amount2 = double.tryParse(quantity2.text.trim().replaceAll(',', '.'));
            if (type == 'Tansiyon' && !validJournalAmount('Küçük tansiyon', amount2)) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Geçerli bir küçük tansiyon girin (30–160 mmHg).')));
              return;
            }
            if (date.isAfter(DateTime.now())) return;
            Navigator.pop(ctx, {'type': type, 'date': date.toIso8601String(),
              'amount': amount, if (type == 'Tansiyon') 'amount2': amount2, 'side': side, 'note': note.text.trim()});
          }, child: const Text('Kaydet'))],
      )),
    );
    if (result == null || !mounted) return;
    final warning = journalEntryWarning(result);
    if (warning != null) {
      ScaffoldMessenger.of(context)..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(warning), duration: const Duration(seconds: 8)));
    }
    setState(() { _entries.insert(0, result); _entries.sort((a, b) =>
      (b['date'] as String).compareTo(a['date'] as String)); });
    await _save();
  }

  Future<void> _delete(Map<String, dynamic> entry) async {
    final approved = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Kaydı sil?'), content: const Text('Bu işlem geri alınamaz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (approved != true || !mounted) return;
    setState(() => _entries.remove(entry));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayEntries = _entries.where((e) {
      final d = DateTime.tryParse(e['date'] as String? ?? '');
      return d != null && d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();
    final mamaTotal = todayEntries.where((e) => e['type'] == 'Mama')
      .fold<double>(0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0));
    final summary = feedingSummary(_entries, today);
    final monthSummary = feedingPeriodSummary(_entries, today, 30);
    final weekComparison = compareBabyWeeks(_entries, const [], today);
    final monthly = compareBabyMonths(_entries, const [], today);
    final visibleEntries = _showLastSevenDays
      ? _entries.where((e) {
          final date = DateTime.tryParse(e['date'] as String? ?? '');
          return date != null && !date.isAfter(today) &&
            !date.isBefore(DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6)));
        }).toList()
      : _entries;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(color: const Color(0xFFF8DDEB), child: Padding(padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.pregnancy ? 'Gebelik günlüğüm 🤰' : 'Beslenme günlüğüm 🍼',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF764A72))),
          const SizedBox(height: 8),
          Text(widget.pregnancy ? 'Kilo, tansiyon, kan şekeri, belirti ve kontrollerini tarihli kaydet.' :
            'Emzirme, mama, süt sağma ve ek gıda kayıtlarını bir arada tut.'),
          if (!widget.pregnancy) Padding(padding: const EdgeInsets.only(top: 12),
            child: Text('Bugün: ${todayEntries.length} kayıt • Mama: ${mamaTotal.toStringAsFixed(0)} ml')),
        ]))),
      if (!widget.pregnancy) Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Son 7 günün özeti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Mama: ${summary.formulaMl.toStringAsFixed(0)} ml • ${summary.formulaCount} kayıt'),
          Text('Emzirme: ${summary.nursingMinutes.toStringAsFixed(0)} dk • ${summary.nursingCount} kayıt'),
          Text('Ek gıda: ${summary.solidFoodCount} kayıt'),
          const Text('Bu özet tıbbi öneri veya beslenme hedefi değildir.',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
        ]))),
      if (!widget.pregnancy) Card(child: Padding(
        padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Son 30 günün özeti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Mama: ${monthSummary.formulaMl.toStringAsFixed(0)} ml • ${monthSummary.formulaCount} kayıt'),
          Text('Emzirme: ${monthSummary.nursingMinutes.toStringAsFixed(0)} dk • ${monthSummary.nursingCount} kayıt'),
          Text('Ek gıda: ${monthSummary.solidFoodCount} kayıt'),
          const Text('Kayıtların toplamıdır; beslenme yeterliliğini değerlendirmez.',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
        ]))),
      if (!widget.pregnancy) Card(child: ListTile(
        title: const Text('Takvim ayı karşılaştırması • beslenme'),
        subtitle: Text('Bu ay (${monthly.current.days} gün): ${monthly.current.formulaMl.toStringAsFixed(0)} ml mama, ${monthly.current.nursingMinutes.toStringAsFixed(0)} dk emzirme, ${monthly.current.solids} ek gıda\n'
          'Önceki ayın ilk ${monthly.previous.days} günü: ${monthly.previous.formulaMl.toStringAsFixed(0)} ml mama, ${monthly.previous.nursingMinutes.toStringAsFixed(0)} dk emzirme, ${monthly.previous.solids} ek gıda\n'
          'Mama farkı: ${monthly.formulaChangeMl >= 0 ? "+" : ""}${monthly.formulaChangeMl.toStringAsFixed(0)} ml'),
        isThreeLine: true,
      )),
      if (!widget.pregnancy) Card(child: ListTile(
        title: const Text('Bu hafta / önceki hafta • mama'),
        subtitle: Text('Son 7 gün: ${weekComparison.currentFormulaMl.toStringAsFixed(0)} ml\n'
          'Önceki 7 gün: ${weekComparison.previousFormulaMl.toStringAsFixed(0)} ml\n'
          'Fark: ${weekComparison.formulaDifferenceMl >= 0 ? "+" : ""}${weekComparison.formulaDifferenceMl.toStringAsFixed(0)} ml'),
        isThreeLine: true,
      )),
      if (!widget.pregnancy) Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Günlük mama miktarı • son 7 gün', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...dailyBabyStats(_entries, const [], today).map((day) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(width: 48, child: Text('${day.day.day}.${day.day.month}', style: const TextStyle(fontSize: 12))),
              Expanded(child: LinearProgressIndicator(value: (day.formulaMl / 1000).clamp(0.0, 1.0),
                minHeight: 12, borderRadius: BorderRadius.circular(6))),
              const SizedBox(width: 8),
              SizedBox(width: 65, child: Text('${day.formulaMl.toStringAsFixed(0)} ml', textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 12))),
            ]),
          )),
          const SizedBox(height: 4),
          const Text('Çubuk ölçeği 1.000 ml; önerilen tüketim miktarı değildir.',
            style: TextStyle(fontSize: 11, color: Colors.black54)),
        ]))),
      if (!widget.pregnancy) SwitchListTile(
        title: const Text('Yalnızca son 7 günün kayıtlarını göster'),
        value: _showLastSevenDays,
        onChanged: (value) => setState(() => _showLastSevenDays = value),
      ),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Yeni kayıt ekle')),
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (!_loading && _entries.isEmpty) const Padding(padding: EdgeInsets.all(20),
        child: Text('Henüz kayıt bulunmuyor. Yeni kayıt ekleyerek başlayabilirsin.')),
      ...visibleEntries.map((entry) {
        final d = DateTime.tryParse(entry['date'] as String? ?? '');
        final amount = entry['amount'];
        final type = entry['type'] as String? ?? '';
        final detail = <String>[
          if (d != null) '${d.day}.${d.month}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}',
          if (amount is num) journalAmountText(entry),
          if (type == 'Emzirme' && entry['side'] != 'Belirtilmedi') '${entry['side']}',
          if ((entry['note'] as String? ?? '').isNotEmpty) entry['note'] as String,
        ];
        final warning = journalEntryWarning(entry);
        if (warning != null) detail.add('⚠️ $warning');
        return Card(color: warning != null ? const Color(0xFFFFF0F0) : null,
          child: ListTile(title: Text(type), subtitle: Text(detail.join(' • ')),
          trailing: IconButton(tooltip: 'Kaydı sil', icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(entry))));
      }),
      const Padding(padding: EdgeInsets.all(12), child: Text(
        'Bu kayıtlar cihazın güvenli depolama alanında tutulur; otomatik bulut yedeği değildir. '
        'Tıbbi değerlendirme ya da tedavi önerisi yerine geçmez.',
        style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]);
  }
}

bool _numericType(String type) =>
    const {'Mama', 'Emzirme', 'Kilo', 'Süt sağma', 'Tansiyon', 'Kan şekeri'}.contains(type);
String _unitLabel(String type) => switch (type) {
      'Mama' || 'Süt sağma' => 'Miktar (ml)',
      'Kilo' => 'Kilo (kg)',
      'Tansiyon' => 'Büyük tansiyon (mmHg)',
      'Kan şekeri' => 'Kan şekeri (mg/dL)',
      _ => 'Süre (dakika)',
    };

String journalAmountText(Map<String, dynamic> entry) {
  final type = entry['type'];
  final a = entry['amount'], b = entry['amount2'];
  String n(Object? v) => v is num ? (v == v.roundToDouble() ? v.toInt().toString() : v.toString()) : '';
  return switch (type) {
    'Tansiyon' => '${n(a)}/${n(b)} mmHg',
    'Kan şekeri' => '${n(a)} mg/dL',
    'Mama' || 'Süt sağma' => '${n(a)} ml',
    'Kilo' => '${n(a)} kg',
    _ => '${n(a)} dk',
  };
}

String? journalEntryWarning(Map<String, dynamic> entry) {
  final a = entry['amount'], b = entry['amount2'];
  return pregnancyReadingWarning('${entry['type']}', a is num ? a.toDouble() : null, b is num ? b.toDouble() : null);
}

bool validJournalAmount(String type, double? value) {
  if (value == null || !value.isFinite) return false;
  switch (type) {
    case 'Mama': return value > 0 && value <= 1000;
    case 'Emzirme': return value > 0 && value <= 240;
    case 'Kilo': return value >= 20 && value <= 350;
    case 'Süt sağma': return value > 0 && value <= 1000;
    case 'Tansiyon': return value >= 60 && value <= 250;
    case 'Küçük tansiyon': return value >= 30 && value <= 160;
    case 'Kan şekeri': return value >= 20 && value <= 600;
    default: return true;
  }
}

List<Map<String, dynamic>> decodeJournal(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final data = jsonDecode(raw);
    if (data is! List) return [];
    final result = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is! Map) continue;
      final type = item['type'];
      final date = item['date'];
      if (type is! String || date is! String || DateTime.tryParse(date) == null) continue;
      result.add(Map<String, dynamic>.from(item));
    }
    result.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return result;
  } catch (_) { return []; }
}

/// Seven calendar days including [now]. Invalid and future records are ignored.
class FeedingSummary {
  final double formulaMl;
  final int formulaCount;
  final double nursingMinutes;
  final int nursingCount;
  final int solidFoodCount;
  const FeedingSummary({required this.formulaMl, required this.formulaCount,
    required this.nursingMinutes, required this.nursingCount,
    required this.solidFoodCount});
}

FeedingSummary feedingSummary(List<Map<String, dynamic>> entries, DateTime now) {
  final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  double formula = 0, nursing = 0;
  int formulaCount = 0, nursingCount = 0, solids = 0;
  for (final entry in entries) {
    final raw = entry['date'];
    final date = raw is String ? DateTime.tryParse(raw) : null;
    if (date == null || date.isBefore(start) || date.isAfter(now)) continue;
    final type = entry['type'];
    final amount = entry['amount'];
    if (type == 'Mama' && amount is num && validJournalAmount('Mama', amount.toDouble())) {
      formula += amount.toDouble(); formulaCount++;
    } else if (type == 'Emzirme' && amount is num && validJournalAmount('Emzirme', amount.toDouble())) {
      nursing += amount.toDouble(); nursingCount++;
    } else if (type == 'Ek gıda') { solids++; }
  }
  return FeedingSummary(formulaMl: formula, formulaCount: formulaCount,
    nursingMinutes: nursing, nursingCount: nursingCount, solidFoodCount: solids);
}


/// Calendar-day summary for a configurable trailing period, including today.
/// Entries outside the period, future entries, and invalid quantities are ignored.
FeedingSummary feedingPeriodSummary(List<Map<String, dynamic>> entries, DateTime now, int days) {
  if (days < 1 || days > 366) throw ArgumentError.value(days, 'days');
  final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
  double formula = 0, nursing = 0;
  int formulaCount = 0, nursingCount = 0, solids = 0;
  for (final entry in entries) {
    final raw = entry['date'];
    final date = raw is String ? DateTime.tryParse(raw) : null;
    if (date == null || date.isBefore(start) || date.isAfter(now)) continue;
    final amount = entry['amount'];
    final type = entry['type'];
    if (type == 'Mama' && amount is num && validJournalAmount('Mama', amount.toDouble())) {
      formula += amount.toDouble(); formulaCount++;
    } else if (type == 'Emzirme' && amount is num && validJournalAmount('Emzirme', amount.toDouble())) {
      nursing += amount.toDouble(); nursingCount++;
    } else if (type == 'Ek gıda') { solids++; }
  }
  return FeedingSummary(formulaMl: formula, formulaCount: formulaCount,
    nursingMinutes: nursing, nursingCount: nursingCount, solidFoodCount: solids);
}
