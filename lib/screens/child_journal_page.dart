import 'package:flutter/material.dart';
import '../services/child_journals.dart';
import '../services/child_profiles.dart';
import '../services/secure_health_store.dart';

class ChildJournalPage extends StatefulWidget {
  final ChildProfile child;
  const ChildJournalPage({super.key, required this.child});
  @override
  State<ChildJournalPage> createState() => _ChildJournalPageState();
}

class _ChildJournalPageState extends State<ChildJournalPage> {
  static const _key = 'child_journal_entries_v59';
  static const categories = ['Beslenme', 'Uyku', 'Kilo (kg)', 'Boy (cm)',
    'Baş çevresi (cm)', 'Belirti', 'Alerji gözlemi', 'Doktor kontrolü'];
  List<ChildJournalEntry> _all = [];
  bool _loading = true, _saving = false;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final data = decodeChildJournal(await SecureHealthStore.read(_key));
      if (mounted) setState(() { _all = data; _error = null; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Günlük okunamadı; kayıtlar korunuyor.');
    } finally { if (mounted) setState(() => _loading = false); }
  }
  Future<void> _save(List<ChildJournalEntry> next) async {
    if (_saving || _error != null) return;
    setState(() => _saving = true);
    try {
      await SecureHealthStore.write(_key, encodeChildJournal(next));
      if (mounted) setState(() => _all = next);
    } catch (_) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilemedi; eski kayıtlar korundu.'))); }
    } finally { if (mounted) setState(() => _saving = false); }
  }
  Future<void> _add() async {
    final note = TextEditingController();
    final number = TextEditingController();
    String category = categories.first;
    DateTime at = DateTime.now();
    final entry = await showDialog<ChildJournalEntry>(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: Text('${widget.child.name} · Yeni kayıt'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(initialValue: category,
              items: categories.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (s) { if (s != null) update(() => category = s); },
              decoration: const InputDecoration(labelText: 'Kategori')),
            TextField(controller: note, maxLines: 2, maxLength: 300,
              decoration: const InputDecoration(labelText: 'Açıklama / not')),
            if (category == 'Kilo (kg)' || category == 'Boy (cm)' || category == 'Baş çevresi (cm)')
              TextField(controller: number, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Ölçüm değeri')),
            OutlinedButton(onPressed: () async {
              final selected = await showDatePicker(context: ctx, initialDate: at,
                firstDate: widget.child.birthDate, lastDate: DateTime.now());
              if (selected != null) update(() => at = selected);
            }, child: Text('Tarih: ${at.day}.${at.month}.${at.year}')),
          ])),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            final isMeasure = category.contains('(kg)') || category.contains('(cm)');
            final parsed = double.tryParse(number.text.replaceAll(',', '.'));
            if (isMeasure && (parsed == null || !parsed.isFinite || parsed <= 0 || parsed > 300)) return;
            if (!isMeasure && note.text.trim().isEmpty) return;
            Navigator.pop(ctx, ChildJournalEntry(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              childId: widget.child.id, category: category, note: note.text.trim(),
              at: at, value: isMeasure ? parsed : null));
          }, child: const Text('Kaydet'))],
      )));
    note.dispose(); number.dispose();
    if (entry != null && mounted) await _save([..._all, entry]);
  }
  Future<void> _edit(ChildJournalEntry original) async {
    if (_saving || _error != null) return;
    final note = TextEditingController(text: original.note);
    final number = TextEditingController(text: original.value?.toString() ?? '');
    DateTime at = original.at;
    final isMeasure = original.category == 'Kilo (kg)' ||
        original.category == 'Boy (cm)' || original.category == 'Baş çevresi (cm)';
    final changed = await showDialog<ChildJournalEntry>(context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: Text('${widget.child.name} · Kaydı düzenle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(original.category),
          TextField(controller: note, maxLines: 2, maxLength: 300,
            decoration: const InputDecoration(labelText: 'Açıklama / not')),
          if (isMeasure) TextField(controller: number,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Ölçüm değeri')),
          OutlinedButton(onPressed: () async {
            final selected = await showDatePicker(context: ctx,
              initialDate: at.isAfter(DateTime.now()) ? DateTime.now() :
                at.isBefore(widget.child.birthDate) ? widget.child.birthDate : at,
              firstDate: widget.child.birthDate, lastDate: DateTime.now());
            if (selected != null) update(() => at = selected);
          }, child: Text('Tarih: ${at.day}.${at.month}.${at.year}')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            final parsed = double.tryParse(number.text.replaceAll(',', '.'));
            if (isMeasure && (parsed == null || !parsed.isFinite || !parsed.isFinite || parsed <= 0 || parsed > 300)) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Geçerli bir ölçüm girin.')));
              return;
            }
            if (!isMeasure && note.text.trim().isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Not boş olamaz.')));
              return;
            }
            Navigator.pop(ctx, ChildJournalEntry(id: original.id,
              childId: original.childId, category: original.category,
              note: note.text.trim(), at: at, value: isMeasure ? parsed : null));
          }, child: const Text('Değişiklikleri kaydet')),
        ],
      )));
    note.dispose(); number.dispose();
    if (changed != null && mounted) {
      await _save(_all.map((entry) => entry.id == original.id &&
          entry.childId == widget.child.id ? changed : entry).toList());
    }
  }
  @override
  Widget build(BuildContext context) {
    final records = _all.where((e) => e.childId == widget.child.id).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    return Scaffold(appBar: AppBar(title: Text('${widget.child.name} · Günlük')),
      floatingActionButton: _loading || _saving || _error != null ? null :
        FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Kayıt ekle')),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD7EA), Color(0xFFE9DDFF)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.auto_awesome, color: Color(0xFF75466F)),
                SizedBox(width: 8), Text('Günlük bakım yolculuğu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF75466F)))]),
              const SizedBox(height: 8),
              Text('${widget.child.name} için ${records.length} kayıt',
                style: const TextStyle(color: Color(0xFF75466F))),
              const SizedBox(height: 8),
              const Text('Kayıtlar bu çocuğa özeldir. Ölçümler tıbbi değerlendirme yerine geçmez.',
                style: TextStyle(fontSize: 12, color: Color(0xFF75466F))),
            ]),
          ),
          const SizedBox(height: 12),
          if (_error != null) ListTile(title: Text(_error!), trailing: TextButton(
            onPressed: () { setState(() => _loading = true); _load(); }, child: const Text('Yeniden dene'))),
          if (records.isEmpty && _error == null) const ListTile(title: Text('Bu çocuk için henüz kayıt yok.')),
          for (final e in records) Card(child: ListTile(
            title: Text(e.category + (e.value == null ? '' : ': ${e.value}')),
            subtitle: Text('${e.at.day}.${e.at.month}.${e.at.year}  ${e.note}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(tooltip: 'Kaydı düzenle', icon: const Icon(Icons.edit_outlined),
                onPressed: _saving ? null : () => _edit(e)),
              IconButton(tooltip: 'Kaydı sil', icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : () async {
                final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                  title: const Text('Kayıt silinsin mi?'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
                if (ok == true) await _save(_all.where((x) => x.id != e.id || x.childId != widget.child.id).toList());
              }),
            ]))),
          const SizedBox(height: 80),
        ]));
  }
}
