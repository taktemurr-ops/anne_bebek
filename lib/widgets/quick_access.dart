import 'package:flutter/material.dart' hide Text;
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';

/// Arama hem Türkçe büyük/küçük harf hem de boşluk farklılıklarını tolere eder.
String normalizeQuickSearch(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll('ı', 'i')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ş', 's')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c');

class QuickAccessItem {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onOpen;
  const QuickAccessItem({required this.title, required this.description,
    required this.icon, required this.onOpen});
}

class QuickAccessSheet extends StatefulWidget {
  final List<QuickAccessItem> items;
  const QuickAccessSheet({super.key, required this.items});

  @override
  State<QuickAccessSheet> createState() => _QuickAccessSheetState();
}

/// Arama metinleri yalnızca öğe listesi değiştiğinde indekslenir.
/// Her tuş vuruşunda açıklamaları tekrar normalize etmeyi önler.
class QuickSearchIndex {
  final List<QuickAccessItem> items;
  late final List<String> _keys = items
      .map((item) => normalizeQuickSearch('${item.title} ${item.description}'))
      .toList(growable: false);

  QuickSearchIndex(this.items);

  List<QuickAccessItem> search(String query) {
    final needle = normalizeQuickSearch(query);
    if (needle.isEmpty) return items;
    return [for (var i = 0; i < items.length; i++)
      if (_keys[i].contains(needle)) items[i]];
  }
}

class _QuickAccessSheetState extends State<QuickAccessSheet> {
  String query = '';
  late QuickSearchIndex _index;

  @override
  void initState() {
    super.initState();
    _index = QuickSearchIndex(widget.items);
  }

  @override
  void didUpdateWidget(covariant QuickAccessSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items)) {
      _index = QuickSearchIndex(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _index.search(query);
    return SafeArea(child: Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Hızlı erişim', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(autofocus: true, textInputAction: TextInputAction.search, onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(prefixIcon: Icon(Icons.search),
            hintText: t('Bölüm veya işlem ara'), border: OutlineInputBorder())),
        const SizedBox(height: 10),
        Flexible(child: results.isEmpty
          ? const Padding(padding: EdgeInsets.all(24), child: Text('Aramanızla eşleşen bölüm bulunamadı.'))
          : ListView.builder(itemCount: results.length, itemBuilder: (context, index) {
            final item = results[index];
            return ListTile(minVerticalPadding: 12, leading: Icon(item.icon), title: Text(item.title),
              subtitle: Text(item.description), trailing: const Icon(Icons.chevron_right),
              onTap: () { Navigator.of(context).pop(); item.onOpen(); });
          })),
      ]),
    ));
  }
}
