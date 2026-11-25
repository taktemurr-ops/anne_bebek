# GP-12 Yayın Kabul Kontrol Listesi

Bu liste yayın için **zorunlu** kontrolleri tanımlar. Bir PR veya commit oluşturulması teslim onayı değildir.

- [ ] GP-01–GP-12 kapsamları ürün gereksinimlerine göre tamamlandı ve gözden geçirildi.
- [ ] `flutter analyze` başarılı.
- [ ] `flutter test` başarılı; yeni modüllerin regresyon testleri var.
- [ ] Android release derlemesi ve imzalama gerçek ortamda doğrulandı.
- [ ] Android gerçek cihazda temel akışlar ve veri kalıcılığı test edildi.
- [ ] iOS release/archive derlemesi, sertifikalar ve provisioning doğrulandı.
- [ ] iOS gerçek cihazda temel akışlar ve veri kalıcılığı test edildi.
- [ ] Hassas anne/bebek verileri, izinler, saklama, silme ve gizlilik beyanları incelendi.
- [ ] Harici AI aktarımı için açık onay, veri minimizasyonu ve sağlayıcı sözleşmeleri doğrulandı.
- [ ] Satın alma ve premium erişim mağaza/sunucu üzerinden doğrulandı; sahte istemci yetkileri reddediliyor.
- [ ] App Store ve Google Play mağaza açıklamaları, görselleri ve yaş/sağlık beyanları hazır.
- [ ] Sürüm numarası, changelog, hata izleme ve geri dönüş prosedürü hazır.

## Kabul kaydı

Her madde için CI koşusu veya test raporu, tarih, sorumlu ve doğrulama bağlantısı kaydedilmelidir. Kanıtı bulunmayan maddeler tamamlandı işaretlenmez.
