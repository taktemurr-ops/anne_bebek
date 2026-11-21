import 'utils/dialog_helpers.dart';
import 'services/secure_health_store.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

/// Yerel-öncelikli aile yaşamı kayıt merkezi. Kayıtlar cihazın güvenli saklama alanında tutulur.
class LifeTool {
  final String group, name, hint;
  final IconData icon;
  final bool numeric;
  const LifeTool(this.group, this.name, this.hint, this.icon, {this.numeric = false});
}

const lifeTools = <LifeTool>[
  LifeTool('Bebek', 'Emzirme', 'Süre ve tarafı kaydet', Icons.child_friendly),
  LifeTool('Bebek', 'Mama', 'Miktar ve saat kaydı', Icons.local_drink, numeric: true),
  LifeTool('Bebek', 'Ek gıda', 'Yeni besin ve öğün günlüğü', Icons.restaurant),
  LifeTool('Bebek', 'Uyku', 'Uyku süresi ve notlar', Icons.bedtime),
  LifeTool('Bebek', 'Bez', 'Islak veya kirli bez', Icons.baby_changing_station),
  LifeTool('Bebek', 'Banyo', 'Banyo ve bakım kaydı', Icons.bathtub),
  LifeTool('Bebek', 'Dişler', 'Diş çıkma günlüğü', Icons.sentiment_satisfied_alt),
  LifeTool('Bebek', 'İlkler', 'İlk adım, kelime ve anılar', Icons.auto_awesome),
  LifeTool('Bebek', 'Boy ve kilo notları', 'Ölçüm açıklamaları', Icons.monitor_weight),
  LifeTool('Bebek', 'Aşı kayıtları', 'Yapılan aşı ve tarihleri', Icons.vaccines),
  LifeTool('Bebek', 'Doktor notları', 'Kontrol ve doktor notları', Icons.medical_services),
  LifeTool('Bebek', 'Alerjen günlüğü', 'Besin ve gözlem kaydı', Icons.fact_check),
  LifeTool('Hamilelik', 'Gebelik belirtileri', 'Günlük belirtiler', Icons.pregnant_woman),
  LifeTool('Hamilelik', 'Gebelik kilo takibi', 'Ölçüm ve açıklama', Icons.monitor_weight, numeric: true),
  LifeTool('Hamilelik', 'Gebelik randevuları', 'Kontrol ve test kayıtları', Icons.event_available),
  LifeTool('Hamilelik', 'Doğum planı', 'Tercihler ve yapılacaklar', Icons.assignment),
  LifeTool('Hamilelik', 'Hastane çantası', 'Hazırlık kontrol listesi', Icons.luggage),
  LifeTool('Hamilelik', 'Lohusalık', 'Doğum sonrası günlük', Icons.favorite),
  LifeTool('Kadın', 'Regl günlüğü', 'Başlangıç ve belirtiler', Icons.calendar_month),
  LifeTool('Kadın', 'Ruh hâli', 'Günlük duygu notları', Icons.mood),
  LifeTool('Kadın', 'Su tüketimi', 'Mililitre cinsinden kayıt', Icons.water_drop, numeric: true),
  LifeTool('Kadın', 'Egzersiz', 'Aktivite ve süre', Icons.fitness_center),
  LifeTool('Kadın', 'Uyku günlüğü', 'Uyku ve dinlenme', Icons.nights_stay),
  LifeTool('Kadın', 'Kişisel bakım', 'Cilt ve saç bakım rutinleri', Icons.spa),
  LifeTool('Kadın', 'Sağlık kontrolleri', 'Muayene ve test notları', Icons.health_and_safety),
  LifeTool('Kadın', 'İlaç günlüğü', 'Doktor önerisiyle kullanım kaydı', Icons.medication),
  LifeTool('Aile', 'Günlük görevler', 'Yapılacaklar ve tamamlananlar', Icons.checklist),
  LifeTool('Aile', 'Aile bütçesi', 'TL cinsinden harcama kaydı', Icons.account_balance_wallet, numeric: true),
  LifeTool('Aile', 'Ev işleri', 'Temizlik ve düzen', Icons.cleaning_services),
  LifeTool('Aile', 'Market listesi', 'Alınacaklar', Icons.shopping_basket),
  LifeTool('Aile', 'Haftalık menü', 'Öğün planlama', Icons.menu_book),
  LifeTool('Aile', 'Aile randevuları', 'Randevu ve tarih', Icons.event),
  LifeTool('Aile', 'Doğum günleri', 'Önemli tarihler', Icons.cake),
  LifeTool('Aile', 'Seyahat hazırlığı', 'Valiz ve yolculuk listesi', Icons.flight_takeoff),
  LifeTool('Aile', 'Acil durum bilgileri', 'İletişim ve önemli notlar', Icons.emergency),
  LifeTool('Anılar', 'Fotoğraf notları', 'Fotoğraf açıklamaları ve tarihler', Icons.photo_album),
  LifeTool('Anılar', 'Günlük', 'Anne ve aile günlüğü', Icons.edit_note),
  LifeTool('Anılar', 'Hedefler', 'Kişisel hedefler', Icons.flag),
  LifeTool('Anılar', 'Okuma listesi', 'Kitap ve makale listesi', Icons.auto_stories),
  LifeTool('Anılar', 'Hediye fikirleri', 'Hediye ve özel gün fikirleri', Icons.card_giftcard),
];

