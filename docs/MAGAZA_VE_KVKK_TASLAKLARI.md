# Anne & Bebek — Mağaza ve KVKK Taslakları

> **Taslaktır.** Yayından önce bir hukukçu (KVKK) ve bir sağlık uzmanı tarafından gözden geçirilmelidir. Köşeli parantezli alanlar (`[...]`) sizin tarafınızdan doldurulmalıdır.

Uygulama kimliği: `com.taktemurr.annebebek` · Sürüm: `1.0.0 (137)`

---

## 1. Mağaza metinleri

### Uygulama adı (en fazla 30 karakter)
Anne & Bebek

### Kısa açıklama (Google Play, en fazla 80 karakter)
Bebek takibi, döngü takvimi, 1000+ tarif ve alışveriş listesi tek uygulamada.

### Alt başlık (App Store, en fazla 30 karakter)
Bebek, sağlık ve mutfak

### Uzun açıklama
Anne & Bebek; bebeğinin günlük bakımını, kendi sağlık takibini ve ailenin mutfağını tek yerde toplamak isteyen anneler için hazırlandı.

**Bebeğim**
- Beslenme, uyku, bez ve ölçüm kayıtları; günlük özet ve tarih gezgini
- Kilo, boy ve baş çevresi takibi, büyüme özeti
- Birden fazla çocuk profili
- Aşı ve sağlık planı hatırlatıcıları (isteğe bağlı bildirim)

**Kadınlar**
- Adet döngüsü takvimi ve tahmini sonraki dönem
- Gebelik haftası kartı ve gebelik kontrol listesi
- Doğum sonrası takip ve kadın sağlığı günlüğü

**Tarifler**
- 1000'den fazla ayrıntılı genel tarif: ölçülü malzemeler, adım adım yapılış, süre, porsiyon, saklama ve servis önerileri
- 6–72 ay için 300'den fazla bebek ve çocuk tarifi; yaş grubuna göre filtre, 12 ay altında tuzsuz/şekersiz/balsız tarifler

**Alışveriş**
- Kategorili alışveriş listesi, adet ayarı, bütçe ve kiler takibi

**Gizlilik**
- Kayıtların cihazında tutulur; sağlık kayıtları cihazın güvenli deposunda şifrelenir
- Hesap açmak gerekmez
- Şifreli yedek alıp yeni cihaza taşıyabilir, tüm kayıtları tek dokunuşla silebilirsin

*Anne & Bebek tıbbi tavsiye vermez; tanı ve tedavi için doktorunuza danışın. Döngü tahminleri yaklaşıktır ve doğum kontrolü amacıyla kullanılmamalıdır.*

### Anahtar kelimeler (App Store, en fazla 100 karakter)
bebek,anne,emzirme,uyku,aşı,gebelik,adet,regl,tarif,ek gıda,alışveriş,büyüme

### Kategori ve yaş sınıfı
- Kategori: Sağlık ve Fitness (ikincil: Ebeveynlik / Yaşam Tarzı)
- Hedef kitle: 18 yaş ve üzeri yetişkinler (uygulama çocuklara yönelik değildir; çocuk verisini ebeveyn girer)
- İçerik derecelendirmesi anketi: şiddet, kumar, kullanıcı etkileşimi yok (forum "Yakında" olduğu sürece)

### Ekran görüntüleri listesi (her platformda en az 4)
1. Ana sayfa (pastel kartlar, hızlı işlemler)
2. Bebeğim → günlük takip ve özet
3. Kadınlar → döngü takvimi
4. Tarifler → tarif kartları ve tarif detayı
5. Bebek tarifleri → yaş grubu filtresi
6. Alışveriş → liste ve adet ayarı
7. Profil → yedek ve gizlilik

Telefon (1080×1920 veya üstü) ve 7"/10" tablet görüntüleri gerekir. Görsellerde gerçek kişi ve çocuk verisi kullanmayın.

