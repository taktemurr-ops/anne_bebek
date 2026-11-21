# Anne & Bebek 1.0.0 — Gerçek Cihaz Test Listesi

Telefona son "Release derlemeleri" çıktısındaki APK'yı kurun (PR #14 → Checks → Release derlemeleri → `anne-bebek-android-test-imzali`). Her satırı işaretleyin; hata görürseniz ekran görüntüsü ve kısa açıklama yeterli.

Önerilen cihazlar: en az bir Android 13+ telefon, bir eski/küçük ekranlı Android (Android 9–11), mümkünse bir iPhone.

## 1. İlk açılış ve gizlilik
- [ ] Uygulama ilk açılışta gizlilik özeti ve onay kutusunu gösteriyor; kutu işaretlenmeden "Devam et" çalışmıyor
- [ ] Onaydan sonra kapatıp açınca onay tekrar sorulmuyor
- [ ] Profil → "Bu cihazdaki kayıtlarımı sil" → onay → uygulama yeniden onay ekranıyla açılıyor, kayıtlar boş

## 2. Bebeğim ve günlük takip
- [ ] Bebek profili oluştur (ad, doğum tarihi); hatalı tarih (gelecek tarih) reddediliyor
- [ ] Ana sayfadaki hızlı işlemlerle beslenme, uyku, bez kaydı ekle; sayaçlar artıyor
- [ ] Kayıt diyaloğunda "Kaydet"e hızlıca iki kez dokun: tek kayıt oluşuyor, kırmızı ekran yok
- [ ] Günlük Takip'te tarih ileri/geri; günün özeti doğru
- [ ] Uyku günlüğü: ikinci bir çocuk profili ekle, o çocuk için uyku kaydı gir; uygulamayı kapatıp aç, kayıt duruyor
- [ ] Büyüme: 3 ölçüm gir; büyüme geçmişinde 3/6/12 ay filtresi çalışıyor

## 3. Kadınlar
- [ ] Adet başlangıcı kaydet; takvimde adet, verimli dönem ve tahmini sonraki dönem görünüyor
- [ ] Üreme takvimi ayarlarını kaydet, uygulamayı kapatıp aç: ayarlar korunuyor *(bu sürümde düzeltilen hata)*
- [ ] Gebelik: son adet tarihi, kontrol listesi ve randevu ekle; kapatıp aç: hepsi duruyor *(bu sürümde düzeltilen hata)*

## 4. Tarifler
- [ ] Tarifler sekmesi akıcı kayıyor, arama ve kategori çipleri çalışıyor
- [ ] Bir tarifi aç → "Aile tarif defterime ekle" → tekrar dokununca "zaten defterde" mesajı
- [ ] Bebek tarifleri: yaş grubu filtresi; bir tarif detayında defter ekleme

## 5. Alışveriş ve mutfak
- [ ] Ürün ekle, adetini değiştir, tamamla, sil; kapatıp aç: liste korunuyor
- [ ] Akıllı alışveriş → "Mutfak araçları · Tümü": 5 kategori görünüyor, "bütçe" araması sonuç veriyor
- [ ] Bütçe belirle, ürün fiyatı gir: tahmini toplam güncelleniyor
- [ ] Kendi tariflerim / haftalık yemek şablonları açılıyor, kayıt eklenebiliyor

## 6. Hatırlatıcı ve bildirimler
- [ ] Bildirim izni iste → izin ver; 2 dakika sonrasına hatırlatıcı kur, bildirim geliyor
- [ ] Bildirim ayarlarından hatırlatıcıları kapat: planlı bildirim gelmiyor
- [ ] Telefonu yeniden başlat: açık hatırlatıcı yine geliyor
- [ ] Sessiz saat aralığındaki hatırlatıcı bildirim göstermiyor

## 7. Yedek ve geri yükleme
- [ ] Profil → Yedekleme: parolalı yedek al, metni bir not uygulamasına kaydet
- [ ] "Kayıtlarımı sil" → yedeği geri yükle → bebek kayıtları, kadın sağlığı kayıtları, tarif defteri, alışveriş ve mutfak verileri geri geliyor
- [ ] Yanlış parola ve bozuk metin: anlaşılır hata, mevcut kayıtlar değişmiyor

## 8. Genel
- [ ] Küçük ekranda (veya Ayarlar → yazı boyutu en büyük) taşan/kesilen yazı yok
- [ ] Geri tuşu: Alışveriş ve Kadınlar'dan ana sayfaya dönüyor
- [ ] Uçak modunda tüm bölümler çalışıyor ("Yakında" ekranları dışında)
- [ ] 10 dakika kullanım sonrası belirgin yavaşlama veya ısınma yok
