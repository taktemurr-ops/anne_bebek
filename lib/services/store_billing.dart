import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'cloud_auth_service.dart';
import 'subscription_service.dart';

/// Google Play / App Store abonelik satın alma ve geri yükleme.
/// Ücretli hak burada açılmaz: her satın alma sunucuda doğrulanır
/// (SubscriptionService.verifyPurchase) ve yalnızca sunucu yanıtı kullanılır.
/// Mağaza ürününün ekranda gösterilen bilgisi (eklentiden bağımsız).
class StorePlan {
  final String id, title, description, price;
  const StorePlan(this.id, this.title, this.description, this.price);
}

class StoreBilling {
  static final _details = <String, ProductDetails>{};
  static StreamSubscription<List<PurchaseDetails>>? _sub;
  static final status = ValueNotifier<SubscriptionStatus?>(null);
  static final message = ValueNotifier<String?>(null);

  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get _ios => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static Set<String> get productIds => {
        if (_android) ...[SubscriptionService.androidMonthly, SubscriptionService.androidYearly, SubscriptionService.androidFamily],
        if (_ios) ...[SubscriptionService.iosMonthly, SubscriptionService.iosYearly, SubscriptionService.iosFamily],
      }..removeWhere((e) => e.isEmpty);

  static bool get configured => SubscriptionService.configured && productIds.isNotEmpty;

  /// Bekleyen satın alımları yakalamak için uygulama açılışında çağrılır.
  static void start() {
    if (!configured || _sub != null) return;
    _sub = InAppPurchase.instance.purchaseStream.listen(_onPurchases, onError: (Object _) {
      message.value = 'Mağaza bağlantısında sorun oluştu.';
    });
  }

  static Future<List<StorePlan>> loadProducts() async {
    if (!configured) return const [];
    start();
    if (!await InAppPurchase.instance.isAvailable()) return const [];
    final r = await InAppPurchase.instance.queryProductDetails(productIds);
    final list = List.of(r.productDetails)..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    for (final p in list) { _details[p.id] = p; }
    return [for (final p in list) StorePlan(p.id, p.title, p.description, p.price)];
  }

  static Future<bool> buy(StorePlan plan) async {
    final product = _details[plan.id];
    if (product == null) return false;
    start();
    final session = await CloudAuthService.currentSession();
    final user = session?['user'];
    final uid = user is Map ? user['id'] : null;
    if (uid is! String || uid.isEmpty) {
      message.value = 'Satın almak için önce hesabına giriş yap.';
      return false;
    }
    return InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product, applicationUserName: uid));
  }

  static Future<void> restore() async {
    start();
    await InAppPurchase.instance.restorePurchases();
  }

  static Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.status == PurchaseStatus.pending) {
        message.value = 'Ödeme onay bekliyor.';
        continue;
      }
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        try {
          final s = await SubscriptionService.verifyPurchase(
            platform: _android ? 'google' : 'apple',
            productId: p.productID,
            verificationData: _android ? p.verificationData.serverVerificationData : (p.purchaseID ?? ''),
          );
          status.value = s;
          message.value = s.isPremium ? 'Premium üyeliğin etkin.' : 'Satın alma doğrulandı ancak etkin abonelik bulunamadı.';
        } catch (_) {
          // Onaylanmadan bırakılır; "Satın alımları geri yükle" ile yeniden denenir.
          message.value = 'Satın alma sunucuda doğrulanamadı. Biraz sonra “Satın alımları geri yükle” ile tekrar dene.';
          continue;
        }
      } else if (p.status == PurchaseStatus.canceled) {
        message.value = 'Satın alma iptal edildi.';
      } else if (p.status == PurchaseStatus.error) {
        message.value = 'Satın alma tamamlanamadı.';
      }
      if (p.pendingCompletePurchase) await InAppPurchase.instance.completePurchase(p);
    }
  }
}
