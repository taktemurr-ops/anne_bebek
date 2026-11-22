import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/link_launcher.dart';
import '../services/store_billing.dart';
import '../services/subscription_service.dart';

/// Ücretsiz ve Premium seçenekleri; mağaza üzerinden satın alma ve geri yükleme.
/// Ücretli haklar yalnızca sunucuda doğrulanan abonelikle açılır.
/// Sağlık ve güvenlik içerikleri hiçbir zaman ücretli değildir.
class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});
  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

const _pink = Color(0xFFF0449B);

const freeFeatures = <String>[
  'Tüm sağlık, güvenlik ve ilk yardım rehberleri',
  'Bebek, anne ve kadın takipleri; hatırlatıcılar',
  'Gebelik hafta hafta, aşı takvimi, gelişim basamakları',
  'Toplu takip raporu (metin olarak paylaşma)',
  'Şifreli yedekleme ve geri yükleme',
];

const premiumFeatures = <String>[
  'Toplu takip raporunu PDF olarak indirme ve yazdırma',
  'Doktor görüşmeleri için tüm süreçlerin tek belgede özeti',
  'Yeni premium araçlara ek ücret ödemeden erişim',
  'Uygulamanın reklamsız ve bağımsız kalmasına destek',
];

class _MembershipPageState extends State<MembershipPage> {
  SubscriptionStatus? _status;
  String? _statusError;
  List<StorePlan> _products = const [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    StoreBilling.message.addListener(_onMessage);
    StoreBilling.status.addListener(_onStatus);
    unawaited(_load());
  }

  @override
  void dispose() {
    StoreBilling.message.removeListener(_onMessage);
    StoreBilling.status.removeListener(_onStatus);
    super.dispose();
  }

  void _onMessage() {
    final m = StoreBilling.message.value;
    if (m == null || !mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(m)));
    StoreBilling.message.value = null;
  }

  void _onStatus() {
    if (mounted) setState(() => _status = StoreBilling.status.value);
  }

  Future<void> _load() async {
    SubscriptionStatus? status;
    String? error;
    var products = const <StorePlan>[];
    if (SubscriptionService.configured) {
      try { status = await SubscriptionService.fetchStatus(); } catch (_) { error = 'Üyelik doğrulanamadı; bağlantını kontrol edip yenile.'; }
    }
    if (StoreBilling.configured) {
      try { products = await StoreBilling.loadProducts(); } catch (_) {}
    }
    if (mounted) setState(() { _status = status; _statusError = error; _products = products; _loading = false; });
  }

  Future<void> _buy(StorePlan p) async {
    setState(() => _busy = true);
    try {
      final started = await StoreBilling.buy(p);
      if (!started && mounted) setState(() => _busy = false);
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text('Satın alma başlatılamadı.')));
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    try { await StoreBilling.restore(); } catch (_) {}
    if (mounted) setState(() => _busy = false);
    await _load();
  }

  Future<void> _manage() async {
    final url = defaultTargetPlatform == TargetPlatform.iOS
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions';
    var ok = false;
    try { ok = await LinkLauncher.open(url); } catch (_) {}
    if (!ok && mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text('Mağaza açılamadı. Aboneliğini mağaza uygulamasındaki “Abonelikler” bölümünden yönetebilirsin.')));
    }
  }

  String _current(SubscriptionStatus s) {
    final label = t('Mevcut üyelik');
    return '$label: ${t(s.label)}';
  }

  String _renewal(DateTime d) {
    final label = t('Yenileme / bitiş');
    return '$label: ${d.day}.${d.month}.${d.year}';
  }

  Widget _list(String title, IconData icon, List<String> items, {bool featured = false}) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: featured ? _pink : const Color(0xFFF1E5EF), width: featured ? 1.6 : 1)),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: _pink), const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 8),
          for (final b in items) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_circle_outline, color: _pink, size: 19),
            const SizedBox(width: 9), Expanded(child: Text(b)),
          ])),
        ])),
      );

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return Scaffold(
      appBar: AppBar(title: Text('Üyelik ve Premium'), actions: [
        IconButton(tooltip: t('Yenile'), onPressed: _loading ? null : () { setState(() => _loading = true); _load(); }, icon: const Icon(Icons.refresh)),
      ]),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD9ED), Color(0xFFEDE1FF)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.workspace_premium, color: _pink, size: 34),
            const SizedBox(height: 8),
            Text('Her aile için bir seçenek', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Sağlık ve güvenlik bilgileri herkes için her zaman ücretsizdir.'),
          ]),
        ),
        const SizedBox(height: 12),
        if (_loading) const LinearProgressIndicator(),
        if (status != null)
          Card(child: ListTile(
            leading: Icon(status.isPremium ? Icons.verified : Icons.verified_user_outlined, color: _pink),
            title: Text(_current(status)),
            subtitle: status.expiresAt == null ? null
                : Text(_renewal(status.expiresAt!)),
          )),
        if (_statusError != null) Card(child: ListTile(leading: const Icon(Icons.warning_amber_rounded), title: Text(_statusError!))),
        _list('Ücretsiz', Icons.spa_outlined, freeFeatures),
        _list('Premium', Icons.auto_awesome_outlined, premiumFeatures, featured: true),
        const SizedBox(height: 6),
        if (_products.isNotEmpty) ...[
          Text('Planı seç', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          for (final p in _products)
            Card(child: ListTile(
              key: Key('plan_${p.id}'),
              title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: p.description.isEmpty ? null : Text(p.description),
              trailing: FilledButton(
                onPressed: _busy || (status?.isPremium ?? false) ? null : () => _buy(p),
                child: Text(p.price)),
            )),
        ] else if (!_loading)
          Card(color: const Color(0xFFFFF4FA), child: Padding(padding: const EdgeInsets.all(16), child: Text(
            StoreBilling.configured
                ? 'Mağaza planları şu an yüklenemedi. İnternet bağlantını kontrol edip yenile.'
                : 'Premium satın alma, uygulama mağaza sürümünde etkinleşir. Tüm ücretsiz özellikler şimdiden kullanılabilir.'))),
        if (StoreBilling.configured) Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(onPressed: _busy ? null : _restore, icon: const Icon(Icons.restore), label: Text('Satın alımları geri yükle')),
          OutlinedButton.icon(onPressed: _manage, icon: const Icon(Icons.manage_accounts_outlined), label: Text('Aboneliği yönet / iptal et')),
        ]),
        const SizedBox(height: 10),
        Text(
          'Abonelik, seçtiğin dönem sonunda otomatik yenilenir ve ücret mağaza hesabından alınır. '
          'Yenilemeyi istemiyorsan dönem bitmeden en az 24 saat önce mağazanın “Abonelikler” bölümünden iptal et. '
          'İptal ettiğinde Premium, ödenmiş dönemin sonuna kadar açık kalır. Satın almak için hesabına giriş yapman gerekir.',
          style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ]),
    );
  }
}
