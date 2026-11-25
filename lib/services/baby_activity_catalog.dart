class BabyActivity {
  final String id, title, area, materials, steps, safety;
  final int minMonth, maxMonth, minutes;
  const BabyActivity({required this.id, required this.title, required this.area, required this.materials, required this.steps, required this.safety, required this.minMonth, required this.maxMonth, required this.minutes});
}

class BabyActivityCatalog {
  static const ageBands = <(int, int)>[(0, 2), (3, 5), (6, 8), (9, 11), (12, 17), (18, 23), (24, 29), (30, 35), (36, 47), (48, 59), (60, 72)];
  static const _ideas = <(String, String, String, String)>[
    ('Yüz ifadelerini keşfet', 'İletişim', 'Ayna', 'Karşılıklı yüz ifadeleri yapın ve tepki vermesi için bekleyin.'),
    ('Ninni dinleme', 'Dil', 'Sesiniz', 'Yavaş bir ninni söyleyin; ses ve ritim değişikliklerini fark etmesini sağlayın.'),
    ('Renkli kumaş izleme', 'Duyu', 'Büyük yumuşak kumaş', 'Kumaşı görüş alanında yavaşça hareket ettirin.'),
    ('Dokunma keşfi', 'Duyu', 'Farklı dokulu büyük kumaşlar', 'Güvenli dokuları sırayla hissetmesine fırsat verin.'),
    ('Hikâye saati', 'Dil', 'Yaşa uygun resimli kitap', 'Resimleri göstererek kısa bir hikâye anlatın.'),
    ('Resim adlandırma', 'Dil', 'Büyük resimli kitap', 'Resimdeki nesneleri isimlendirin ve tekrar edin.'),
    ('Ritim tutma', 'Müzik', 'Elleriniz', 'Ellerinizle yumuşak ritimler oluşturun.'),
    ('Sesin yönünü bul', 'Duyu', 'Yumuşak ses çıkaran oyuncak', 'Sesi farklı yönlerden duyurarak dikkatini takip edin.'),
    ('Yumuşak top yuvarlama', 'Motor', 'Büyük yumuşak top', 'Topu yavaşça yuvarlayarak karşılıklı oyun kurun.'),
    ('Hareketli şarkı', 'Müzik', 'Müzik', 'Şarkıya uygun güvenli el ve beden hareketleri yapın.'),
    ('Hayvan sesleri', 'Dil', 'Hayvan resimleri', 'Resimdeki hayvanın sesini taklit edin.'),
    ('Renk avı', 'Bilişsel', 'Büyük renkli nesneler', 'Çevrede aynı renkte nesneler arayın.'),
    ('Şekil keşfi', 'Bilişsel', 'Büyük güvenli şekiller', 'Yuvarlak ve köşeli şekilleri birlikte inceleyin.'),
    ('Saklanan oyuncağı bul', 'Bilişsel', 'Büyük oyuncak ve örtü', 'Oyuncağı kısmen örtüp bulmasını teşvik edin.'),
    ('Taklit oyunu', 'Sosyal', 'Gereç gerekmez', 'Basit hareketleri sırayla taklit edin.'),
    ('Kukla sohbeti', 'Dil', 'Büyük yumuşak kukla', 'Kuklayla kısa bir konuşma canlandırın.'),
    ('Yastık yolu', 'Motor', 'Kaymayan büyük minderler', 'Yerde güvenli bir hareket rotası hazırlayın.'),
    ('Dans molası', 'Motor', 'Müzik', 'Müziğe uygun serbest ve güvenli hareket edin.'),
    ('Doğa sesleri', 'Duyu', 'Pencere veya açık hava', 'Çevredeki sesleri birlikte dinleyip adlandırın.'),
    ('Bulut izleme', 'Duyu', 'Açık hava', 'Gökyüzünü birlikte izleyip şekiller hakkında konuşun.'),
    ('Yaprak inceleme', 'Doğa', 'Büyük sağlam yaprak', 'Yaprağın rengini ve dokusunu birlikte inceleyin.'),
    ('Su sesi dinleme', 'Duyu', 'Yetişkin kontrollü su', 'Suyun sesini dinletin; suyla teması sürekli gözetin.'),
    ('Duygu aynası', 'Sosyal', 'Ayna', 'Mutlu ve şaşkın gibi ifadeleri aynada gösterin.'),
    ('Aile fotoğrafı sohbeti', 'Sosyal', 'Fotoğraf albümü', 'Aile bireylerini fotoğraflardan tanıtın.'),
    ('Oyuncak sıralama', 'Bilişsel', 'Büyük oyuncaklar', 'Oyuncakları boyutlarına veya renklerine göre ayırın.'),
    ('Kule kurma', 'Motor', 'Büyük yumuşak bloklar', 'Blokları üst üste koyup birlikte yıkın.'),
    ('Kapak aç-kapa', 'Motor', 'Büyük güvenli kaplar', 'Kapların açılıp kapanmasını gösterin.'),
    ('Eşleştirme oyunu', 'Bilişsel', 'Büyük resim kartları', 'Aynı resimleri birlikte eşleştirin.'),
    ('Nesne sayma', 'Bilişsel', 'Büyük oyuncaklar', 'Oyuncakları işaret ederek yavaşça sayın.'),
    ('Sıra bekleme', 'Sosyal', 'Yumuşak top', 'Topu sırayla birbirinize verin.'),
    ('Merhaba oyunu', 'Sosyal', 'Gereç gerekmez', 'El sallayarak selamlaşmayı canlandırın.'),
    ('Hikâyeyi tamamlama', 'Dil', 'Resimli kitap', 'Hikâyeyi durdurup sıradaki olayı birlikte düşünün.'),
    ('Kafiyeli sözcükler', 'Dil', 'Gereç gerekmez', 'Benzer sesli sözcüklerle eğlenceli tekrarlar yapın.'),
    ('Gölge izleme', 'Duyu', 'Gün ışığı', 'Duvara düşen gölgeleri birlikte inceleyin.'),
    ('Basit yoga hareketleri', 'Motor', 'Yumuşak zemin', 'Yaşa uygun, zorlamayan esneme hareketleri yapın.'),
    ('Yavaş-hızlı ritim', 'Müzik', 'Elleriniz', 'Ritmi yavaşlatıp hızlandırarak farkı gösterin.'),
    ('Oyuncak pikniği', 'Hayal gücü', 'Büyük oyuncaklar', 'Oyuncaklarla hayali piknik kurun.'),
    ('Doktorculuk', 'Hayal gücü', 'Büyük oyuncak seti', 'Oyuncaklarla basit bakım rolleri canlandırın.'),
    ('Mutfak oyunu', 'Hayal gücü', 'Güvenli büyük kaplar', 'Hayali yemek hazırlama oyunu oynayın.'),
    ('Hazine sepeti', 'Duyu', 'Büyük güvenli ev nesneleri', 'Sepetteki nesneleri tek tek keşfedin.'),
    ('Mevsimleri konuşma', 'Doğa', 'Mevsim resimleri', 'Hava durumunu ve mevsim farklarını konuşun.'),
    ('Renkli yol', 'Motor', 'Kaymaz renkli yer işaretleri', 'Yerdeki işaretleri takip ederek ilerleyin.'),
    ('Hafıza sohbeti', 'Bilişsel', 'Fotoğraf', 'Günün bir olayını hatırlayıp anlatın.'),
    ('Nesne nerede', 'Bilişsel', 'Büyük oyuncak', 'Oyuncağı görünür bir yere koyup yerini tarif edin.'),
    ('Beden bölümleri', 'Dil', 'Gereç gerekmez', 'El, ayak ve burun gibi bölümleri adlandırın.'),
    ('Günün şarkısı', 'Müzik', 'Gereç gerekmez', 'Bir şarkıyı tekrar ederek birlikte söyleyin.'),
    ('Masal kahramanı', 'Hayal gücü', 'Resimli kitap', 'Bir kahramanın ne yapacağını birlikte hayal edin.'),
    ('Duygu kartları', 'Sosyal', 'Büyük duygu resimleri', 'Resimlerdeki duyguları isimlendirin.'),
    ('Yumuşak engel yolu', 'Motor', 'Büyük minderler', 'Güvenli bir parkuru yetişkin eşliğinde geçin.'),
    ('Ses taklidi', 'Dil', 'Gereç gerekmez', 'Günlük sesleri taklit ederek karşılıklı tekrar edin.'),
    ('Renkli hikâye', 'Dil', 'Resimli kitap', 'Bir renk seçip hikâyedeki o renkte nesneleri bulun.'),
    ('Gün sonu sohbeti', 'Sosyal', 'Gereç gerekmez', 'Günün sevilen anlarını kısa cümlelerle paylaşın.'),
  ];

