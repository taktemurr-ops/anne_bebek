import 'dart:async';
import 'dart:convert';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import '../services/affiliate.dart';
import '../services/affiliate_log.dart';
import '../services/link_launcher.dart';
import '../services/product_catalog.dart';
import '../services/secure_health_store.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});
  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  static const key = 'product_catalog_v1';
  final Set<String> favorites = {}, compared = {};
  String search = '', category = 'Tümü';
  bool onlyFavorites = false, loading = true, saving = false;
  String? error;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final raw = await SecureHealthStore.read(key);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        favorites.addAll((data['favorites'] as List<dynamic>? ?? []).whereType<String>());
        compared.addAll((data['compared'] as List<dynamic>? ?? []).whereType<String>());
      }
    } catch (e) { error = 'Kayıtlar okunamadı: $e'; }
    if (mounted) setState(() => loading = false);
  }
  Future<void> _toggle(String id, {required bool comparison}) async {
    if (saving) return;
    final target = comparison ? compared : favorites;
    if (comparison && !target.contains(id) && target.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('En fazla 3 ürün karşılaştırabilirsiniz.')));
      return;
    }
    final before = Set<String>.from(target);
    setState(() { if (!target.add(id)) target.remove(id); saving = true; });
    try {
      await SecureHealthStore.write(key, jsonEncode({'favorites': favorites.toList(), 'compared': compared.toList()}));
    } catch (e) {
      if (mounted) {
        setState(() { target..clear()..addAll(before); error = 'Kaydetme başarısız: $e'; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error!)));
      }
    } finally { if (mounted) setState(() => saving = false); }
  }
  String _storeLabel() {
    final label = t('Mağazada ara');
    return '$label: ${Affiliate.partner}';
  }

  void _details(CatalogProduct p) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Chip(label: Text(p.category)), const SizedBox(height: 10),
        Text(p.description, style: const TextStyle(fontSize: 17)),
        const SizedBox(height: 16), const Text('Karşılaştırma ölçütleri', style: TextStyle(fontWeight: FontWeight.bold)),
        for (final f in p.features) ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(f)),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Text('Dikkat: ${p.note}'))),
        const SizedBox(height: 10),
        if (Affiliate.configured) ...[
          FilledButton.icon(
            key: const Key('affiliate_ac'),
            onPressed: () async {
              final url = Affiliate.urlFor(t(p.name));
              if (url == null) return;
              unawaited(AffiliateLog.click(p.id, Affiliate.partner));
              var ok = false;
              try { ok = await LinkLauncher.open(url); } catch (_) {}
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Bağlantı açılamadı.'))));
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: Text(_storeLabel())),
          const SizedBox(height: 4),
          const Text('Reklam · İş birliği bağlantısı: bu bağlantıyla yapılan alışverişlerden uygulama komisyon alabilir; fiyat sana değişmez.',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
        ] else const Text('Bu katalog marka, satıcı, güncel fiyat, stok veya satın alma bağlantısı içermez.'),
        StatefulBuilder(builder: (context, refresh) => Column(children: [
          ListTile(leading: Icon(favorites.contains(p.id) ? Icons.favorite : Icons.favorite_border), title: const Text('Favori durumunu değiştir'), onTap: () async { await _toggle(p.id, comparison: false); refresh(() {}); }),
          ListTile(leading: Icon(compared.contains(p.id) ? Icons.check_box : Icons.check_box_outline_blank), title: const Text('Karşılaştırma seçimini değiştir'), onTap: () async { await _toggle(p.id, comparison: true); refresh(() {}); }),
        ])),
      ]),
    )));
  }
  void _compare() {
    final chosen = ProductCatalog.products.where((p) => compared.contains(p.id)).toList();
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Ürün özellik karşılaştırması')),
      body: chosen.length < 2 ? const Center(child: Text('Karşılaştırmak için 2 veya 3 ürün seçin.')) : ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Bu karşılaştırma ürün türlerine ait seçim ölçütlerini gösterir. Marka, teknik model, fiyat veya gerçek ürün performansı karşılaştırması değildir.'),
        const SizedBox(height: 12),
        for (final p in chosen) Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: Theme.of(context).textTheme.titleMedium),
          Text(p.category), const SizedBox(height: 8),
          for (final f in p.features) Text('• $f'),
          const SizedBox(height: 8), Text(p.note, style: const TextStyle(color: Colors.black54)),
        ]))),
      ]),
    )));
  }
  @override
  Widget build(BuildContext context) {
    final q = search.trim().toLowerCase();
    final visible = ProductCatalog.products.where((p) =>
      (category == 'Tümü' || p.category == category) &&
      (!onlyFavorites || favorites.contains(p.id)) &&
      (q.isEmpty || '${p.name} ${p.category} ${p.description} ${p.features.join(' ')}'.toLowerCase().contains(q))
    ).toList();
    return Scaffold(appBar: AppBar(title: const Text('Ürün keşif kataloğu')),
      body: loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        const Text('36 ürün türü • 6 kategori • Bağımsız seçim rehberi'),
        const SizedBox(height: 8),
        if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
        TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), labelText: t('Ürün veya özellik ara'), border: OutlineInputBorder()), onChanged: (v) => setState(() => search = v)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: category, isExpanded: true, decoration: InputDecoration(labelText: t('Kategori')), items: ['Tümü', ...ProductCatalog.categories].map((c) => DropdownMenuItem(value: c, child: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => category = v ?? 'Tümü')),
        SwitchListTile(title: const Text('Yalnızca favoriler'), value: onlyFavorites, onChanged: (v) => setState(() => onlyFavorites = v)),
        FilledButton.icon(onPressed: _compare, icon: const Icon(Icons.compare_arrows), label: Text('Karşılaştır (${compared.length}/3)')),
        const SizedBox(height: 8),
        for (final p in visible) Card(child: ListTile(
          title: Text(p.name), subtitle: Text('${p.category} • ${p.features.join(', ')}', maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () => _details(p),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: t('Favori'), icon: Icon(favorites.contains(p.id) ? Icons.favorite : Icons.favorite_border), onPressed: () => _toggle(p.id, comparison: false)),
            IconButton(tooltip: t('Karşılaştır'), icon: Icon(compared.contains(p.id) ? Icons.check_box : Icons.check_box_outline_blank), onPressed: () => _toggle(p.id, comparison: true)),
          ]),
        )),
        if (visible.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Aramaya uygun ürün bulunamadı.')),
        const Text('Bilgilendirme: Katalogda gerçek satıcı fiyatları, stok durumu, ödeme ve sipariş entegrasyonu bulunmaz.', style: TextStyle(color: Colors.black54)),
      ]),
    );
  }
}
