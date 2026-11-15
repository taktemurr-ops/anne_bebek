import 'package:flutter/material.dart';
import 'integration_status_page.dart';
import 'project_completion_center_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yerel kontrol listesi. Bu işaretlemeler yayın onayı yerine geçmez.
const releaseChecks = <String>[
  'Bebek profili ve eski kayıtlar görüntüleniyor',
  'Beslenme, uyku ve büyüme kaydı eklenebiliyor',
  'Gebelik ve kadın sağlığı ekranları açılıyor',
  'Test verileriyle yedekleme ve geri yükleme denendi',
  'Android cihazda açılış, gezinme ve geri tuşu kontrol edildi',
  'Gizlilik metni ve mağaza veri güvenliği beyanı incelendi',
  'Erişilebilirlik: büyük yazı ve ekran okuyucu denendi',
  'Hatırlatıcı ekleme, işaretleme ve silme test edildi',
  'Android release APK/AAB gerçek cihazda denendi',
  'iOS derleme ve TestFlight doğrulaması yapıldı (Mac gerekli)',
  'Mağaza ekran görüntüleri, izinler ve gizlilik beyanı hazır',
  'Hassas verilerle temiz kurulum ve yükseltme senaryosu test edildi',
  'İki forumun canlı Supabase bağlantısı ve RLS politikaları doğrulandı',
  'Premium için gerçek mağaza satın alma ve geri yükleme akışları doğrulandı',
  'AI asistanı sunucu bağlantısı, kota ve sağlık güvenliği kontrolleri doğrulandı',
  'İnternet kapalıyken yerel kayıtlar ve ekran geçişleri denendi',
  'Tarif arama, favori ve alışveriş listesi yeniden başlatmadan sonra kontrol edildi',
  'Kullanıcı verileri korunarak önceki paket üzerinden yükseltme denendi',
  'Alışveriş ekranından akıllı alışveriş ve yemek planlayıcıya geçiş test edildi',
  'Bebek profilleri, büyüme ve günlük ekranlarına geçiş test edildi',
  'Kadın sağlığı günlüğü ve doğum sonrası bakım ekranları test edildi',
  'Tekrarlanan .dart.dart dosyaları ve import çakışmaları denetlendi',
  'Modül merkezinden tüm 14 ekranın açılışı doğrulandı',
  'Modül merkezi arama ve kategori filtreleri kontrol edildi',
  'Favoriler uygulama yeniden başlatıldıktan sonra korundu',
  'Bebek ve kadın ekranlarından modül merkezine geçiş denendi',
  'Her ekrandan geri dönüş ve yönlendirme döngüsü test edildi',
  'Hassas sağlık kayıtlarının yedekleme ve geri yükleme akışı denendi',
  'Çevrimdışı modül geçişleri ve hata durumları kontrol edildi',
  'Gerçek Android ve iOS derleme hataları giderildi',

];

class ReleaseCheckPage extends StatefulWidget {
  const ReleaseCheckPage({super.key});

  @override
  State<ReleaseCheckPage> createState() => _ReleaseCheckPageState();
}

class _ReleaseCheckPageState extends State<ReleaseCheckPage> {
  static const _key = 'release_checks_v32_final_audit';
  Set<int> checked = {};
  bool loading = true;
  bool saving = false;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key) ?? [];
      if (!mounted) return;
      setState(() {
        checked = saved.map(int.tryParse).whereType<int>()
            .where((i) => i >= 0 && i < releaseChecks.length).toSet();
        loading = false;
        loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadError = 'Kontroller yüklenemedi. Tekrar deneyin.';
      });
    }
  }

  Future<void> _toggle(int index, bool value) async {
    if (saving || loadError != null) return;
    final before = Set<int>.of(checked);
    setState(() {
      saving = true;
      if (value) { checked.add(index); } else { checked.remove(index); }
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final values = checked.map((i) => i.toString()).toList()..sort();
      final ok = await prefs.setStringList(_key, values);
      if (!ok) throw StateError('Kaydetme başarısız');
    } catch (_) {
      if (!mounted) return;
      setState(() => checked = before);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Kontrol kaydedilemedi. Lütfen tekrar deneyin.')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Yayın öncesi kontrol')),
    body: loading ? const Center(child: CircularProgressIndicator())
        : loadError != null ? Center(child: Column(
            mainAxisSize: MainAxisSize.min, children: [
              Text(loadError!),
              TextButton(onPressed: () { setState(() { loading = true; loadError = null; }); _load(); },
                child: const Text('Tekrar dene')),
            ])) : ListView(padding: const EdgeInsets.all(16), children: [
          Text('Yayın öncesi kontrol listesi',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Bu liste cihazınızdaki manuel kontrolleri takip eder. '
              'Tamamlanması uygulamanın mağazada yayınlanmaya hazır olduğunu garanti etmez. '),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const IntegrationStatusPage())),
            icon: const Icon(Icons.hub_outlined),
            label: const Text('Entegrasyon ve eksiklerin durumu'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const ProjectCompletionCenterPage())),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Tüm modüller için tamamlama merkezi'),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: checked.length / releaseChecks.length),
          const SizedBox(height: 8),
          Text('${checked.length} / ${releaseChecks.length} kontrol tamamlandı'),
          const SizedBox(height: 12),
          for (var i = 0; i < releaseChecks.length; i++)
            CheckboxListTile(
              key: ValueKey('release_check_$i'),
              title: Text(releaseChecks[i]),
              value: checked.contains(i),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: saving ? null : (value) => _toggle(i, value ?? false),
            ),
          const SizedBox(height: 16),
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text(
            'Önemli: Sağlık kayıtlarıyla test yapmadan önce yedek alın. '
            'Geri yüklemeyi yalnızca test verileriyle deneyin. '
            'Flutter analyze, flutter test ve gerçek cihaz testleri ayrıca gereklidir.'))),
        ]),
  );
}