### İletişim
- Destek e-postası: `[destek@...]`
- Gizlilik politikası URL'si: `[https://.../gizlilik]` (aşağıdaki metin yayımlanmalı)
- Web sitesi (isteğe bağlı): `[...]`

---

## 2. Google Play "Veri güvenliği" formu için yanıtlar (1.0.0)

| Soru | Yanıt | Gerekçe |
|---|---|---|
| Uygulama kullanıcı verisi topluyor veya paylaşıyor mu? | **Hayır** | 1.0.0'da tüm kayıtlar yalnızca cihazda tutulur; sunucuya gönderim yok. AI, forum, bulut ve premium "Yakında" ekranındadır ve ağ çağrısı yapmaz. |
| Veriler aktarım sırasında şifreleniyor mu? | Uygulanamaz | Aktarım yok |
| Kullanıcı verilerinin silinmesini isteyebilir mi? | Evet | Profil → "Tüm yerel kayıtları sil" |

> Sunucu özellikleri (AI, forum, bulut hesabı, premium) açıldığında bu form **mutlaka** güncellenmelidir: sağlık bilgisi, kişisel bilgi ve uygulama etkinliği toplanacağı için.

Apple "App Privacy" için de 1.0.0'da **"Data Not Collected"** seçilebilir; aynı uyarı geçerlidir.

### İzinler
| İzin | Neden |
|---|---|
| `POST_NOTIFICATIONS` | Kullanıcının açtığı hatırlatıcı bildirimleri |
| `RECEIVE_BOOT_COMPLETED` | Cihaz yeniden başladığında planlı hatırlatıcıların korunması |

Not: Release manifestinde `INTERNET` izni yoktur. Sunucu özellikleri açılırken eklenmelidir.

---

## 3. Kişisel veri envanteri (uygulama içi)

| Veri grubu | Örnek alanlar | Hassas mı? | Saklama yeri | Yedeğe dahil | Silme |
|---|---|---|---|---|---|
| Çocuk kimlik bilgisi | Ad, doğum tarihi, cinsiyet (`child_profiles_directory_v58`, `bebekAdi`, `dogum`) | Kişisel (çocuk) | Şifreli güvenli depo | Evet | Evet |
| Bebek bakım kayıtları | Beslenme, uyku, bez, notlar (`olaylar`, `baby_feeding_journal_v5`, `baby_sleep_journal_v1*`, `child_journal_entries_v59`) | Sağlık | Şifreli güvenli depo | Evet | Evet |
| Büyüme ve sağlık | Kilo/boy/baş çevresi, sağlık günlüğü, aşı/sağlık planı (`olcumler`, `baby_health_journal_v41`, `child_care_plan_v96`) | **Özel nitelikli (sağlık)** | Şifreli güvenli depo | Evet | Evet |
| Kadın sağlığı | Adet tarihleri, döngü geçmişi, gebelik, doğum sonrası (`sonAdet`, `cycle_history_v1`, `reproductive_calendar_v1`, `pregnancy_*`, `womens_health_journal_v46`, `postpartum_companion_v1`) | **Özel nitelikli (sağlık)** | Şifreli güvenli depo | Evet | Evet |
| Hatırlatıcılar ve bildirim tercihleri | `family_reminders_v40`, `family_notification_preferences_v1` | Kişisel | Şifreli güvenli depo | Evet | Evet (planlı bildirimler de iptal edilir) |
| Mutfak ve alışveriş | Liste, adetler, bütçe, kiler, menü, kişisel tarifler (`alisveris*`, `paket39_*`, `family_recipes_v1`) | Kişisel değil / düşük | Cihaz ayarları (düz) veya güvenli depo | Evet | Evet |
| Oturum (gelecek) | `cloud_auth_session_v1` | Kimlik doğrulama | Şifreli güvenli depo | Hayır (bilinçli olarak) | Evet |