const hubPurple = Color(0xFF764A72);
const hubPink = Color(0xFFF8DDEB);

class LifeHubPage extends StatefulWidget {
  const LifeHubPage({super.key});
  @override
  State<LifeHubPage> createState() => _LifeHubPageState();
}

class _LifeHubPageState extends State<LifeHubPage> {
  String filter = 'Tümü', query = '';
  final Map<String, List<Map<String, dynamic>>> records = {};
  bool ready = false;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final data = jsonDecode(await SecureHealthStore.read('anne_bebek_lifehub_v1') ?? '{}');
      if (data is Map) {
        for (final entry in data.entries) {
          if (entry.value is List) {
            records[entry.key.toString()] = (entry.value as List)
                .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
      }
    } catch (_) { /* Bozuk isteğe bağlı kayıtlar boş başlar. */ }
    if (mounted) setState(() => ready = true);
  }
  Future<void> _save() async {
    await SecureHealthStore.write('anne_bebek_lifehub_v1', jsonEncode(records));
  }
  Future<void> _open(LifeTool tool) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _LifeRecordsPage(tool: tool, entries: records[tool.name] ?? [],
        onChanged: (items) async {
          records[tool.name] = items;
          await _save();
          if (mounted) setState(() {});
        }),
    ));
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final groups = ['Tümü', 'Bebek', 'Hamilelik', 'Kadın', 'Aile', 'Anılar'];
    final filtered = lifeTools.where((t) => (filter == 'Tümü' || t.group == filter) &&
      ('${t.name} ${t.hint}'.toLowerCase().contains(query.toLowerCase()))).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FC),
      appBar: AppBar(title: const Text('Yaşam Merkezim'), backgroundColor: hubPink),
      body: !ready ? const Center(child: CircularProgressIndicator()) : LayoutBuilder(
        builder: (context, box) {
          final cols = box.maxWidth >= 1050 ? 5 : box.maxWidth >= 720 ? 4 : box.maxWidth >= 480 ? 3 : 2;
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: double.infinity, padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(colors: [Color(0xFFF8DDEB), Color(0xFFE9DFFF)])),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Her şey bir arada 💗', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: hubPurple)),
                    const SizedBox(height: 7),
                    Text('${lifeTools.length} günlük yaşam aracı • Kayıtların bu cihazda saklanır',
                      style: const TextStyle(color: hubPurple)),
                  ])),
                const SizedBox(height: 16),
                TextField(onChanged: (s) => setState(() => query = s),
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'İhtiyacın olan aracı ara',
                    filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none))),
                const SizedBox(height: 10),
                SizedBox(height: 48, child: ListView(scrollDirection: Axis.horizontal,
                  children: groups.map((g) => Padding(padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(label: Text(g), selected: filter == g,
                      onSelected: (_) => setState(() => filter = g)))).toList())),
                const SizedBox(height: 10),
                Text('${filtered.length} araç', style: const TextStyle(fontWeight: FontWeight.w700, color: hubPurple)),
              ]))),
            SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, i) {
                final t = filtered[i];
                final count = records[t.name]?.length ?? 0;
                return Card(color: Colors.white, elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => _open(t),
                    child: Padding(padding: const EdgeInsets.all(12), child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                      CircleAvatar(backgroundColor: hubPink, radius: 22, child: Icon(t.icon, color: hubPurple)),
                      const SizedBox(height: 9),
                      Text(t.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('$count kayıt', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                    ]))),
                );
              }, childCount: filtered.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols, crossAxisSpacing: 9, mainAxisSpacing: 9,
                mainAxisExtent: 155))),
          ]);
        }),
    );
  }
}

class _LifeRecordsPage extends StatefulWidget {
  final LifeTool tool;
  final List<Map<String, dynamic>> entries;
  final Future<void> Function(List<Map<String, dynamic>>) onChanged;
  const _LifeRecordsPage({required this.tool, required this.entries, required this.onChanged});
  @override
  State<_LifeRecordsPage> createState() => _LifeRecordsPageState();
}

