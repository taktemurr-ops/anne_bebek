import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/general_recipe_catalog.dart';

/// Paket 39 / Aşama 22. Mevcut tarif ve alışveriş kayıtlarını değiştirmez.
class PantryRecipePage extends StatefulWidget {
  const PantryRecipePage({super.key});
  @override
  State<PantryRecipePage> createState() => _PantryRecipePageState();
}

class _PantryRecipePageState extends State<PantryRecipePage> {
  static const _storageKey = 'paket39_pantry_ingredients_v1';
  static const _detailsKey = 'paket39_pantry_details_v1';
  final Map<String, Map<String, String>> _details = {};
  static const _purple = Color(0xFF48235F);
  final _input = TextEditingController();
  final _search = TextEditingController();
  final Set<String> _pantry = {};
  String _category = 'Tümü';
  bool _onlyComplete = false;
  bool _loading = true;
  String _pantryQuery = '';
  String _pantryCategory = 'Tümü';
  bool _expiringFirst = false;
  static const _usageKey = 'paket39_pantry_usage_v1';
  static const _historyKey = 'paket39_pantry_consumption_history_v1';
  final List<Map<String, String>> _history = [];

  final Map<String, int> _usage = {};


  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = jsonDecode(prefs.getString(_storageKey) ?? '[]');
      if (saved is List) {
        _pantry.addAll(saved.whereType<String>().map(_normalize).where((e) => e.isNotEmpty));
      }
      final rawUsage = jsonDecode(prefs.getString(_usageKey) ?? '{}');
      if (rawUsage is Map) {
        for (final entry in rawUsage.entries) {
          if (entry.key is String && entry.value is num) {
            _usage[entry.key as String] = (entry.value as num).toInt();
          }
        }
      }
      final rawHistory = jsonDecode(prefs.getString(_historyKey) ?? '[]');
      if (rawHistory is List) {
        for (final row in rawHistory) {
          if (row is Map && row['item'] is String && row['amount'] is String && row['date'] is String) {
            _history.add({'item': row['item'] as String, 'amount': row['amount'] as String, 'date': row['date'] as String});
          }
        }
      }
      final rawDetails = jsonDecode(prefs.getString(_detailsKey) ?? '{}');
      if (rawDetails is Map) {
        for (final entry in rawDetails.entries) {
          if (entry.key is String && entry.value is Map) {
            final value = entry.value as Map;
            _details[entry.key as String] = {
              'quantity': (value['quantity'] ?? '').toString(),
              'expiry': (value['expiry'] ?? '').toString(),
              'minimum': (value['minimum'] ?? '').toString(),
            };
          }
        }
      }
    } catch (_) {
      // Bozuk veri silinmez; kullanıcı yeni malzeme ekleyebilir.
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(_storageKey, jsonEncode(_pantry.toList()..sort()));
      if (!ok) throw StateError('Kaydedilemedi');
      final detailsSaved = await prefs.setString(_detailsKey, jsonEncode(_details));
      if (!detailsSaved) throw StateError('Detaylar kaydedilemedi');
      if (!await prefs.setString(_historyKey, jsonEncode(_history))) throw StateError('Tüketim geçmişi kaydedilemedi');
      if (!await prefs.setString(_usageKey, jsonEncode(_usage))) {
        throw StateError('Kullanım bilgileri kaydedilemedi');
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Malzemeler kaydedilemedi.')));
    }
  }

  String _normalize(String value) => value.toLowerCase().trim()
      .replaceAll('ı', 'i').replaceAll('ğ', 'g').replaceAll('ü', 'u')
      .replaceAll('ş', 's').replaceAll('ö', 'o').replaceAll('ç', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');

  // Miktar/ölçü ifadelerini atarak malzeme adını yaklaşık olarak çıkarır.
  String _ingredientName(String value) {
    var s = _normalize(value);
    s = s.replaceAll(RegExp(r'\([^)]*\)'), ' ');
    s = s.replaceAll(RegExp(r'^\s*[\d.,/]+\s*'), '');
    s = s.replaceAll(RegExp(r'^(yarim|bir|iki|uc|dort|bes)\s+'), '');
    s = s.replaceAll(RegExp(r'^(su|cay|yemek|tatli)\s+(bardagi|kasigi|kasik|bardak)\s*'), '');
    s = s.replaceAll(RegExp(r'^(adet|dis|dilim|tutam|demet|paket|gram|gr|g|kg|ml|litre|l|avuc|kase|kucuk|orta|buyuk|silme|tepeleme)\s+'), '');
    s = s.replaceAll(RegExp(r'^(su|cay|yemek|tatli)\s+(bardagi|kasigi|kasik|bardak)\s*'), '');
    return s.trim();
  }

  bool _have(String ingredient) {
    final name = _ingredientName(ingredient);
    if (name.isEmpty) return false;
    return _pantry.any((p) => p == name ||
        (p.length >= 4 && name.contains(p)) ||
        (name.length >= 4 && p.contains(name)));
  }

  DateTime? _expiry(String item) {
    final value = _details[item]?['expiry'];
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  int? _daysLeft(String item) {
    final expiry = _expiry(item);
    if (expiry == null) return null;
    final today = DateUtils.dateOnly(DateTime.now());
    return DateUtils.dateOnly(expiry).difference(today).inDays;
  }

  String _itemCategory(String item) {
    final n = _normalize(item);
    if (RegExp(r'domates|biber|patates|sogan|sarimsak|kabak|patlican|havuc|marul|salatalik|elma|muz|limon|portakal|meyve|sebze|maydanoz|ispanak').hasMatch(n)) return 'Sebze ve meyve';
    if (RegExp(r'tavuk|et|kiyma|balik|somon|hindi').hasMatch(n)) return 'Et ve balık';
    if (RegExp(r'sut|yogurt|peynir|tereyag|krema|kefir').hasMatch(n)) return 'Süt ürünleri';
    if (RegExp(r'pirinc|bulgur|mercimek|nohut|fasulye|makarna|un|yulaf|ekmek').hasMatch(n)) return 'Tahıl ve bakliyat';
    return 'Diğer';
  }

  // Stok eşiği yalnızca aynı birimdeki sayısal miktarlarla karşılaştırılır.
  ({double value, String unit})? _parseAmount(String raw) {
    final match = RegExp(r'^\s*(\d+(?:[.,]\d+)?)\s*(.*)$').firstMatch(raw);
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null || value < 0) return null;
    return (value: value, unit: _normalize(match.group(2)!.trim()));
  }

  // Sadece ağırlık ve hacim birimleri kendi gruplarında dönüştürülür.
  ({double value, String unit})? _canonicalAmount(String raw) {
    final parsed = _parseAmount(raw);
    if (parsed == null) return null;
    switch (parsed.unit) {
      case 'kg': case 'kilogram': return (value: parsed.value * 1000, unit: 'g');
      case 'g': case 'gr': case 'gram': return (value: parsed.value, unit: 'g');
      case 'l': case 'lt': case 'litre': return (value: parsed.value * 1000, unit: 'ml');
      case 'ml': case 'mililitre': return (value: parsed.value, unit: 'ml');
      default: return parsed;
    }
  }

  double? _stockDeficit(String item) {
    final quantity = _canonicalAmount(_details[item]?['quantity'] ?? '');
    final minimum = _canonicalAmount(_details[item]?['minimum'] ?? '');
    if (quantity == null || minimum == null || minimum.value <= 0 || quantity.unit != minimum.unit) return null;
    return minimum.value - quantity.value;
  }

  bool _isLowStock(String item) {
    final difference = _stockDeficit(item);
    return difference != null && difference >= 0;
  }

  String _suggestedPurchase(String item) {
    final minimum = _canonicalAmount(_details[item]?['minimum'] ?? '');
    final deficit = _stockDeficit(item);
    if (minimum == null || deficit == null) return item;
    final n = deficit <= 0 ? 0 : deficit;
    final formatted = n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);
    return '$item ($formatted ${minimum.unit} eksik)';
  }

  Future<void> _quickAdd() async {
    final name = TextEditingController();
    final amount = TextEditingController();
    final minimum = TextEditingController();
    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Hızlı ürün ekle'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Ürün adı')),
        TextField(controller: amount, decoration: const InputDecoration(labelText: 'Miktar (örn. 1 kg)')),
        TextField(controller: minimum, decoration: const InputDecoration(labelText: 'Minimum stok (örn. 500 g)')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ekle'))],
    ));
    if (result == true && mounted) {
      final item = _normalize(name.text);
      if (item.isNotEmpty) {
        setState(() {
          _pantry.add(item);
          final details = _details.putIfAbsent(item, () => {'quantity': '', 'minimum': '', 'expiry': ''});
          if (amount.text.trim().isNotEmpty) details['quantity'] = amount.text.trim();
          if (minimum.text.trim().isNotEmpty) details['minimum'] = minimum.text.trim();
        });
        await _save();
      }
    }
    name.dispose(); amount.dispose(); minimum.dispose();
  }

  Future<void> _showConsumptionReport() async {
    final history = _history.reversed.take(50).toList();
    final count = _history.length;
    final affected = _history.map((r) => r['item']).toSet().length;
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Stok ve tüketim raporu'),
      content: SizedBox(width: double.maxFinite, child: ListView(shrinkWrap: true, children: [
        Text('Envanter: ${_pantry.length} ürün • Düşük stok: ${_pantry.where(_isLowStock).length}'),
        Text('Kayıtlı tüketim: $count işlem • $affected farklı ürün'),
        const Divider(),
        if (history.isEmpty) const Text('Henüz tüketim kaydı yok.'),
        for (final row in history) ListTile(dense: true, title: Text(row['item'] ?? ''),
          subtitle: Text('${row['amount']} • ${row['date']}')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))],
    ));
  }

  Future<void> _sendLowStockToShopping() async {
    final low = _pantry.where(_isLowStock).toList()..sort();
    if (low.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alışverişe aktarılacak düşük stok bulunmuyor.')));
      return;
    }
    final approved = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Azalan stokları alışverişe ekle'),
      content: Text('${low.length} ürün: ${low.join(', ')}\n\nMevcut alışveriş listen korunacak.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Listeye ekle')),
      ],
    ));
    if (approved != true || !mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonDecode(prefs.getString('alisveris') ?? '[]');
      if (raw is! List || raw.any((e) => e is! String)) throw const FormatException('Alışveriş listesi biçimi geçersiz');
      final existing = raw.cast<String>();
      final merged = <String>[...existing];
      var added = 0;
      for (final item in low) {
        if (!merged.any((e) => _normalize(e).split(' (').first == _normalize(item))) {
          merged.add(_suggestedPurchase(item));
          added++;
        }
      }
      if (!await prefs.setString('alisveris', jsonEncode(merged))) throw StateError('Kayıt başarısız');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$added ürün alışveriş listesine eklendi.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alışveriş listesi okunamadı; eski kayıtlar değiştirilmedi.')));
    }
  }

  Future<void> _showStockAlerts() async {
    final expiring = _pantry.where((p) { final d = _daysLeft(p); return d != null && d >= 0 && d <= 3; }).toList()..sort();
    final expired = _pantry.where((p) { final d = _daysLeft(p); return d != null && d < 0; }).toList()..sort();
    final low = _pantry.where(_isLowStock).toList()..sort();
    if (!mounted) return;
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Mutfak uyarı merkezi'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Bu ekran uygulama içi kontrol listesidir; telefon bildirimi göndermez.'),
        const SizedBox(height: 12),
        Text('Azalan stok (${low.length}): ${low.isEmpty ? 'Yok' : low.join(', ')}'),
        const SizedBox(height: 8),
        Text('SKT yaklaşan (${expiring.length}): ${expiring.isEmpty ? 'Yok' : expiring.join(', ')}'),
        const SizedBox(height: 8),
        Text('SKT geçmiş (${expired.length}): ${expired.isEmpty ? 'Yok' : expired.join(', ')}'),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))],
    ));
  }

  Future<void> _consume(String item) async {
    final current = _details[item]?['quantity'] ?? '';
    final match = RegExp(r'^\s*(\d+(?:[.,]\d+)?)\s*(.*)$').firstMatch(current);
    if (match == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Önce ürün miktarını sayı ve birim olarak gir (örn. 500 g).')));
      return;
    }
    final available = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0;
    final unit = match.group(2)!.trim();
    final controller = TextEditingController();
    final used = await showDialog<double>(context: context, builder: (ctx) => AlertDialog(
      title: Text('$item • Tüketim kaydı'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Mevcut: $current'),
        TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Tüketilen miktar${unit.isEmpty ? '' : ' ($unit)'}')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
        FilledButton(onPressed: () {
          final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
          if (value == null || value <= 0 || value > available) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Geçerli bir miktar gir.')));
            return;
          }
          Navigator.pop(ctx, value);
        }, child: const Text('Tüketimi kaydet')),
      ],
    ));
    controller.dispose();
    if (used == null || !mounted) return;
    final remaining = available - used;
    String fmt(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);
    setState(() {
      _details.putIfAbsent(item, () => {'quantity': '', 'expiry': '', 'minimum': ''})['quantity'] =
        '${fmt(remaining)}${unit.isEmpty ? '' : ' $unit'}';
      _usage[item] = (_usage[item] ?? 0) + 1;
      _history.add({'item': item, 'amount': '${fmt(used)}${unit.isEmpty ? '' : ' $unit'}', 'date': DateTime.now().toIso8601String()});
    });
    await _save();
  }

  Future<void> _editItem(String item) async {
    final quantity = TextEditingController(text: _details[item]?['quantity'] ?? '');
    final minimum = TextEditingController(text: _details[item]?['minimum'] ?? '');
    DateTime? selectedDate = _expiry(item);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, update) => AlertDialog(
          title: Text('$item • Stok bilgisi'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(controller: quantity,
              decoration: const InputDecoration(labelText: 'Miktar (örn. 500 g, 2 adet)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: minimum,
              decoration: const InputDecoration(labelText: 'Minimum stok (örn. 200 g, 2 adet)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Text(selectedDate == null ? 'Son kullanma tarihi: Belirtilmedi' :
              'Son kullanma: ${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}'),
            Wrap(spacing: 8, children: [
              TextButton.icon(onPressed: () async {
                final date = await showDatePicker(context: dialogContext,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (date != null) update(() => selectedDate = date);
              }, icon: const Icon(Icons.calendar_month), label: const Text('Tarih seç')),
              TextButton(onPressed: () => update(() => selectedDate = null), child: const Text('Tarihi kaldır')),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('İptal')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, {
              'quantity': quantity.text.trim(),
              'minimum': minimum.text.trim(),
              'expiry': selectedDate == null ? '' :
                '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
            }), child: const Text('Kaydet')),
          ],
        ),
      ),
    );
    quantity.dispose();
    minimum.dispose();
    if (result != null && mounted) {
      setState(() => _details[item] = result);
      await _save();
    }
  }

  void _add() {
    final text = _normalize(_input.text);
    if (text.isEmpty) return;
    setState(() => _pantry.add(text));
    _input.clear();
    _save();
  }

  Future<void> _addMissing(GeneralRecipe recipe) async {
    final missing = recipe.ingredients.where((i) => !_have(i)).toSet();
    if (missing.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu tarif için eksik malzeme görünmüyor.')));
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final decoded = jsonDecode(prefs.getString('alisveris') ?? '[]');
      if (decoded is! List || decoded.any((e) => e is! String)) {
        throw const FormatException('Liste biçimi geçersiz');
      }
      final existing = decoded.cast<String>();
      final merged = <String>{...existing, ...missing};
      final added = merged.length - existing.toSet().length;
      if (!await prefs.setString('alisveris', jsonEncode(merged.toList()))) {
        throw StateError('Kaydedilemedi');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$added malzeme alışveriş listesine eklendi.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Alışveriş listesi güncellenemedi; mevcut kayıtlar korunuyor.')));
    }
  }

  void _detail(GeneralRecipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(child: SizedBox(
        height: MediaQuery.sizeOf(ctx).height * .8,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          Text(recipe.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: _purple)),
          Text('${recipe.category} • ${recipe.minutes} dakika'),
          const SizedBox(height: 16),
          const Text('Malzemeler', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          for (final ingredient in recipe.ingredients)
            ListTile(dense: true,
              leading: Icon(_have(ingredient) ? Icons.check_circle : Icons.add_circle_outline,
                color: _have(ingredient) ? Colors.green : Colors.deepOrange),
              title: Text(ingredient)),
          const SizedBox(height: 12),
          const Text('Hazırlanışı', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          for (var i = 0; i < recipe.steps.length; i++)
            Padding(padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text('${i + 1}. ${recipe.steps[i]}')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: () => _addMissing(recipe),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Eksikleri alışveriş listesine ekle')),
        ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Tümü', ...{for (final r in generalRecipes) r.category}];
    final query = _normalize(_search.text);
    final scored = <({GeneralRecipe recipe, int matched, int total})>[];
    final expiring = _pantry.where((p) { final d = _daysLeft(p); return d != null && d >= 0 && d <= 3; }).toList()..sort();
    final expired = _pantry.where((p) { final d = _daysLeft(p); return d != null && d < 0; }).toList()..sort();
    final lowStock = _pantry.where(_isLowStock).toList()..sort();
    final filteredPantry = _pantry.where((item) =>
      (_pantryQuery.isEmpty || item.contains(_normalize(_pantryQuery))) &&
      (_pantryCategory == 'Tümü' || _itemCategory(item) == _pantryCategory)).toList();
    filteredPantry.sort((a, b) {
      if (_expiringFirst) {
        final cmp = (_daysLeft(a) ?? 999999).compareTo(_daysLeft(b) ?? 999999);
        if (cmp != 0) return cmp;
      }
      return a.compareTo(b);
    });
    final priorityIngredients = _pantry.where((p) {
      final d = _daysLeft(p);
      return d != null && d >= 0 && d <= 3;
    }).toList();
    for (final r in generalRecipes) {
      if (_category != 'Tümü' && r.category != _category) continue;
      if (query.isNotEmpty && !_normalize(r.title).contains(query) &&
          !r.ingredients.any((i) => _normalize(i).contains(query))) { continue ; }
      final total = r.ingredients.length;
      if (total == 0) continue;
      final matched = r.ingredients.where(_have).length;
      if (_onlyComplete && matched != total) continue;
      scored.add((recipe: r, matched: matched, total: total));
    }
    scored.sort((a, b) {
      final aScore = a.matched / a.total;
      final bScore = b.matched / b.total;
      final cmp = bScore.compareTo(aScore);
      if (cmp != 0) return cmp;
      return b.matched.compareTo(a.matched);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FC),
      appBar: AppBar(title: const Text('Evdeki malzemeler'), backgroundColor: const Color(0xFFFFD9ED)),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView(padding: const EdgeInsets.all(14), children: [
          const Text('Dolabımda neler var?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: _purple)),
          const SizedBox(height: 6),
          const Text('Malzemeleri tek tek ekle. Öneriler yaklaşık metin eşleşmesine göre sıralanır; miktar yeterliliğini ayrıca kontrol et.'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: _input,
              onSubmitted: (_) => _add(),
              decoration: const InputDecoration(labelText: 'Örn. domates, yumurta, süt',
                border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _add, tooltip: 'Malzeme ekle', icon: const Icon(Icons.add)),
            IconButton(onPressed: _quickAdd, tooltip: 'Miktarıyla hızlı ekle', icon: const Icon(Icons.playlist_add)),
          ]),
          const SizedBox(height: 10),
          if (_pantry.isEmpty) const Text('Henüz malzeme eklenmedi.'),
          Wrap(spacing: 7, runSpacing: 5, children: [
            for (final item in (_pantry.toList()..sort())) InputChip(
              label: Text(item), onDeleted: () { setState(() { _pantry.remove(item); _details.remove(item); }); _save(); }),
          ]),
          const SizedBox(height: 12),
          Card(color: const Color(0xFFFFEAF4), child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Mutfak envanteri özeti', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _purple)),
              Text('Toplam: ${_pantry.length} ürün • Miktarı girilen: ${_pantry.where((p) => (_details[p]?['quantity'] ?? '').isNotEmpty).length} • Tarihi girilen: ${_pantry.where((p) => _expiry(p) != null).length}'),
              Text('3 gün içinde son kullanma: ${expiring.length} • Tarihi geçmiş: ${expired.length}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
              if (expiring.isNotEmpty) Text('Yaklaşan: ${expiring.join(', ')}'),
              Text('Azalan stok: ${lowStock.length} • Normal stok: ${_pantry.length - lowStock.length}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
              if (expired.isNotEmpty) Text('Tarihi geçmiş: ${expired.join(', ')}',
                style: const TextStyle(color: Colors.deepOrange)),
              const SizedBox(height: 4),
              const Text('Ürün miktarları bilgi amaçlıdır; tariflerin miktar yeterliliği otomatik doğrulanmaz.',
                style: TextStyle(fontSize: 12)),
            ]),
          )),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: [
            OutlinedButton.icon(onPressed: _showConsumptionReport, icon: const Icon(Icons.insights_outlined), label: const Text('Tüketim raporu')),
            OutlinedButton.icon(onPressed: _showStockAlerts, icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Uyarı merkezi')),
            FilledButton.tonalIcon(onPressed: _sendLowStockToShopping,
              icon: const Icon(Icons.add_shopping_cart), label: const Text('Azalanları alışverişe ekle')),
          ]),
          const SizedBox(height: 10),
          TextField(onChanged: (value) => setState(() => _pantryQuery = value),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search),
              labelText: 'Envanterde ürün ara', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: [
            for (final category in ['Tümü', 'Sebze ve meyve', 'Et ve balık', 'Süt ürünleri', 'Tahıl ve bakliyat', 'Diğer'])
              ChoiceChip(label: Text(category), selected: _pantryCategory == category,
                onSelected: (_) => setState(() => _pantryCategory = category)),
          ]),
          SwitchListTile(contentPadding: EdgeInsets.zero,
            title: const Text('Son kullanma tarihi yaklaşanlar önce'),
            value: _expiringFirst, onChanged: (value) => setState(() => _expiringFirst = value)),
          Text('Gösterilen: ${filteredPantry.length} / ${_pantry.length} ürün • Tüketim işlemi: ${_usage.values.fold<int>(0, (sum, n) => sum + n)}',
            style: const TextStyle(color: _purple)),
          const SizedBox(height: 10),
          const Text('Ürün miktarı ve son kullanma tarihini düzenlemek için ürünün üzerine dokun.',
            style: TextStyle(fontSize: 12, color: _purple)),
          for (final item in filteredPantry) Card(
            color: _daysLeft(item) != null && _daysLeft(item)! < 0 ? const Color(0xFFFFE2DC) : Colors.white,
            child: ListTile(
              dense: true,
              title: Text(item),
              subtitle: Text([
                if ((_details[item]?['quantity'] ?? '').isNotEmpty) 'Miktar: ${_details[item]!['quantity']}',
                if ((_details[item]?['minimum'] ?? '').isNotEmpty) 'Minimum: ${_details[item]!['minimum']}',
                if (_isLowStock(item)) 'Stok azaldı: ${_suggestedPurchase(item)}',
                if (_expiry(item) != null) 'SKT: ${_details[item]!['expiry']}',
                if (_daysLeft(item) != null && _daysLeft(item)! < 0) 'Tarihi geçmiş',
                if (_daysLeft(item) != null && _daysLeft(item)! >= 0 && _daysLeft(item)! <= 3) 'Son kullanma tarihi yaklaşıyor',
              ].join(' • ').isEmpty ? 'Miktar / tarih ekle' : [
                if ((_details[item]?['quantity'] ?? '').isNotEmpty) 'Miktar: ${_details[item]!['quantity']}',
                if ((_details[item]?['minimum'] ?? '').isNotEmpty) 'Minimum: ${_details[item]!['minimum']}',
                if (_isLowStock(item)) 'Stok azaldı: ${_suggestedPurchase(item)}',
                if (_expiry(item) != null) 'SKT: ${_details[item]!['expiry']}',
                if (_daysLeft(item) != null && _daysLeft(item)! < 0) 'Tarihi geçmiş',
                if (_daysLeft(item) != null && _daysLeft(item)! >= 0 && _daysLeft(item)! <= 3) 'Son kullanma tarihi yaklaşıyor',
              ].join(' • ')),
              trailing: Wrap(children: [
                IconButton(tooltip: 'Tüketim kaydet', icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _consume(item)),
                IconButton(tooltip: 'Ürünü sil', icon: const Icon(Icons.delete_outline),
                  onPressed: () { setState(() { _pantry.remove(item); _details.remove(item); }); _save(); }),
              ]),
              onTap: () => _editItem(item),
            ),
          ),
          if (priorityIngredients.isNotEmpty) Card(color: const Color(0xFFFFEAF4), child: Padding(
            padding: const EdgeInsets.all(12), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Önce tüketilmesi önerilen ürünlerle tarifler',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _purple)),
                const Text('Son kullanma tarihine 3 gün veya daha az kalan ürünler; tarihi geçmiş ürünler dahil edilmez.'),
                for (final recipe in (generalRecipes.where((r) => r.ingredients.any((i) =>
                  priorityIngredients.any((p) {
                    final n = _ingredientName(i);
                    return n == p || (p.length >= 4 && n.contains(p));
                  }))).take(8)))
                  ListTile(dense: true, title: Text(recipe.title),
                    subtitle: Text('${recipe.minutes} dk'), onTap: () => _detail(recipe)),
              ]))),
          const Divider(height: 28),
          const Text('Tarif önerileri', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: _purple)),
          const SizedBox(height: 8),
          TextField(controller: _search, onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search),
              hintText: 'Tarif veya malzeme ara', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final c in categories) Padding(padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(label: Text(c), selected: _category == c,
                onSelected: (_) => setState(() => _category = c))),
          ])),
          SwitchListTile(contentPadding: EdgeInsets.zero,
            title: const Text('Yalnızca tüm malzemeleri bulunan tarifler'),
            value: _onlyComplete, onChanged: (v) => setState(() => _onlyComplete = v)),
          Text('${scored.length} tarif • Uygunluk yaklaşık malzeme eşleşmesidir',
            style: const TextStyle(color: _purple)),
          const SizedBox(height: 8),
          for (final result in scored) Card(color: Colors.white, child: ListTile(
            title: Text(result.recipe.title),
            subtitle: Text('${result.recipe.category} • ${result.recipe.minutes} dk • '
              '${result.matched}/${result.total} malzeme var'),
            leading: CircleAvatar(backgroundColor: const Color(0xFFFFD9ED),
              child: Text('${(result.matched * 100 / result.total).round()}%',
                style: const TextStyle(fontSize: 11, color: _purple))),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _detail(result.recipe),
          )),
        ]),
    );
  }
}
