import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';

/// Gece ışığı tonları. Sıcak (kırmızı-turuncu) ışık, mavi-beyaz ışığa göre
/// uyku hormonu melatonini daha az baskılar; gece emzirme ve bez değişiminde
/// bebeği tam uyandırmadan görmeyi kolaylaştırır.
const nightLightColors = <(String, Color)>[
  ('Kırmızı', Color(0xFFB71C1C)),
  ('Kehribar', Color(0xFFE65100)),
  ('Sıcak sarı', Color(0xFFF9A825)),
];

/// Tam ekran, loş gece ışığı. Ekrana dokunmak parlaklığı değiştirir;
/// uzun basmak ya da geri tuşu çıkar.
class NightLightPage extends StatefulWidget {
  const NightLightPage({super.key});

  @override
  State<NightLightPage> createState() => _NightLightPageState();
}

class _NightLightPageState extends State<NightLightPage> {
  int _color = 0;
  // Görece parlaklık seviyeleri; en düşük seviye karanlık odada göz almaz.
  static const _levels = [0.25, 0.45, 0.7, 1.0];
  int _level = 1;
  bool _hint = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = nightLightColors[_color].$2;
    final color = Color.lerp(Colors.black, base, _levels[_level])!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        key: const Key('gece_isigi'),
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() { _level = (_level + 1) % _levels.length; _hint = false; }),
        onLongPress: () => Navigator.maybePop(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: color,
          child: SafeArea(child: Stack(children: [
            Positioned(top: 8, left: 8, child: IconButton(
              tooltip: t('Kapat'), color: Colors.black54, icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.maybePop(context))),
            Positioned(bottom: 24, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < nightLightColors.length; i++)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Semantics(
                  button: true, selected: i == _color, label: t(nightLightColors[i].$1),
                  child: GestureDetector(
                    key: Key('gece_renk_$i'),
                    onTap: () => setState(() { _color = i; _hint = false; }),
                    child: Container(width: 40, height: 40, decoration: BoxDecoration(
                      color: Color.lerp(Colors.black, nightLightColors[i].$2, 0.6), shape: BoxShape.circle,
                      border: Border.all(color: i == _color ? Colors.black54 : Colors.transparent, width: 3)))))),
            ])),
            if (_hint) const Center(child: Padding(padding: EdgeInsets.all(32), child: Text(
              'Parlaklık için ekrana dokun; çıkmak için uzun bas.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 15)))),
          ])),
        ),
      ),
    );
  }
}
