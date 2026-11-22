import '../utils/privacy_log_sanitizer.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/recipe_notebook_bridge.dart';
import '../widgets/add_to_notebook_tile.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/baby_recipe_catalog.dart';
import '../widgets/recipe_art.dart';

/// Mevcut baby_recipe_catalog.dart veri modelini değiştirmeden kullanır.
class BabyRecipesPage extends StatefulWidget {
  const BabyRecipesPage({super.key});

  @override
  State<BabyRecipesPage> createState() => _BabyRecipesPageState();
}

class _BabyRecipesPageState extends State<BabyRecipesPage> {
  static const _favoritesKey = 'baby_recipe_favorites_v1';
  final _searchController = TextEditingController();
  final Set<String> _favorites = <String>{};
  String _query = '';
  String _age = 'Tümü';
  String _category = 'Tümü';
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _favorites
          ..clear()
          // Eski varyasyon kimlikleri yeni tarif kimliğine taşınır.
          ..addAll((prefs.getStringList(_favoritesKey) ?? const <String>[]).map(babyRecipeIdFor));
      });
    } catch (error) {
      logSafeError('Bebek tarifi favorileri yüklenemedi', error);
    }
  }

  Future<void> _toggleFavorite(String id) async {
    // Keep the previous selection so a failed disk write cannot appear saved.
    final previous = Set<String>.from(_favorites);
    setState(() {
      if (!_favorites.add(id)) _favorites.remove(id);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setStringList(_favoritesKey, _favorites.toList());
      if (!saved) throw StateError('Favoriler kaydedilemedi');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _favorites
          ..clear()
          ..addAll(previous);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favori kaydedilemedi. Tekrar deneyin.')),
      );
      logSafeError('Bebek tarifi favori kayıt hatası', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>[
      'Tümü',
      ...{for (final recipe in babyRecipes) recipe.category},
    ];
    final ages = <String>[
      'Tümü',
      ...babyAgeGroups,
    ];
    final normalizedQuery = _query.trim().toLowerCase();
    final visible = babyRecipes.where((recipe) {
      final ageMatches = _age == 'Tümü' || recipe.ageGroup == _age;
      final categoryMatches =
          _category == 'Tümü' || recipe.category == _category;
      final favoriteMatches = !_favoritesOnly || _favorites.contains(recipe.id);
      final searchText = [
        recipe.title,
        recipe.ingredient,
        recipe.vegetable,
        ...recipe.variants,
        ...recipe.ingredients,
      ].join(' ').toLowerCase();
      return ageMatches && categoryMatches && favoriteMatches &&
          searchText.contains(normalizedQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bebek tarifleri')),
      body: SafeArea(
        // Filtreler listeyle birlikte kayar; kısa ve yatay ekranlarda taşmaz.
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEAF5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bebeğim için tarifler 💗',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                                color: Color(0xFF48235F))),
                        const SizedBox(height: 6),
                        Text('${babyRecipes.length} tarif • 6–72 ay • Yaşa ve malzemeye göre keşfet'),
                        const SizedBox(height: 5),
                        const Text(
                          'Yaş etiketleri genel bilgi içindir. Alerjenleri, kıvamı ve bebeğinizin gelişimini dikkate alın.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: t('Tarif veya malzeme ara'),
                      suffixIcon: _query.isEmpty ? null : IconButton(
                        tooltip: t('Aramayı temizle'),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: DropdownButtonFormField<String>(
                        key: ValueKey('age_$_age'),
                        initialValue: _age,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: t('Yaş')),
                        items: ages.map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value == 'Tümü' ? 'Tüm yaşlar' : value,
                              overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _age = value);
                        },
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: DropdownButtonFormField<String>(
                        key: ValueKey('category_$_category'),
                        initialValue: _category,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: t('Kategori')),
                        items: categories.map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value, overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _category = value);
                        },
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('${visible.length} sonuç',
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                      FilterChip(
                        label: Text('Favoriler (${_favorites.length})'),
                        avatar: const Icon(Icons.favorite, size: 17),
                        selected: _favoritesOnly,
                        onSelected: (value) => setState(() => _favoritesOnly = value),
                      ),
                    ],
                  ),
                ],
              ),
            )),
            if (visible.isEmpty)
              SliverFillRemaining(hasScrollBody: false,
                  child: Center(child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 48,
                              color: Color(0xFF48235F)),
                          const SizedBox(height: 10),
                          const Text('Bu filtrelerde tarif bulunamadı.'),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _age = 'Tümü';
                                _category = 'Tümü';
                                _favoritesOnly = false;
                              });
                            },
                            child: const Text('Filtreleri temizle'),
                          ),
                        ],
                      ),
                    )))
            else
              SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  sliver: SliverList.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final recipe = visible[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            leading: RecipeArt(title: recipe.title, category: recipe.category,
                                ingredients: recipe.ingredients, size: 52, borderRadius: 14),
                            title: Text(recipe.title,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(recipe.variants.isEmpty
                                ? '${recipe.ageGroup} • ${recipe.category}'
                                : '${recipe.ageGroup} • ${recipe.category} • ${recipe.variants.length} sebze seçeneği'),
                            trailing: IconButton(
                              tooltip: _favorites.contains(recipe.id)
                                  ? 'Favorilerden çıkar' : 'Favorilere ekle',
                              icon: Icon(_favorites.contains(recipe.id)
                                  ? Icons.favorite : Icons.favorite_border,
                                  color: const Color(0xFFF0449B)),
                              onPressed: () => _toggleFavorite(recipe.id),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => _BabyRecipeDetailPage(recipe: recipe),
                              ),
                            ),
                          ),
                        );
                      },
                    )),
          ],
        ),
      ),
    );
  }
}

