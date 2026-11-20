# Anne Bebek — Kullanıcı talepleri / kalan iş listesi
_Güncelleme: 21.11.2026 — kaynak: mevcut entegrasyon dalı ve önceki 12 paket kapsamı._

> **WIP:** Bir modülün kaynak kodunun bulunması, test edildiği veya yayınlanabilir olduğu anlamına gelmez. PR #13 henüz main'e alınmadı.

| Paket | Mevcut somut çıktı | Kalan iş / kabul koşulu |
|---|---|---|
| GP-01 Mimari ve stabilizasyon | Mevcut ana uygulama ve ayrı GP PR'ları | Ayrı PR değişikliklerini karşılaştır; bağımlılık/CI, hata yönetimi ve mimari incelemeyi bitir |
| GP-02 Kullanıcı / profil | Çocuk profili, profil bazlı günlük kayıt erişimi | Giriş, oturum, yetki, veri taşıma ve çoklu çocuk senaryolarını uçtan uca test et |
| GP-03 Bebek gelişimi / sağlık | Mevcut sağlık/büyüme ekranları; ayrı PR | GP-03 dalını entegre et; referans, veri doğruluğu ve sağlık uyarılarını gözden geçir |
| GP-04 Günlük yaşam | Uyku, beslenme, bez, not ekranı ve şifreli depo | UI, kalıcılık, veri silme ve çoklu profil cihaz testleri |
| GP-05 Gebelik / kadın sağlığı | Döngü takvimi ve kayıt ekranı | Sınır tarihleri, gizlilik ve cihaz testleri |
| GP-06 Alışveriş | Alışveriş kontrol listesi ekranı ve depo | Ekran ve kalıcılık testleri |
| GP-07 Beslenme / tarif | Kişisel tarif defteri ekranı ve depo | Kapsamlı tarif/öneri özellikleri ve testler |
| GP-08 AI | Açık onay, veri maskeleme, AI servis istemcisi | Gerçek backend, kota, kimlik doğrulama, güvenli hata yanıtları, entegrasyon testleri |
| GP-09 Bildirim / topluluk | Bildirim izinleri, sessiz saatler, yerel hatırlatıcılar | Topluluk akışları, gerçek push, izin iptalinde cihaz doğrulaması, zaman dilimi testleri |
| GP-10 Premium | Sunucudan abonelik durumunu okuma ve doğrulama | Android/iOS mağaza ürünleri, satın alma, geri yükleme, makbuz doğrulama, sandbox testleri |
| GP-11 Güvenlik / gizlilik | Şifreli yerel kayıtlar, log maskeleme ve test kaynakları | KVKK/gizlilik, tehdit modeli, API ve yetki testleri, gerçek veri sızıntısı kontrolleri |
| GP-12 Test / yayın | Yayın kapıları ve test kaynakları | flutter analyze/test, Android AAB/APK, iOS IPA, gerçek cihaz, imzalama, mağaza metadata |

## Bloklayıcı sıra
1. **CI/Flutter:** `flutter pub get`, `flutter analyze`, `flutter test` sonuçları doğrulanmalı; başarısız testler giderilmeli.
2. **Entegrasyon:** GP-01/02/03 ayrı PR'larıyla çakışmalar çözümlenmeli; WIP PR #13 test sonrası gözden geçirilmeli.
3. **Backend:** AI, topluluk, bildirim ve premium sunucu servisleri gerçek ortamda doğrulanmalı.
4. **Mobil:** Android/iOS imzalama, build ve gerçek cihaz senaryoları tamamlanmalı.
5. **Yayın:** Gizlilik, mağaza içerikleri, satın alma politikaları ve yayın onayları tamamlanmalı.

## Bu dalda eklenen test kaynakları
- `test/gp02_gp04_gp11_gp12_regression_test.dart`
- `test/gp04_gp06_gp07_data_integrity_test.dart`
- `test/gp08_gp10_gp12_integration_guard_test.dart`
- `test/gp09_gp10_subscription_notification_test.dart`

**Not:** Test kaynakları GitHub'a gönderildi; CI başarı sonucu veya cihaz testi kanıtı olmadan tamamlandı denmez. Public depoya gerçek kullanıcı/çocuk verisi veya gizli anahtar yüklenmez.
