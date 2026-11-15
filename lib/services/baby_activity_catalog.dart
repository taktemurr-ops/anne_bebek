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
  ]);

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
