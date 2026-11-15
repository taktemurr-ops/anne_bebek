# GP-01 — Kullanıcı deneyimi ve kararlılık

Bu belge, 8 alt iş kaleminin gerçek durumunu ve kabul kriterlerini takip eder. **Kodlanmış olmak test edilmiş olmak değildir.**

| İş | Durum | Açıklama |
| --- | --- | --- |
| GP01-01 Ana ekran | Uygulandı; CI bekleniyor | Profil, günlük özet ve hızlı işlemler |
| GP01-02 Bebek profili | Mevcut akışa erişim eklendi; uçtan uca test gerekli | Ad/yaş kartı, profil düzenleme |
| GP01-03 Günlük takip | Mevcut günlüklerle bağlantı eklendi; uçtan uca test gerekli | Beslenme, uyku, bez |
| GP01-04 Büyüme | Mevcut grafiğe ve ölçüme erişim eklendi | Ölçüm geçmişi, grafik |
| GP01-05 Tarifler | Mevcut kataloğa erişim eklendi | Yaş/kategori/malzeme filtreleri korunur |
| GP01-06 Veri güvenliği | Mevcut şifreli yedekleme ekranına erişim eklendi | Geri yükleme testi ayrıca gerekli |
| GP01-07 Arayüz standardı | Kısmi | Hızlı işlem bileşeni ortak Material tema kullanıyor; diğer ekranlar denetlenmeli |
| GP01-08 Otomatik test | Kısmi | Hızlı işlem widget testi eklendi; tüm akışlar için test henüz yok |

## Kabul kriterleri

- `flutter analyze` başarılı.
- `flutter test` başarılı.
- `flutter build apk --debug` başarılı.
- Ana ekran küçük ekranlarda taşma yapmıyor.
- Profil, günlük, ölçüm, tarif ve yedekleme geçişleri gerçek cihazda çalışıyor.
- Mevcut kişisel kayıtlar güncellemeden sonra korunuyor.
- Geri yükleme işlemi, test verileriyle doğrulanıyor.

## Güvenli yayın

Değişiklikler yalnızca `feature/gp01-ana-ekran-hizli-islemler` dalındadır. CI ve manuel kabul tamamlanmadan `main` ile birleştirilmemelidir.
