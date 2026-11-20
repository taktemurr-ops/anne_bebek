# Anne Bebek — 12 paket toplu aktarım durumu (WIP)

Bu dal **tamamlanmamış geliştirmeler dahil** çalışmaları korumak içindir. Ana dala birleştirilmeden önce Flutter analiz/test/Android/iOS doğrulamaları gereklidir.

## GitHub'da mevcut geliştirme dalları
GP-01–GP-12 geliştirmeleri ayrı açık PR'larda (#1–#12) bulunmaktadır. Bunlar tek bir çalışır uygulamaya birleştirilmiş değildir.

## Çevrimdışı paket
19–20 Kasım 2026 tarihli çevrimdışı ZIP paketi 39 arşiv girdisi içerir; 23 Dart kaynak/test dosyası ve kurulum/denetim belgeleri bulunmaktadır. Bu WIP dalına ZIP'in **tamamı henüz aktarılmamıştır**. Şu an bu dala aktarılanlar:
- GP-08: lib/utils/ai_request_guard.dart
- GP-10: lib/services/premium_entitlement.dart
- GP-12: lib/utils/release_readiness.dart

## Bilinen engeller
- GP-03 ve GP-04 GitHub Actions işleri runner atanmadan başarısız olmuştu; gerçek Flutter test çıktısı değildir.
- Gerçek AI sunucusu, ödeme doğrulaması, topluluk/bildirim altyapısı ve cihaz testleri tamamlanmış kabul edilmez.
- Flutter SDK/Android/iOS derlemeleri doğrulanmadan yayın kararı alınmaz.
- Bu dal public depoda görünür. Gizli anahtarlar, gerçek kullanıcı/çocuk sağlık verileri eklenmemelidir.

**Durum: Kısmi aktarım; teslim/yayın onayı değildir.**
