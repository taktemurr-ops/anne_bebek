# Para kazanma: kurulum ve yayın adımları

Uygulamada para kazanmanın iki yolu kurulu. İkisi de ayarlar girilene kadar kapalı durur; kapalıyken kullanıcıya satış ya da bağlantı gösterilmez.

| Yöntem | Nasıl kazandırır | Uygulamada nerede |
|---|---|---|
| **Premium abonelik** (aylık / yıllık, isteğe bağlı aile) | Google Play ve App Store abonelik ücreti; mağaza ilk yıl %15 komisyon alır | Ana sayfa → Premium, ⋮ menü → Üyelik seçenekleri, rapor sayfasındaki PDF düğmesi |
| **İş birliği (affiliate) bağlantıları** | Ürün kataloğundan mağazaya giden alışverişlerden komisyon | Alışveriş → Ürün kataloğu → ürün ayrıntısı → "Mağazada ara" |

Sağlık, güvenlik ve ilk yardım içerikleri hiçbir koşulda ücretli değildir. Premium yalnızca ek kolaylık sunar: toplu takip raporunu PDF olarak indirme ve yazdırma, ileride eklenecek premium araçlar.

Uygulamaya reklam ağı (AdMob vb.) eklenmedi. Gerekçeler:

- Sağlık verisi işleyen bir anne-bebek uygulamasında reklam, kullanıcı güvenini düşürür.
- Google Play "Aileler" politikası ve KVKK ek yükümlülük getirir.
- Uygulama, ayarlanmamış bir reklam kimliğiyle açılışta çökebilir.

## 1. Sunucu (Supabase)

1. SQL düzenleyicide sırasıyla şunları çalıştır:
   - `BABY_FORUM_SUPABASE_SETUP.sql`
   - `WOMEN_FORUM_SUPABASE_SETUP.sql`
   - `FORUM_MODERATION_SETUP.sql`
   - `ADMIN_DASHBOARD_SETUP.sql`
   - `MONETIZATION_SUPABASE_SETUP.sql`
2. Doğrulama fonksiyonunu yükle: `supabase functions deploy subscription`. JWT doğrulaması açık kalmalı.
3. Gizli değerleri gir: `supabase secrets set ...`.
   - **Google:**
     - `GOOGLE_SERVICE_ACCOUNT_JSON`: Play Console → Kullanıcılar ve izinler bölümünde "Finansal veriler ve siparişleri görüntüleme" izni verilmiş servis hesabının JSON dosyası.
     - `ANDROID_PACKAGE_NAME`
   - **Apple:**
     - `APPLE_ISSUER_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY` (App Store Connect → Kullanıcılar ve Erişim → In-App Purchase anahtarı, .p8 içeriği)
     - `APPLE_BUNDLE_ID`
   - **İsteğe bağlı:** `PRODUCT_TIERS`, örneğin `{"premium_monthly":"premium","premium_yearly":"premium","family_monthly":"family"}`.
4. Kendi hesabını yönetici yap:

   ```sql
   insert into public.app_administrators(user_id) values ('HESAP-UUID');
   ```

   Profil → Merkezi Yönetim ekranında "Gelir ve üyelik" sayıları görünür. TL tutarları Play Console ve App Store Connect raporlarındadır.

## 2. Mağaza ürünleri

- **Google Play Console → Para kazanma → Abonelikler:**
  1. Örneğin `premium_monthly` ve `premium_yearly` aboneliklerini oluştur.
  2. Her birine bir temel plan ekle (otomatik yenilenen).
  3. Fiyatları gir.
  4. Kapalı test kanalına yüklenmiş bir sürüm gerekir.
- **App Store Connect → Abonelikler:**
  1. Bir abonelik grubu aç.
  2. Aynı kimliklerle ürünleri ekle.
  3. Ücretli Uygulamalar Sözleşmesi'ni ve banka/vergi bilgilerini tamamla.

## 3. Uygulama ayarları (GitHub → Settings → Variables)

Bunlar gizli değildir; repository **Variables** olarak girilir. Release iş akışı bunları derlemeye ekler.

| Değişken | Örnek |
|---|---|
| `SUPABASE_URL` | `https://xxxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase → API → anon key |
| `SUBSCRIPTION_API_URL` | `https://xxxx.supabase.co/functions/v1/subscription` |
| `ANDROID_PREMIUM_MONTHLY_ID` | `premium_monthly` |
| `ANDROID_PREMIUM_YEARLY_ID` | `premium_yearly` |
| `ANDROID_FAMILY_MONTHLY_ID` | boş bırakılabilir |
| `AFFILIATE_SEARCH_URL` | İş ortağının arama adresi; ürün adı `{q}` yerine gelir. Örnek: `https://www.magaza.com/sr?q={q}&ref=KODUN` |
| `AFFILIATE_PARTNER` | Mağazanın görünen adı |

iOS için `IOS_PREMIUM_MONTHLY_ID` ve `IOS_PREMIUM_YEARLY_ID` aynı biçimde `--dart-define` ile verilir.

## 4. Akış

1. Kullanıcı hesabına giriş yapar ve Premium'da plan seçer. Mağaza ödeme ekranı açılır.
2. Ödeme tamamlanınca uygulama satın alma belgesini `subscription/verify` adresine gönderir.
3. Sunucu belgeyi Google ya da Apple'a sorar ve sonucu `premium_subscriptions` tablosuna yazar.
4. Premium yalnızca sunucu "etkin" derse açılır. Satın alma başka bir hesaba bağlıysa reddedilir.
5. Yenilemeler `/status` çağrısında mağazaya yeniden sorularak güncellenir.
6. "Satın alımları geri yükle" ve "Aboneliği yönet / iptal et" düğmeleri Premium sayfasındadır.

## 5. Yasal kontrol listesi (yayından önce)

- Premium sayfasında yenileme ve iptal bilgisi yazılı. Mağaza sayfası ve gizlilik politikasına da abonelik koşulları eklenmeli.
- İş birliği bağlantıları uygulamada "Reklam · İş birliği bağlantısı" olarak etiketli (Ticari Reklam ve Haksız Ticari Uygulamalar Yönetmeliği).
- Tıklama sayımında kişisel veri tutulmuyor: yalnızca ürün kimliği, iş ortağı ve gün. Aydınlatma metninde yine de belirtilmeli.
- Vergi ve şirket bilgileri mağaza hesaplarında tamamlanmalı. Mağaza gelirleri için mali müşavirle görüşülmeli.
