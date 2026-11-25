import 'package:flutter/material.dart' hide Text;
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/baby_activity_catalog.dart';

class BabyActivityCatalogPage extends StatefulWidget {
  const BabyActivityCatalogPage({super.key});
  @override
  State<BabyActivityCatalogPage> createState() => _BabyActivityCatalogPageState();
}

class _BabyActivityCatalogPageState extends State<BabyActivityCatalogPage> {
  int _band = 0;
  String _query = '';
  String _area = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final ages = BabyActivityCatalog.ageBands;
    final areas = ['Tümü', ...BabyActivityCatalog.all.map((e) => e.area).toSet().toList()..sort()];
    final filtered = BabyActivityCatalog.all.where((a) =>
      a.minMonth == ages[_band].$1 && (_area == 'Tümü' || a.area == _area) &&
      ('${a.title} ${a.materials} ${a.area}'.toLowerCase().contains(_query.toLowerCase()))).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Bebek oyun ve aktiviteleri')),
      // Filtreler listeyle birlikte kayar; kısa ve yatay ekranlarda taşmaz.
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t('${BabyActivityCatalog.baseCount} temel etkinlik ${ages.length} yaş dönemine uyarlanmıştır; ayrıca ${BabyActivityCatalog.targetedCount} etkinlik yalnızca belirli yaşlar için yazılmıştır. Her etkinlik her yaşta uygun olmayabilir; açıklamaları okuyun.')),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(isExpanded: true, initialValue: _band, decoration: InputDecoration(labelText: t('Yaş aralığı (ay)'), border: OutlineInputBorder()),
            items: [for (var i = 0; i < ages.length; i++) DropdownMenuItem(value: i, child: Text('${ages[i].$1}–${ages[i].$2} ay'))],
            onChanged: (value) => setState(() => _band = value ?? 0)),
          const SizedBox(height: 8),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: t('Etkinlik veya malzeme ara'), border: OutlineInputBorder()), onChanged: (value) => setState(() => _query = value.trim())),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(isExpanded: true, initialValue: _area, decoration: InputDecoration(labelText: t('Gelişim alanı'), border: OutlineInputBorder()),
            items: areas.map((area) => DropdownMenuItem(value: area, child: Text(area))).toList(), onChanged: (value) => setState(() => _area = value ?? 'Tümü')),
          const SizedBox(height: 8),
          Text('${filtered.length} etkinlik gösteriliyor', style: Theme.of(context).textTheme.labelLarge),
        ]))),
        SliverList.builder(itemCount: filtered.length, itemBuilder: (context, index) {
          final activity = filtered[index];
          return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: ListTile(
            title: Text(activity.title), subtitle: Text('${activity.area} • ${activity.minutes} dk • ${activity.materials}'),
            trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => Scaffold(
              appBar: AppBar(title: Text(activity.title)), body: ListView(padding: const EdgeInsets.all(20), children: [
                Text('${activity.minMonth}–${activity.maxMonth} ay • ${activity.area} • ${activity.minutes} dakika', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16), const Text('Malzemeler', style: TextStyle(fontWeight: FontWeight.bold)), Text(activity.materials),
                const SizedBox(height: 16), const Text('Uygulama', style: TextStyle(fontWeight: FontWeight.bold)), Text(activity.steps),
                const SizedBox(height: 16), const Text('Güvenlik', style: TextStyle(fontWeight: FontWeight.bold)), Text(activity.safety),
                const SizedBox(height: 16), const Text('Bu öneriler tıbbi gelişim testi değildir. Çocuğun becerisine, ilgisine ve güvenliğine göre uyarlayın.'),
              ]),
            )))),
          );
        }),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ]),
    );
  }
}
