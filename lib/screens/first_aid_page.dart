import 'package:flutter/material.dart' hide Text;

import '../data/first_aid.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// İlk yardım: tek dokunuşla 112 / 114 ve adım adım kartlar (internetsiz).
class FirstAidPage extends StatelessWidget {
  final String? openId;
  const FirstAidPage({super.key, this.openId});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const KitCallButton('112', 'Acil yardım'),
        const KitCallButton('114', 'Zehir Danışma Merkezi', color: Color(0xFFE08A00)),
        const KitNote(firstAidIntro, color: Color(0xFFFFF1E6)),
        for (final c in firstAidCards)
          PastelCard(padding: EdgeInsets.zero, child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: Key('ilkyardim_${c.id}'),
              initiallyExpanded: c.id == openId,
              leading: const Icon(Icons.medical_services_outlined, color: Color(0xFFD32F2F)),
              title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFFE6E6), borderRadius: BorderRadius.circular(12)),
                  child: Text(c.when, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < c.steps.length; i++)
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(radius: 11, backgroundColor: kitMor,
                        child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: Colors.white))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(c.steps[i], style: const TextStyle(fontSize: 13.5))),
                  ])),
                if (c.dont.isNotEmpty) ...[
                  Text('Yapma', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD32F2F))),
                  for (final d in c.dont) Text('✕ ${t(d)}', style: const TextStyle(fontSize: 13)),
                ],
                if (c.call != null) Padding(padding: const EdgeInsets.only(top: 8),
                    child: KitCallButton(c.call!, c.call == '114' ? 'Zehir Danışma Merkezi' : 'Acil yardım',
                        color: c.call == '114' ? const Color(0xFFE08A00) : const Color(0xFFD32F2F))),
              ],
            ),
          )),
        const KitFootnote('Kaynak: Avrupa Resüsitasyon Konseyi (ERC 2021) çocuk temel yaşam desteği, Amerikan Kalp Derneği, Türkiye Ulusal Zehir Danışma Merkezi. Kurs eğitiminin yerini tutmaz.'),
      ]);
}