  /// Yalnızca belirli yaş dönemine uygun, dönemin gelişim becerilerine göre
  /// yazılmış etkinlikler (yaş dönemi dizini, ad, alan, malzeme, uygulama).
  static const _targeted = <(int, String, String, String, String)>[
    (0, 'Karın üstü sohbet', 'Motor', 'Yumuşak battaniye, sizin yüzünüz', 'Bebek uyanık ve tokken onu göğsünüzün üzerine yüzüstü yatırın. Yüzünüzü onun hizasına getirip konuşun; başını kaldırmaya çalıştıkça gülümseyin. 1–2 dakika ile başlayın.'),
    (0, 'Siyah-beyaz kart izleme', 'Duyu', 'Siyah-beyaz desenli kartlar', 'Kartı bebeğin yüzünden 20–30 cm uzakta tutun. Bakışını sabitlediğinde kartı yavaşça sağa sola kaydırın. Başını çevirince durun.'),
    (0, 'Ses ve gülümseme sırası', 'İletişim', 'Gereç gerekmez', 'Bebek bir ses çıkardığında aynı sesi yumuşakça tekrarlayın ve bekleyin. Karşılıklı “konuşma” sırası kurmaya çalışın.'),
    (0, 'Bebek masajı', 'Duyu', 'Kokusuz bebek yağı (isteğe bağlı)', 'Sıcak bir odada, beslenmeden en az 30 dakika sonra bacaklardan başlayarak hafif ve yavaş hareketlerle masaj yapın. Ağlarsa bırakın.'),
    (1, 'Oyuncağa uzanma', 'Motor', 'Hafif çıngırak', 'Bebek sırtüstü yatarken çıngırağı göğsünün üstünde, eliyle ulaşabileceği yerde tutun. Uzanıp dokununca adını söyleyerek kutlayın.'),
    (1, 'Yan dönme desteği', 'Motor', 'Yumuşak minder', 'Bebeği yerde sırtüstü yatırın, sevdiği oyuncağı bir yanına koyun. Dönmeye çalışırken kalçasına hafif destek verin; döndürmeye zorlamayın.'),
    (1, 'Ayna karşısında karın üstü', 'Sosyal', 'Kırılmaz bebek aynası', 'Karın üstü zamanında aynayı önüne yerleştirin. Kendi yansımasıyla ilgilenmesini izleyin, onunla birlikte konuşun.'),
    (1, 'Agucuk taklidi', 'Dil', 'Gereç gerekmez', 'Bebeğin “agu, ba” gibi seslerini taklit edin, sonra yeni bir hece ekleyin. Cevap vermesi için birkaç saniye bekleyin.'),
    (2, 'Ce-e oyunu', 'Sosyal', 'Hafif örtü', 'Yüzünüzü örtüyle kapatın ve “Ce-e!” diyerek açın. Sonra örtüyü bebeğin eline verin, kendisi çekmesine fırsat verin.'),
    (2, 'Elden ele geçirme', 'Motor', 'İki küçük ama yutulamayacak büyüklükte oyuncak', 'Oyuncağı bir eline verin, sonra diğer eline uzatın. İki elini birlikte kullanmasını teşvik edin.'),
    (2, 'Destekli oturma oyunu', 'Motor', 'Emzirme yastığı ya da minder', 'Bebeği yastık desteğiyle oturtun, oyuncakları biraz yanlara koyun. Uzanırken dengesini korumasını izleyin; yanından ayrılmayın.'),
    (2, 'Kap içine bırakma', 'Bilişsel', 'Büyük plastik kase, büyük bloklar', 'Bir bloğu kaseye bırakıp sesini dinletin. Sonra bloğu ona verin ve bırakmasını bekleyin.'),
    (3, 'Bay bay ve alkış', 'Sosyal', 'Gereç gerekmez', 'Biri odadan çıkarken “bay bay” deyip el sallayın; şarkı sonunda alkışlayın. Taklit etmesi için bekleyin.'),
    (3, 'Mobilyaya tutunarak yürüme', 'Motor', 'Sağlam kanepe, oyuncak', 'Oyuncağı kanepenin diğer ucuna koyun. Tutunarak yan yan ilerlemesini teşvik edin; sivri köşeleri koruyun.'),
    (3, 'Tencere davulu', 'Müzik', 'Tencere, tahta kaşık', 'Tencereyi ters çevirip tahta kaşıkla vurmayı gösterin. Hızlı-yavaş, sesli-sessiz vuruşları birlikte deneyin.'),
    (3, 'Kutudan çıkarma', 'Bilişsel', 'Ayakkabı kutusu, büyük yumuşak oyuncaklar', 'Oyuncakları kutuya koyun, birlikte tek tek çıkarın. Sonra geri koyma oyununa dönüştürün.'),
    (4, 'İtme arabası yürüyüşü', 'Motor', 'Sağlam itme arabası ya da boş karton kutu', 'Çocuğun arabayı iterek yürümesine eşlik edin. Kaymayan zeminde ve merdivenden uzakta oynayın.'),
    (4, 'İşaret et ve söyle', 'Dil', 'Resimli kitap', 'Bir resmi işaret edip “Kedi nerede?” diye sorun. Gösterdiğinde sözcüğü tekrar edin.'),
    (4, 'Basit şekil kutusu', 'Bilişsel', 'Yuvarlak ve kare delikli şekil kutusu', 'Önce yuvarlak parçayla başlayın. Doğru deliği bulana kadar elini yönlendirin, sonra kendi denemesine izin verin.'),
    (4, 'Kalın boya ile karalama', 'Sanat', 'Kalın mum boya, büyük kâğıt', 'Kâğıdı masaya bantlayın. Boyayı tutmayı gösterip birlikte karalayın; boyayı ağzına götürmemesi için yanında olun.'),
    (5, 'Top tekmeleme', 'Motor', 'Büyük hafif top', 'Topu çocuğun ayağının önüne koyun, tekmelemeyi gösterin. Düşmemesi için gerekirse elinden tutun.'),
    (5, 'İki kelimelik cümleler', 'Dil', 'Gereç gerekmez', 'Çocuğun tek kelimesini iki kelimeyle genişletin: “Su” dediğinde “Su iç” deyin. Düzeltmeden, örnek olun.'),
    (5, 'Bebeğini doyur', 'Hayal gücü', 'Oyuncak bebek, plastik kaşık ve kase', 'Oyuncak bebeği doyurup uyutmayı canlandırın. Sırayı çocuğa verin ve ne yaptığını anlatın.'),
    (5, 'Bez çorap eşleştirme', 'Bilişsel', '3–4 çift renkli çorap', 'Çorapları karıştırın, birlikte eşlerini bulun. Her eşi bulunca rengini söyleyin.'),
    (6, 'Zıplama oyunu', 'Motor', 'Yumuşak minder', 'İki ayak birlikte zıplamayı gösterin. Minderin üstünde, elini tutarak birkaç kez deneyin.'),
    (6, 'Renk sepeti', 'Bilişsel', 'İki renkli kova, renkli toplar', 'Kırmızı topları kırmızı kovaya, mavileri mavi kovaya koyun. Karışık olanları birlikte düzeltin.'),
    (6, 'Oyun hamuru', 'Sanat', 'Ev yapımı ya da güvenli oyun hamuru', 'Hamuru yuvarlayıp yılan ve top yapın. Kalıplarla basmayı gösterin; ağzına koymamasını hatırlatın.'),
    (6, 'Ne yapıyoruz?', 'Dil', 'Gereç gerekmez', 'Gün içinde yaptığınız işleri anlatın: “Çorap giyiyoruz.” Sonra çocuğa “Ne yapıyoruz?” diye sorun.'),
    (7, 'Kısa engel parkuru', 'Motor', 'Minder, karton tünel, yastık', 'Altından geç, üstünden atla, etrafından dolaş gibi üç adımlı bir parkur kurun. Sırayı birlikte söyleyin.'),
    (7, 'Büyük-küçük sıralama', 'Bilişsel', 'Farklı boyutta 3–4 kap', 'Kapları büyükten küçüğe dizin. Karıştırıp çocuğun sıralamasına fırsat verin.'),
    (7, 'Parmak boyası', 'Sanat', 'Yıkanabilir parmak boyası, önlük', 'Kâğıt ve önlük hazırlayın. Elleriyle iz bırakmasına, renkleri karıştırmasına izin verin; sonra birlikte temizleyin.'),
    (7, 'Duygu kuklası', 'Sosyal', 'Çorap kukla', 'Kuklanın üzgün, kızgın, mutlu olduğu küçük sahneler canlandırın. Çocuğa “Kukla ne hissediyor?” diye sorun.'),
    (8, 'Makasla kesme denemesi', 'Motor', 'Çocuk makası, kalın kâğıt şeritleri', 'Ucu yuvarlak çocuk makasıyla kâğıt şeritlerini kesmeyi gösterin. Makası taşırken ucu aşağıda tutmayı öğretin.'),
    (8, 'Hikâye zarı', 'Dil', 'Resimli zar ya da resim kartları', 'Zarı atın, çıkan resimle hikâyeye bir cümle ekleyin. Sırayla devam edin.'),
    (8, 'Desen tamamlama', 'Bilişsel', 'Renkli bloklar', 'Kırmızı-mavi-kırmızı-mavi gibi bir desen kurun. Sıradaki rengi çocuğun bulmasını isteyin.'),
    (8, 'Evde market oyunu', 'Hayal gücü', 'Boş ambalajlar, oyuncak para', 'Kasiyer ve müşteri rolleri alın. Saymayı ve teşekkür etmeyi oyunun içinde tekrar edin.'),
    (9, 'Tek ayak üstünde durma', 'Motor', 'Gereç gerekmez', 'Tek ayak üstünde birlikte 5’e kadar sayın. Ayak değiştirin; düşerse gülerek yeniden deneyin.'),
    (9, 'Harf avı', 'Dil', 'Kitap ya da ambalajlar', 'Çocuğun adının ilk harfini evdeki yazılarda arayın. Bulunca sesini birlikte söyleyin.'),
    (9, 'Batan-yüzen deneyi', 'Bilim', 'Su dolu kap, farklı nesneler', 'Önce tahmin edin, sonra nesneyi suya koyup bakın. Sonuçları iki gruba ayırın. Suyun başından ayrılmayın.'),
    (9, 'Kurallı masa oyunu', 'Sosyal', 'Basit kutu oyunu', 'Sıra bekleme ve kaybetmeyi kabul etmeyi öğreten kısa bir oyun oynayın. Kuralları oyundan önce birlikte tekrarlayın.'),
    (10, 'Bisiklet ya da denge bisikleti', 'Motor', 'Kask, denge bisikleti', 'Kask takarak trafikten uzak, düz bir alanda pratik yapın. Kısa mesafelerle başlayın.'),
    (10, 'Mini tarif', 'Yaşam becerisi', 'Yoğurt, meyve, kase', 'Çocuğun meyveyi tereyağı bıçağıyla kesip yoğurda karıştırmasına izin verin. Elleri yıkamayla başlayın.'),
    (10, 'Haftalık hava durumu çizelgesi', 'Bilim', 'Kâğıt, kalem', 'Her gün havayı gözleyip çizelgeye güneş, bulut ya da yağmur çizin. Hafta sonunda sayın.'),
    (10, 'Mektup yazma oyunu', 'Dil', 'Kâğıt, zarf, boya', 'Büyükanne ya da arkadaşa resimli bir “mektup” hazırlayın. Çocuk anlatsın, siz yazın; adını kendisi yazmayı denesin.'),
  ];

