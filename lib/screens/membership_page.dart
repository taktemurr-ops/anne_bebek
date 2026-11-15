import 'package:flutter/material.dart';
import '../services/subscription_service.dart';

/// Informational plans and read-only server-verified membership status.
/// Checkout is intentionally disabled until store products and secure receipt
/// verification are deployed. Displayed amounts are NOT store prices.
class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});
  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  Future<SubscriptionStatus>? _status;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(() { _status = SubscriptionService.fetchStatus(); });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Üyelik ve Premium')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFD9ED), Color(0xFFEDE1FF)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.workspace_premium, color: Color(0xFFF0449B), size: 34),
          SizedBox(height: 8),
          Text('Her aile için bir seçenek', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('Temel sağlık bilgileri ve temel takipler ücretsiz kalır.'),
        ]),
      ),
      const SizedBox(height: 14),
      FutureBuilder<SubscriptionStatus>(
        future: _status,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Card(child: ListTile(title: Text('Üyelik durumu kontrol ediliyor…'), trailing: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Card(child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded),
              title: const Text('Üyelik doğrulanamadı'),
              subtitle: const Text('Bağlantıyı kontrol ederek tekrar deneyin. Premium hakları doğrulanmadan açılmaz.'),
              trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
            ));
          }
          final status = snapshot.data!;
          return Card(child: ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text('Mevcut üyelik: ${status.label}'),
            subtitle: Text(!status.configured
              ? 'Abonelik sunucusu henüz yapılandırılmadı.'
              : status.expiresAt == null ? 'Durum sunucudan doğrulandı.'
                : 'Bitiş: ${status.expiresAt!.day}.${status.expiresAt!.month}.${status.expiresAt!.year}'),
            trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          ));
        },
      ),
      const SizedBox(height: 10),
      _plan('Ücretsiz', 'Ücretsiz', Icons.spa_outlined, const [
        'Temel bebek ve kadın sağlığı rehberleri',
        'Temel takip ve günlükler',
        'Tarifler ve forumlar (sunucu kurulumu gerektirir)',
      ]),
      _plan('Premium', 'Fiyat mağazada belirlenecek', Icons.auto_awesome_outlined, const [
        'Gelişmiş raporlar (planlanan özellik)',
        'Kişiselleştirilmiş planlama (planlanan özellik)',
        'Reklamsız kullanım (planlanan özellik)',
      ], featured: true),
      _plan('Premium Aile', 'Fiyat mağazada belirlenecek', Icons.family_restroom_outlined, const [
        'Premium özellikleri (planlanan)',
        'Aile paylaşımı (planlanan)',
        'Çocuklar için ortak yönetim (planlanan)',
      ]),
      const Card(child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Satın alma henüz aktif değil', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 7),
          Text('Bu ekrandan ödeme alınmaz. Mağaza ürünleri, satın alma/geri yükleme, sunucu tarafında makbuz doğrulama ve abonelik haklarının denetlenmesi tamamlanmadan satış açılmayacak.'),
          SizedBox(height: 8),
          Text('Abonelik yönetimi ve iptal, satın alma etkinleştirildiğinde ilgili uygulama mağazasından yapılacaktır.'),
        ]),
      )),
    ]),
  );

  Widget _plan(String title, String price, IconData icon, List<String> benefits, {bool featured = false}) =>
    Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: featured ? const Color(0xFFF0449B) : const Color(0xFFF1E5EF), width: featured ? 1.6 : 1)),
      child: Padding(padding: const EdgeInsets.all(17), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: const Color(0xFFF0449B)), const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
            if (featured) const Chip(label: Text('Planlanan'))]),
          Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          for (final benefit in benefits) Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFFF0449B), size: 19),
              const SizedBox(width: 9), Expanded(child: Text(benefit)),
            ])),
        ],
      )),
    );
}
