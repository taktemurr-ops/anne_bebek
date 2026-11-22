import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/json_store.dart';
import '../services/mood_screening.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Doğum sonrası ruh hali öz değerlendirmesi (EPDS) ve destek yönlendirmesi.
class MoodCheckPage extends StatefulWidget {
  static const storageKey = 'mood_screening_v1';
  const MoodCheckPage({super.key});

  @override
  State<MoodCheckPage> createState() => _MoodCheckPageState();
}

class _MoodCheckPageState extends State<MoodCheckPage> {
  List<EpdsResult> _history = [];
  bool _loading = true;
  List<int?>? _answers; // test sürerken dolu
  int _q = 0;
  EpdsResult? _result;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(MoodCheckPage.storageKey); } catch (_) {}
    if (!mounted) return;
    setState(() { _history = decodeEpdsHistory(all['history']); _loading = false; });
  }

  Future<void> _finish() async {
    final r = scoreEpds(_answers!.cast<int>(), DateTime.now());
    final next = [r, ..._history].take(50).toList();
    try {
      await JsonStore.writeMap(MoodCheckPage.storageKey, {'history': next.map((e) => e.toJson()).toList()});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
    if (mounted) setState(() { _history = next; _result = r; _answers = null; });
  }

  Widget _support({required bool urgent}) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (urgent) const KitNote(
          'Kendine zarar verme düşünceleri ciddiye alınmalı ve bunlar için yardım almak çok önemli. '
          'Şu an kendini güvende hissetmiyorsan hemen 112’yi ara ya da en yakın acil servise git. '
          'Yalnız kalma; şimdi güvendiğin birini ara ve yanına gelmesini iste.',
          title: 'Şimdi destek al', color: Color(0xFFFFE6E6)),
        const KitCallButton('112', 'Acil yardım'),
        const KitCallButton('183', 'ALO 183 Sosyal Destek Hattı (Türkiye)', color: kitMor),
      ]);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_answers != null) return _question();
    final r = _result;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      if (r != null) ...[
        PastelCard(color: const Color(0xFFFFF4FA), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sonucun: ${r.score} / 30', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kitMor)),
          const SizedBox(height: 6),
          Text(epdsBandText(r.band), style: const TextStyle(fontSize: 13.5)),
        ])),
        if (r.selfHarm || r.band == EpdsBand.likely) _support(urgent: r.selfHarm),
      ] else const KitNote(
        'Son 7 günde nasıl hissettiğini 10 kısa soruyla değerlendir. Bu bir tarama testidir, tanı koymaz; '
        'sonuç ne olursa olsun nasıl hissettiğini doktorunla konuşabilirsin. Gebelikte de kullanılabilir.',
        title: 'Ruh halim nasıl?'),
      FilledButton.icon(key: const Key('epds_basla'), onPressed: () => setState(() {
        _answers = List<int?>.filled(epdsItems.length, null);
        _q = 0;
        _result = null;
      }), icon: const Icon(Icons.play_arrow_rounded), label: Text(r == null ? 'Teste başla' : 'Testi yeniden yap')),
      const KitHeader('Bilmen gerekenler', Icons.favorite_outline),
      const KitBullets(moodSupportTips),
      if (r == null || !(r.selfHarm || r.band == EpdsBand.likely)) ...[
        const KitHeader('Yardım hatları', Icons.support_agent),
        _support(urgent: false),
      ],
      if (_history.isNotEmpty) ...[
        const KitHeader('Geçmiş sonuçlarım', Icons.history),
        for (final h in _history.take(12))
          ListTile(dense: true, contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.circle, size: 12, color: h.band == EpdsBand.low ? const Color(0xFF2E8B57)
                : h.band == EpdsBand.possible ? const Color(0xFFE08A00) : Colors.red),
            title: Text(dmy(h.date)), trailing: Text('${h.score} / 30')),
      ],
      const KitFootnote('Edinburgh Doğum Sonrası Depresyon Ölçeği (Cox, Holden ve Sagovsky, 1987). Yanıtlar yalnızca bu telefonda, şifreli saklanır; yalnızca puan kaydedilir.'),
    ]);
  }

  Widget _question() {
    final item = epdsItems[_q];
    final answers = _answers!;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      LinearProgressIndicator(value: (_q + 1) / epdsItems.length, color: kitMor, backgroundColor: const Color(0xFFF1E6F0)),
      const SizedBox(height: 8),
      Text('${t('Soru')} ${_q + 1} / ${epdsItems.length}', style: const TextStyle(color: Colors.black54)),
      Text('Son 7 günde…', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
      const SizedBox(height: 8),
      Text(item.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kitMor)),
      const SizedBox(height: 12),
      for (var i = 0; i < item.options.length; i++)
        PastelCard(
          color: answers[_q] == i ? const Color(0xFFF6E3F2) : const Color(0xFFFFFFFF),
          onTap: () => setState(() => answers[_q] = i),
          child: Row(children: [
            Icon(answers[_q] == i ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: kitMor),
            const SizedBox(width: 10),
            Expanded(child: Text(item.options[i].text, key: Key('epds_${_q}_$i'))),
          ])),
      const SizedBox(height: 8),
      Row(children: [
        if (_q > 0) TextButton(onPressed: () => setState(() => _q--), child: Text('Geri')),
        const Spacer(),
        TextButton(onPressed: () => setState(() => _answers = null), child: Text('Vazgeç')),
        FilledButton(key: const Key('epds_ileri'), onPressed: answers[_q] == null ? null : () {
          if (_q < epdsItems.length - 1) { setState(() => _q++); } else { _finish(); }
        }, child: Text(_q < epdsItems.length - 1 ? 'İleri' : 'Sonucu gör')),
      ]),
    ]);
  }
}
