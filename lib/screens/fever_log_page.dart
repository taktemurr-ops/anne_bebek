import 'dart:async';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';

import 'package:flutter/material.dart' hide Text;

import '../services/fever_log.dart';
import '../services/secure_health_store.dart';
import '../utils/dialog_helpers.dart';

const _mor = Color(0xFF764A72);

/// Ateş ve ilaç kaydı: ölçüm, ölçüm yöntemi, verilen ilaç ve yaşa göre uyarılar.
class FeverLogPage extends StatefulWidget {
  static const storageKey = 'baby_fever_log_v1';
  final DateTime? birth;
  final DateTime Function()? clock;
  const FeverLogPage({super.key, this.birth, this.clock});

  @override
  State<FeverLogPage> createState() => _FeverLogPageState();
}

class _FeverLogPageState extends State<FeverLogPage> {
  List<FeverEntry> _entries = [];
  bool _loading = true;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  int? get _ageMonths {
    final b = widget.birth;
    if (b == null) return null;
    final n = _now();
    var m = (n.year - b.year) * 12 + n.month - b.month;
    if (n.day < b.day) m--;
    return m < 0 ? 0 : m;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    List<FeverEntry> list = [];
    try {
      list = decodeFeverLog(await SecureHealthStore.read(FeverLogPage.storageKey));
    } catch (_) {}
    if (mounted) setState(() { _entries = list; _loading = false; });
  }

  Future<bool> _save(List<FeverEntry> next) async {
    try {
      await SecureHealthStore.write(FeverLogPage.storageKey, encodeFeverLog(next));
      setState(() => _entries = next);
      return true;
    } catch (_) {
      _snack('Kayıt cihazda saklanamadı. Lütfen tekrar deneyin.');
      return false;
    }
  }

