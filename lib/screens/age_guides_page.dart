import 'dart:convert';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import '../data/age_guides.dart';
import '../data/monthly_age_content.dart';
import '../services/secure_health_store.dart';

class AgeGuidesPage extends StatefulWidget {
  final DateTime? birth;
  const AgeGuidesPage({super.key, this.birth});
  @override
  State<AgeGuidesPage> createState() => _AgeGuidesPageState();
}

class _AgeGuidesPageState extends State<AgeGuidesPage> {
  final _search = TextEditingController();
  final Set<String> _completed = {};
  bool _loading = true;
  String? _error;
  String _category = 'Tümü';
  int? _selectedMonth;
  bool _showMonthly = true;
  int get _displayMonth => (_selectedMonth ?? _months ?? 0).clamp(0, 72);
  int? get _months => ageInCompletedMonths(widget.birth, DateTime.now());

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final saved = await SecureHealthStore.read('age_guide_checklist_v56');
      if (saved != null) {
        final values = (jsonDecode(saved) as List).cast<String>();
        _completed.addAll(values.where((v) => ageGuides.any((g) => g.id == v) || RegExp(r'^monthly_([0-9]|[1-6][0-9]|7[0-2])_(Gelişim|Beslenme|Uyku|Oyun|Bakım|Güvenlik)$').hasMatch(v)));
      }
    } catch (_) { _error = 'Kayıtlar yüklenemedi. Önceki veriler silinmedi.'; }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggle(String id, bool checked) async {
    final previous = Set<String>.of(_completed);
    setState(() { if (checked) { _completed.add(id); } else { _completed.remove(id); } _error = null; });
    try {
      await SecureHealthStore.write('age_guide_checklist_v56', jsonEncode(_completed.toList()..sort()));
    } catch (_) {
      if (mounted) setState(() { _completed..clear()..addAll(previous); _error = 'Kaydedilemedi, değişiklik geri alındı.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthly = guidesForMonth(_displayMonth).where((g) =>
        (_category == 'Tümü' || g.category == _category) &&
        ('${g.title} ${g.description} ${g.category}'.toLowerCase().contains(_search.text.toLowerCase()))).toList();
    final visible = ageGuides.where((g) => g.matchesAge(_months) &&
        (_category == 'Tümü' || g.category == _category) && g.matchesQuery(_search.text)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Yaşa uygun yaşam rehberi')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_months == null ? 'Doğum tarihi girilmedi: tüm yaş grupları gösteriliyor.' : 'Bebeğinizin yaşı: $_months tamamlanmış ay', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Bu içerikler genel bilgilendirme amaçlıdır; kişisel tıbbi değerlendirme yerine geçmez.'),
          if (_error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('0–72 ay aylık rehber', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Her ay için gelişim, beslenme, uyku, oyun, bakım ve güvenlik. İçerikler genel öneridir; aylık gelişim kontrol listesi değildir.'),
            Row(children: [
              IconButton(tooltip: t('Önceki ay'), onPressed: _displayMonth > 0 ? () => setState(() => _selectedMonth = _displayMonth - 1) : null, icon: const Icon(Icons.chevron_left)),
              Expanded(child: DropdownButton<int>(isExpanded: true, value: _displayMonth, items: List.generate(73, (m) => DropdownMenuItem(value: m, child: Text('$m. ay'))), onChanged: (v) => setState(() => _selectedMonth = v))),
              IconButton(tooltip: t('Sonraki ay'), onPressed: _displayMonth < 72 ? () => setState(() => _selectedMonth = _displayMonth + 1) : null, icon: const Icon(Icons.chevron_right)),
            ]),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Aylık rehberi göster'), value: _showMonthly, onChanged: (v) => setState(() => _showMonthly = v)),
          ]))),
          const SizedBox(height: 12),
          TextField(controller: _search, decoration: InputDecoration(prefixIcon: Icon(Icons.search), labelText: t('Rehberde ara'), border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(initialValue: _category, decoration: InputDecoration(labelText: t('Kategori')),
            items: ['Tümü', 'Gelişim', 'Beslenme', 'Uyku', 'Oyun', 'Bakım', 'Güvenlik', 'Sağlık', 'Aile'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Tümü')),
          const SizedBox(height: 12),
          if (_showMonthly) ...[
            Text('${monthly.length} aylık konu • ${monthly.where((g) => _completed.contains(g.id)).length} okundu', style: Theme.of(context).textTheme.titleMedium),
            for (final guide in monthly) Card(child: CheckboxListTile(
              value: _completed.contains(guide.id), onChanged: (v) => _toggle(guide.id, v ?? false),
              title: Text(guide.title), subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('${guide.category}\n${guide.description}'.replaceAll('\n', '\n'))),
              isThreeLine: true, controlAffinity: ListTileControlAffinity.leading,
            )),
            const Divider(),
            const Text('Ek yaş grubu önerileri', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
          Text('${visible.length} öneri • ${visible.where((g) => _completed.contains(g.id)).length} okundu', style: Theme.of(context).textTheme.labelLarge),
          for (final guide in visible) Card(child: CheckboxListTile(
            value: _completed.contains(guide.id), onChanged: (v) => _toggle(guide.id, v ?? false),
            title: Text(guide.title), subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('${guide.category} • ${guide.fromMonth}–${guide.toMonth} ay\n${guide.description}')),
            isThreeLine: true, controlAffinity: ListTileControlAffinity.leading,
          )),
          if (visible.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Bu filtreye uygun içerik bulunamadı.')),
        ],
      ),
    );
  }
}
