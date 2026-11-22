import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/json_store.dart';
import '../services/more_guides.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

const _green = Color(0xFF2E8B57);
const _orange = Color(0xFFE08A00);
const _blue = Color(0xFF3B6FB6);

Widget _box(String title, IconData icon, Color color, List<String> items, {bool numbered = false}) => PastelCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color))),
        ]),
        const SizedBox(height: 6),
        if (numbered)
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 22, child: Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor))),
                Expanded(child: Text(items[i], style: const TextStyle(fontSize: 13))),
              ]),
            )
        else
          KitBullets(items),
      ]),
    );

Widget _chips(List<String> labels, int sel, ValueChanged<int> onSel, String keyPrefix) => Wrap(spacing: 6, runSpacing: 6, children: [
      for (var i = 0; i < labels.length; i++)
        ChoiceChip(key: Key('${keyPrefix}_$i'), label: Text(labels[i]), selected: i == sel, onSelected: (_) => onSel(i)),
    ]);

/// Bebek bakımı nasıl yapılır: banyo, göbek, tırnak, bez, gaz, kundak…
class BabyCareHowToPage extends StatefulWidget {
  const BabyCareHowToPage({super.key});
  @override
  State<BabyCareHowToPage> createState() => _BabyCareHowToPageState();
}

class _BabyCareHowToPageState extends State<BabyCareHowToPage> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final h = babyCareHowTos[_sel];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote('Bir konu seç; adım adım nasıl yapılacağını ve dikkat edilecekleri gör.'),
      _chips([for (final x in babyCareHowTos) x.name], _sel, (i) => setState(() => _sel = i), 'bakim'),
      const SizedBox(height: 10),
      Text(h.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kitMor)),
      const SizedBox(height: 4),
      Text(h.intro, style: const TextStyle(fontSize: 13.5)),
      const SizedBox(height: 8),
      if (h.steps.isNotEmpty) _box('Adım adım', Icons.format_list_numbered, _green, h.steps, numbered: true),
      if (h.cautions.isNotEmpty) _box('Dikkat', Icons.error_outline, _orange, h.cautions),
      if (h.doctor.isNotEmpty) _box('Doktora göster', Icons.medical_services_outlined, const Color(0xFFD32F2F), h.doctor),
      const KitFootnote('Kaynak: Amerikan Pediatri Akademisi (HealthyChildren), NHS, Dünya Sağlık Örgütü yenidoğan bakımı önerileri.'),
    ]);
  }
}

/// Konuşma ve dil gelişimi.
class SpeechDevelopmentPage extends StatefulWidget {
  final DateTime? birth;
  const SpeechDevelopmentPage({super.key, this.birth});
  @override
  State<SpeechDevelopmentPage> createState() => _SpeechDevelopmentPageState();
}

class _SpeechDevelopmentPageState extends State<SpeechDevelopmentPage> {
  int? _ageIndex;
  late int _sel;

  @override
  void initState() {
    super.initState();
    final m = ageInMonths(widget.birth, DateTime.now());
    if (m != null) _ageIndex = speechStages.indexOf(speechStageFor(m));
    _sel = _ageIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final s = speechStages[_sel];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote('Yaş aralığını seç: bu dönemde neler beklenir, dil gelişimini nasıl desteklersin ve ne zaman uzmana danışmalısın.'),
      _chips([for (final x in speechStages) x.label], _sel, (i) => setState(() => _sel = i), 'dil'),
      const SizedBox(height: 10),
      Text(_sel == _ageIndex ? '${t(s.label)} · ${t('Bebeğinin yaşı')}' : s.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kitMor)),
      const SizedBox(height: 6),
      _box('Bu dönemde neler yapar?', Icons.record_voice_over_outlined, _blue, s.expect),
      _box('Nasıl desteklersin?', Icons.favorite_border, _green, s.support),
      _box('Uzmana danış', Icons.hearing_outlined, _orange, s.flags),
      const KitHeader('Her yaşta', Icons.info_outline),
      const KitBullets(speechGeneralNotes),
      const KitFootnote('Kaynak: ABD Hastalık Kontrol Merkezi (CDC) gelişim basamakları 2022, Amerikan Konuşma-Dil-İşitme Derneği (ASHA).'),
    ]);
  }
}

/// Doğum sonrası korunma yöntemleri.
class PostpartumContraceptionPage extends StatefulWidget {
  const PostpartumContraceptionPage({super.key});
  @override
  State<PostpartumContraceptionPage> createState() => _PostpartumContraceptionPageState();
}

class _PostpartumContraceptionPageState extends State<PostpartumContraceptionPage> {
  bool _bf = true;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const KitBullets(contraIntro),
        PastelSegmentTabs(labels: const ['Emziriyorum', 'Emzirmiyorum'], selected: _bf ? 0 : 1, onChanged: (i) => setState(() => _bf = i == 0)),
        const SizedBox(height: 10),
        for (final m in contraMethods)
          PastelCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name, style: const TextStyle(fontWeight: FontWeight.w900, color: kitMor)),
              const SizedBox(height: 2),
              Text('${t('Etkinlik')}: ${t(m.effectiveness)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _blue)),
              const SizedBox(height: 4),
              Text('${t('Ne zaman başlanır?')} ${t(_bf ? m.breastfeeding : m.notBreastfeeding)}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 2),
              Text(m.note, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B5B6B))),
            ]),
          ),
        const KitNote('Sana en uygun yöntemi sağlık durumuna göre doktorun ya da ebenle birlikte seçin. Doğum sonrası kontrolde bunu konuşmak için Soru defterine not alabilirsin.'),
        const KitFootnote('Kaynak: Dünya Sağlık Örgütü Kontrasepsiyon Uygunluk Kriterleri (MEC), ABD CDC US MEC, NHS.'),
      ]);
}