  static final List<BabyActivity> all = List.unmodifiable([
    for (var band = 0; band < ageBands.length; band++)
      for (var i = 0; i < _ideas.length; i++)
        BabyActivity(
          id: 'activity_${band}_$i', title: _ideas[i].$1,
          area: _ideas[i].$2, materials: _ideas[i].$3,
          minMonth: ageBands[band].$1, maxMonth: ageBands[band].$2,
          minutes: ageBands[band].$1 < 6 ? 3 : ageBands[band].$1 < 24 ? 8 : 15,
          steps: '${_ideas[i].$4}\n\nYaşa uyarlama: ${_adaptation(band)}',
          safety: ageBands[band].$1 < 36
              ? 'Yetişkin sürekli gözetiminde uygulayın. Küçük parçalar, kopabilen nesneler, ipler ve boğulma riski oluşturan malzemeler kullanmayın. Bebek istemezse durun.'
              : 'Yetişkin gözetiminde, yaşa uygun güvenli malzemelerle uygulayın. Çocuk istemezse ara verin.',
        ),
    for (var i = 0; i < _targeted.length; i++)
      BabyActivity(
        id: 'activity_age_$i', title: _targeted[i].$2,
        area: _targeted[i].$3, materials: _targeted[i].$4,
        minMonth: ageBands[_targeted[i].$1].$1, maxMonth: ageBands[_targeted[i].$1].$2,
        minutes: ageBands[_targeted[i].$1].$1 < 6 ? 3 : ageBands[_targeted[i].$1].$1 < 24 ? 8 : 15,
        steps: _targeted[i].$5,
        safety: ageBands[_targeted[i].$1].$1 < 36
            ? 'Yetişkin sürekli gözetiminde uygulayın. Küçük parçalar, kopabilen nesneler, ipler ve boğulma riski oluşturan malzemeler kullanmayın. Bebek istemezse durun.'
            : 'Yetişkin gözetiminde, yaşa uygun güvenli malzemelerle uygulayın. Çocuk istemezse ara verin.',
      ),
  ]);

