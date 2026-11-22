import 'visuals.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import 'pastel_design.dart';

/// Paket 39 referans tasarımı: Ana Sayfa • Bebeğim • (+) • Tarifler • Profil.
///
/// [selected] -1 olduğunda (ör. Alışveriş veya Kadınlar ekranı açıkken)
/// hiçbir sekme vurgulanmaz.
class PastelBottomBar extends StatelessWidget {
  const PastelBottomBar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onAdd,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  static const items = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home_rounded, 'Ana Sayfa'),
    (Icons.child_care_outlined, Icons.child_care_rounded, 'Bebek'),
    (Icons.pregnant_woman_outlined, Icons.pregnant_woman_rounded, 'Anne'),
    (Icons.local_florist_outlined, Icons.local_florist_rounded, 'Kadınlar'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget tab(int i) {
      final (icon, activeIcon, label) = items[i];
      final active = selected == i;
      final color = active ? PastelPalette.primary : PastelPalette.text;
      return Expanded(
        child: Semantics(
          button: true,
          selected: active,
          label: label,
          child: InkResponse(
            onTap: () => onSelect(i),
            radius: 36,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(active ? activeIcon : icon, color: color, size: 26),
                const SizedBox(height: 3),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11.5,
                        color: color,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
              ]),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: PastelPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x1FE94791), blurRadius: 18, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(children: [
            tab(0),
            tab(1),
            Expanded(
              child: Center(
                child: Tooltip(
                  message: t('Hızlı kayıt ekle'),
                  child: Material(
                    color: PastelPalette.primary,
                    shape: const CircleBorder(),
                    elevation: 6,
                    shadowColor: const Color(0x66E94791),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAdd,
                      child: const SizedBox(
                        width: 58,
                        height: 58,
                        child: Icon(Icons.add_rounded, color: Colors.white, size: 34),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            tab(2),
            tab(3),
          ]),
        ),
      ),
    );
  }
}

/// Ekran başlığı: pembe simge + kalın başlık (referanstaki üst çubuk).
class PastelTitle extends StatelessWidget {
  const PastelTitle({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: PastelPalette.primary, size: 24),
        const SizedBox(width: 8),
        // Geri tuşu ve eylemlerle dar kalan çubukta kesilmek yerine küçülür.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(title,
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, color: PastelPalette.primary)),
          ),
        ),
      ]);
}

/// Ana sayfadaki iki sütunlu modül kartı (simge + başlık + alt başlık).
class PastelModuleTile extends StatelessWidget {
  const PastelModuleTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: PastelPalette.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 1.5,
        shadowColor: const Color(0x22E94791),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 11, 8, 11),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: IconGlyph(icon, size: 26),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Dar ekranlarda kesilmek yerine hafifçe küçülür.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(title,
                        maxLines: 1,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: PastelPalette.text, fontSize: 13.5)),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

/// Ana sayfanın üstündeki karşılama kartı.
class PastelGreetingCard extends StatelessWidget {
  const PastelGreetingCard({super.key, required this.greeting, required this.subtitle});

  final String greeting;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE3F0), Color(0xFFF3E6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(greeting,
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFFB0306E))),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: PastelPalette.text)),
            ]),
          ),
          const MotherBabyArt(width: 120, height: 104),
        ]),
      );
}
