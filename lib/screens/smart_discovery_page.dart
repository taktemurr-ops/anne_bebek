import 'package:flutter/material.dart';

/// Offline, deterministic content discovery. No AI API or personal data upload.
class SmartDiscoveryPage extends StatefulWidget {
  const SmartDiscoveryPage({super.key});
  @override
  State<SmartDiscoveryPage> createState() => _SmartDiscoveryPageState();
}

class _SmartDiscoveryPageState extends State<SmartDiscoveryPage> {
  final _query = TextEditingController();
  String _filter = 'Tümü';
  static const _entries = <({String category, String title, String description, String keywords})>[
    (category: 'Bebek', title: 'Uyku rutini', description: 'Yaşa uygun ve tutarlı bir uyku öncesi rutin oluşturun. Uyku ortamının güvenliğini kontrol edin; bebeği sırtüstü yatırın.', keywords: 'uyku gece rutin bebek'),
    (category: 'Bebek', title: 'Beslenme günlüğü', description: 'Beslenme saatlerini ve miktarları takip ederek kendi kayıtlarınızı karşılaştırabilirsiniz. Yaşa uygun beslenme için sağlık uzmanınıza danışın.', keywords: 'mama emzirme süt beslenme'),
    (category: 'Bebek', title: 'Gelişim gözlemleri', description: 'Günlük hareket, iletişim ve oyun gözlemlerinizi kaydedin. Gelişim hızı çocuklar arasında değişebilir.', keywords: 'gelişim aylık oyun hareket'),
    (category: 'Bebek', title: 'Ek gıdaya geçiş', description: 'Ek gıda döneminde uygun doku, hijyen ve alerjenleri göz önünde bulundurun. Boğulma riski taşıyan yiyeceklerden kaçının.', keywords: 'ek gıda tarif yemek püre'),
    (category: 'Kadınlar', title: 'Döngü kayıtları', description: 'Regl başlangıç tarihlerini ve belirtilerinizi not ederek geçmiş döngü aralıklarını inceleyebilirsiniz. Bu kayıtlar doğurganlık tahmini değildir.', keywords: 'adet regl döngü takvim'),
    (category: 'Kadınlar', title: 'Gebelikte takip', description: 'Kontrol randevularınızı, sorularınızı ve doktor önerilerini tek yerde not edin. Tıbbi değerlendirme için hekiminize başvurun.', keywords: 'hamilelik gebelik hafta'),
    (category: 'Kadınlar', title: 'Doğum sonrası destek', description: 'Dinlenme, beslenme ve destek ihtiyaçlarınızı planlayın. Şiddetli veya beklenmeyen belirtilerde sağlık hizmeti alın.', keywords: 'lohusalık doğum sonrası anne'),
    (category: 'Genel', title: 'Haftalık alışveriş planı', description: 'Evde bulunan malzemeleri kontrol edin, eksikleri listeye ekleyin ve alışveriş öncesi listenizi gözden geçirin.', keywords: 'alışveriş liste market'),
    (category: 'Genel', title: 'Pratik öğün planlama', description: 'Haftalık yemeklerinizi önceden seçmek alışverişi kolaylaştırabilir. Alerjileri ve bireysel ihtiyaçları dikkate alın.', keywords: 'tarif yemek öğün plan'),
  ];
  @override
  void dispose() { _query.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim().toLowerCase();
    final matches = _entries.where((e) => (_filter == 'Tümü' || e.category == _filter) &&
      (q.isEmpty || '${e.title} ${e.description} ${e.keywords}'.toLowerCase().contains(q))).toList();
    return Scaffold(appBar: AppBar(title: const Text('Akıllı içerik keşfi')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Card(color: Color(0xFFFFE6F3), child: Padding(padding: EdgeInsets.all(16),
          child: Text('Aradığınız konuyla ilgili içerikleri cihazınızda bulabilirsiniz. Bu sürüm yapay zekâ sohbeti değil, çevrimdışı anahtar kelime aramasıdır.'))),
        const SizedBox(height: 12),
        TextField(controller: _query, onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Konu ara', hintText: 'Örn. uyku, regl, tarif')),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: ['Tümü', 'Bebek', 'Kadınlar', 'Genel'].map((c) => ChoiceChip(
          label: Text(c), selected: _filter == c, onSelected: (_) => setState(() => _filter = c))).toList()),
        const SizedBox(height: 12),
        Text('${matches.length} içerik', style: Theme.of(context).textTheme.titleMedium),
        if (matches.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Aramanıza uygun içerik bulunamadı. Farklı bir kelime deneyin.')),
        for (final e in matches) Card(child: ListTile(
          leading: const Icon(Icons.auto_stories_outlined, color: Color(0xFF48235F)),
          title: Text(e.title), subtitle: Text(e.category), trailing: const Icon(Icons.chevron_right),
          onTap: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
            title: Text(e.title), content: SingleChildScrollView(child: Text(e.description)),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))])))),
        const SizedBox(height: 10),
        const Text('Bilgilendirme amaçlıdır; tanı veya tedavi önerisi değildir.', style: TextStyle(color: Colors.black54)),
      ]));
  }
}
