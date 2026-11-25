import 'package:flutter/material.dart' hide Text;

import '../i18n/text.dart';
import '../services/care_guides.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

const _green = Color(0xFF2E8B57);
const _orange = Color(0xFFE08A00);
const _red = Color(0xFFD32F2F);

Widget _section(String title, IconData icon, Color color, List<String> items) => PastelCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color))),
        ]),
        const SizedBox(height: 6),
        KitBullets(items),
      ]),
    );

/// Belirtiye göre evde bakım, doktor ve acil ayrımı yapan ortak rehber.
class CareTopicGuide extends StatefulWidget {
  final List<CareTopic> topics;
  final String intro;
  final String footnote;
  const CareTopicGuide({super.key, required this.topics, required this.intro, required this.footnote});
  @override
  State<CareTopicGuide> createState() => _CareTopicGuideState();
}

class _CareTopicGuideState extends State<CareTopicGuide> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final c = widget.topics[_sel];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      KitNote(widget.intro),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (var i = 0; i < widget.topics.length; i++)
          ChoiceChip(
            key: Key('konu_$i'),
            label: Text(widget.topics[i].name),
            selected: i == _sel,
            onSelected: (_) => setState(() => _sel = i),
          ),
      ]),
      const SizedBox(height: 10),
      Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kitMor)),
      const SizedBox(height: 4),
      Text(c.intro, style: const TextStyle(fontSize: 13.5)),
      const SizedBox(height: 8),
      if (c.home.isNotEmpty) _section('Evde yapabileceklerin', Icons.home_outlined, _green, c.home),
      if (c.doctor.isNotEmpty) _section('Doktoruna başvur', Icons.medical_services_outlined, _orange, c.doctor),
      if (c.urgent.isNotEmpty) ...[
        _section('Hemen acile git ya da 112’yi ara', Icons.warning_amber_rounded, _red, c.urgent),
        const KitCallButton('112', 'Acil yardım'),
      ],
      KitFootnote(widget.footnote),
    ]);
  }
}

/// Hasta bebek: ne zaman doktora?
class SickBabyGuidePage extends StatelessWidget {
  const SickBabyGuidePage({super.key});
  @override
  Widget build(BuildContext context) => const CareTopicGuide(
        topics: sickBabyTopics,
        intro: 'Bir belirti seç: evde neler yapabileceğini, ne zaman doktora ve ne zaman acile gitmen gerektiğini gör. İçgüdün bir şeylerin yolunda olmadığını söylüyorsa beklemeden başvur.',
        footnote: 'Kaynak: NHS, Amerikan Pediatri Akademisi, Dünya Sağlık Örgütü. Bu rehber muayenenin yerini tutmaz.',
      );
}

/// Emzirme sorunları ve çözümleri.
class BreastfeedingHelpPage extends StatelessWidget {
  const BreastfeedingHelpPage({super.key});
  @override
  Widget build(BuildContext context) => const CareTopicGuide(
        topics: breastfeedingTopics,
        intro: 'Emzirmede yaşadığın sorunu seç. Çoğu sorun kavrama ve sık emzirmeyle düzelir; zorlanırsan bir ebeden ya da emzirme danışmanından destek almak çok işe yarar.',
        footnote: 'Kaynak: Dünya Sağlık Örgütü, UNICEF Bebek Dostu girişimi, Emzirme Tıbbı Akademisi (ABM) protokolleri.',
      );
}

/// Bez ve kaka rengi rehberi.
class StoolGuidePage extends StatefulWidget {
  const StoolGuidePage({super.key});
  @override
  State<StoolGuidePage> createState() => _StoolGuidePageState();
}

class _StoolGuidePageState extends State<StoolGuidePage> {
  int _day = 0;

  Color _levelColor(int l) => l == 0 ? _green : l == 1 ? _orange : _red;

