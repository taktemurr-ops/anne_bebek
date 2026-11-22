import 'package:flutter/material.dart' hide Text;
import '../i18n/text.dart';
import '../widgets/ui.dart';
import 'module_hub_page.dart';
import '../widgets/adaptive.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> navigate;
  const HomeScreen({super.key, required this.navigate});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFF7D6E8), Color(0xFFE8D9FF)])),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Merhaba Anne! 💕', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: purple)),
        SizedBox(height: 10),
        Text('Anne, bebek ve kadın yaşamına dair her şey tek yerde.', style: TextStyle(color: purple)),
      ]),
    ),
    sectionTitle('Neler yapmak istersin?'),
    Card(child: ListTile(leading: const Icon(Icons.apps, color: purple),
      title: const Text('Tüm modüller'), subtitle: const Text('Ekranlara tek yerden ulaş'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ModuleHubPage())))),
    AdaptiveGrid(minTileWidth: 150, tileHeight: 140, spacing: 12, minColumns: 2, maxColumns: 4,
      children: [
        categoryCard('Bebek Gelişimi', Icons.child_care, const Color(0xFFFFE1ED), () => navigate(1)),
        categoryCard('Bugün Ne Pişirsem?', Icons.restaurant, const Color(0xFFFFEBCF), () => navigate(2)),
        categoryCard('Alışveriş', Icons.shopping_bag, const Color(0xFFE1DFFF), () => navigate(3)),
        categoryCard('Kadın Sağlığı', Icons.favorite, const Color(0xFFFFDCE5), () => navigate(4)),
      ],
    ),
    sectionTitle('Bugünün Önerisi ✨'),
    const Card(child: ListTile(leading: Icon(Icons.lightbulb_outline, color: purple), title: Text('Bebeğinin gelişim yolculuğunu birlikte takip edelim.'))),
    sectionTitle('A’dan Z’ye rehber'),
    const Card(child: ListTile(leading: Icon(Icons.menu_book_outlined, color: purple), title: Text('Beslenme, uyku, gelişim ve ebeveynlik'), subtitle: Text('Beslenme, uyku ve gelişim konularında genel bilgilendirme içerikleri.'))),
  ]);
}
