import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/app_store.dart';
import '../widgets/ui.dart';
import 'baby_health_page.dart';
import 'child_profiles_page.dart';
import 'child_growth_trends_page.dart';
import 'child_journal_page.dart';
import 'module_hub_page.dart';

class BabyScreen extends StatelessWidget {
  final AppStore store;
  const BabyScreen({super.key, required this.store});

  Future<void> editBaby(BuildContext context) async {
    final name = await askText(context, 'Bebeğinin adı', hint: store.baby?.name ?? 'Örn. Deniz');
    if (!context.mounted || name == null || name.isEmpty) return;
    final date = await showDatePicker(
      context: context, firstDate: DateTime(2010), lastDate: DateTime.now(),
      initialDate: store.baby?.birthDate ?? DateTime.now(), helpText: 'Doğum tarihi',
    );
    if (date == null || !context.mounted) return;
    await store.saveBaby(BabyProfile(name: name, birthDate: date));
  }

  Future<void> addRecord(BuildContext context, String category) async {
    final note = await askText(context, '$category kaydı', hint: 'Açıklama veya miktar');
    if (note == null || note.isEmpty) return;
    await store.addEntry(category, note);
  }

  @override
  Widget build(BuildContext context) {
    const categories = <(String, IconData)>[
      ('Beslenme', Icons.restaurant), ('Uyku', Icons.bedtime_outlined),
      ('Bez', Icons.baby_changing_station), ('Boy / Kilo', Icons.monitor_weight_outlined),
      ('Not', Icons.note_add_outlined),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(onPressed: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const ModuleHubPage())),
          icon: const Icon(Icons.apps_outlined), label: const Text('Tüm modüller')),
        OutlinedButton.icon(onPressed: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const ChildProfilesPage())),
          icon: const Icon(Icons.people_outline), label: const Text('Çocuk profilleri')),
        OutlinedButton.icon(onPressed: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const BabyHealthPage())),
          icon: const Icon(Icons.monitor_heart_outlined), label: const Text('Bebek sağlığı')),
        OutlinedButton.icon(onPressed: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const ChildGrowthTrendsPage())),
          icon: const Icon(Icons.show_chart), label: const Text('Büyüme trendleri')),
        OutlinedButton.icon(onPressed: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const ChildJournalPage())),
          icon: const Icon(Icons.book_outlined), label: const Text('Günlük')),
      ]),
      const SizedBox(height: 12),

      sectionTitle('Bebeğim 💕'),
      Card(child: ListTile(
        leading: const Icon(Icons.child_care, color: purple),
        title: Text(store.baby?.name ?? 'Bebek profili oluştur'),
        subtitle: Text(store.baby == null ? 'İsim ve doğum tarihi ekle' : 'Doğum: ${store.baby!.birthDate.day}.${store.baby!.birthDate.month}.${store.baby!.birthDate.year}'),
        trailing: const Icon(Icons.edit), onTap: () => editBaby(context),
      )),
      sectionTitle('Günlük takip'),
      GridView.count(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        children: [for (final item in categories) categoryCard(item.$1, item.$2, const Color(0xFFFFE1ED), () => addRecord(context, item.$1))],
      ),
      sectionTitle('Son kayıtlar'),
      if (store.entries.isEmpty) const Card(child: ListTile(title: Text('Henüz kayıt eklenmedi.'))),
      for (final entry in store.entries) Card(child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: purple),
        title: Text('${entry.category} • ${entry.note}'),
        subtitle: Text('${entry.createdAt.day}.${entry.createdAt.month}.${entry.createdAt.year} ${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}'),
        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => store.deleteEntry(entry.id)),
      )),
      const SizedBox(height: 12),
      const Text('Kayıtlar bu cihazda saklanır. Bulut yedekleme henüz yoktur.', style: TextStyle(color: Colors.black54)),
    ]);
  }
}
