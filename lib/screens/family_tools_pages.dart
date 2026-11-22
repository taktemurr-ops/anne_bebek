import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';

import '../data/newborn_checklist.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/json_store.dart';
import '../services/potty_training.dart';
import '../services/text_share.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Bebek gelmeden ve geldikten sonra yapılacaklar.
class NewbornChecklistPage extends StatefulWidget {
  static const storageKey = 'newborn_checklist_v1';
  final String childKey;
  const NewbornChecklistPage({super.key, this.childKey = 'main'});

  @override
  State<NewbornChecklistPage> createState() => _NewbornChecklistPageState();
}

class _NewbornChecklistPageState extends State<NewbornChecklistPage> {
  Map<String, dynamic> _all = {};
  Map<String, String> _done = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(NewbornChecklistPage.storageKey); } catch (_) {}
    final ids = newbornChecklist.map((e) => e.id).toSet();
    final done = <String, String>{};
    final raw = all[widget.childKey];
    if (raw is Map) {
      raw.forEach((k, v) { if (ids.contains(k) && v is String) done['$k'] = v; });
    }
    if (mounted) setState(() { _all = all; _done = done; _loading = false; });
  }

  Future<void> _toggle(ChecklistItem i) async {
    final next = Map<String, String>.from(_done);
    next.containsKey(i.id) ? next.remove(i.id) : next[i.id] = DateTime.now().toIso8601String();
    final all = {..._all, widget.childKey: next};
    try {
      await JsonStore.writeMap(NewbornChecklistPage.storageKey, all);
      if (mounted) setState(() { _all = all; _done = next; });
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(child: Column(children: [
        Text('${_done.length} / ${newbornChecklist.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor)),
        Text('tamamlandı', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _done.length / newbornChecklist.length, color: kitMor, backgroundColor: const Color(0xFFF1E6F0)),
      ])),
      for (final p in checklistPhases) ...[
        KitHeader(p, Icons.flag_outlined),
        for (final i in newbornChecklist.where((e) => e.phase == p))
          PastelCard(padding: const EdgeInsets.symmetric(horizontal: 4), child: CheckboxListTile(
            key: Key('liste_${i.id}'), value: _done.containsKey(i.id), activeColor: kitMor, onChanged: (_) => _toggle(i),
            title: Text(i.title, style: const TextStyle(fontSize: 14)),
            subtitle: i.detail.isEmpty ? null : Text(i.detail, style: const TextStyle(fontSize: 12)))),
      ],
      const KitFootnote('Tarama, aşı ve takviye zamanları T.C. Sağlık Bakanlığı programlarına göredir. Başka bir ülkede yaşıyorsan doktorunun önerisine uy.'),
    ]);
  }
}

/// Tuvalet eğitimi: hazır olma belirtileri ve günlük kayıt.
class PottyTrainingPage extends StatefulWidget {
  static const storageKey = 'potty_training_v1';
  final String childKey;
  final DateTime? birth;
  const PottyTrainingPage({super.key, this.childKey = 'main', this.birth});

  @override
  State<PottyTrainingPage> createState() => _PottyTrainingPageState();
}

class _PottyTrainingPageState extends State<PottyTrainingPage> {
  Map<String, dynamic> _all = {};
  Set<String> _signs = {};
  List<PottyDay> _days = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(PottyTrainingPage.storageKey); } catch (_) {}
    final sec = childSection(all, widget.childKey);
    final s = sec['signs'];
    if (!mounted) return;
    setState(() {
      _all = all;
      _signs = s is List ? s.whereType<String>().where(pottyReadinessSigns.contains).toSet() : {};
      _days = decodePottyDays(sec['days']);
      _loading = false;
    });
  }

  Future<void> _save() async {
    final all = {..._all, widget.childKey: {
      'signs': _signs.toList(),
      'days': _days.map((d) => d.toJson()).toList(),
    }};
    try {
      await JsonStore.writeMap(PottyTrainingPage.storageKey, all);
      _all = all;
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  void _log({int pee = 0, int poo = 0, int accidents = 0}) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final cur = _days.firstWhere((d) => d.day == today, orElse: () => PottyDay(today));
    setState(() {
      _days = [..._days.where((d) => d.day != today), cur.add(pee: pee, poo: poo, accidents: accidents)]
        ..sort((a, b) => a.day.compareTo(b.day));
    });
    unawaited(_save());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final months = ageInMonths(widget.birth, DateTime.now());
    final n = DateTime.now();
    final today = _days.firstWhere((d) => d.day == DateTime(n.year, n.month, n.day), orElse: () => PottyDay(n));
    final rate = weeklySuccessRate(_days, n);
    Widget counter(String label, int value, IconData icon, VoidCallback onAdd, VoidCallback onRemove, Key key) => Expanded(child: PastelCard(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(children: [
        Icon(icon, color: kitMor),
        Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(tooltip: t('Azalt'), visualDensity: VisualDensity.compact, onPressed: value > 0 ? onRemove : null, icon: const Icon(Icons.remove_circle_outline)),
          IconButton(key: key, tooltip: t('Ekle'), visualDensity: VisualDensity.compact, onPressed: onAdd, icon: const Icon(Icons.add_circle, color: kitMor)),
        ]),
      ])));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      if (months != null && months < 18) const KitNote(
        'Çoğu çocuk 18 ay ile 3 yaş arasında tuvalet eğitimine hazır olur. Şimdilik hazır olma belirtilerini takip edebilirsin.'),
      const KitHeader('Bugün', Icons.today),
      Row(children: [
        counter('Çiş (tuvalette)', today.pee, Icons.water_drop_outlined, () => _log(pee: 1), () => _log(pee: -1), const Key('lazimlik_cis')),
        const SizedBox(width: 6),
        counter('Kaka (tuvalette)', today.poo, Icons.check_circle_outline, () => _log(poo: 1), () => _log(poo: -1), const Key('lazimlik_kaka')),
        const SizedBox(width: 6),
        counter('Kaza', today.accidents, Icons.water_damage_outlined, () => _log(accidents: 1), () => _log(accidents: -1), const Key('lazimlik_kaza')),
      ]),
      if (rate != null) KitNote('${t('Son 7 günde başarı')}: %$rate', color: const Color(0xFFEDF7EE)),
      if (_days.length > 1) ...[
        const KitHeader('Son günler', Icons.history),
        for (final d in _days.reversed.take(10))
          ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(dmy(d.day)),
            trailing: Text('✓ ${d.successes}   ✕ ${d.accidents}')),
      ],
      KitHeader('Hazır mı? (${_signs.length}/${pottyReadinessSigns.length})', Icons.checklist),
      for (final s in pottyReadinessSigns)
        CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, activeColor: kitMor, value: _signs.contains(s),
          title: Text(s, style: const TextStyle(fontSize: 13.5)),
          onChanged: (_) { setState(() => _signs.contains(s) ? _signs.remove(s) : _signs.add(s)); unawaited(_save()); }),
      if (_signs.length >= 5) const KitNote('Belirtilerin çoğu var; hazır olabilir. Sakin bir dönemde başlamayı deneyebilirsin.', color: Color(0xFFEDF7EE)),
      const KitHeader('İpuçları', Icons.lightbulb_outline),
      const KitBullets(pottyTips),
    ]);
  }
}

