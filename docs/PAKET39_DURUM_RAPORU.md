# Paket 39 ve Excel eksikleri: durum raporu

Dal: `claude/tum-duzeltmeler` (PR #14), tabanı `wip/anne-bebek-tum-paketler-20261121` (PR #13).
Doğrulama yalnızca GitHub CI ile yapılmıştır (flutter analyze, flutter test, debug APK).
Gerçek cihaz testi yapılmamıştır.

## Tamamlananlar

| Konu | Yapılan | Kanıt |
|---|---|---|
| CI #333 analiz hataları | 6 ekranda `setState(() => {...})` set-literal hatası ve lint uyarısı giderildi | CI: analiz, test ve APK adımları geçti |
| GP-01/02/03 entegrasyonu | Üç zincir dal PR #13'e birleştirildi; profil silme korumasındaki çakışma iki kontrolü birlikte tutarak çözüldü | Merge commit |
| GP-04…12 eksik dosyalar | 13 test dosyası, `daily_routine_validator.dart`, GP-12 kabul dokümanı alındı | CI testleri |
| Kaydet → kırmızı ekran (§8) | `_dependents.isEmpty`: controller'lar diyalog kapanma animasyonu bitmeden dispose ediliyordu. `showDialogAndDispose` yardımcısı 24 diyaloğa uygulandı. Ana ekran hızlı kayıtlarına çift dokunma / çift pop koruması eklendi | `lib/utils/dialog_helpers.dart` |
| Tasarım (§1) — referans 8 ekran | Alt menü (Ana Sayfa • Bebeğim • + • Tarifler • Profil). Bebeğim: çocuk kartı + Gelişim/Sağlık/Aşılar/Notlar, büyüme grafiği, Günlük Bakım. Günlük Takip: tarih gezinme, + ile kayıt, günün özeti. Tarifler: arama, pembe kategori çipleri, kart ızgarası (süre, zorluk, favori). Kadınlar: Döngü Takibi/Sağlık/İyi Hisset, adet–yumurtlama–verimli dönem takvimi. Gebelik: hafta kartı, 40 hafta ilerleme. Alışveriş: Bebek/Anne/Aile, alt kategori kutuları, adet seçicili liste, liste toplamı. Önceki tüm bağlantılar ilgili sekmede korundu | `lib/widgets/reference_widgets.dart`, `lib/main.dart`, `lib/extra_features.dart` |
| Modül ayrımı (§2) | Alışveriş ve Kadınlar ana sayfa kartlarından açılır; geri tuşu ana sayfaya döner; genel ve bebek tarifleri ayrı | `lib/main.dart` |
| Genel tarifler (§3) | 18 kategori; 54 isim kopyası, 96 yakın kopya, 55 tek malzeme varyantı çıkarıldı; kişi sayısı, süreler, zorluk, fırın, püf, servis, saklama, alerjen; 51 tarif baştan yazıldı | `lib/data/general_recipe_catalog.dart`, `recipe_meta.dart` |
| Bebek tarifleri (§4) | 6–8, 9–11, 12–18, 18–24, 24–36, 36–72 ay grupları. 304 ayrıntılı tarif (6–8: 47, 9–11: 49, 12–18: 54, 18–24: 45, 24–36: 54, 36–72: 55); her tarifte ölçülü malzeme, en az 4 adım, ipucu ve saklama bilgisi. 12 ay altı tariflerde tuz, şeker ve bal yok | `lib/data/baby_recipe_catalog.dart` |
| Döngü takvimi | Ortalama döngü kayıtlardan; yaz saati güvenli tarih hesabı; sınır testleri | `lib/services/cycle_estimate.dart` |
| Yedek kapsamı | Yeni alışveriş adetleri yedekte, bozuk veri reddediliyor | `lib/services/backup_service.dart` |
| Yedek/silme veri kaybı (GP-01/04/07/11) | 43 kullanıcı verisi alanı (sağlık günlükleri, hatırlatıcılar, aile tarifleri, mutfak/kiler/bütçe, favoriler) ve çocuk başına uyku günlükleri yedeğe ve "tüm kayıtları sil"e eklendi; dışa aktar → sil → geri yükle, eski/kısmi/bozuk yedek testleri | `test/gp01_backup_coverage_test.dart` |
| Kayıt hataları (GP-05) | Üreme takvimi (`reproductive_calendar_v1`), gebelik randevuları (`pregnancy_appointments_v3`) ve çocuk başına uyku günlüğü şifreli depoda tanımlı değildi; kayıt hata veriyordu, gebelik ekranı yüklenemiyordu. Düzeltildi | `lib/services/secure_health_store.dart` |
| Bildirimler (GP-09) | Kayıtlar silinince planlı tüm bildirimler iptal ediliyor; yedekten dönüşte hatırlatıcılar tercihe göre yeniden planlanıyor | `local_reminder_notifications.dart` |
| KVKK açık rıza (GP-11) | İlk açılışta aydınlatma özeti ve açık rıza ekranı; Profil'de gizlilik özeti; kayıt silme rızayı geri alır | `lib/widgets/consent_gate.dart` |
| Mağaza/KVKK taslakları (GP-12) | Mağaza metinleri, Play veri güvenliği yanıtları, veri envanteri, gizlilik politikası taslağı | `docs/MAGAZA_VE_KVKK_TASLAKLARI.md` |
| Sürüm | 1.0.0 (137) | `pubspec.yaml` |
| Mutfak modülü (Paket 39) | Uygulamaya hiç bağlanmamış ~25.000 satırlık tam Akıllı Alışveriş/Mutfak sayfası (`smart_shopping_page.dart.dart`) asıl sayfanın yerine alındı: bütçe, kiler, menü, fiyat geçmişi, israf, mutfak yedeği. 65 diyalogda kırmızı ekran kalıbı giderildi. 122 araç kategorili ve aranabilir "Mutfak araçları" ekranına taşındı; QA aracı yalnızca geliştirmede. Eski 4 kopya dosya silindi | `lib/screens/smart_shopping_page.dart`, `test/paket39_kitchen_tools_test.dart` |
| Sürüm yükseltme göçü (GP-02) | Eski düz kayıtların şifreli depoya kayıpsız taşınması, çelişen kopyada veri korunması ve ana ekranın eski profili göstermesi testli | `test/gp02_upgrade_migration_test.dart` |
| Günlük sızıntısı (GP-11) | `debugPrint` yayın sürümünde logcat'e yazıyordu ve JSON hataları kayıt içeriği taşıyabiliyordu; yayında günlük kapalı, geliştirmede maskeli | `lib/utils/privacy_log_sanitizer.dart` |
| Büyüme filtresi (GP-03) | Çocuk başına büyüme geçmişinde 3/6/12 ay filtresi | `child_growth_trends_page.dart` |
| Tarif defteri bağlantısı (GP-07) | Genel ve bebek tariflerinden "Aile tarif defterime ekle" | `lib/services/recipe_notebook_bridge.dart` |
| Cihaz test listesi | Gerçek cihazda yapılacak 30+ kontrol | `docs/CIHAZ_TEST_LISTESI.md` |
| Profil doğrulama (GP-02) | Ana ekran bebek profili formu doğrulayıcıdan geçiyor | `lib/main.dart` |
| Performans | Tarifler sekmesi 40'arlık sayfalama | `lib/main.dart` |

## Açık kalanlar (dürüst durum)

- **Genel tarifler:** 1003 tarif, hepsi ayrıntılı (test ile korunuyor). Uzman/editör okuması önerilir.
- **Bebek tarifleri (§4):** 304 tarif ile 300+ hedefi tamamlandı. Uzman/diyetisyen incelemesi yapılmadı; yayından önce önerilir.
- **Tarif ve bebek görselleri:** Lisanslı fotoğraf dosyaları gerekiyor; şu an simge kullanılıyor.
- **Görseller:** Referanstaki fotoğraf/illüstrasyonlar (bebek, anne, yemek fotoğrafları) lisanslı görsel gerektirir; şu an simge ve renk geçişi kullanılıyor.
- **Alışveriş (§7):** ürün detay, karşılaştırma ve kategori yapısı; gerçek fiyat/mağaza verisi için veri kaynağı gerekiyor.
- **Excel'deki backend/mağaza maddeleri:** AI backend, push, topluluk moderasyonu, Google Play / App Store satın alma ve sunucu makbuz doğrulaması, iOS imzalama, KVKK metinlerinin hukukçu onayı ve yayımlanması: hesap/anahtar ve yönetim kararı gerektirir; kodla tek başına kapatılamaz.
- **Gerçek cihaz testi:** Yapılmadı; kontrol listesi `docs/CIHAZ_TEST_LISTESI.md`.
