import 'dart:async';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';

import 'package:flutter/material.dart' hide Text;

import '../services/local_reminder_notifications.dart';
import '../services/my_health.dart';
import '../services/secure_health_store.dart';
import '../utils/dialog_helpers.dart';
import 'mother_profile_page.dart';
import '../widgets/adaptive.dart';

const _mor = Color(0xFF764A72);
const _pembe = Color(0xFFFFE3F0);

/// "Sağlığım": kadının kendi ölçümleri, ilaç/vitamin planı ve koruyucu kontrolleri.
class MyHealthPage extends StatefulWidget {
  static const storageKey = 'my_health_v1';
  final int initialTab;
  final int? age;
  final DateTime Function()? clock;
  final bool scheduleNotifications;
  const MyHealthPage({super.key, this.initialTab = 0, this.age, this.clock, this.scheduleNotifications = true});

  @override
  State<MyHealthPage> createState() => _MyHealthPageState();
}

class _MyHealthPageState extends State<MyHealthPage> {
  MyHealthData _data = const MyHealthData();
  bool _loading = true;
  int? _age;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    MyHealthData d = const MyHealthData();
    try {
      d = MyHealthData.decode(await SecureHealthStore.read(MyHealthPage.storageKey));
    } catch (_) {}
    final age = widget.age ?? (await MotherProfile.load()).ageAt(_now());
    if (mounted) setState(() { _data = d; _age = age; _loading = false; });
  }

  Future<bool> _save(MyHealthData next) async {
    try {
      await SecureHealthStore.write(MyHealthPage.storageKey, next.encode(_now()));
      if (mounted) setState(() => _data = next);
      return true;
    } catch (_) {
      _snack('Kayıt cihazda saklanamadı. Lütfen tekrar deneyin.');
      return false;
    }
  }

  void _snack(String t, {int seconds = 4}) {
    final m = ScaffoldMessenger.maybeOf(context);
    m?..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(t), duration: Duration(seconds: seconds)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return DefaultTabController(length: 3, initialIndex: widget.initialTab.clamp(0, 2), child: Column(children: [
      const Material(color: Colors.white, child: TabBar(labelColor: _mor, indicatorColor: _mor, tabs: [
        Tab(key: Key('saglik_tab_olcum'), text: 'Ölçümlerim'),
        Tab(key: Key('saglik_tab_ilac'), text: 'İlaç & vitamin'),
        Tab(key: Key('saglik_tab_kontrol'), text: 'Kontrollerim'),
      ])),
      Expanded(child: TabBarView(children: [_measures(), _medicines(), _checkups()])),
    ]));
  }

  // ---------------- Ölçümler ----------------
  Widget _measures() {
    final now = _now();
    final weight = todayValue(_data.entries, 'weight', now) ??
        _data.entries.where((e) => e.kind == 'weight').firstOrNull?.value;
    final b = weight != null && _data.heightCm != null ? bmi(weight, _data.heightCm!) : null;
    return ListView(padding: const EdgeInsets.all(14), children: [
      const Text('Bugün', style: TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 16)),
      const SizedBox(height: 8),
      AdaptiveGrid(minTileWidth: 72, tileHeight: 92, spacing: 8, minColumns: 3, maxColumns: 8, children: [
          for (final k in healthKinds) _kindTile(k, todayValue(_data.entries, k.id, now)),
        ]),
      const SizedBox(height: 6),
      Card(child: ListTile(
        leading: const Text('📏', style: TextStyle(fontSize: 24)),
        title: Text(_data.heightCm == null ? 'Boyunu ekle (vücut kitle indeksi için)'
            : 'Boy: ${_data.heightCm!.toStringAsFixed(0)} cm'),
        subtitle: b == null ? null : Text('Vücut kitle indeksi: ${b.toStringAsFixed(1)} (${bmiLabel(b)}). '
            'Gebelikte ve emzirirken geçerli bir ölçüt değildir.'),
        trailing: const Icon(Icons.edit_outlined),
        onTap: _editHeight)),
      const SizedBox(height: 8),
      const Text('Son kayıtlar', style: TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 16)),
      if (_data.entries.isEmpty) const Padding(padding: EdgeInsets.all(16),
          child: Text('Yukarıdaki kutulardan birine dokunarak ilk ölçümünü ekle.', textAlign: TextAlign.center)),
      for (final e in _data.entries.take(60)) _entryTile(e),
      const Padding(padding: EdgeInsets.all(10), child: Text(
        'Bu kayıtlar kişisel takip içindir; tanı ve tedavi yerine geçmez.',
        style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]);
  }

  Widget _kindTile(HealthKind k, double? today) {
    final goal = k.dailyGoal;
    String value;
    if (today == null) {
      value = '—';
    } else if (k.id == 'mood') {
      value = moodEmoji(today.round());
    } else {
      value = today == today.roundToDouble() ? today.toInt().toString() : today.toStringAsFixed(1);
      if (goal != null) value = '$value/${goal.toInt()}';
    }
    return Material(color: _pembe, borderRadius: BorderRadius.circular(16), child: InkWell(
      key: Key('olcum_${k.id}'),
      borderRadius: BorderRadius.circular(16),
      onTap: () => k.id == 'water' ? _quickWater() : _addEntry(k),
      onLongPress: k.id == 'water' ? () => _addEntry(k) : null,
      child: Padding(padding: const EdgeInsets.all(6), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(k.emoji, style: const TextStyle(fontSize: 22)),
        FittedBox(child: Text(k.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _mor))),
        FittedBox(child: Text(value, style: const TextStyle(fontSize: 13))),
        if (k.id == 'water') const FittedBox(child: Text('+1 için dokun', style: TextStyle(fontSize: 9.5, color: Colors.black54))),
      ])),
    ));
  }

  Future<void> _quickWater() async {
    final e = HealthEntry('water', _now(), 1);
    if (await _save(_data.copyWith(entries: [e, ..._data.entries]))) {
      final t = todayValue(_data.entries, 'water', _now()) ?? 1;
      _snack('💧 Bugün ${t.toInt()} bardak su. Hedef 8 bardak (emziriyorsan daha fazlası).');
    }
  }

  Widget _entryTile(HealthEntry e) {
    final k = kindById(e.kind);
    final w = entryWarning(e, history: _data.entries);
    final d = e.date;
    return Card(color: w != null ? const Color(0xFFFFF0F0) : null, child: ListTile(
      leading: Text(k.emoji, style: const TextStyle(fontSize: 22)),
      title: Text('${k.title}: ${formatEntryValue(e)}'),
      subtitle: Text([
        '${d.day}.${d.month}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}',
        if (e.note.isNotEmpty) e.note,
        if (w != null) '⚠️ $w',
      ].join(' • ')),
      trailing: IconButton(tooltip: t('Sil'), icon: const Icon(Icons.delete_outline),
          onPressed: () => _save(_data.copyWith(entries: _data.entries.where((x) => !identical(x, e)).toList()))),
    ));
  }

  Future<void> _addEntry(HealthKind k) async {
    final v1 = TextEditingController(), v2 = TextEditingController(), note = TextEditingController();
    var mood = 3;
    final result = await showDialogAndDispose<HealthEntry>(context: context, disposables: [v1, v2, note],
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: Text('${k.emoji} ${k.title}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (k.id == 'mood') Wrap(spacing: 6, children: [
            for (var i = 1; i <= 5; i++) ChoiceChip(key: Key('ruh_$i'), label: Text(moodEmoji(i), style: const TextStyle(fontSize: 22)),
              selected: mood == i, onSelected: (_) => update(() => mood = i)),
          ]) else TextField(key: const Key('olcum_deger'), controller: v1,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: k.twoValues ? 'Büyük tansiyon (mmHg)' : '${k.title} (${k.unit})')),
          if (k.twoValues) TextField(key: const Key('olcum_deger2'), controller: v2,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: t('Küçük tansiyon (mmHg)'))),
          TextField(controller: note, maxLength: 200, decoration: InputDecoration(labelText: t('Not (isteğe bağlı)'))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(key: const Key('olcum_kaydet'), onPressed: () {
            double? p(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));
            final a = k.id == 'mood' ? mood.toDouble() : p(v1);
            final b = k.twoValues ? p(v2) : null;
            final err = validateEntry(k.id, a, b);
            if (err != null) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(err)));
              return;
            }
            Navigator.pop(ctx, HealthEntry(k.id, _now(), a!, value2: b, note: note.text.trim()));
          }, child: const Text('Kaydet')),
        ],
      )));
    if (result == null || !mounted) return;
    if (await _save(_data.copyWith(entries: [result, ..._data.entries]))) {
      final w = entryWarning(result, history: _data.entries);
      _snack(w ?? '${k.title} kaydedildi.', seconds: w == null ? 3 : 8);
    }
  }

  Future<void> _editHeight() async {
    final c = TextEditingController(text: _data.heightCm?.toStringAsFixed(0) ?? '');
    final v = await showDialogAndDispose<double>(context: context, disposables: [c], builder: (ctx) => AlertDialog(
      title: const Text('Boy (cm)'),
      content: TextField(key: const Key('boy_deger'), controller: c, keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: t('ör. 165'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () {
          final h = double.tryParse(c.text.trim().replaceAll(',', '.'));
          if (h == null || h < 100 || h > 230) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('100–230 cm arasında girin.')));
            return;
          }
          Navigator.pop(ctx, h);
        }, child: const Text('Kaydet')),
      ]));
    if (v != null) await _save(_data.copyWith(heightCm: v));
  }

  // ---------------- İlaç & vitamin ----------------
  Widget _medicines() {
    final now = _now();
    final active = _data.meds.where((m) => m.active).toList();
    final doses = <(Medication, String)>[for (final m in active) for (final t in m.times) (m, t)]
      ..sort((a, b) => a.$2.compareTo(b.$2));
    final takenToday = doses.where((d) => _data.taken.contains(doseKey(d.$1.id, now, d.$2))).length;
    return ListView(padding: const EdgeInsets.all(14), children: [
      Card(color: _pembe, child: ListTile(
        leading: const Text('💊', style: TextStyle(fontSize: 26)),
        title: Text(doses.isEmpty ? 'Henüz ilaç ya da vitamin eklemedin' : 'Bugün: $takenToday / ${doses.length} doz alındı',
            style: const TextStyle(fontWeight: FontWeight.w700, color: _mor)),
        subtitle: const Text('Folik asit, demir, D vitamini, doğum kontrol hapı, tiroid ilacı… hepsini ekleyebilirsin.'),
      )),
      const SizedBox(height: 6),
      FilledButton.icon(key: const Key('ilac_ekle'), style: FilledButton.styleFrom(backgroundColor: _mor),
          onPressed: () => _editMed(), icon: const Icon(Icons.add), label: const Text('İlaç / vitamin ekle')),
      const SizedBox(height: 10),
      if (doses.isNotEmpty) const Text('Bugünkü dozlar', style: TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 16)),
      for (final (m, t) in doses) Card(child: CheckboxListTile(
        key: Key('doz_${m.id}_$t'),
        value: _data.taken.contains(doseKey(m.id, now, t)),
        title: Text('$t  •  ${m.name}'),
        subtitle: m.dose.isEmpty ? null : Text(m.dose),
        onChanged: (v) {
          final k = doseKey(m.id, now, t);
          final next = {..._data.taken};
          v == true ? next.add(k) : next.remove(k);
          _save(_data.copyWith(taken: next));
        })),
      if (_data.meds.isNotEmpty) ...[
        const SizedBox(height: 10),
        const Text('Tüm ilaçlarım', style: TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 16)),
        for (final m in _data.meds) Card(child: ListTile(
          leading: Icon(m.active ? Icons.medication_rounded : Icons.medication_outlined, color: m.active ? _mor : Colors.grey),
          title: Text(m.name),
          subtitle: Text('${m.dose.isEmpty ? '' : '${m.dose} • '}${m.times.join(', ')}'
              '${m.notify ? ' • 🔔' : ''}${m.active ? '' : ' • durduruldu'}'),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => _editMed(m))),
      ],
      const Padding(padding: EdgeInsets.all(10), child: Text(
        'Doz ve kullanım süresini doktorunun ya da eczacının önerisine göre gir. Uygulama doz önermez. '
        'Gebelikte ve emzirirken her yeni ilaç için doktoruna danış.',
        style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]);
  }

  Future<void> _editMed([Medication? existing]) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final dose = TextEditingController(text: existing?.dose ?? '');
    final times = TextEditingController(text: (existing?.times ?? const ['09:00']).join(', '));
    var notify = existing?.notify ?? false;
    var active = existing?.active ?? true;
    final result = await showDialogAndDispose<Object>(context: context, disposables: [name, dose, times],
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: Text(existing == null ? 'İlaç / vitamin ekle' : 'Düzenle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(key: const Key('ilac_ad'), controller: name, maxLength: 60,
              decoration: InputDecoration(labelText: t('Adı (ör. Folik asit)'))),
          TextField(controller: dose, maxLength: 60,
              decoration: InputDecoration(labelText: t('Miktar (ör. 1 tablet)'))),
          TextField(key: const Key('ilac_saat'), controller: times,
              decoration: InputDecoration(labelText: t('Saat(ler)'), helperText: t('Virgülle ayır: 08:00, 20:00'))),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: notify, title: const Text('Her gün hatırlat'),
              onChanged: (v) => update(() => notify = v)),
          if (existing != null) SwitchListTile(contentPadding: EdgeInsets.zero, value: active,
              title: const Text('Kullanıyorum'), onChanged: (v) => update(() => active = v)),
        ])),
        actions: [
          if (existing != null) TextButton(onPressed: () => Navigator.pop(ctx, 'delete'),
              child: const Text('Sil', style: TextStyle(color: Colors.redAccent))),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(key: const Key('ilac_kaydet'), onPressed: () {
            final list = times.text.split(RegExp(r'[,\s]+')).map((t) => t.trim()).where((t) => t.isNotEmpty)
                .map((t) => t.length == 4 ? '0$t' : t).toList();
            if (name.text.trim().isEmpty || list.isEmpty || !list.every(validTime)) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Ad ve geçerli saat (SS:DD) girin.')));
              return;
            }
            final id = existing?.id ?? 'med_${_now().microsecondsSinceEpoch}';
            Navigator.pop(ctx, Medication(id, name.text.trim(), dose: dose.text.trim(),
                times: (list.toSet().toList()..sort()), notify: notify, active: active));
          }, child: const Text('Kaydet')),
        ],
      )));
    if (result == null || !mounted) return;
    final old = existing;
    List<Medication> meds;
    if (result == 'delete') {
      meds = _data.meds.where((m) => m.id != old!.id).toList();
    } else {
      final m = result as Medication;
      meds = old == null ? [..._data.meds, m] : _data.meds.map((x) => x.id == m.id ? m : x).toList();
    }
    if (!await _save(_data.copyWith(meds: meds))) return;
    if (!widget.scheduleNotifications) return;
    try {
      if (old != null) {
        for (final t in old.times) {
          await LocalReminderNotifications.cancel('ilac_${old.id}_$t');
        }
      }
      if (result is Medication && result.notify && result.active) {
        final granted = await LocalReminderNotifications.requestPermission();
        for (final t in result.times) {
          final p = t.split(':');
          await LocalReminderNotifications.scheduleDaily('ilac_${result.id}_$t',
              '💊 ${result.name}${result.dose.isEmpty ? '' : ' – ${result.dose}'}', int.parse(p[0]), int.parse(p[1]));
        }
        if (!granted) _snack('Hatırlatma için bildirim izni ve Ayarlar > Bildirimler’de hatırlatıcılar açık olmalı.', seconds: 6);
      }
    } catch (_) {
      _snack('Kaydedildi; ancak bildirim planlanamadı.');
    }
  }

  // ---------------- Kontroller ----------------
  Widget _checkups() {
    final now = _now();
    final items = checkups.map((c) => (c, checkupState(c, _data.checks[c.id], _age, now)))
        .where((x) => x.$2 != CheckupState.notApplicable).toList()
      ..sort((a, b) => a.$2.index.compareTo(b.$2.index));
    final due = items.where((x) => x.$2 == CheckupState.due || x.$2 == CheckupState.never).length;
    return ListView(padding: const EdgeInsets.all(14), children: [
      Card(color: _pembe, child: ListTile(
        leading: const Text('🩺', style: TextStyle(fontSize: 26)),
        title: Text(due == 0 ? 'Tüm kontrollerin güncel 🎉' : '$due kontrol zamanı gelmiş ya da hiç kaydedilmemiş',
            style: const TextStyle(fontWeight: FontWeight.w700, color: _mor)),
        subtitle: Text(_age == null
            ? 'Doğum tarihini “Anne profilim”e girersen yaşına uygun kontroller gösterilir.'
            : '$_age yaşına uygun genel tarama önerileri.'),
      )),
      for (final (c, st) in items) Card(child: ListTile(
        key: Key('kontrol_${c.id}'),
        leading: Icon(switch (st) {
          CheckupState.ok => Icons.check_circle_rounded,
          CheckupState.due => Icons.error_outline_rounded,
          _ => Icons.radio_button_unchecked_rounded,
        }, color: st == CheckupState.ok ? Colors.green : st == CheckupState.due ? Colors.deepOrange : _mor),
        title: Text(c.title),
        subtitle: Text('${c.detail}\n${_checkText(c, _data.checks[c.id])}'),
        isThreeLine: true,
        trailing: IconButton(key: Key('kontrol_yap_${c.id}'), tooltip: t('Yaptırdım'), icon: const Icon(Icons.event_available_rounded),
            onPressed: () => _markCheck(c)),
      )),
      const Padding(padding: EdgeInsets.all(10), child: Text(
        'Genel tarama önerileridir. Aile öykün ve kişisel riskine göre doktorun farklı aralık önerebilir.',
        style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]);
  }

  String _checkText(Checkup c, DateTime? last) {
    if (last == null) return 'Henüz kaydedilmedi.';
    final next = addMonths(last, c.intervalMonths);
    String f(DateTime d) => '${d.day}.${d.month}.${d.year}';
    return 'Son: ${f(last)} • Sonraki: ${f(next)}';
  }

  Future<void> _markCheck(Checkup c) async {
    final d = await showDatePicker(context: context, initialDate: _now(), firstDate: DateTime(2000), lastDate: _now(),
        helpText: t('${c.title} tarihi'));
    if (d == null) return;
    await _save(_data.copyWith(checks: {..._data.checks, c.id: d}));
  }
}