// Katalog modelinin somut tipine bağımlı olmamak için detay sayfası
// aynı dosyada kurulur; mevcut katalog alanları korunur.
class _BabyRecipeDetailPage extends StatelessWidget {
  const _BabyRecipeDetailPage({required this.recipe});
  final BabyRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final ingredients = recipe.ingredients;
    final steps = recipe.steps;
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: RecipeArt(title: recipe.title, category: recipe.category,
                    ingredients: recipe.ingredients, borderRadius: 0),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAF5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${recipe.minMonths} ay ve üzeri (${recipe.ageGroup}) • ${recipe.category}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AddToNotebookTile(build: () => RecipeNotebookBridge.fromBaby(recipe)),
            const SizedBox(height: 12),
            Text('Malzemeler', style: Theme.of(context).textTheme.titleLarge),
            ...ingredients.map((item) => ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline,
                  color: Color(0xFF48235F)),
              title: Text(item),
            )),
            const SizedBox(height: 14),
            Text('Hazırlanışı', style: Theme.of(context).textTheme.titleLarge),
            ...steps.asMap().entries.map((entry) => ListTile(
              leading: CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFFFFD9ED),
                child: Text('${entry.key + 1}',
                    style: const TextStyle(color: Color(0xFF48235F))),
              ),
              title: Text(entry.value),
            )),
            if (recipe.variants.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Sebze seçenekleri', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Tarifte "seçtiğiniz" yazan yere bunlardan birini kullanabilirsiniz:',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final v in recipe.variants)
                  Chip(label: Text(v), backgroundColor: const Color(0xFFFFEAF5), side: BorderSide.none),
              ]),
            ],
            if (recipe.tips.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Püf noktaları', style: Theme.of(context).textTheme.titleLarge),
              ...recipe.tips.map((t) => ListTile(dense: true,
                leading: const Icon(Icons.lightbulb_outline, color: Color(0xFF48235F)),
                title: Text(t))),
            ],
            if (recipe.storage != null) ...[
              const SizedBox(height: 8),
              Text('Saklama', style: Theme.of(context).textTheme.titleLarge),
              Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(recipe.storage!)),
            ],
            const SizedBox(height: 18),
            const Card(
              color: Color(0xFFFFF1F7),
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'ÖNEMLİ: Ek gıdaya genellikle yaklaşık 6. ayda, gelişimsel hazır oluşa göre başlanır. '
                  '12 aydan önce bal vermeyin; tuz ve şeker eklemeyin. '
                  'Bütün kuruyemişler ve sert/yuvarlak parçalar boğulma riski taşır. '
                  'Alerjenleri kontrol edin, yiyecekleri uygun kıvamda sunun '
                  've bebeği yemek sırasında yalnız bırakmayın.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
