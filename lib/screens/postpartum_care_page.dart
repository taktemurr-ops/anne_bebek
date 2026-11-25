import '../utils/dialog_helpers.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'dart:convert';
import 'package:flutter/material.dart' hide Text;
import '../services/secure_health_store.dart';

/// Educational postpartum companion. Does not diagnose or replace follow-up care.
class PostpartumCarePage extends StatefulWidget {
  const PostpartumCarePage({super.key});
  @override
  State<PostpartumCarePage> createState() => _PostpartumCarePageState();
}

class _PostpartumCarePageState extends State<PostpartumCarePage> {
  static const _key = 'postpartum_companion_v1';
  DateTime? birthDate;
  final Set<String> completed = {};
  final List<Map<String, String>> notes = [];
  bool loading = true;
  String? error;

  static const sections = <({String title, String description, IconData icon})>[
    (title: 'İyileşme ve dinlenme', description: 'Doğum şekline göre iyileşme farklılık gösterir. Ağrı, kanama, yara bakımı ve hareket konusunda taburculuk önerilerini takip edin. Dinlenme için yakınlarınızdan destek isteyin.', icon: Icons.self_improvement),
    (title: 'Emzirme ve beslenme', description: 'Emzirme sırasında rahat pozisyon ve etkili kavrama önemlidir. Sürekli ağrı, ateş veya memede kızarıklık varsa sağlık uzmanıyla görüşün. Beslenme ve sıvı ihtiyacınızı ihmal etmeyin.', icon: Icons.water_drop_outlined),
    (title: 'Ruh hâli ve destek', description: 'Doğum sonrası duygusal dalgalanmalar görülebilir. Yoğun üzüntü, kaygı veya işlev kaybı sürüyorsa profesyonel destek alın. Kendinize veya bebeğe zarar verme düşüncesinde acil yardım isteyin.', icon: Icons.favorite_border),
    (title: 'Uyku ve günlük yaşam', description: 'Kısa dinlenme araları planlayın; bakım sorumluluklarını paylaşın. Yorgunken bebeğinizle koltukta veya kanepede uyumamaya dikkat edin.', icon: Icons.nightlight_outlined),
    (title: 'Kontroller ve sorular', description: 'Doğum sonrası kontrolleri sağlık ekibinizle planlayın. Kanama, ağrı, ilaçlar, korunma ve emzirme ile ilgili sorularınızı not edin.', icon: Icons.medical_services_outlined),
    (title: 'Pelvik taban ve hareket', description: 'Hareket ve egzersize dönüş süreci kişiye ve doğum şekline göre değişir. Ağrı veya kaçırma şikâyetlerini kontrol sırasında paylaşın.', icon: Icons.directions_walk_outlined),
  ];

  static const weekTips = <String>[
    'İlk günler: Taburculuk önerilerini, kanama miktarını ve ağrı kontrolünü takip edin. Evde destek planı oluşturun.',
    '2. hafta: Dinlenme ve beslenme düzenini gözden geçirin. Emzirme veya besleme güçlüğünde destek isteyin.',
    '3. hafta: Günlük yaşamda zorlanma ve ruh hâli değişimlerini not edin. Gerektiğinde kontrol randevusu alın.',
    '4. hafta: İyileşme hızınızı başkalarıyla kıyaslamayın. Şikâyetleriniz devam ediyorsa sağlık ekibine danışın.',
    '5. hafta: Uyku, destek ve bakım paylaşımını yeniden planlayın. İyileşmeyi zorlayacak aktivitelere acele etmeyin.',
    '6. hafta: Doğum sonrası kontrol, ruh sağlığı, korunma ve fiziksel iyileşme sorularını doktorunuzla görüşün.',
    '7. hafta: Enerji düzeyinizi, beslenmenizi ve günlük iş yükünüzü değerlendirin; ihtiyaç duyduğunuz desteği isteyin.',
    '8. hafta: Devam eden ağrı, idrar kaçırma veya yoğun yorgunluk gibi yakınmaları not ederek uzmanla paylaşın.',
    '9. hafta: Bebeğin bakım düzeni değişirken kendi sağlık kontrollerinizi ve dinlenmenizi ihmal etmeyin.',
    '10. hafta: Günlük hareketi ve sosyal desteği kişisel iyileşme hızınıza göre düzenleyin.',
    '11. hafta: Ruh hâli, uyku ve fiziksel belirtilerdeki değişimleri gözden geçirin.',
    '12. hafta: Uzun dönem iyilik hâli, beslenme, hareket ve sağlık kontrolleri için sürdürülebilir bir plan yapın.',
  ];

