import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/women_lifestyle_content.dart';
import '../services/secure_health_store.dart';

class WomenLifestylePage extends StatefulWidget {
  final String? initialCategory;
  const WomenLifestylePage({super.key, this.initialCategory});
  @override
  State<WomenLifestylePage> createState() => _WomenLifestylePageState();
}

class _WomenLifestylePageState extends State<WomenLifestylePage> {
  static const _storageKey = 'women_lifestyle_v1';
  final Set<String> favorites = {};
  final Set<String> completed = {};
  bool loading = true;
  bool onlyFavorites = false;
  String query = '';
  String? error;
  String? category;

  @override
  void initState() {
    super.initState();
    category = widget.initialCategory;
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await SecureHealthStore.read(_storageKey);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        favorites.addAll((data['favorites'] as List<dynamic>? ?? []).whereType<String>());
        completed.addAll((data['completed'] as List<dynamic>? ?? []).whereType<String>());
      }
    } catch (e) { error = 'Kayıtlar okunamadı: $e'; }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _toggle(String id, {required bool done}) async {
    final target = done ? completed : favorites;
    final wasPresent = target.contains(id);
    setState(() { if (wasPresent) { target.remove(id); } else { target.add(id); } });
    try {
      await SecureHealthStore.write(_storageKey, jsonEncode({
        'favorites': favorites.toList(), 'completed': completed.toList(),
      }));
    } catch (e) {
      if (mounted) {
        setState(() { if (wasPresent) { target.add(id); } else { target.remove(id); } });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt yapılamadı: $e')));
      }
    }
  }

  void _details(LifestyleArticle article) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (ctx) => Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Chip(label: Text(article.category)),
        const SizedBox(height: 16),
        Text(article.body, style: const TextStyle(fontSize: 17, height: 1.6)),
        const SizedBox(height: 20),
        Card(color: const Color(0xFFFFF0F4), child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Dikkat: ${article.caution}', style: const TextStyle(height: 1.5)),
        )),
        const SizedBox(height: 16),
        StatefulBuilder(builder: (context, refresh) => Column(children: [
          ListTile(leading: Icon(favorites.contains(article.id) ? Icons.favorite : Icons.favorite_border),
            title: Text(favorites.contains(article.id) ? 'Favorilerden çıkar' : 'Favorilere ekle'),
            onTap: () async { await _toggle(article.id, done: false); refresh(() {}); }),
          ListTile(leading: Icon(completed.contains(article.id) ? Icons.check_circle : Icons.radio_button_unchecked),
            title: Text(completed.contains(article.id) ? 'Okundu işaretini kaldır' : 'Okundu olarak işaretle'),
            onTap: () async { await _toggle(article.id, done: true); refresh(() {}); }),
        ])),
        const SizedBox(height: 16),
        const Text('Bu içerik genel bilgilendirme amaçlıdır. Tıbbi değerlendirme yerine geçmez.', style: TextStyle(color: Colors.black54)),
      ]),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final categories = lifestyleArticles.map((e) => e.category).toSet().toList();
    final normalized = query.trim().toLowerCase();
    final visible = lifestyleArticles.where((a) =>
      (category == null || a.category == category) &&
      (!onlyFavorites || favorites.contains(a.id)) &&
      (normalized.isEmpty || '${a.title} ${a.body} ${a.category}'.toLowerCase().contains(normalized))
    ).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Kadın Yaşamı ve Bakım')),
      body: loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        if (error != null) Card(color: const Color(0xFFFFE1E1), child: Padding(padding: const EdgeInsets.all(12), child: Text(error!))),
        const Text('Kendine zaman ayır 💗', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('${lifestyleArticles.length} editoryal başlangıç içeriği • ${completed.length} okundu'),
        const SizedBox(height: 12),
        TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Konu veya kelime ara', border: OutlineInputBorder()),
          onChanged: (value) => setState(() => query = value)),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          ChoiceChip(label: const Text('Tümü'), selected: category == null, onSelected: (_) => setState(() => category = null)),
          const SizedBox(width: 6),
          ...categories.map((c) => Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
            label: Text(c), selected: category == c, onSelected: (_) => setState(() => category = c)))),
        ])),
        SwitchListTile(title: const Text('Yalnızca favorilerim'), value: onlyFavorites,
          onChanged: (value) => setState(() => onlyFavorites = value)),
        if (visible.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Bu filtrelerde içerik bulunamadı.')),
        for (final a in visible) Card(child: ListTile(
          title: Text(a.title), subtitle: Text(a.category),
          leading: Icon(completed.contains(a.id) ? Icons.check_circle_outline : Icons.auto_stories_outlined, color: const Color(0xFF75466F)),
          trailing: Icon(favorites.contains(a.id) ? Icons.favorite : Icons.chevron_right, color: const Color(0xFF75466F)),
          onTap: () => _details(a),
        )),
        const SizedBox(height: 18),
        const Text('İçerikler genel bilgilendirme amaçlıdır. Sağlıkla ilgili konularda uzman görüşü alın.', style: TextStyle(color: Colors.black54)),
      ]),
    );
  }
}
