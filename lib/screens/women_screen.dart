import 'package:flutter/material.dart';
import '../widgets/ui.dart';
import 'women_lifestyle_page.dart';
import 'womens_health_journal_page.dart';
import 'postpartum_care_page.dart';
import 'module_hub_page.dart';

class WomenScreen extends StatelessWidget {
  const WomenScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    sectionTitle('Kadın Yaşamı 💗'),
    Wrap(spacing: 8, runSpacing: 8, children: [
      OutlinedButton.icon(onPressed: () => Navigator.push(context,
        MaterialPageRoute<void>(builder: (_) => const ModuleHubPage())),
        icon: const Icon(Icons.apps_outlined), label: const Text('Tüm modüller')),
      OutlinedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
          builder: (_) => const WomensHealthJournalPage())),
        icon: const Icon(Icons.edit_note_outlined),
        label: const Text('Sağlık günlüğü')),
      OutlinedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
          builder: (_) => const PostpartumCarePage())),
        icon: const Icon(Icons.spa_outlined),
        label: const Text('Doğum sonrası bakım')),
    ]),
    const SizedBox(height: 12),

    for (final item in const [
      ('Kadın sağlığı', Icons.favorite_outline, 'Genel sağlık bilgileri'),
      ('Hamilelik', Icons.pregnant_woman, 'Gebelik dönemi rehberi'),
      ('Doğum sonrası', Icons.spa_outlined, 'İyileşme ve yaşam'),
      ('Kişisel bakım', Icons.face_retouching_natural, 'Bakım ve iyi yaşam'),
      ('Aile ve yaşam', Icons.family_restroom, 'Günlük yaşam önerileri'),
    ]) Card(child: ListTile(
      leading: Icon(item.$2, color: purple), title: Text(item.$1), subtitle: Text(item.$3),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => WomenLifestylePage(initialCategory: item.$1 == 'Kişisel bakım' ? 'Güzellik & Bakım' : item.$1 == 'Aile ve yaşam' ? 'Aile ve Yaşam' : null))),
    )),
    const SizedBox(height: 14),
    const Text('Sağlık içerikleri bilgilendirme amaçlıdır; tanı veya tedavi yerine geçmez.', style: TextStyle(color: Colors.black54)),
  ]);
}
