import 'dart:async';
import 'dart:convert';
import 'i18n/i18n.dart' show t;
import 'i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import 'services/secure_health_store.dart';
import 'services/daily_analytics.dart';
import 'services/period_comparison.dart';
import 'services/child_profiles.dart';
import 'services/wake_window.dart';

const sleepJournalKey = 'baby_sleep_journal_v1';
/// Canlı uyku zamanlayıcıları: {günlük anahtarı: başlangıç ISO}.
const sleepRunningKey = 'baby_sleep_running_v1';

Map<String, String> decodeSleepRunning(String? raw) {
  if (raw == null || raw.isEmpty) return {};
  try {
    final data = jsonDecode(raw);
    if (data is! Map) return {};
    return {
      for (final e in data.entries)
        if (e.key is String && e.value is String && DateTime.tryParse(e.value as String) != null)
          e.key as String: e.value as String,
    };
  } catch (_) {
    return {};
  }
}

/// Reject reversed, future, or implausibly long sleep intervals.
int? sleepDurationMinutes(DateTime start, DateTime end, DateTime now) {
  if (end.isAfter(now) || !end.isAfter(start)) return null;
  final minutes = end.difference(start).inMinutes;
  return minutes > 0 && minutes <= 24 * 60 ? minutes : null;
}

/// True when a proposed sleep interval overlaps an existing saved interval.
bool sleepOverlaps(List<Map<String, dynamic>> records, DateTime start, DateTime end) {
  for (final record in records) {
    final existingStart = DateTime.tryParse(record['start']?.toString() ?? '');
    final existingEnd = DateTime.tryParse(record['end']?.toString() ?? '');
    if (existingStart == null || existingEnd == null) continue;
    if (start.isBefore(existingEnd) && end.isAfter(existingStart)) return true;
  }
  return false;
}

List<Map<String, dynamic>> parseSleepJournal(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    final result = <Map<String, dynamic>>[];
    for (final item in decoded) {
      if (item is! Map || item['start'] is! String || item['end'] is! String) continue;
      final start = DateTime.tryParse(item['start'] as String);
      final end = DateTime.tryParse(item['end'] as String);
      if (start == null || end == null || sleepDurationMinutes(start, end, DateTime.now()) == null) continue;
      result.add({'start': start.toIso8601String(), 'end': end.toIso8601String()});
    }
    result.sort((a, b) => (b['start'] as String).compareTo(a['start'] as String));
    return result;
  } catch (_) { return []; }
}

class SleepJournalPage extends StatefulWidget {
  final ChildProfile? child;
  /// Profil seçilmeden açıldığında uyanıklık penceresi için doğum tarihi.
  final DateTime? birth;
  final DateTime Function()? clock;
  const SleepJournalPage({super.key, this.child, this.birth, this.clock});
  @override
  State<SleepJournalPage> createState() => _SleepJournalPageState();
}

