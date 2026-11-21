import 'package:flutter/foundation.dart' show kReleaseMode;
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'smart_shopping_page.dart';
import 'weekly_meal_planner_page.dart';
import 'baby_recipes_page.dart';
import 'baby_health_page.dart';
import 'child_profiles_page.dart';
import 'womens_health_journal_page.dart';
import 'postpartum_care_page.dart';
import 'backup_page.dart';
import 'reminders_page.dart';
import 'ai_assistant_page.dart';
import 'release_check_page.dart';
import 'project_completion_center_page.dart';

/// Ekranların tek noktadan erişilebilir, yerel çalışan modül merkezi.
class ModuleHubPage extends StatefulWidget {
  const ModuleHubPage({super.key});
  @override
  State<ModuleHubPage> createState() => _ModuleHubPageState();
}

class _ModuleHubPageState extends State<ModuleHubPage> {
  static const _favoritesKey = 'module_hub_favorites_v1';
  String query = '';
  String category = 'Tümü';
  Set<String> favorites = {};
  bool onlyFavorites = false;
  final modules = <(String, String, IconData, Widget)>[
    ('Bebek', 'Çocuk profilleri', Icons.people_outline, const ChildProfilesPage()),
    ('Bebek', 'Bebek sağlığı', Icons.monitor_heart_outlined, const BabyHealthPage()),
    ('Bebek', 'Büyüme trendleri (çocuk seçimi)', Icons.show_chart, const ChildProfilesPage()),
    ('Bebek', 'Çocuk günlüğü (çocuk seçimi)', Icons.book_outlined, const ChildProfilesPage()),
    ('Mutfak', 'Akıllı alışveriş', Icons.shopping_basket_outlined, const SmartShoppingPage()),
    ('Mutfak', 'Haftalık yemek planı', Icons.restaurant_menu, const WeeklyMealPlannerPage()),
    ('Mutfak', 'Bebek tarifleri', Icons.rice_bowl_outlined, const BabyRecipesPage()),
    ('Kadın', 'Kadın sağlığı günlüğü', Icons.favorite_outline, const WomensHealthJournalPage()),
    ('Kadın', 'Doğum sonrası bakım', Icons.spa_outlined, const PostpartumCarePage()),
    ('Araçlar', 'Hatırlatıcılar', Icons.notifications_outlined, const RemindersPage()),
    ('Araçlar', 'Yedekleme', Icons.backup_outlined, const BackupPage()),
    ('Araçlar', 'Bilgi asistanı', Icons.auto_awesome_outlined, const AiAssistantPage()),
    // Geliştirici araçları yalnızca geliştirme sürümlerinde.
    if (!kReleaseMode) ('Yayın', 'Yayın kontrolleri', Icons.fact_check_outlined, const ReleaseCheckPage()),
    if (!kReleaseMode) ('Yayın', 'Proje tamamlama', Icons.task_alt_outlined, const ProjectCompletionCenterPage()),
  ];
  @override
  void initState() { super.initState(); _loadFavorites(); }
  Future<void> _loadFavorites() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted) setState(() => favorites = (p.getStringList(_favoritesKey) ?? []).toSet());
    } catch (_) { /* Tercihler okunamazsa modüller kullanılabilir kalır. */ }
  }
  Future<void> _toggleFavorite(String title) async {
    final old = Set<String>.from(favorites);
    setState(() { if (!favorites.add(title)) favorites.remove(title); });
    try {
      final p = await SharedPreferences.getInstance();
      if (!await p.setStringList(_favoritesKey, favorites.toList())) throw StateError('Kayıt hatası');
    } catch (_) {
      if (mounted) {
        setState(() => favorites = old);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favori tercihi kaydedilemedi.')));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final visible = modules.where((m) =>
      (category == 'Tümü' || m.$1 == category) &&
      (!onlyFavorites || favorites.contains(m.$2)) &&
      (m.$2.toLowerCase().contains(query.toLowerCase()) ||
       m.$1.toLowerCase().contains(query.toLowerCase()))).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Tüm modüller'), actions: [
        IconButton(tooltip: t('Modül listesini kopyala'),
          icon: const Icon(Icons.copy_all_outlined),
          onPressed: () async {
            final rows = <String>['Kategori,Modül',
              ...modules.map((m) => '"${m.$1}","${m.$2}"')];
            await Clipboard.setData(ClipboardData(text: rows.join('\\n')));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Modül listesi panoya kopyalandı.')));
            }
          }),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Anne & Bebek • Modül merkezi',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold,
            color: Color(0xFF48235F))),
        const SizedBox(height: 8),
        TextField(decoration: InputDecoration(
          prefixIcon: Icon(Icons.search), labelText: t('Modül ara')),
          onChanged: (v) => setState(() => query = v)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 4, children: [
          for (final c in ['Tümü', 'Bebek', 'Mutfak', 'Kadın', 'Araçlar', 'Yayın'])
            ChoiceChip(label: Text(c), selected: category == c,
              onSelected: (_) => setState(() => category = c)),
          FilterChip(label: const Text('Favoriler'), selected: onlyFavorites,
            onSelected: (v) => setState(() => onlyFavorites = v)),
        ]),
        Text('${visible.length} / ${modules.length} modül'),
        if (visible.isEmpty) const ListTile(title: Text('Bu filtreye uygun modül bulunamadı.')),
        for (final m in visible)
          Card(child: ListTile(
            leading: Icon(m.$3, color: const Color(0xFF48235F)),
            title: Text(m.$2), subtitle: Text(m.$1),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => m.$4)),
            trailing: IconButton(
              tooltip: favorites.contains(m.$2) ? 'Favorilerden çıkar' : 'Favorilere ekle',
              icon: Icon(favorites.contains(m.$2) ? Icons.star : Icons.star_border),
              onPressed: () => _toggleFavorite(m.$2)),
          )),
      ]),
    );
  }
}
