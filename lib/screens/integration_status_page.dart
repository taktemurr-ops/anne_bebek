import 'package:flutter/material.dart';

/// Paket 32: Kurulum ve doğrulama gereksinimlerini açıkça gösterir.
/// Bu ekran sunucuya bağlanıp canlı durum ölçmez.
class IntegrationStatusPage extends StatelessWidget {
  const IntegrationStatusPage({super.key});

  static const sections = <({String title, String state, String detail})>[
    (title: 'Yerel bebek ve kadın kayıtları', state: 'Cihaz testi gerekli', detail: 'Kayıt ekleme, yeniden başlatma, yedekleme ve yükseltme senaryolarını gerçek cihazda doğrulayın.'),
    (title: 'Bulut kullanıcı hesabı', state: 'Kurulum gerekli', detail: 'Supabase proje bilgileri, e-posta doğrulama, hesap silme ve oturum senaryoları doğrulanmalı.'),
    (title: 'Bebeğim ve Kadınlar forumları', state: 'Kurulum gerekli', detail: 'İki forumun SQL dosyaları, RLS politikaları ve çok kullanıcılı testleri gerekli.'),
    (title: 'Moderasyon ve bildirimler', state: 'Kurulum gerekli', detail: 'Yetkiler, şikâyet akışları, spam koruması ve gerçek bildirim testleri gerekli. Telefon push bildirimi yok.'),
    (title: 'Premium abonelik', state: 'Eksik entegrasyon', detail: 'Google Play / App Store satın alma, sunucu doğrulaması, geri yükleme ve iptal/iade akışları eksik.'),
    (title: 'AI bilgi asistanı', state: 'Kurulum gerekli', detail: 'Sunucu işlevi, API anahtarı, kota, maliyet limiti ve sağlık güvenliği kontrolleri gerekli.'),
    (title: 'Merkezi yönetim', state: 'Kısmi', detail: 'Temel istatistik ve moderasyon kodlandı; içerik yönetimi, kullanıcı yönetimi ve işlem günlüğü eksik.'),
    (title: 'Tarif ve ürün içerikleri', state: 'Eksik içerik', detail: '1.000+ özgün ölçülü tarif ve gerçek marka/model/fiyat kataloğu hedefleri karşılanmadı.'),
    (title: 'Android ve iOS dağıtımı', state: 'Derleme/test gerekli', detail: 'Flutter analiz, otomatik test, APK/AAB, gerçek cihaz ve iOS TestFlight doğrulaması yapılmadı.'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Entegrasyon durumu')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Modüller arası bütünleşme • Yayın hazırlığı', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Bu liste kaynak kodun mevcut kapsamını gösterir; canlı sunucu kontrolü değildir. '
              'Hiçbir madde otomatik olarak tamamlandı sayılmaz.'),
        ],
      ))),
      const SizedBox(height: 8),
      for (final item in sections) Card(child: ListTile(
        leading: const Icon(Icons.pending_actions_outlined),
        title: Text(item.title),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(item.state, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4), Text(item.detail)],
        )),
        isThreeLine: true,
      )),
    ]),
  );
}