  void _snack(String text) {
    final m = ScaffoldMessenger.maybeOf(context);
    m?..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 6)));
  }

  Future<void> _add() async {
    final temp = TextEditingController();
    final medicine = TextEditingController();
    final note = TextEditingController();
    var method = 'Koltuk altı';
    final result = await showDialogAndDispose<FeverEntry>(disposables: [temp, medicine, note], context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Ateş / ilaç kaydı'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(key: const Key('ates_derece'), controller: temp,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t('Ateş (°C)'), hintText: t('ör. 38,4'))),
          DropdownButtonFormField<String>(initialValue: method,
            decoration: InputDecoration(labelText: t('Ölçüm yeri')),
            items: feverMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) { if (v != null) update(() => method = v); }),
          TextField(key: const Key('ates_ilac'), controller: medicine, maxLength: 80,
            decoration: InputDecoration(labelText: t('Verilen ilaç ve miktar (isteğe bağlı)'),
                helperText: t('Dozu doktorun/eczacının önerisine göre ver.'), helperMaxLines: 2)),
          TextField(controller: note, maxLength: 300,
            decoration: InputDecoration(labelText: t('Not (belirtiler, sıvı alımı…)'))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(key: const Key('ates_kaydet'), onPressed: () {
            final t = temp.text.trim().isEmpty ? null : parseTemperature(temp.text);
            if (temp.text.trim().isNotEmpty && t == null) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('34–43 °C arasında geçerli bir değer girin.')));
              return;
            }
            if (t == null && medicine.text.trim().isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Ateş ya da ilaç bilgisi girin.')));
              return;
            }
            Navigator.pop(ctx, FeverEntry(_now(), temperature: t, method: method,
                medicine: medicine.text.trim(), note: note.text.trim()));
          }, child: const Text('Kaydet')),
        ],
      )));
    if (result == null || !mounted) return;
    final ok = await _save([result, ..._entries]);
    if (ok && result.temperature != null && mounted) {
      _snack(feverAdvice(result.temperature!, result.method, _ageMonths).message);
    }
  }

  Future<void> _delete(FeverEntry e) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Kaydı sil?'), content: const Text('Bu işlem geri alınamaz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (yes == true) await _save(_entries.where((x) => !identical(x, e)).toList());
  }

  Color _color(FeverLevel l) => switch (l) {
        FeverLevel.emergency => const Color(0xFFFFD6D6),
        FeverLevel.doctor => const Color(0xFFFFE6CC),
        FeverLevel.fever => const Color(0xFFFFF4D6),
        FeverLevel.low => const Color(0xFFDDEBFF),
        FeverLevel.normal => const Color(0xFFE3F6E8),
      };

  String _when(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _since(Duration d) => d.inHours >= 1 ? '${d.inHours} sa ${d.inMinutes % 60} dk' : '${d.inMinutes} dk';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final now = _now();
    final age = _ageMonths;
    final latest = _entries.where((e) => e.temperature != null).firstOrNull;
    final advice = latest == null ? null : feverAdvice(latest.temperature!, latest.method, age);
    final long = longFeverWarning(feverDuration(_entries, now), age);
    final med = lastMedicine(_entries, now);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFFFFE3F0), Color(0xFFEDE4FF)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ateş ve ilaç takibi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _mor)),
          const SizedBox(height: 4),
          Text(age == null
              ? 'Ölçümleri ve verdiğin ilaçları saatleriyle kaydet; doktora giderken hepsi elinin altında olsun.'
              : 'Bebeğin $age aylık. Ölçümleri ve verdiğin ilaçları saatleriyle kaydet.',
              style: const TextStyle(color: _mor, fontSize: 13)),
        ])),
      const SizedBox(height: 12),
      if (advice != null) Card(key: const Key('ates_uyari'), color: _color(advice.level), child: ListTile(
        leading: Icon(advice.level == FeverLevel.emergency ? Icons.local_hospital_rounded : Icons.thermostat_rounded,
            color: advice.level == FeverLevel.emergency ? Colors.redAccent : _mor),
        title: Text('Son ölçüm: ${latest!.temperature!.toStringAsFixed(1).replaceAll('.', ',')} °C (${latest.method.toLowerCase()})',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(advice.message))),
      if (long != null) Card(key: const Key('ates_uzun'), color: const Color(0xFFFFE6CC),
        child: ListTile(leading: const Icon(Icons.schedule_rounded, color: Colors.deepOrange), title: Text(long))),
      if (med != null) Card(key: const Key('ates_son_ilac'), child: ListTile(
        leading: const Icon(Icons.medication_outlined, color: _mor),
        title: Text('Son ilaç: ${med.medicine}'),
        subtitle: Text('${_since(med.since)} önce verildi. Bir sonraki doz aralığını ilacın prospektüsüne ve doktorunun önerisine göre belirle.'))),
      const SizedBox(height: 6),
      FilledButton.icon(key: const Key('ates_ekle'), style: FilledButton.styleFrom(backgroundColor: _mor),
          onPressed: _add, icon: const Icon(Icons.add), label: const Text('Ölçüm / ilaç ekle')),
      const SizedBox(height: 10),
      Card(color: const Color(0xFFFFF4F4), child: const Padding(padding: EdgeInsets.all(12), child: Text(
        'Ateşin derecesinden bağımsız olarak hemen 112’yi ara: nöbet geçirme, morarma, nefes almada zorluk, '
        'bardakla bastırınca solmayan döküntü, uyandırılamama ya da aşırı uyku hâli, ense sertliği, '
        'bıngıldakta şişlik, 8 saatten uzun süre ıslak bez olmaması.',
        style: TextStyle(fontSize: 12.5)))),
      const SizedBox(height: 8),
      if (_entries.isEmpty) const Padding(padding: EdgeInsets.all(16),
          child: Text('Henüz kayıt yok.', textAlign: TextAlign.center)),
      for (final e in _entries) Card(child: ListTile(
        leading: CircleAvatar(
          backgroundColor: e.temperature == null ? const Color(0xFFEDE4FF) : _color(feverAdvice(e.temperature!, e.method, age).level),
          child: Icon(e.temperature == null ? Icons.medication_outlined : Icons.thermostat, color: _mor, size: 20)),
        title: Text([
          if (e.temperature != null) '${e.temperature!.toStringAsFixed(1).replaceAll('.', ',')} °C',
          if (e.medicine.isNotEmpty) '💊 ${e.medicine}',
        ].join('  •  ')),
        subtitle: Text([_when(e.time), if (e.temperature != null) e.method, if (e.note.isNotEmpty) e.note].join(' • ')),
        trailing: IconButton(tooltip: t('Sil'), icon: const Icon(Icons.delete_outline), onPressed: () => _delete(e)),
      )),
      const Padding(padding: EdgeInsets.all(12), child: Text(
        'Bu sayfa tanı koymaz ve ilaç dozu önermez. Eşikler genel bilgilendirme amaçlıdır; doktorunun söyledikleri önceliklidir.',
        style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]);
  }
}