  static const tasks = <String>[
    'Taburculuk ve ilaç talimatlarını gözden geçirdim',
    'Doğum sonrası kontrol randevumu planladım',
    'Yardım isteyebileceğim kişileri belirledim',
    'Emzirme / besleme sorularımı not ettim',
    'Ruh hâlim ve uyku düzenim için destek planladım',
    'Acil belirtilerde başvuracağım sağlık kuruluşunu biliyorum',
  ];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final raw = await SecureHealthStore.read(_key);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final date = data['birthDate'] as String?;
        birthDate = date == null ? null : DateTime.tryParse(date);
        completed.addAll((data['completed'] as List<dynamic>? ?? []).whereType<String>());
        for (final item in data['notes'] as List<dynamic>? ?? []) {
          notes.add(Map<String, String>.from(item as Map));
        }
      }
    } catch (_) { error = 'Kayıtlar okunamadı; mevcut veriler değiştirilmedi.'; }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _persist() async {
    try {
      await SecureHealthStore.write(_key, jsonEncode({
        'birthDate': birthDate?.toIso8601String(),
        'completed': completed.toList(), 'notes': notes,
      }));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydetme başarısız. Lütfen tekrar deneyin.')));
    }
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(context: context, initialDate: birthDate ?? DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime.now());
    if (date == null || !mounted) return;
    setState(() => birthDate = date);
    await _persist();
  }

  Future<void> _addNote() async {
    final controller = TextEditingController();
    final value = await showDialogAndDispose<String>(disposables: [controller], context: context, builder: (ctx) => AlertDialog(
      title: const Text('Yeni kişisel not'),
      content: TextField(controller: controller, maxLength: 500, maxLines: 4,
        decoration: InputDecoration(hintText: t('Belirti, kontrol sorusu veya günlük gözlem'))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Kaydet'))],
    ));
    if (value == null || value.isEmpty || !mounted) return;
    setState(() => notes.insert(0, {'date': DateTime.now().toIso8601String(), 'text': value}));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final days = birthDate == null ? null : DateTime.now().difference(birthDate!).inDays;
    final week = days == null ? null : (days ~/ 7 + 1).clamp(1, 12);
    return Scaffold(
      appBar: AppBar(title: const Text('Doğum Sonrası & Annelik')),
      floatingActionButton: loading || error != null ? null : FloatingActionButton.extended(
        onPressed: _addNote, icon: const Icon(Icons.edit_note), label: const Text('Not ekle')),
      body: loading ? const Center(child: CircularProgressIndicator()) : error != null
        ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!)))
        : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), children: [
          Card(color: const Color(0xFFFFE6F0), child: Padding(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Lohusalık rehberim 💗', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Bu rehber genel bilgi ve kişisel not tutma amaçlıdır. Doğum sonrası bakımda sağlık ekibinizin önerileri önceliklidir.'),
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: _chooseDate, icon: const Icon(Icons.calendar_today_outlined),
                label: Text(birthDate == null ? 'Doğum tarihini seç' : 'Doğum tarihi: ${birthDate!.day}.${birthDate!.month}.${birthDate!.year}')),
              if (days != null) Text(days <= 83 ? 'Doğum sonrası yaklaşık ${days + 1}. gün • $week. hafta' : 'İlk 12 hafta tamamlandı; takip ve destek devam edebilir.'),
            ]))),
          const SizedBox(height: 12),
          Text('İlk 12 hafta', style: Theme.of(context).textTheme.titleLarge),
          for (var i = 0; i < weekTips.length; i++) ExpansionTile(
            initiallyExpanded: week == i + 1, title: Text('${i + 1}. hafta'),
            subtitle: week == i + 1 ? const Text('Bulunduğunuz dönem') : null,
            children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(weekTips[i]))]),
          const SizedBox(height: 12),
          Text('Bakım ve destek konuları', style: Theme.of(context).textTheme.titleLarge),
          for (final section in sections) Card(child: ExpansionTile(
            leading: Icon(section.icon, color: const Color(0xFF9563A4)), title: Text(section.title),
            children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(section.description))])),
          const SizedBox(height: 12),
          Text('Kişisel hazırlık listem (${completed.length}/${tasks.length})', style: Theme.of(context).textTheme.titleLarge),
          for (final task in tasks) CheckboxListTile(
            value: completed.contains(task), title: Text(task), controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) async {
              setState(() { if (value == true) { completed.add(task); } else { completed.remove(task); } });
              await _persist();
            }),
          const SizedBox(height: 12),
          Text('Günlük notlarım', style: Theme.of(context).textTheme.titleLarge),
          if (notes.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('Henüz not eklenmedi.')),
          for (final note in notes) Card(child: ListTile(
            title: Text(note['text'] ?? ''),
            subtitle: Text((note['date'] ?? '').split('T').first),
            trailing: IconButton(tooltip: t('Notu sil'), icon: const Icon(Icons.delete_outline), onPressed: () async {
              final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Not silinsin mi?'), actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
                ]));
              if (confirmed == true && mounted) { setState(() => notes.remove(note)); await _persist(); }
            }),
          )),
          const Card(color: Color(0xFFFFF0ED), child: Padding(padding: EdgeInsets.all(14), child: Text(
            'Acil uyarı: Çok yoğun kanama, göğüs ağrısı, nefes darlığı, nöbet, şiddetli baş ağrısı, yüksek ateş veya kendinize/bebeğe zarar verme düşüncesinde acil sağlık yardımı alın.'))),
        ]),
    );
  }
}