  /// Her yaşa uyarlanan temel etkinlik sayısı ve yaşa özel etkinlik sayısı.
  static int get baseCount => _ideas.length;
  static int get targetedCount => _targeted.length;

  static String _adaptation(int band) {
    if (band == 0) return 'Yalnızca izleme, dinleme ve nazik karşılıklı etkileşim kullanın; bebeği zorlamayın. Hareket ve nesne gerektiren adımları uygulamayın.';
    if (band == 1) return 'Kısa tekrarlar yapın; bebeğin bakışını ve tepkisini takip edin. Nesneleri ağzına götürmesine izin vermeyin.';
    if (band == 2) return 'Yerde güvenli bir alanda, oturma ve uzanma becerisine göre yetişkin yardımıyla oynayın.';
    if (band == 3) return 'Bebeğin kendi hareketini başlatmasına fırsat verin; destek olmadan ayakta durmaya zorlamayın.';
    if (band == 4) return 'Tek adımlı yönergeler ve büyük, güvenli nesneler kullanın.';
    if (band == 5) return 'Basit seçimler sunun ve çocuğun tekrar etmesine zaman tanıyın.';
    if (band == 6) return 'İki adımlı küçük görevler ekleyin; başarıyı değil keşfi öne çıkarın.';
    if (band == 7) return 'Sıra alma ve basit sınıflandırma ekleyin.';
    if (band == 8) return 'Kısa hikâye kurma ve neden-sonuç soruları ekleyin.';
    if (band == 9) return 'Çocuğun kendi kurallarını önermesine ve etkinliği anlatmasına fırsat verin.';
    return 'Planlama, açıklama ve birlikte değerlendirme adımlarını çocuğa bırakın.';
  }
}
