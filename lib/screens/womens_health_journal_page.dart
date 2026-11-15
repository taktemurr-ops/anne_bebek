import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/secure_health_store.dart';

/// Symptom diary only: not a diagnosis, screening or fertility prediction.
class WomensHealthJournalPage extends StatefulWidget {
  const WomensHealthJournalPage({super.key});
  @override
  State<WomensHealthJournalPage> createState() => _WomensHealthJournalPageState();
}

class _WomensHealthJournalPageState extends State<WomensHealthJournalPage> {
  static const storageKey = 'womens_health_journal_v46';
  static const categories = <String>[
    'Döngü ve belirtiler', 'Gebelik ve kontroller',
    'Doğum sonrası', 'Perimenopoz / menopoz', 'PCOS belirti günlüğü', 'Endometriozis belirti günlüğü', 'Tahlil ve kontroller', 'Diğer sağlık notları',
  ];
  final List<Map<String, String>> entries = [];
  int category = 0;
  bool loading = true;
  String? error;
  bool newestFirst = true;
  String search = '';

  static const prompts = <String, String>{
    'Döngü ve belirtiler': 'Kanama başlangıcı/bitişi, ağrı ve günlük etkileri not edin. Takvim doğum kontrol yöntemi değildir.',
    'Gebelik ve kontroller': 'Kontrol tarihlerini, doktor önerilerini ve sorularınızı kaydedin.',
    'Doğum sonrası': 'İyileşme, uyku, ruh hâli ve doktor kontrol notlarını kaydedin.',
    'Perimenopoz / menopoz': 'Sıcak basması, uyku ve döngü değişimlerini takip edin.',
    'PCOS belirti günlüğü': 'Döngü değişimi, cilt ve diğer belirtileri hekiminizle görüşmek için not edin.',
    'Endometriozis belirti günlüğü': 'Ağrının günü, şiddeti ve günlük yaşam üzerindeki etkisini kaydedin.',
    'Tahlil ve kontroller': 'Tahlil tarihini, birimi, referans aralığını ve hekim değerlendirmesini not edin.',
    'Diğer sağlık notları': 'Diğer sağlık gözlemlerinizi ve sorularınızı kaydedin.',
  };

