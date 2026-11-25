import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/text.dart';
import '../services/json_store.dart';
import '../services/life_guides.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Annelik ve çalışma hakları (Türkiye).
class MotherRightsPage extends StatefulWidget {
  final VoidCallback? onOpenReminders;
  const MotherRightsPage({super.key, this.onOpenReminders});
  @override
  State<MotherRightsPage> createState() => _MotherRightsPageState();
}

class _MotherRightsPageState extends State<MotherRightsPage> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final sec = rightsSections[_sel];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote('Çalışan anneler için yasal haklar (İş Kanunu’na tabi işçiler esas alınmıştır). Bir başlık seç.'),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (var i = 0; i < rightsSections.length; i++)
          ChoiceChip(key: Key('hak_$i'), label: Text(rightsSections[i].$1), selected: i == _sel,
              onSelected: (_) => setState(() => _sel = i)),
      ]),
      const SizedBox(height: 10),
      PastelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(sec.$1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kitMor)),
        const SizedBox(height: 6),
        KitBullets(sec.$2),
      ])),
      if (widget.onOpenReminders != null)
        OutlinedButton.icon(onPressed: widget.onOpenReminders, icon: const Icon(Icons.event_note_outlined),
            label: Text('Tarihleri hatırlatıcıya ekle')),
      const KitFootnote('Kaynak: 4857 sayılı İş Kanunu (m.13, 74, Ek 2), 7578 sayılı Kanun (Resmî Gazete 1.5.2026), 4447 sayılı Kanun Ek 5, 657 sayılı Kanun m.104. Kasım 2026 itibarıyla; değişebilir. Hukuki danışmanlık değildir; SGK, İŞKUR ya da işvereninin insan kaynaklarına danış.'),
    ]);
  }
}

/// Bebekle seyahat kontrol listesi.
class TravelWithBabyPage extends StatefulWidget {
  static const storageKey = 'travel_checklist_v1';
  const TravelWithBabyPage({super.key});
  @override
  State<TravelWithBabyPage> createState() => _TravelWithBabyPageState();
}

class _TravelWithBabyPageState extends State<TravelWithBabyPage> {
  Set<String> _done = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(TravelWithBabyPage.storageKey); } catch (_) {}
    final valid = travelItems.toSet();
    final d = m['done'];
    if (mounted) {
      setState(() {
        _done = d is List ? d.whereType<String>().where(valid.contains).toSet() : {};
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    try {
      await JsonStore.writeMap(TravelWithBabyPage.storageKey, {'done': _done.toList()});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(child: Row(children: [
        Expanded(child: Text('${_done.length} / ${travelItems.length}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor))),
        TextButton.icon(onPressed: _done.isEmpty ? null : () async {
          final ok = await kitConfirm(context, 'Liste sıfırlansın mı?', 'İşaretlerin kaldırılır; yeni yolculuk için baştan başlarsın.', yes: 'Sıfırla');
          if (!ok) return;
          setState(() => _done.clear());
          await _save();
        }, icon: const Icon(Icons.refresh), label: Text('Yeni yolculuk')),
      ])),
      for (final phase in travelPhases) ...[
        KitHeader(phase.$1, Icons.luggage_outlined),
        for (final item in phase.$2)
          PastelCard(padding: const EdgeInsets.symmetric(horizontal: 4), child: CheckboxListTile(
            value: _done.contains(item), activeColor: kitMor,
            onChanged: (_) {
              setState(() => _done.contains(item) ? _done.remove(item) : _done.add(item));
              unawaited(_save());
            },
            title: Text(item, style: const TextStyle(fontSize: 13.5)),
          )),
      ],
      const KitFootnote('Kaynak: Amerikan Pediatri Akademisi, NHS seyahat önerileri. Uzun yolculuk ya da yurt dışı için çocuk doktoruna danış.'),
    ]);
  }
}

/// Meme kendi muayenesi ve tarama takvimi.
class BreastSelfExamPage extends StatefulWidget {
  final VoidCallback? onOpenCheckups;
  const BreastSelfExamPage({super.key, this.onOpenCheckups});
  @override
  State<BreastSelfExamPage> createState() => _BreastSelfExamPageState();
}

class _BreastSelfExamPageState extends State<BreastSelfExamPage> {
  final _done = <int>{};

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const KitNote(breastExamWhen),
        const KitHeader('Adım adım', Icons.format_list_numbered),
        for (var i = 0; i < breastExamSteps.length; i++)
          PastelCard(padding: const EdgeInsets.symmetric(horizontal: 4), child: CheckboxListTile(
            key: Key('meme_adim_$i'), value: _done.contains(i), activeColor: kitMor,
            onChanged: (_) => setState(() => _done.contains(i) ? _done.remove(i) : _done.add(i)),
            title: Text(breastExamSteps[i], style: const TextStyle(fontSize: 13.5)),
          )),
        const KitHeader('Fark edersen doktora git', Icons.medical_services_outlined),
        const KitBullets(breastExamDoctor),
        const KitHeader('Ücretsiz taramalar', Icons.fact_check_outlined),
        const KitBullets(breastScreening),
        if (widget.onOpenCheckups != null)
          FilledButton.icon(onPressed: widget.onOpenCheckups, icon: const Icon(Icons.alarm_add_outlined),
              label: Text('Kontrollerime ekle ve hatırlat')),
        const KitFootnote('Kaynak: T.C. Sağlık Bakanlığı Ulusal Kanser Tarama Programı ve Meme Kanseri Tarama Standartları.'),
      ]);
}
