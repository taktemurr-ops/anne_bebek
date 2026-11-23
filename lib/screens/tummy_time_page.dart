import 'dart:async';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';

import 'package:flutter/material.dart' hide Text;

import '../services/secure_health_store.dart';
import '../services/tummy_time.dart';
import '../services/wake_window.dart' show ageInMonths;
import '../utils/dialog_helpers.dart';

const _mor = Color(0xFF764A72);

/// Karın üstü zamanı: başlat/durdur zamanlayıcısı, günlük hedef, son 7 gün.
class TummyTimePage extends StatefulWidget {
  static const storageKey = 'tummy_time_v1';
  final DateTime? birth;
  final DateTime Function()? clock;
  const TummyTimePage({super.key, this.birth, this.clock});

  @override
  State<TummyTimePage> createState() => _TummyTimePageState();
}

class _TummyTimePageState extends State<TummyTimePage> {
  TummyTimeData _data = const TummyTimeData([]);
  bool _loading = true;
  Timer? _ticker;

  DateTime _now() => (widget.clock ?? DateTime.now)();
  int? get _age => widget.birth == null ? null : ageInMonths(widget.birth!, _now());

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    var data = const TummyTimeData([]);
    try {
      data = TummyTimeData.decode(await SecureHealthStore.read(TummyTimePage.storageKey));
    } catch (_) {}
    if (!mounted) return;
    setState(() { _data = data; _loading = false; });
    _syncTicker();
  }

  void _syncTicker() {
    if (_data.runningSince != null) {
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  Future<void> _save(TummyTimeData next) async {
    final previous = _data;
    setState(() => _data = next);
    _syncTicker();
    try {
      await SecureHealthStore.write(TummyTimePage.storageKey, next.encode());
    } catch (_) {
      if (!mounted) return;
      setState(() => _data = previous);
      _syncTicker();
      _snack('Kayıt cihazda saklanamadı. Lütfen tekrar deneyin.');
    }
  }

  void _snack(String text) {
    final m = ScaffoldMessenger.maybeOf(context);
    m?..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _toggle() async {
    final now = _now();
    if (_data.runningSince == null) {
      await _save(_data.start(now));
      return;
    }
    final minutes = now.difference(_data.runningSince!).inMinutes;
    await _save(_data.stop(now));
    if (mounted && minutes < 1) _snack('1 dakikadan kısa seanslar kaydedilmez.');
  }

  Future<void> _addManual() async {
    final c = TextEditingController();
    final minutes = await showDialogAndDispose<int>(disposables: [c], context: context, builder: (ctx) => AlertDialog(
      title: const Text('Seans ekle'),
      content: TextField(key: const Key('karin_dakika'), controller: c, autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: t('Süre (dakika)'), hintText: t('ör. 5'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(key: const Key('karin_kaydet'), onPressed: () {
          final v = int.tryParse(c.text.trim());
          if (v == null || !validTummyMinutes(v)) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('1–120 dakika arasında bir değer girin.')));
            return;
          }
          Navigator.pop(ctx, v);
        }, child: const Text('Kaydet')),
      ]));
    if (minutes == null || !mounted) return;
    final now = _now();
    await _save(_data.add(TummySession(now.subtract(Duration(minutes: minutes)), minutes)));
  }

  Future<void> _delete(TummySession s) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Kaydı sil?'), content: const Text('Bu işlem geri alınamaz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (yes == true) await _save(_data.remove(s));
  }

  String _clock(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _hm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final now = _now();
    final age = _age;
    final goal = tummyGoalMinutes(age);
    final running = _data.runningSince;
    final today = _data.minutesOn(now) + (running == null ? 0 : now.difference(running).inMinutes.clamp(0, 120));
    final week = _data.lastWeek(now);
    final maxWeek = [goal ?? 30, ...week.map((d) => d.minutes)].reduce((a, b) => a > b ? a : b);
    final todaySessions = _data.sessions.where((s) =>
        s.start.year == now.year && s.start.month == now.month && s.start.day == now.day).toList();
    final older = _data.sessions.where((s) => !todaySessions.contains(s)).take(30).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFFE3F6E8), Color(0xFFEDE4FF)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Karın üstü zamanı', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _mor)),
          const SizedBox(height: 4),
          Text(tummyStageTip(age), style: const TextStyle(color: _mor, fontSize: 13)),
        ])),
      const SizedBox(height: 16),
      Center(child: Text(running == null ? '00:00' : _clock(now.difference(running)),
          key: const Key('karin_sure'),
          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: _mor))),
      const SizedBox(height: 8),
      Center(child: FilledButton.icon(
        key: const Key('karin_dugme'),
        style: FilledButton.styleFrom(backgroundColor: running == null ? _mor : Colors.redAccent,
            minimumSize: const Size(220, 54)),
        icon: Icon(running == null ? Icons.play_arrow_rounded : Icons.stop_rounded),
        label: Text(running == null ? 'Başlat' : 'Bitir ve kaydet'),
        onPressed: _toggle)),
      Center(child: TextButton.icon(onPressed: running == null ? _addManual : null,
          icon: const Icon(Icons.edit_note_rounded), label: const Text('Süreyi elle ekle'))),
      const SizedBox(height: 8),
      Card(key: const Key('karin_bugun'), child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(goal == null ? 'Bugün: $today dakika' : 'Bugün: $today / $goal dakika',
              style: const TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 16)),
          if (goal != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (today / goal).clamp(0.0, 1.0), minHeight: 12,
                borderRadius: BorderRadius.circular(6), color: const Color(0xFF4CAF7A),
                backgroundColor: const Color(0xFFE8F3EC)),
            const SizedBox(height: 6),
            Text(today >= goal ? 'Günlük hedefe ulaşıldı. Harika!' : 'Hedefe $goal dakika; kalan ${goal - today} dakika. Gün içine kısa seanslar halinde yay.',
                style: const TextStyle(fontSize: 12.5)),
          ],
          Text('Bugün ${todaySessions.length} seans', style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]))),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Son 7 gün', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final d in week) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
            SizedBox(width: 48, child: Text('${d.day.day}.${d.day.month}', style: const TextStyle(fontSize: 12))),
            Expanded(child: LinearProgressIndicator(value: maxWeek == 0 ? 0 : d.minutes / maxWeek, minHeight: 10,
                borderRadius: BorderRadius.circular(5),
                color: goal != null && d.minutes >= goal ? const Color(0xFF4CAF7A) : _mor,
                backgroundColor: const Color(0xFFF2E5F0))),
            SizedBox(width: 60, child: Text('${d.minutes} dk', textAlign: TextAlign.end, style: const TextStyle(fontSize: 12))),
          ])),
        ]))),
      Card(color: const Color(0xFFFFF4F4), child: Padding(padding: const EdgeInsets.all(12), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Güvenlik', style: TextStyle(fontWeight: FontWeight.w800, color: _mor)),
          for (final n in tummySafetyNotes) Padding(padding: const EdgeInsets.only(top: 4),
              child: Text('• $n', style: const TextStyle(fontSize: 12.5))),
        ]))),
      if (_data.sessions.isEmpty) const Padding(padding: EdgeInsets.all(16),
          child: Text('Henüz seans kaydı yok.', textAlign: TextAlign.center)),
      for (final s in [...todaySessions, ...older]) Card(child: ListTile(dense: true,
        leading: const Icon(Icons.child_care_rounded, color: _mor),
        title: Text('${s.minutes} dakika'),
        subtitle: Text('${s.start.day}.${s.start.month}.${s.start.year} ${_hm(s.start)}'),
        trailing: IconButton(tooltip: t('Sil'), icon: const Icon(Icons.delete_outline), onPressed: () => _delete(s)))),
      const Padding(padding: EdgeInsets.all(12), child: Text(
        'Hedefler genel bilgilendirme amaçlıdır. Bebeğin başını kaldırmakta zorlanıyor ya da hep aynı tarafa dönüyorsa doktoruna danış.',
        style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]);
  }
}
