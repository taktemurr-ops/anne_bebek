import 'dart:convert';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/general_recipe_catalog.dart';
import '../widgets/ui.dart';
import 'weekly_meal_planner_page.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});
  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  static const _favoritesKey = 'general_recipe_favorites_v22';
  final _search = TextEditingController();
  final Set<String> _favorites = {};
  String _category = 'Tümü';
  bool _onlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _search.addListener(() { if (mounted) setState(() {}); });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final saved = jsonDecode(prefs.getString(_favoritesKey) ?? '[]') as List<dynamic>;
      if (mounted) setState(() => _favorites.addAll(saved.whereType<String>()));
    } catch (_) { /* Bozuk favori verisi ekranı engellemez. */ }
  }

  Future<void> _toggleFavorite(GeneralRecipe recipe) async {
    final previous = Set<String>.of(_favorites);
    setState(() { if (!_favorites.add(recipe.id)) _favorites.remove(recipe.id); });
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(_favoritesKey, jsonEncode(_favorites.toList()))) {
        throw StateError('Favori kaydedilemedi');
      }
    } catch (_) {
      if (mounted) {
        setState(() { _favorites..clear()..addAll(previous); });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favori kaydedilemedi. Lütfen tekrar deneyin.')));
      }
    }
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  void _showRecipe(GeneralRecipe recipe) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (ctx) => SafeArea(
      child: FractionallySizedBox(heightFactor: .78, child: ListView(padding: const EdgeInsets.all(20), children: [
        Text(recipe.title, style: Theme.of(ctx).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('${recipe.category} • Yaklaşık ${recipe.minutes} dk', style: const TextStyle(color: purple)),
        const SizedBox(height: 12),
        const Text('Porsiyon ve miktar hesaplama: Bu başlangıç kataloğunda ölçüler doğrulanmadığından otomatik porsiyon çarpanı uygulanmaz.', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 12),
        const Text('Malzemeler', style: TextStyle(fontWeight: FontWeight.bold)),
        for (final item in recipe.ingredients) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('• $item')),
        const SizedBox(height: 12),
        const Text('Hazırlanışı', style: TextStyle(fontWeight: FontWeight.bold)),
        for (var i=0; i<recipe.steps.length; i++) Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Text('${i+1}. ${recipe.steps[i]}')),
        const SizedBox(height: 16),
        const Text('Not: Bu katalogdaki tarifler başlangıç fikirleridir. Malzeme miktarları ve pişirme süreleri tarif özelinde doğrulanmadan kesin reçete olarak kullanılmamalıdır.', style: TextStyle(fontSize: 12)),
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = generalRecipes.where((r) =>
      (_category == 'Tümü' || r.category == _category) &&
      (!_onlyFavorites || _favorites.contains(r.id)) &&
      (query.isEmpty || r.title.toLowerCase().contains(query) || r.ingredients.join(' ').toLowerCase().contains(query))
    ).toList();
    final categories = ['Tümü', ...generalRecipeCategories];
    return ListView(padding: const EdgeInsets.all(16), children: [
      sectionTitle('Bugün Ne Pişirsem? 🍲'),
      const Text('155 tarif kaydı; bunların 35 tanesi ölçülü tarif, 120 tanesi başlangıç fikridir. 1.000 özgün tarif hedefi henüz tamamlanmadı.'),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WeeklyMealPlannerPage())), icon: const Icon(Icons.calendar_month), label: const Text('Haftalık yemek planı ve alışveriş listesi')),
      const SizedBox(height: 12),
      TextField(controller: _search, decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: t('Tarif veya malzeme ara'), border: OutlineInputBorder())),
      const SizedBox(height: 8),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        for (final category in categories) Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(category), selected: _category == category, onSelected: (_) => setState(() => _category = category))),
      ])),
      SwitchListTile(title: const Text('Yalnızca favoriler'), value: _onlyFavorites, onChanged: (value) => setState(() => _onlyFavorites = value)),
      Text('${filtered.length} tarif bulundu', style: const TextStyle(color: purple)),
      const SizedBox(height: 8),
      if (filtered.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Bu filtrelere uygun tarif bulunamadı.'))),
      for (final recipe in filtered) Card(child: ListTile(
        leading: const Icon(Icons.restaurant_menu, color: purple),
        title: Text(recipe.title),
        subtitle: Text('${recipe.category} • ~${recipe.minutes} dk'),
        onTap: () => _showRecipe(recipe),
        trailing: IconButton(tooltip: _favorites.contains(recipe.id) ? 'Favorilerden çıkar' : 'Favorilere ekle', icon: Icon(_favorites.contains(recipe.id) ? Icons.favorite : Icons.favorite_border, color: purple), onPressed: () => _toggleFavorite(recipe)),
      )),
    ]);
  }
}
