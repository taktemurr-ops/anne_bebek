import '../utils/dialog_helpers.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'dart:convert';
import 'package:flutter/material.dart' hide Text;
import '../services/secure_health_store.dart';
import '../data/baby_care_guidance.dart';

/// A parent-maintained journal. It is not a diagnostic tool or an official
/// vaccination schedule. Medical schedules must be verified with clinicians.
class BabyHealthPage extends StatefulWidget {
  const BabyHealthPage({super.key});
  @override
  State<BabyHealthPage> createState() => _BabyHealthPageState();
}

class _BabyHealthPageState extends State<BabyHealthPage> {
  static const _key = 'baby_health_journal_v41';
  static const _sections = <String>['Aşı ve kontroller', 'Gelişim basamakları', 'Hastalık ve belirtiler', 'Alerji ve besin gözlemleri', 'İlaç takibi', 'Diş gelişimi', 'Doktor randevuları', 'Günlük bakım'];
  final List<Map<String, String>> _entries = [];
  bool _loading = true;
  String? _error;
  int _section = 0;
  String _query = '';
  bool _showCompleted = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final raw = await SecureHealthStore.read(_key);
      final decoded = jsonDecode(raw ?? '[]') as List<dynamic>;
      final records = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
      records.sort((a,b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
      if (mounted) setState(() { _entries.addAll(records); _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Kayıtlar okunamadı. Veriler silinmedi; lütfen yedeğinizi koruyun.'; _loading = false; });
    }
  }

  Future<void> _add({Map<String, String>? existing}) async {
    final title = TextEditingController(text: existing?['title'] ?? '');
    final notes = TextEditingController(text: existing?['notes'] ?? '');
    DateTime date = DateTime.tryParse(existing?['date'] ?? '') ?? DateTime.now();
    bool completed = existing?['completed'] == 'true';
    final sectionName = existing?['section'] ?? _sections[_section];
    final item = await showDialogAndDispose<Map<String, String>>(disposables: [title, notes], context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
      title: Text(existing == null ? 'Yeni kayıt: $sectionName' : 'Kaydı düzenle: $sectionName'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, maxLength: 100, decoration: InputDecoration(labelText: t('Başlık / aşı / belirti / gözlem'))),
        TextField(controller: notes, maxLines: 3, maxLength: 1000, decoration: InputDecoration(labelText: t('Açıklama (isteğe bağlı)'))),
        OutlinedButton.icon(icon: const Icon(Icons.calendar_month), label: Text('${date.day}.${date.month}.${date.year}'), onPressed: () async {
          final picked = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100));
          if (picked != null) update(() => date = picked);
        }),
        if (sectionName == _sections[0] || sectionName == _sections[1] || sectionName == 'Doktor randevuları') CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Tamamlandı / uygulandı'), value: completed, onChanged: (v) => update(() => completed = v ?? false)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
        FilledButton(onPressed: () {
          if (title.text.trim().isEmpty) return;
          Navigator.pop(ctx, {'section': sectionName, 'title': title.text.trim(), 'notes': notes.text.trim(), 'date': date.toIso8601String(), 'completed': completed.toString()});
        }, child: const Text('Kaydet'))],
    )));
    if (item == null || !mounted) return;
    final previous = List<Map<String, String>>.from(_entries);
    setState(() {
      if (existing == null) { _entries.insert(0, item); }
      else { final index = _entries.indexOf(existing); if (index >= 0) _entries[index] = item; }
      _entries.sort((a,b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    });
    await _saveOrRollback(previous);
  }

  Future<void> _saveOrRollback(List<Map<String, String>> previous) async {
    try { await SecureHealthStore.write(_key, jsonEncode(_entries)); }
    catch (_) {
      if (!mounted) return;
      setState(() { _entries..clear()..addAll(previous); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt saklanamadı. Değişiklik geri alındı.')));
    }
  }

  Future<void> _remove(Map<String, String> entry) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Kaydı sil?'), content: Text(entry['title'] ?? ''),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (ok != true || !mounted) return;
    final previous = List<Map<String, String>>.from(_entries);
    setState(() => _entries.remove(entry));
    await _saveOrRollback(previous);
  }

  Future<void> _toggle(Map<String, String> entry) async {
    final previous = _entries.map((e) => Map<String, String>.from(e)).toList();
    setState(() => entry['completed'] = (entry['completed'] != 'true').toString());
    await _saveOrRollback(previous);
  }

  void _showGuidance() {
    final selected = _sections[_section];
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text('$selected • Bilgilendirme'),
      content: SizedBox(width: double.maxFinite, child: ListView(
        shrinkWrap: true, children: [for (final tip in babyCareGuidance[selected] ?? <String>[])
          Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('• $tip'))],
      )),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _sections[_section];
    final query = _query.trim().toLowerCase();
    final records = _entries.where((e) => e['section'] == selected &&
      (_showCompleted || e['completed'] != 'true') &&
      (query.isEmpty || '${e['title'] ?? ''} ${e['notes'] ?? ''}'.toLowerCase().contains(query))).toList();
    final total = _entries.where((e) => e['section'] == selected).length;
    return Scaffold(appBar: AppBar(title: const Text('Bebek Sağlığı ve Gelişimi'), actions: [IconButton(tooltip: t('Bakım rehberi'), icon: const Icon(Icons.info_outline), onPressed: _showGuidance)]),
      floatingActionButton: _loading || _error != null ? null : FloatingActionButton.extended(onPressed: () => _add(), icon: const Icon(Icons.add), label: const Text('Kayıt ekle')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(_error!))) :
      Column(children: [
        const Padding(padding: EdgeInsets.all(12), child: Text('Kişisel sağlık günlüğüdür; tanı, tedavi veya resmi aşı kartı değildir. İlaç ve aşı planlarını sağlık uzmanıyla doğrulayın. Acil belirtilerde sağlık kuruluşuna başvurun.')),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: TextField(
          decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: t('Başlık veya notlarda ara'), border: OutlineInputBorder()),
          onChanged: (value) => setState(() => _query = value),
        )),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
          Expanded(child: Text('$selected • $total kayıt', maxLines: 2, overflow: TextOverflow.ellipsis)),
          const Text('Tamamlananlar'),
          Switch(value: _showCompleted, onChanged: (value) => setState(() => _showCompleted = value)),
        ])),
        SizedBox(height: 56, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _sections.length, itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(label: Text(_sections[i]), selected: _section == i, onSelected: (_) => setState(() => _section = i))))),
        Expanded(child: records.isEmpty ? const Center(child: Text('Henüz kayıt yok. Sağ alttan yeni kayıt ekleyin.')) : ListView.builder(padding: const EdgeInsets.only(bottom: 90), itemCount: records.length, itemBuilder: (ctx, i) {
          final item = records[i]; final d = DateTime.tryParse(item['date'] ?? '');
          return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(
            title: Text(item['title'] ?? ''),
            subtitle: Text('${d == null ? '' : '${d.day}.${d.month}.${d.year}'}${(item['notes'] ?? '').isEmpty ? '' : '\n${item['notes']}'}'),
            isThreeLine: (item['notes'] ?? '').isNotEmpty,
            leading: (_section == 0 || _section == 1 || selected == 'Doktor randevuları') ? Checkbox(value: item['completed'] == 'true', onChanged: (_) => _toggle(item)) : const Icon(Icons.notes),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(tooltip: t('Düzenle'), icon: const Icon(Icons.edit_outlined), onPressed: () => _add(existing: item)),
              IconButton(tooltip: t('Sil'), icon: const Icon(Icons.delete_outline), onPressed: () => _remove(item)),
            ]),
          ));
        })),
      ]));
  }
}
