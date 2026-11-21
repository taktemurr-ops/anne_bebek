import '../utils/dialog_helpers.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/services.dart';
import '../services/child_calendar_export.dart';
import 'package:flutter/material.dart' hide Text;
import '../services/child_care_plans.dart';
import '../services/child_profiles.dart';
import '../services/secure_health_store.dart';

class ChildCarePlanPage extends StatefulWidget {
  final ChildProfile child;
  const ChildCarePlanPage({super.key, required this.child});
  @override
  State<ChildCarePlanPage> createState() => _ChildCarePlanPageState();
}

class _ChildCarePlanPageState extends State<ChildCarePlanPage> {
  static const _key = 'child_care_plan_v96';
  List<ChildCareItem> _all = [];
  bool _loading = true, _saving = false;
  String? _error;
  String _filter = 'Tümü';
  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final raw = await SecureHealthStore.read(_key);
      final items = decodeChildCareItems(raw);
      if (mounted) setState(() { _all = items; _error = null; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Kayıtlar okunamadı. Mevcut veriler silinmedi.');
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _save(List<ChildCareItem> next) async {
    if (_saving || _error != null) return;
    setState(() => _saving = true);
    try {
      await SecureHealthStore.write(_key, encodeChildCareItems(next));
      if (mounted) setState(() => _all = next);
    } catch (_) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilemedi; eski kayıtlar korundu.'))); }
    } finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _edit(ChildCareItem original) async {
    await _openEditor(original: original);
  }

  Future<void> _add() async {
    await _openEditor();
  }

  Future<void> _openEditor({ChildCareItem? original}) async {
    final title = TextEditingController(), note = TextEditingController();
    if (original != null) { title.text = original.title; note.text = original.note; }
    var category = original?.category ?? 'Aşı';
    var date = original?.date ?? DateTime.now();
    final result = await showDialogAndDispose<ChildCareItem>(disposables: [title, note], context: context, builder: (ctx) =>
      StatefulBuilder(builder: (ctx, refresh) => AlertDialog(
        title: Text(original == null ? 'Takip kaydı ekle' : 'Takip kaydını düzenle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(initialValue: category, decoration: InputDecoration(labelText: t('Kategori')),
            items: ['Aşı', 'Doktor kontrolü', 'Gelişim gözlemi'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) { if (v != null) refresh(() => category = v); }),
          TextField(controller: title, maxLength: 90, decoration: InputDecoration(labelText: t('Başlık / aşı adı'))),
          TextField(controller: note, maxLines: 3, maxLength: 500, decoration: InputDecoration(labelText: t('Not / sağlık kuruluşu'))),
          Text('Tarih, çocuğun doğum tarihinden önce olamaz.', style: Theme.of(ctx).textTheme.bodySmall),
          OutlinedButton.icon(icon: const Icon(Icons.event),
            label: Text('Tarih: ${date.day}.${date.month}.${date.year}'),
            onPressed: () async {
              final selected = await showDatePicker(context: ctx, initialDate: date,
                firstDate: widget.child.birthDate, lastDate: DateTime(2100));
              if (selected != null) refresh(() => date = selected);
            }),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            if (title.text.trim().isEmpty || date.isBefore(DateTime(widget.child.birthDate.year, widget.child.birthDate.month, widget.child.birthDate.day))) return;
            Navigator.pop(ctx, ChildCareItem(id: original?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
              childId: widget.child.id, category: category, title: title.text.trim(),
              note: note.text.trim(), date: date, completed: original?.completed ?? false));
          }, child: const Text('Kaydet'))],
      )));
    if (result != null && mounted) {
      final next = original == null ? [..._all, result] :
          _all.map((item) => item.id == original.id ? result : item).toList();
      await _save(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = careItemsForChild(_all, widget.child.id);
    final pending = items.where((item) => !item.completed).length;
    final now = DateTime.now();
    final overdue = items.where((item) => careDueStatus(item, now) == CareDueStatus.overdue).length;
    final today = items.where((item) => careDueStatus(item, now) == CareDueStatus.today).length;
    final visible = filterCareItems(_all, widget.child.id, now, _filter);
    return Scaffold(
      appBar: AppBar(title: Text('${widget.child.name} • Sağlık planı'), actions: [
        IconButton(tooltip: t('Takvimi panoya kopyala'), icon: const Icon(Icons.event_available_outlined),
          onPressed: _loading || _error != null ? null : () async {
            final content = buildChildCareCalendar(_all, widget.child.id, widget.child.name);
            await Clipboard.setData(ClipboardData(text: content));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(
              'Takvim metni panoya kopyalandı. .ics dosyasına kaydedip takvime aktarabilirsiniz.')));
          }),
      ]),
      floatingActionButton: _loading || _saving || _error != null ? null :
        FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Kayıt ekle')),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView(padding: const EdgeInsets.all(16), children: [
          const Card(child: Padding(padding: EdgeInsets.all(12), child: Text(
            'Bu bölüm yalnızca sizin girdiğiniz aşı, kontrol ve gelişim notlarını takip eder. '
            'Resmî aşı takvimini otomatik oluşturmaz; tıbbi değerlendirme yerine geçmez. '
            'Aşı tarihlerini sağlık kuruluşunuzla doğrulayın.'))),
          if (_error != null) Card(child: ListTile(title: Text(_error!),
            trailing: TextButton(onPressed: () { setState(() => _loading = true); _load(); }, child: const Text('Tekrar dene')))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Toplam ${items.length} kayıt • $pending bekleyen',
              style: Theme.of(context).textTheme.titleMedium)),
          Text('$overdue geciken • $today bugün', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 6, children: ['Tümü', 'Geciken', 'Bugün', 'Yaklaşan', 'Tamamlanan'].map((f) => ChoiceChip(
            label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f))).toList()),
          if (items.isEmpty && _error == null) const Padding(padding: EdgeInsets.all(16),
            child: Text('Henüz kayıt yok. Sağlık kuruluşunuzdan aldığınız tarihleri ekleyebilirsiniz.')),
          for (final item in visible) Card(child: ListTile(
            leading: Checkbox(value: item.completed, onChanged: _saving ? null : (v) {
              if (v != null) _save(_all.map((e) => e.id == item.id ? e.withCompleted(v) : e).toList());
            }),
            title: Text(item.title),
            tileColor: careDueStatus(item, now) == CareDueStatus.overdue
              ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4) : null,
            subtitle: Text('${item.category} • ${item.date.day}.${item.date.month}.${item.date.year}'
              '${item.note.isEmpty ? '' : '\n${item.note}'}'),
            isThreeLine: item.note.isNotEmpty,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit_outlined), tooltip: t('Düzenle'),
                onPressed: _saving ? null : () => _edit(item)),
              IconButton(icon: const Icon(Icons.delete_outline), tooltip: t('Sil'),
              onPressed: _saving ? null : () async {
                final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                  title: const Text('Kayıt silinsin mi?'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
                if (yes == true) await _save(_all.where((e) => e.id != item.id).toList());
              }),
            ]),
          )),
          const SizedBox(height: 85),
        ]),
    );
  }
}