class _LifeRecordsPageState extends State<_LifeRecordsPage> {
  late final List<Map<String, dynamic>> entries;
  @override
  void initState() { super.initState(); entries = widget.entries.map((e) => Map<String, dynamic>.from(e)).toList(); }
  String dateText(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
  Future<void> add() async {
    final title = TextEditingController();
    final note = TextEditingController();
    final amount = TextEditingController();
    final form = GlobalKey<FormState>();
    DateTime chosen = DateTime.now();
    final result = await showDialogAndDispose<Map<String, dynamic>>(disposables: [title, note, amount], context: context, builder: (dialogCtx) => StatefulBuilder(
      builder: (context, update) => AlertDialog(
        title: Text('${widget.tool.name} • Yeni kayıt'),
        content: SizedBox(width: 400, child: SingleChildScrollView(child: Form(key: form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: title, maxLength: 90, decoration: const InputDecoration(labelText: 'Başlık / açıklama *'),
              validator: (s) => (s == null || s.trim().isEmpty) ? 'Başlık girin' : null),
            if (widget.tool.numeric) TextFormField(controller: amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: widget.tool.name == 'Aile bütçesi' ? 'Tutar (TL)' : 'Miktar (sayı)'),
              validator: (s) => s == null || s.trim().isEmpty || double.tryParse(s.replaceAll(',', '.')) == null
                ? 'Geçerli sayı girin' : null),
            TextFormField(controller: note, maxLines: 3, maxLength: 500,
              decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)')),
            TextButton.icon(icon: const Icon(Icons.event),
              label: Text(dateText(chosen.toIso8601String())), onPressed: () async {
                final d = await showDatePicker(context: dialogCtx, initialDate: chosen,
                  firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (d != null && dialogCtx.mounted) {
                  update(() => chosen = DateTime(d.year, d.month, d.day, chosen.hour, chosen.minute));
                }
              }),
          ])))),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            if (form.currentState?.validate() != true) return;
            Navigator.pop(dialogCtx, <String, dynamic>{
              'title': title.text.trim(), 'note': note.text.trim(),
              'amount': amount.text.trim(), 'date': chosen.toIso8601String(), 'done': false,
            });
          }, child: const Text('Kaydet'))],
      )));
    if (result == null || !mounted) return;
    setState(() => entries.insert(0, result));
    await widget.onChanged(entries);
  }
  Future<void> remove(int index) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Kayıt silinsin mi?'), content: const Text('Bu işlem geri alınamaz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (yes != true || !mounted) return;
    setState(() => entries.removeAt(index));
    await widget.onChanged(entries);
  }
  @override
  Widget build(BuildContext context) {
    final total = widget.tool.numeric ? entries.fold<double>(0, (s, e) => s +
      (double.tryParse((e['amount'] ?? '').toString().replaceAll(',', '.')) ?? 0)) : null;
    return Scaffold(backgroundColor: const Color(0xFFFFF8FC),
      appBar: AppBar(title: Text(widget.tool.name), backgroundColor: hubPink),
      floatingActionButton: FloatingActionButton.extended(onPressed: add,
        icon: const Icon(Icons.add), label: const Text('Yeni kayıt')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(color: const Color(0xFFF1E4F6), child: Padding(padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.tool.hint, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: hubPurple)),
            const SizedBox(height: 6),
            Text('${entries.length} kayıt${total == null ? '' : ' • Toplam: ${total.toStringAsFixed(1)}'}'),
          ]))),
        if (entries.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 50),
          child: Center(child: Text('Henüz kayıt yok. İlk kaydını ekleyebilirsin.', textAlign: TextAlign.center))),
        ...List.generate(entries.length, (i) {
          final e = entries[i];
          return Card(color: Colors.white, child: ListTile(
            leading: Checkbox(value: e['done'] == true, onChanged: (v) {
              setState(() => e['done'] = v == true);
              widget.onChanged(entries);
            }),
            title: Text((e['title'] ?? '').toString(),
              style: TextStyle(decoration: e['done'] == true ? TextDecoration.lineThrough : null)),
            subtitle: Text('${dateText((e['date'] ?? '').toString())}'
              '${(e['amount'] ?? '').toString().isNotEmpty ? ' • ${e['amount']}' : ''}'
              '${(e['note'] ?? '').toString().isNotEmpty ? '\n${e['note']}' : ''}'),
            isThreeLine: (e['note'] ?? '').toString().isNotEmpty,
            trailing: IconButton(tooltip: 'Kaydı sil', icon: const Icon(Icons.delete_outline),
              onPressed: () => remove(i)),
          ));
        }),
        const SizedBox(height: 85),
      ]));
  }
}