/// Bakıcı kartı: bebeği başkasına bırakırken paylaşılacak bilgiler.
class CaregiverCardPage extends StatefulWidget {
  static const storageKey = 'caregiver_card_v1';
  final String childName;
  final DateTime? birth;
  const CaregiverCardPage({super.key, this.childName = '', this.birth});

  @override
  State<CaregiverCardPage> createState() => _CaregiverCardPageState();
}

const caregiverFields = <(String, String, String)>[
  ('name', 'Çocuğun adı', ''),
  ('allergies', 'Alerjiler', 'Yoksa “yok” yaz'),
  ('meds', 'İlaçlar ve dozları (doktorun yazdığı)', ''),
  ('feeding', 'Beslenme', 'Ne, ne zaman, ne kadar; yasak yiyecekler'),
  ('sleep', 'Uyku düzeni', 'Saatler, uyku ritüeli, sırtüstü yatırma'),
  ('soothe', 'Sakinleştirmek için', 'Sevdiği oyuncak, şarkı, yöntem'),
  ('contact1', 'Anne / baba telefonu', ''),
  ('contact2', 'Diğer acil kişi', ''),
  ('doctor', 'Çocuk doktoru / aile hekimi', ''),
  ('address', 'Ev adresi', '112 aranırsa söylenecek'),
  ('notes', 'Diğer notlar', 'Ekran süresi, kurallar, dikkat edilecekler'),
];

class _CaregiverCardPageState extends State<CaregiverCardPage> {
  final _c = <String, TextEditingController>{};
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (!_loading) unawaited(_persist());
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    Map<String, dynamic> raw = {};
    try { raw = await JsonStore.readMap(CaregiverCardPage.storageKey); } catch (_) {}
    for (final (id, _, _) in caregiverFields) {
      final v = raw[id];
      _c[id] = TextEditingController(text: v is String ? v : (id == 'name' ? widget.childName : ''))
        ..addListener(() {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 600), () => unawaited(_persist()));
        });
    }
    if (mounted) setState(() => _loading = false);
  }

  Map<String, String> _values() => {
        for (final e in _c.entries)
          if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
      };

  Future<void> _persist() async {
    try {
      await JsonStore.writeMap(CaregiverCardPage.storageKey, _values());
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  String _render() {
    final v = _values();
    final b = StringBuffer()..writeln(t('BAKICI KARTI'));
    if (widget.birth != null) b.writeln('${t('Doğum tarihi')}: ${dmy(widget.birth!)}');
    for (final (id, label, _) in caregiverFields) {
      if (v[id] != null) b.writeln('${t(label)}: ${v[id]}');
    }
    b..writeln()..writeln(t('Acil durumda 112’yi ara. Zehirlenme şüphesinde 114 Ulusal Zehir Danışma Merkezi.'))
      ..writeln(t('Bebeği her zaman sırtüstü, boş ve düz bir yatakta uyut. Bebeği asla sarsma.'));
    return b.toString();
  }

  Future<void> _share() async {
    final text = _render();
    try {
      await TextShare.share(text, subject: t('Bakıcı kartı'));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) kitSnack(context, 'Paylaşım açılamadı; kart panoya kopyalandı.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote('Bebeğini anneanneye, babaanneye ya da bir bakıcıya bırakırken bilmesi gerekenleri bir kez yaz, istediğin zaman paylaş.'),
      for (final (id, label, hint) in caregiverFields)
        Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(
          key: Key('bakici_$id'), controller: _c[id], minLines: 1, maxLines: id == 'notes' || id == 'feeding' || id == 'sleep' ? 4 : 2,
          keyboardType: id.startsWith('contact') ? TextInputType.phone : TextInputType.multiline,
          decoration: InputDecoration(border: const OutlineInputBorder(), labelText: t(label), hintText: hint.isEmpty ? null : t(hint)))),
      FilledButton.icon(key: const Key('bakici_paylas'), onPressed: _share, icon: const Icon(Icons.share_outlined), label: Text('Kartı paylaş')),
      const KitFootnote('Kart yalnızca bu telefonda şifreli saklanır; sen paylaşmadıkça kimseye gönderilmez.'),
    ]);
  }
}