  List<Map<String, String>> visibleEntries() {
    final query = search.trim().toLowerCase();
    final result = entries.where((e) => e['category'] == categories[category] &&
      (query.isEmpty || (e['title'] ?? '').toLowerCase().contains(query) ||
        (e['note'] ?? '').toLowerCase().contains(query))).toList();
    result.sort((a, b) => newestFirst
        ? (b['date'] ?? '').compareTo(a['date'] ?? '')
        : (a['date'] ?? '').compareTo(b['date'] ?? ''));
    return result;
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final raw = await SecureHealthStore.read(storageKey);
      final parsed = jsonDecode(raw ?? '[]') as List<dynamic>;
      final loaded = parsed.map((e) => Map<String, String>.from(e as Map)).toList();
      loaded.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
      if (mounted) setState(() { entries.addAll(loaded); loading = false; });
    } catch (_) {
      if (mounted) setState(() { error = 'Sağlık günlüğü açılamadı. Kayıtlar silinmedi.'; loading = false; });
    }
  }

  Future<void> _save(List<Map<String, String>> before) async {
    try { await SecureHealthStore.write(storageKey, jsonEncode(entries)); }
    catch (_) {
      if (!mounted) return;
      setState(() { entries..clear()..addAll(before); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydetme başarısız. Değişiklik geri alındı.')));
    }
  }

  Future<void> _add() async {
    final title = TextEditingController();
    final note = TextEditingController();
    DateTime date = DateTime.now();
    int severity = 0;
    final selectedCategory = categories[category];
    final result = await showDialog<Map<String, String>>(context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (dialogContext, refresh) => AlertDialog(
        title: Text('Yeni kayıt • $selectedCategory'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, maxLength: 100, decoration: const InputDecoration(labelText: 'Belirti / kontrol / konu')),
          TextField(controller: note, maxLength: 1000, maxLines: 3, decoration: const InputDecoration(labelText: 'Notlar (isteğe bağlı)')),
          OutlinedButton.icon(icon: const Icon(Icons.calendar_today), label: Text('${date.day}.${date.month}.${date.year}'),
            onPressed: () async { final chosen = await showDatePicker(context: dialogContext, initialDate: date, firstDate: DateTime(1950), lastDate: DateTime(2100)); if (chosen != null) refresh(() => date = chosen); }),
          DropdownButtonFormField<int>(initialValue: severity, decoration: const InputDecoration(labelText: 'Şiddet / etki'),
            items: const [DropdownMenuItem(value: 0, child: Text('Belirtilmedi')), DropdownMenuItem(value: 1, child: Text('Hafif')), DropdownMenuItem(value: 2, child: Text('Orta')), DropdownMenuItem(value: 3, child: Text('Şiddetli'))],
            onChanged: (v) => refresh(() => severity = v ?? 0)),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Vazgeç')),
          FilledButton(onPressed: () { if (title.text.trim().isEmpty) return; Navigator.pop(dialogContext, {
            'category': selectedCategory, 'title': title.text.trim(), 'note': note.text.trim(),
            'date': date.toIso8601String(), 'severity': severity.toString(),
          }); }, child: const Text('Kaydet'))],
      )));
    title.dispose(); note.dispose();
    if (result == null || !mounted) return;
    final before = entries.map((e) => Map<String, String>.from(e)).toList();
    setState(() { entries.add(result); entries.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? '')); });
    await _save(before);
  }

  Future<void> _edit(Map<String, String> entry) async {
    final title = TextEditingController(text: entry['title'] ?? '');
    final note = TextEditingController(text: entry['note'] ?? '');
    final changed = await showDialog<Map<String, String>>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kaydı düzenle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, maxLength: 100, decoration: const InputDecoration(labelText: 'Başlık')),
          TextField(controller: note, maxLength: 1000, maxLines: 4, decoration: const InputDecoration(labelText: 'Not')),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            if (title.text.trim().isEmpty) return;
            Navigator.pop(ctx, {...entry, 'title': title.text.trim(), 'note': note.text.trim()});
          }, child: const Text('Kaydet'))],
      ));
    title.dispose(); note.dispose();
    if (changed == null || !mounted) return;
    final before = entries.map((e) => Map<String, String>.from(e)).toList();
    setState(() { final index = entries.indexOf(entry); if (index >= 0) entries[index] = changed; });
    await _save(before);
  }

  Future<void> _delete(Map<String, String> entry) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Kaydı sil?'), content: Text(entry['title'] ?? ''),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (confirmed != true || !mounted) return;
    final before = entries.map((e) => Map<String, String>.from(e)).toList();
    setState(() => entries.remove(entry));
    await _save(before);
  }

  @override
  Widget build(BuildContext context) {
    final shown = visibleEntries();
    final recent = shown.where((e) {
      final date = DateTime.tryParse(e['date'] ?? '');
      return date != null && !date.isAfter(DateTime.now()) &&
          DateTime.now().difference(date).inDays < 30;
    }).length;
    return Scaffold(appBar: AppBar(title: const Text('Kadın Sağlığı Günlüğü')),
      floatingActionButton: loading || error != null ? null : FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Kayıt ekle')),
      body: loading ? const Center(child: CircularProgressIndicator()) : error != null ? Center(child: Text(error!)) : Column(children: [
        const Padding(padding: EdgeInsets.all(14), child: Text('Bu günlük belirtileri ve kontrolleri not etmek içindir; tanı, tedavi veya doğurganlık tahmini sunmaz. Şiddetli veya ani belirtilerde sağlık kuruluşuna başvurun.')),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), child: Text(prompts[categories[category]] ?? '', style: Theme.of(context).textTheme.bodySmall)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [
          Expanded(child: Text('Toplam ${shown.length} kayıt • Son 30 gün: $recent')),
          TextButton.icon(onPressed: () => setState(() => newestFirst = !newestFirst),
            icon: const Icon(Icons.sort), label: Text(newestFirst ? 'Yeniden eskiye' : 'Eskiden yeniye')),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: TextField(
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Bu kategoride ara'),
          onChanged: (value) => setState(() => search = value))),
        SizedBox(height: 54, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: categories.length,
          itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(label: Text(categories[i]), selected: category == i, onSelected: (_) => setState(() => category = i))))),
        Expanded(child: shown.isEmpty ? const Center(child: Text('Bu kategoride henüz kayıt yok.')) : ListView.builder(
          padding: const EdgeInsets.only(bottom: 90), itemCount: shown.length, itemBuilder: (ctx, i) {
            final entry = shown[i]; final d = DateTime.tryParse(entry['date'] ?? '');
            const levels = ['Belirtilmedi', 'Hafif', 'Orta', 'Şiddetli'];
            final level = int.tryParse(entry['severity'] ?? '') ?? 0;
            return Card(child: ListTile(title: Text(entry['title'] ?? ''),
              subtitle: Text('${d == null ? '' : '${d.day}.${d.month}.${d.year}'} • ${levels[level.clamp(0, 3)]}${(entry['note'] ?? '').isEmpty ? '' : '\n${entry['note']}'}'),
              isThreeLine: (entry['note'] ?? '').isNotEmpty,
              onTap: () => _edit(entry),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(tooltip: 'Düzenle', icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(entry)),
                IconButton(tooltip: 'Sil', icon: const Icon(Icons.delete_outline), onPressed: () => _delete(entry)),
              ])));
          })),
      ]));
  }
}