class _SleepJournalPageState extends State<SleepJournalPage> {
  List<Map<String, dynamic>> records = [];
  String get storageKey => widget.child == null ? sleepJournalKey : '${sleepJournalKey}_child_${widget.child!.id}';
  bool loading = true;
  String? error;
  DateTime? runningSince;
  Timer? _ticker;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncTicker() {
    if (runningSince != null) {
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  Future<void> _setRunning(DateTime? start) async {
    final map = decodeSleepRunning(await SecureHealthStore.read(sleepRunningKey));
    if (start == null) {
      map.remove(storageKey);
    } else {
      map[storageKey] = start.toIso8601String();
    }
    await SecureHealthStore.write(sleepRunningKey, jsonEncode(map));
  }

  /// "Uyudu" ile canlı zamanlayıcı başlar; "Uyandı" ile kayıt oluşturulur.
  Future<void> _toggleLive() async {
    final now = _now();
    final start = runningSince;
    try {
      if (start == null) {
        await _setRunning(now);
        if (mounted) setState(() => runningSince = now);
      } else {
        final minutes = sleepDurationMinutes(start, now, now.add(const Duration(seconds: 1)));
        await _setRunning(null);
        if (mounted) setState(() => runningSince = null);
        if (minutes == null || minutes < 1) {
          _info('1 dakikadan kısa ya da 24 saatten uzun uyku kaydedilmez.');
        } else if (sleepOverlaps(records, start, now)) {
          _info('Bu saatlerde başka bir uyku kaydı var. Çakışan kayıt eklenemez.');
        } else {
          final updated = [...records, {'start': start.toIso8601String(), 'end': now.toIso8601String()}];
          updated.sort((a, b) => (b['start'] as String).compareTo(a['start'] as String));
          await _persist(updated);
        }
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Kayıt kaydedilemedi; önceki kayıtlar korundu.');
    }
    _syncTicker();
  }

  void _info(String text) {
    final m = ScaffoldMessenger.maybeOf(context);
    m?..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final value = await SecureHealthStore.read(storageKey);
      DateTime? running;
      try {
        running = DateTime.tryParse(decodeSleepRunning(await SecureHealthStore.read(sleepRunningKey))[storageKey] ?? '');
      } catch (_) {}
      if (mounted) setState(() { records = parseSleepJournal(value); runningSince = running; loading = false; });
      _syncTicker();
    } catch (_) {
      if (mounted) setState(() { error = 'Uyku kayıtları okunamadı. Mevcut kayıtlar silinmedi.'; loading = false; });
    }
  }

  Future<void> _add({Map<String, dynamic>? editing}) async {
    final now = DateTime.now();
    DateTime start = editing == null ? now.subtract(const Duration(hours: 1)) : DateTime.parse(editing['start'] as String);
    DateTime end = editing == null ? now : DateTime.parse(editing['end'] as String);
    final otherRecords = records.where((record) => !identical(record, editing)).toList();
    final result = await showDialog<List<DateTime>>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, refresh) => AlertDialog(
        title: Text(editing == null ? 'Uyku süresi ekle' : 'Uyku kaydını düzenle'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: const Text('Başlangıç'), subtitle: Text(_display(start)), onTap: () async {
            final value = await _pick(ctx, start);
            if (value != null) refresh(() => start = value);
          }),
          ListTile(title: const Text('Bitiş'), subtitle: Text(_display(end)), onTap: () async {
            final value = await _pick(ctx, end);
            if (value != null) refresh(() => end = value);
          }),
          if (sleepDurationMinutes(start, end, DateTime.now()) == null)
            const Text('Bitiş başlangıçtan sonra olmalı; süre 24 saati aşamaz.', style: TextStyle(color: Colors.red)),
          if (sleepOverlaps(otherRecords, start, end))
            const Text('Bu saatlerde başka bir uyku kaydı var. Çakışan kayıt eklenemez.', style: TextStyle(color: Colors.red)),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: sleepDurationMinutes(start, end, DateTime.now()) == null || sleepOverlaps(otherRecords, start, end)
            ? null : () => Navigator.pop(ctx, [start, end]), child: const Text('Kaydet'))],
      )));
    if (result == null || !mounted) return;
    if (sleepOverlaps(otherRecords, result[0], result[1])) return;
    final updated = [...otherRecords, {'start': result[0].toIso8601String(), 'end': result[1].toIso8601String()}];
    updated.sort((a, b) => (b['start'] as String).compareTo(a['start'] as String));
    await _persist(updated);
  }

  Future<DateTime?> _pick(BuildContext ctx, DateTime initial) async {
    final day = await showDatePicker(context: ctx, initialDate: initial,
      firstDate: DateTime(2000), lastDate: DateTime.now());
    if (day == null || !ctx.mounted) return null;
    final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return null;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Future<void> _persist(List<Map<String, dynamic>> updated) async {
    try {
      await SecureHealthStore.write(storageKey, jsonEncode(updated));
      if (mounted) setState(() { records = updated; error = null; });
    } catch (_) {
      if (mounted) setState(() => error = 'Kayıt kaydedilemedi; önceki kayıtlar korundu.');
    }
  }

  String _clock(Duration d) =>
      '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  String _hm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// Son uyanıştan bu yana geçen süre ve sıradaki uyku için önerilen aralık.
  List<Widget> _wakeWindowCard() {
    final birth = widget.child?.birthDate ?? widget.birth;
    if (birth == null || loading) return const [];
    final now = _now();
    final s = nextNapSuggestion(records, birth, now);
    if (s == null) {
      return [Card(key: const Key('uyaniklik_penceresi'), color: const Color(0xFFF3EEFF), child: const ListTile(
        leading: Icon(Icons.wb_twilight_rounded, color: Color(0xFF764A72)),
        title: Text('Uyanıklık penceresi'),
        subtitle: Text('Son uykunun bitiş saatini kaydedince sıradaki uyku için önerilen saat aralığı burada görünür.')))];
    }
    final awake = '${s.awake.inHours} sa ${s.awake.inMinutes % 60} dk';
    final range = '${_hm(s.from)}–${_hm(s.to)}';
    final (color, text) = switch (s.status) {
      WakeStatus.early => (const Color(0xFFE3F6E8), 'Sıradaki uyku için önerilen aralık: $range'),
      WakeStatus.inWindow => (const Color(0xFFFFF4D6), 'Uyku zamanı yaklaştı ($range). Yorgunluk belirtilerini izle.'),
      WakeStatus.late => (const Color(0xFFFFE6CC), 'Önerilen aralık geçti ($range). Aşırı yorgunluk uykuya dalmayı zorlaştırabilir; sakin bir ortam hazırla.'),
    };
    return [Card(key: const Key('uyaniklik_penceresi'), color: color, child: Padding(padding: const EdgeInsets.all(12), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Uyanık: $awake (son uyanış ${_hm(s.lastWake)})', style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(text),
        const SizedBox(height: 6),
        Text('Yorgunluk belirtileri: ${sleepyCues.map(t).join(', ')}', style: const TextStyle(fontSize: 12)),
        const Text('Aralıklar yaşa göre genel değerlerdir; bebeğinin belirtileri her zaman önceliklidir.',
            style: TextStyle(fontSize: 11, color: Colors.black54)),
      ])))];
  }

  String _display(DateTime date) => '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = dailyBabyStats(const [], records, today);
    final weeklyMinutes = days.fold<int>(0, (sum, day) => sum + day.sleepMinutes);
    final comparison = compareBabyWeeks(const [], records, today);
    final monthly = compareBabyMonths(const [], records, today);
    final start = days.first.day;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(widget.child == null ? 'Uyku günlüğü 🌙' : '${widget.child!.name} · Uyku günlüğü 🌙', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      if (!loading && error == null) Card(key: const Key('uyku_canli'),
        color: runningSince == null ? const Color(0xFFF3EEFF) : const Color(0xFFE6E9FF),
        child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(runningSince == null ? 'Şimdi mi uyudu?' : 'Uyuyor', style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(runningSince == null
                ? 'Dokun, uyandığında tekrar dokun; süre kendiliğinden kaydedilir.'
                : '${_clock(_now().difference(runningSince!))} • başladı ${_hm(runningSince!)}',
                style: const TextStyle(fontSize: 12.5)),
          ])),
          FilledButton.icon(key: const Key('uyku_canli_dugme'), onPressed: _toggleLive,
            icon: Icon(runningSince == null ? Icons.bedtime_rounded : Icons.wb_sunny_rounded),
            label: Text(runningSince == null ? 'Uyudu' : 'Uyandı')),
        ]))),
      if (runningSince == null) ..._wakeWindowCard(),
      if (!loading && records.isNotEmpty) Builder(builder: (_) {
        final dn = dayNightSleep(records, _now());
        String hm(int m) => t('${m ~/ 60} sa ${m % 60} dk');
        return Card(key: const Key('gece_gunduz'), child: ListTile(
          leading: const Icon(Icons.nights_stay_outlined),
          title: Text('Geçen gece: ${hm(dn.nightMinutes)}'),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bugün gündüz: ${hm(dn.dayMinutes)} • ${dn.naps} şekerleme'),
            const Text('Gece 19:00–07:00, gündüz 07:00–19:00 arası sayılır.', style: TextStyle(fontSize: 11, color: Colors.black54)),
          ])));
      }),
      Card(child: ListTile(title: const Text('Son 7 gündeki uyku süresi'),
        subtitle: Text('${weeklyMinutes ~/ 60} saat ${weeklyMinutes % 60} dakika • ${records.where((r) => !DateTime.parse(r['start'] as String).isBefore(start)).length} kayıt'))),
      const Text('Bu süreler kayıt bazlıdır; uyku ihtiyacı için tıbbi değerlendirme yerine geçmez.'),
      Card(child: ListTile(
        title: const Text('Bu hafta / önceki hafta • uyku'),
        subtitle: Text('Son 7 gün: ${comparison.currentSleepMinutes ~/ 60} sa ${comparison.currentSleepMinutes % 60} dk\n'
          'Önceki 7 gün: ${comparison.previousSleepMinutes ~/ 60} sa ${comparison.previousSleepMinutes % 60} dk\n'
          'Fark: ${comparison.sleepDifferenceMinutes >= 0 ? "+" : ""}${comparison.sleepDifferenceMinutes} dk'),
        isThreeLine: true,
      )),

      Card(child: ListTile(
        title: const Text('Takvim ayı karşılaştırması • uyku'),
        subtitle: Text('Bu ay (${monthly.current.days} gün): ${monthly.current.sleepMinutes ~/ 60} sa ${monthly.current.sleepMinutes % 60} dk\n'
          'Önceki ayın ilk ${monthly.previous.days} günü: ${monthly.previous.sleepMinutes ~/ 60} sa ${monthly.previous.sleepMinutes % 60} dk\n'
          'Günlük kayıt ortalaması: ${(monthly.current.averageSleepMinutes / 60).toStringAsFixed(1)} saat'),
        isThreeLine: true,
      )),
      Card(child: ListTile(
        title: const Text('Günlük ortalama • son 7 gün'),
        subtitle: Text('${(weeklyMinutes / 7).round() ~/ 60} saat ${(weeklyMinutes / 7).round() % 60} dakika'),
      )),

      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Günlere göre uyku • son 7 gün', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...dailyBabyStats(const [], records, today).map((day) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
              SizedBox(width: 48, child: Text('${day.day.day}.${day.day.month}', style: const TextStyle(fontSize: 12))),
              Expanded(child: LinearProgressIndicator(value: (day.sleepMinutes / 1440).clamp(0.0, 1.0),
                minHeight: 12, borderRadius: BorderRadius.circular(6))),
              const SizedBox(width: 8),
              SizedBox(width: 80, child: Text('${day.sleepMinutes ~/ 60} sa ${day.sleepMinutes % 60} dk',
                textAlign: TextAlign.end, style: const TextStyle(fontSize: 12))),
            ]))),
          const Text('Gece yarısını geçen uyku, ilgili günlere paylaştırılır. Ölçek 24 saattir.',
            style: TextStyle(fontSize: 11, color: Colors.black54)),
        ]))),

      const SizedBox(height: 12),
      FilledButton.icon(onPressed: loading || error != null ? null : _add,
        icon: const Icon(Icons.add), label: const Text('Uyku ekle')),
      if (loading) const Center(child: CircularProgressIndicator()),
      if (error != null) Card(child: ListTile(title: Text(error!), trailing: TextButton(onPressed: _load, child: const Text('Tekrar dene')))),
      if (!loading && records.isEmpty && error == null) const Padding(padding: EdgeInsets.all(20), child: Text('Henüz uyku kaydı yok.')),
      ...records.map((entry) {
        final s = DateTime.parse(entry['start'] as String);
        final e = DateTime.parse(entry['end'] as String);
        final minutes = e.difference(s).inMinutes;
        return Card(child: ListTile(title: Text('${minutes ~/ 60} saat ${minutes % 60} dakika'),
          subtitle: Text('${_display(s)} → ${_display(e)}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(tooltip: t('Kaydı düzenle'), icon: const Icon(Icons.edit_outlined), onPressed: () => _add(editing: entry)),
          IconButton(tooltip: t('Kaydı sil'), icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Uyku kaydı silinsin mi?'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
              if (ok == true) await _persist(records.where((r) => !identical(r, entry)).toList());
            }),
          ]))); 
      }),
    ]);
  }
}
