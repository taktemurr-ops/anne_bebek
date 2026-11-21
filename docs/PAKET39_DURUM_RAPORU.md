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
| Profil doğrulama (GP-02) | Ana ekran bebek profili formu doğrulayıcıdan geçiyor | `lib/main.dart` |
| Performans | Tarifler sekmesi 40'arlık sayfalama | `lib/main.dart` |

## Açık kalanlar (dürüst durum)

- **Genel tarif sayısı:** 829 özgün tarif. 1.000 hedefi için yaklaşık 170 yeni özgün tarif gerekiyor.
- **Kalıp adımlı tarifler:** 167 tarif hâlâ genel adımlarla duruyor; uygulama bunları "ayrıntılı anlatım hazırlanıyor" notuyla gösteriyor.
- **Bebek tarifleri (§4):** 304 tarif ile 300+ hedefi tamamlandı. Uzman/diyetisyen incelemesi yapılmadı; yayından önce önerilir.
- **Tarif ve bebek görselleri:** Lisanslı fotoğraf dosyaları gerekiyor; şu an simge kullanılıyor.
- **Görseller:** Referanstaki fotoğraf/illüstrasyonlar (bebek, anne, yemek fotoğrafları) lisanslı görsel gerektirir; şu an simge ve renk geçişi kullanılıyor.
- **Alışveriş (§7):** ürün detay, karşılaştırma ve kategori yapısı; gerçek fiyat/mağaza verisi için veri kaynağı gerekiyor.
- **Excel'deki backend/mağaza maddeleri:** AI backend, push, topluluk moderasyonu, Google Play / App Store satın alma ve sunucu makbuz doğrulaması, iOS imzalama, KVKK dokümanları: hesap/anahtar ve yönetim kararı gerektirir; kodla tek başına kapatılamaz.
- **Gerçek cihaz testi:** Yapılmadı.
