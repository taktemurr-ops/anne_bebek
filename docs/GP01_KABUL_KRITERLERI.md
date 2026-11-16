# GP-01 — Kullanıcı deneyimi ve kararlılık

Bu belge, 8 alt iş kaleminin gerçek durumunu ve kabul kriterlerini takip eder. **Kodlanmış olmak test edilmiş olmak değildir.**

| İş | Durum | Açıklama |
| --- | --- | --- |
| GP01-01 Ana ekran | Uygulandı; CI #32 başarılı, manuel test bekleniyor | Profil, günlük özet ve hızlı işlemler |
| GP01-02 Bebek profili | Mevcut akışa erişim eklendi; uçtan uca test gerekli | Ad/yaş kartı, profil düzenleme |
| GP01-03 Günlük takip | Mevcut günlüklerle bağlantı eklendi; uçtan uca test gerekli | Beslenme, uyku, bez |
| GP01-04 Büyüme | Mevcut grafiğe ve ölçüme erişim eklendi | Ölçüm geçmişi, grafik |
| GP01-05 Tarifler | Mevcut kataloğa erişim eklendi | Yaş/kategori/malzeme filtreleri korunur |
| GP01-06 Veri güvenliği | Yedekleme ekranına erişim ve çoklu çocuk geri yükleme testleri eklendi | Yeni CI ve cihaz testi bekleniyor |
| GP01-07 Arayüz standardı | Kısmi | Hızlı işlem bileşeni ortak Material tema kullanıyor; diğer ekranlar denetlenmeli |
| GP01-08 Otomatik test | Kısmi | Hızlı işlem, yaş hesaplama ve yedek geri yükleme testleri eklendi; uçtan uca cihaz testleri henüz yok |

## Kabul kriterleri

- `flutter analyze` başarılı.
- `flutter test` başarılı.
- `flutter build apk --debug` başarılı.
- Ana ekran küçük ekranlarda taşma yapmıyor.
- Profil, günlük, ölçüm, tarif ve yedekleme geçişleri gerçek cihazda çalışıyor.
- Mevcut kişisel kayıtlar güncellemeden sonra korunuyor.
- Geri yükleme işlemi, test verileriyle doğrulanıyor.

## CI #38 ve kabul kanıtı (16 Kasım 2026)

- Commit `61f599d4eab3bd72d719321c3233b362bedfa8fd` için [Flutter CI #38](https://github.com/taktemurr-ops/anne_bebek/actions/runs/43894958542) **başarılı**.
- Aynı committe `flutter analyze`, `flutter test`, `flutter build apk --debug` ve APK artifact yükleme adımları başarılı.
- Küçük ekran widget testleri 280, 320, 360 ve 600 px genişlikleri kapsıyor; fiziksel cihaz testi yerine geçmez.
- Yedek önizlemesi gizlilik ve geçersiz Life Hub yedeğinde veri koruma testleri CI #38 kapsamında geçti.
- **Açık kabul maddeleri:** gerçek cihazda profil/günlük/ölçüm/tarif/yedekleme gezinmesi, ekran taşması ve güncelleme sonrası kalıcı veri doğrulaması.
- GP-01 yalnızca bu maddeler kanıtlandığında tamamlandı olarak işaretlenebilir.

## Güvenli yayın

Değişiklikler yalnızca `feature/gp01-ana-ekran-hizli-islemler` dalındadır. CI ve manuel kabul tamamlanmadan `main` ile birleştirilmemelidir.

## 16 Kasım 2026 doğrulama notu

- CI #32 (`0a5dbf5`): Flutter analiz, test ve debug APK başarılı.
- Çoklu çocuk profil ve günlük yedeğinin geri yüklenmesini ve geçersiz ilişkili kayıtların veri kaybı olmadan reddini doğrulayan yeni testler `8de83f7` commitine eklendi; bu commit için CI sonucu ayrıca doğrulanmalıdır.
- Gerçek cihazda gezinme, küçük ekran ve kalıcı veri koruma kabul kriterleri henüz tamamlanmadı.
- Dışa aktarılan yedek dosyası düz metindir; şifrelenmiş dosya olarak sunulmamalıdır.
