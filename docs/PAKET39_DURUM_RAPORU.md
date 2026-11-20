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
| Tasarım kabuğu (§1) | Alt menü: Ana Sayfa • Bebeğim • (+) • Tarifler • Profil; ortada pembe + butonu; ekran başlıkları pembe simge + başlık + zil; ana sayfa karşılama kartı, çocuk kartı, 6 modül kartı; profil düzeni | `lib/widgets/pastel_shell.dart` |
| Modül ayrımı (§2) | Alışveriş ve Kadınlar ana sayfa kartlarından açılır; Android geri tuşu alt bölümden ana sayfaya döner; ana sayfadaki bebek tarifi önerisi artık bebek tarifleri sayfasını açar | `lib/main.dart` |
| Genel tarifler (§3) | 39 dağınık kategori adı 18 kategoriye indirildi; 54 isim kopyası, 96 yakın kopya ve 55 tek malzeme varyantı çıkarıldı; tarif modeline kişi sayısı, hazırlık/pişirme süresi, zorluk, fırın sıcaklığı, püf noktası, servis, saklama eklendi; alerjenler malzemeden tespit ediliyor; 51 tarif baştan ayrıntılı yazıldı | `lib/data/general_recipe_catalog.dart`, `recipe_meta.dart`, testler |
| Performans | Tarifler sekmesi ~1000 kartı tek seferde çizmiyor; 40'arlık sayfalama | `lib/main.dart` |

## Açık kalanlar (dürüst durum)

- **Genel tarif sayısı:** 829 özgün tarif. 1.000 hedefi için yaklaşık 170 yeni özgün tarif gerekiyor.
- **Kalıp adımlı tarifler:** 167 tarif hâlâ genel adımlarla duruyor; uygulama bunları "ayrıntılı anlatım hazırlanıyor" notuyla gösteriyor.
- **Bebek tarifleri (§4):** Katalog 321 kayıt, yaş grupları 6+/8+/9+/10+/12+. İstenen 6–8, 9–11, 12–18, 18–24, 24–36, 36–72 ay gruplarına göre yeniden düzenleme ve 18+ ay içerikleri yapılmadı.
- **Tarif ve bebek görselleri:** Lisanslı fotoğraf dosyaları gerekiyor; şu an simge kullanılıyor.
- **Alt ekranların tasarımı:** Kabuk ve ana sayfa/profil referansa uyarlandı; Bebeğim sekmeleri (Gelişim/Sağlık/Aşılar/Notlar), Günlük Takip, Kadınlar takvimi, Gebelik ve Alışveriş ekranlarının referans düzeni henüz uygulanmadı.
- **Alışveriş (§7):** ürün detay, karşılaştırma ve kategori yapısı; gerçek fiyat/mağaza verisi için veri kaynağı gerekiyor.
- **Excel'deki backend/mağaza maddeleri:** AI backend, push, topluluk moderasyonu, Google Play / App Store satın alma ve sunucu makbuz doğrulaması, iOS imzalama, KVKK dokümanları: hesap/anahtar ve yönetim kararı gerektirir; kodla tek başına kapatılamaz.
- **Gerçek cihaz testi:** Yapılmadı.