  @override
  Widget build(BuildContext context) {
    final d = diaperByDay[_day];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote('Kakanın rengi ve kıvamı bebeğin beslenmesine göre değişir. Çoğu renk normaldir; beyaz, gri ya da siyah kaka ise aynı gün doktora gösterilmelidir.'),
      const KitHeader('Kaka rengi', Icons.palette_outlined),
      for (final s in stoolColors)
        PastelCard(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(color: Color(s.color), shape: BoxShape.circle, border: Border.all(color: const Color(0x33000000))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
              Text(stoolLevelLabel(s.level), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: _levelColor(s.level))),
              Text(s.note, style: const TextStyle(fontSize: 12.5)),
            ])),
          ]),
        ),
      const KitHeader('İlk günlerde bez sayısı', Icons.child_care_outlined),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (var i = 0; i < diaperByDay.length; i++)
          ChoiceChip(
            key: Key('bez_gun_$i'),
            label: Text(diaperByDay[i].$1),
            selected: i == _day,
            onSelected: (_) => setState(() => _day = i),
          ),
      ]),
      const SizedBox(height: 8),
      PastelCard(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w900, color: kitMor)),
          Text(d.$2, style: const TextStyle(fontSize: 13.5)),
          Text(d.$3, style: const TextStyle(fontSize: 13.5)),
        ]),
      ),
      const KitNote('Sayılar anne sütü alan bebek içindir. Bez sayısı azalıyorsa ya da bebek kilo almıyorsa doktoruna danış.'),
      _section('Sıvı kaybı belirtileri: hemen doktora', Icons.water_drop_outlined, _red, dehydrationSigns),
      const KitFootnote('Kaynak: NHS, UNICEF Bebek Dostu girişimi, La Leche League bez rehberleri.'),
    ]);
  }
}

/// Gebelik ve doğum sonrası acil belirtiler.
class PregnancyWarningSignsPage extends StatefulWidget {
  final bool postpartum;
  const PregnancyWarningSignsPage({super.key, this.postpartum = false});
  @override
  State<PregnancyWarningSignsPage> createState() => _PregnancyWarningSignsPageState();
}

class _PregnancyWarningSignsPageState extends State<PregnancyWarningSignsPage> {
  late bool _pp = widget.postpartum;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        PastelSegmentTabs(labels: const ['Gebelikte', 'Doğum sonrası'], selected: _pp ? 1 : 0, onChanged: (i) => setState(() => _pp = i == 1)),
        const SizedBox(height: 10),
        const KitNote('Bu belirtiler beklemekle geçmez. Emin değilsen aramak her zaman doğru karardır.'),
        _section('Hemen acile git ya da 112’yi ara', Icons.warning_amber_rounded, _red, _pp ? postpartumUrgentSigns : pregnancyUrgentSigns),
        const KitCallButton('112', 'Acil yardım'),
        _section('Aynı gün doktoruna ulaş', Icons.medical_services_outlined, _orange, _pp ? postpartumSameDaySigns : pregnancySameDaySigns),
        if (!_pp) const KitNote('Bebeğinin hareketlerini her gün hisset. Olağan düzeni değişirse yarını bekleme; tekme sayacıyla da izleyebilirsin.'),
        const KitFootnote('Kaynak: Dünya Sağlık Örgütü, NHS, ACOG ve AWHONN POST-BIRTH uyarı işaretleri.'),
      ]);
}

/// Güvenli mama hazırlama.
class FormulaPrepPage extends StatefulWidget {
  const FormulaPrepPage({super.key});
  @override
  State<FormulaPrepPage> createState() => _FormulaPrepPageState();
}

class _FormulaPrepPageState extends State<FormulaPrepPage> {
  final _done = <int>{};

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const KitNote('Hazırlarken adımları işaretleyebilirsin. Toz mama steril değildir; kaynamış sıcak suyla hazırlamak bebeği mikroplardan korur.'),
        const KitHeader('Adım adım hazırlama', Icons.checklist_outlined),
        for (var i = 0; i < formulaSteps.length; i++)
          PastelCard(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CheckboxListTile(
              key: Key('mama_adim_$i'),
              value: _done.contains(i),
              activeColor: kitMor,
              onChanged: (_) => setState(() => _done.contains(i) ? _done.remove(i) : _done.add(i)),
              title: Text(formulaSteps[i], style: const TextStyle(fontSize: 13.5)),
            ),
          ),
        if (_done.isNotEmpty)
          TextButton.icon(onPressed: () => setState(_done.clear), icon: const Icon(Icons.refresh), label: Text('Yeni biberon için sıfırla')),
        _section('Yapma', Icons.block, _red, formulaDonts),
        _section('Saklama', Icons.kitchen_outlined, _orange, formulaStorage),
        _section('Beslerken', Icons.favorite_border, _green, formulaFeedingTips),
        const KitFootnote('Kaynak: Dünya Sağlık Örgütü “Bebek mamasının güvenli hazırlanması, saklanması ve kullanımı” rehberi, NHS.'),
      ]);
}
