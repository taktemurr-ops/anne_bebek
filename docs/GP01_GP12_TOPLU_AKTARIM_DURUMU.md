# GP-01–GP-12: Toplu geliştirme aktarım durumu

**Durum: WIP — üretime hazır değil.** GP-01–GP-12 ayrı açık PR #1–#12 içinde korunmaktadır. Bu entegrasyon dalı ana dala birleştirilmemiştir.

## Bu dalda bulunan ek modüller
- GP-04: günlük rutin modeli ve şifreli kayıt deposu
- GP-05: üreme takvimi ayarları, hesaplama, depo ve takvim ekranı
- GP-06: alışveriş listesi modeli ve şifreli kayıt deposu
- GP-07: tarif modeli ve şifreli kayıt deposu
- GP-08: AI için açık onay kontrolü ve temel iletişim bilgisi maskeleme
- GP-09: bildirim tercihleri modeli ve şifreli kayıt deposu
- GP-10: sunucu doğrulaması gerektiren premium yetki modeli
- GP-11: log maskeleme yardımcı aracı
- GP-12: yayın öncesi kapılar
- GP-04–09 için SecureHealthStore anahtar izinleri; GP-08/10/12 regresyon testleri

## Henüz tamamlanmamış işler
- Önceki çevrimdışı ZIP'teki bütün ekran ve test dosyaları bu dala aktarılmadı.
- GP-03 gelişim/sağlık değişiklikleri ve GP-01/02 alt dal farkları bu entegrasyon dalında birleştirilmedi.
- Modüllerin ana ekrana bağlanması ve uçtan uca kullanıcı akışları eksik.
- Canlı AI, ödeme, topluluk/bildirim servisleri ve güvenli backend doğrulamaları eksik.
- Flutter analyze/test, Android/iOS build, emülatör ve gerçek cihaz testleri bu dal için doğrulanmadı.
- GP-03/04 CI işleri geçmişte runner başlamadan başarısız oldu.

**Not:** Public depoya gerçek kullanıcı verisi, gizli anahtar, ödeme bilgisi veya çocuk sağlık verisi gönderilmemelidir.
