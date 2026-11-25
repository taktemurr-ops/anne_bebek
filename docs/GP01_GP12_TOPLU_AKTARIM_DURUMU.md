# GP-01–GP-12: Toplu geliştirme aktarım durumu

**Durum: WIP — üretime hazır değil.** GP-01–GP-12 için ayrı PR'lar korunur. Toplu entegrasyon dalı ana dala birleştirilmedi.

## Bu entegrasyon dalında geliştirilenler
- GP-02: Çocuk profili üzerinden GP-04 kayıtlarına geçiş; gerçek çocuk ID'siyle filtreleme; kayıt varken profil silme koruması.
- GP-04: Günlük yaşam (uyku, beslenme, bez, not) ekranı, şifreli depo ve kayıt yönetimi.
- GP-05: Gebelik/döngü takvimi modeli, deposu ve ekranı.
- GP-06: Alışveriş listesi modeli, deposu ve ekranı.
- GP-07: Tarif modeli, deposu ve aile tarif defteri ekranı.
- GP-08: AI açık onay kontrolü ve ekran + servis sınırında temel e-posta/telefon maskeleme.
- GP-09: Bildirim tercihleri ekranı, şifreli depo, sessiz saatler, kayıtlı izne göre hatırlatıcı planlama ve yeniden eşitleme.
- GP-10: Sunucu doğrulamalı abonelik durumu; eksik/geçersiz bitiş tarihinde premium haklarının kapalı tutulması. Gerçek mağaza satın alma aktif değil.
- GP-11: Log maskeleme yardımcı aracı ve regresyon testleri.
- GP-12: Yayın öncesi dokuz kontrol kapısı ve regresyon testleri.
- Ana ekrandan GP-04/05/06/07/09 ekranlarına geçişler.
- GP-02/04/08/09/10/11/12 test kaynakları (çalıştırılmadı).

## Yayına çıkışı engelleyen işler
1. Flutter analyze ve tüm testlerin CI'da başarılı çalıştırılması; test kodları henüz doğrulanmadı.
2. Android APK/AAB derleme, imzalama, emülatör ve fiziksel cihaz testleri.
3. macOS üzerinde iOS derleme, imzalama ve gerçek cihaz testleri.
4. GP-01/02/03 ve diğer açık PR'lardaki farkların dikkatli şekilde birleştirilmesi.
5. AI backend, topluluk, push bildirimleri ve satın alma/geri yükleme için gerçek servislerin entegrasyonu ve güvenlik doğrulaması.
6. Gizlilik değerlendirmesi, mağaza görselleri, açıklamaları ve yayın onayları.
7. Bildirim sessiz saatleri için cihaz üzerinde zaman dilimi ve teslim davranışı doğrulaması.

**Güvenlik:** Public depoya gerçek çocuk verileri, kullanıcı sağlık bilgileri, kimlik bilgileri veya gizli anahtarlar gönderilmez. Henüz hiçbir paket için uçtan uca üretim onayı verilmemiştir.