- **Amaç:** Kullanıcının kendi ve çocuğunun kayıtlarını tutması, özet ve hatırlatıcı göstermek.
- **Hukuki sebep:** Sağlık verileri için açık rıza (KVKK m.6). Uygulama ilk açılışta rıza ekranı göstermelidir (bkz. açık maddeler).
- **Aktarım:** 1.0.0'da yok. Yurt dışına aktarım yok.
- **Saklama süresi:** Kullanıcı silene veya uygulamayı kaldırana kadar cihazda.
- **Yedek:** Kullanıcının oluşturduğu yedek dosyası parola ile şifrelenebilir. Düz yedek seçildiğinde uygulama uyarı gösterir. Yedeğin nerede saklanacağı kullanıcının sorumluluğundadır.

---

## 4. Gizlilik politikası ve aydınlatma metni (taslak)

**Veri sorumlusu:** `[Ad Soyad / Şirket unvanı]`, `[adres]`, `[e-posta]`

**1. Hangi verileri işliyoruz?**
Uygulamaya girdiğiniz bilgiler: sizin ve çocuğunuzun adı, doğum tarihi, bakım kayıtları (beslenme, uyku, bez), büyüme ölçümleri, sağlık ve aşı notları, adet ve gebelik bilgileri, hatırlatıcılar, alışveriş ve tarif kayıtları.

**2. Veriler nerede saklanıyor?**
Tüm kayıtlar yalnızca cihazınızda saklanır. Sağlıkla ilgili kayıtlar cihazınızın güvenli deposunda (Android Keystore / iOS Keychain) şifrelenir. Bu sürümde verileriniz bize veya üçüncü kişilere gönderilmez; reklam veya analiz aracı kullanılmaz.

**3. Hangi amaçla işliyoruz?**
Kayıtlarınızı size göstermek, özet ve tahminler (ör. sonraki adet tarihi) hesaplamak ve sizin açtığınız hatırlatıcıları bildirmek için.

**4. Hukuki sebep**
Sağlık verileriniz, 6698 sayılı KVKK'nın 6. maddesi uyarınca açık rızanıza dayanarak işlenir. Rızanızı istediğiniz zaman, kayıtlarınızı silerek geri alabilirsiniz.

**5. Haklarınız (KVKK m.11)**
Verilerinizin işlenip işlenmediğini öğrenme, düzeltme, silme ve itiraz haklarınız vardır. Veriler cihazınızda olduğundan bu hakları doğrudan uygulamadan kullanabilirsiniz: kayıtları düzenleyebilir, "Tüm yerel kayıtları sil" ile silebilir, yedek alarak bir kopyasını edinebilirsiniz. Sorularınız için: `[e-posta]`.

**6. Çocukların verileri**
Uygulama 18 yaş altı kullanıcılara yönelik değildir. Çocuğa ait bilgiler ebeveyn veya yasal vasi tarafından girilir.

**7. Tıbbi uyarı**
Uygulamadaki içerikler genel bilgilendirme amaçlıdır; tanı veya tedavi yerine geçmez. Döngü ve yumurtlama tahminleri yaklaşıktır, doğum kontrolü için kullanılmamalıdır. Acil durumlarda 112'yi arayın.

**8. Değişiklikler**
Sunucu tabanlı özellikler (hesap, bulut yedek, topluluk, yapay zekâ) eklendiğinde bu metin güncellenecek ve uygulama içinde yeniden onayınız istenecektir.

Son güncelleme: `[tarih]`

---

## 5. Bu taslağa bağlı açık maddeler
- Hukukçu onayı ve veri sorumlusu bilgilerinin doldurulması
- Gizlilik politikasının bir web adresinde yayımlanması (mağazalar zorunlu tutar)
- İlk açılışta açık rıza ekranı ve politikaya bağlantı
- Mağaza ekran görüntüleri ve uygulama simgesinin son hâli
- Sağlık içeriklerinin uzman incelemesi
