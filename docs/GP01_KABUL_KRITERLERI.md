# GP-01 — Mimari, kararlılık ve temel kullanıcı deneyimi

Bu belge GP-01'in sekiz alt işinin **kod ve kabul kanıtlarını** tutar. Kodun GitHub'a yüklenmesi, testten geçmesi ve fiziksel cihaz kabulü farklı aşamalardır. Fiziksel cihaz doğrulanmadıkça sürüm **yayına hazır** sayılmaz.

## Alt işler ve uygulanan kapsam

| Kod | İş | GitHub'da uygulanan kapsam | Kabul |
| --- | --- | --- | --- |
| GP01-01 | Ana ekran | Profil kartı, günlük sayaçlar, dört hızlı işlem; Beslenme ve Uyku kısayolları doğrudan kayıt oluşturuyor | CI + Android smoke + cihaz |
| GP01-02 | Bebek profili | Çoklu profil oluşturma, ad/doğum/cinsiyet düzenleme, profil genel bakışı, boş profil silme korumaları; günlük tarihini bozan doğum değişikliği engellendi | CI + cihaz |
| GP01-03 | Günlük takip | Beslenme, Uyku, Bez ve Ölçüm hızlı kayıtları; çocuğa özgü günlük ekleme/düzenleme ve güvenli saklama | CI + Android smoke + cihaz |
| GP01-04 | Büyüme | Ölçüm ekleme, büyüme geçmişi ve grafik bağlantısı, çocuğa göre filtreleme ve tarihsel karşılaştırma | CI + cihaz |
| GP01-05 | Tarifler | Bebek tarifleri kataloğu, arama, yaş ve kategori filtreleri, favoriler; başarısız favori kaydı geri alınır, favoriler yedeklenir | CI + Android smoke + cihaz |
| GP01-06 | Veri güvenliği | Şifreli yedekleme ekranı, eksik alanları silmeyen geri yükleme, çocuk profili/günlüğü/sağlık planı bütünlüğü, bozuk veri ön doğrulaması, geri alma ve gizli veri testleri | CI + cihazda veri korunumu |
| GP01-07 | Arayüz standardı | Ortak Material tema, hızlı işlem yerleşimi, erişilebilir işlem adları, 280/320/360/600 px widget testleri, doğru geri yükleme uyarıları | CI + cihaz |
| GP01-08 | Otomatik test/dağıtım | Widget, servis ve ekran akışı testleri; Flutter analiz, tüm testler, debug APK artifact; Android emülatör smoke işi eklendi | İki CI işi + APK |

## Otomatik testler

- `test/daily_quick_actions_test.dart`: dört hızlı işlem, erişim etiketleri ve dar ekranlar.
- `test/gp01_home_acceptance_test.dart`: ana ekrandan hızlı kayıt, iptal ve temel sayfa geçişleri.
- `test/gp01_screen_acceptance_test.dart`: çocuk profili → genel bakış → günlük kayıt; tarif favorisi ve arama filtreleri.
- `test/gp01_growth_acceptance_test.dart`: çocuğa özgü kilo ölçümü geçmişi.
- `test/gp01_profile_integrity_test.dart`: sağlık planı olan profilin yanlışlıkla silinmemesi.
- `test/backup_service_test.dart` ve `test/backup_inspection_test.dart`: yedek geçerliliği, veri koruma, şifreli saklama geçişi, tarif favorileri ve sağlık planı.
- `integration_test/gp01_smoke_test.dart`: gerçek Android emülatöründe başlangıç, Beslenme kaydı, profil, tarif ve yedek ekranına geçiş.

## Son doğrulanmış CI kanıtı (16.11.2026)

Commit `9048462dbd7cfde8a562ccc83f3808481a1a4dfa` için [Flutter CI #71](https://github.com/taktemurr-ops/anne_bebek/actions/runs/43926202919) **başarılı**: Flutter Analyze, Flutter Test, Android debug APK ve Android emülatör smoke işleri geçti. [APK artifact](https://github.com/taktemurr-ops/anne_bebek/actions/runs/43926202919/artifacts/14256917837) oluşturuldu (SHA-256 digest: `52f4b85747bd676d6f33a15d56b93af23c264d678959b1ee11b42a6532711e3f`). Bu kanıt **sonraki commitleri kapsamaz**. Sonraki `04e651b` commit'i Android kayıt için tekil kayıt ve geçerli zaman damgası kabulünü güçlendirir; yeni CI doğrulaması gerekir.

## Doğrulama kapıları

- [ ] Son GP-01 commit'inde `flutter analyze` hatasız.
- [ ] Son GP-01 commit'inde `flutter test` hatasız.
- [ ] Son GP-01 commit'inde `flutter build apk --debug` ve APK artifact başarılı.
- [ ] `GP-01 Android emulatorde ekran ve kayit testi` başarılı.
- [ ] Fiziksel Android cihazda küçük ekran/klavye/geri navigasyon ve profil–günlük–büyüme–tarif–yedek ekranları kontrol edildi.
- [ ] Önceki sürümden güncellenmiş cihazda kişisel kayıtlar, favoriler, sağlık planları ve şifreli yedek geri yükleme gerçek verileri silmeden doğrulandı.

Bu maddeleri yalnızca kanıt görüldükten sonra işaretle. Önceki başarılı CI #38 (`61f599d`) bugünkü tüm yeni değişiklikleri kapsamaz; en güncel commit için yeni CI sonucu esastır.

## Veri koruma uyarıları

- `BackupService.export()` servis içi **düz metin JSON** üretir. Kullanıcıya sunulan `BackupPage` bunu parola ile AES-256-GCM üzerinden şifreleyip panoya kopyalar. Panodaki şifreli veri yine de gizli saklanmalıdır.
- Kısmi/eski yedekler yalnızca içerdiği alanları değiştirir; bulunmayan alanları silmez. Hatalı veri yazma başlamadan reddedilir.
- Bulut oturum kimlikleri ve sırlar kullanıcı yedeğine **dahil edilmez**.
- Fiziksel cihaz güncelleme/kayıt koruma kabulü tamamlanmadan `main` birleştirmesi veya mağaza yayını yapılmaz.

**Pull Request:** https://github.com/taktemurr-ops/anne_bebek/pull/1
