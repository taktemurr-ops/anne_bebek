# Klasik Türk mutfağı tamamlama tarifleri. (başlık, kategori, dakika, kişi, fırın°C|None, malzemeler, adımlar, ipucu)
R = []
def r(title, cat, minutes, serv, oven, ing, steps, tip=None):
    R.append(dict(title=title, cat=cat, minutes=minutes, serv=serv, oven=oven, ing=ing, steps=steps, tip=tip))

r("İmam bayıldı", "Sebze yemekleri", 75, 4, 180,
  ["4 orta boy patlıcan", "2 soğan", "4 diş sarımsak", "3 domates", "2 sivri biber", "Yarım demet maydanoz", "Yarım su bardağı zeytinyağı", "1 tatlı kaşığı toz şeker", "1 tatlı kaşığı tuz", "Yarım su bardağı sıcak su"],
  ["Patlıcanları alacalı soyun, tuzlu suda 20 dakika bekletip kurulayın.", "Patlıcanları yağın bir kısmında her yanı hafif kızarana kadar çevirin, fırın kabına dizin.", "Kalan yağda piyazlık soğanı 8 dakika yumuşatın; sarımsak ve biberi ekleyip 2 dakika çevirin.", "Küp doğranmış domatesin yarısını, tuz ve şekeri ekleyip 5 dakika pişirin; maydanozu katın.", "Patlıcanları ortadan yarıp içlerini harçla doldurun, üstüne kalan domatesi koyun.", "Sıcak suyu kabın kenarından dökün, 180 °C fırında 35–40 dakika pişirin.", "Oda sıcaklığında soğuyunca servis edin."],
  "Zeytinyağlı olduğu için ılık ya da soğuk servis edilir; ertesi gün daha lezzetlidir.")
r("İçli köfte", "Hamur işleri", 120, 6, None,
  ["Dış için: 2 su bardağı ince bulgur", "1 su bardağı irmik", "250 g yağsız kıyma (dış için)", "1 yumurta", "1 tatlı kaşığı tuz", "İç için: 250 g orta yağlı kıyma", "2 soğan", "Yarım su bardağı ceviz içi", "1 tatlı kaşığı pul biber", "1 tatlı kaşığı karabiber", "Yarım demet maydanoz", "Kızartmak için ayçiçek yağı"],
  ["Bulguru 1 su bardağı ılık suyla ıslatıp 20 dakika bekletin.", "İç harç için soğanı kıymayla suyunu çekene kadar kavurun; baharat, ceviz ve maydanozu ekleyip soğutun.", "Bulgur, irmik, yağsız kıyma, yumurta ve tuzu 15 dakika, ele yapışmayan bir hamur olana kadar yoğurun.", "Elinizi ıslatıp ceviz büyüklüğünde parça alın, işaret parmağınızla oyarak ince bir kabuk açın.", "İçine 1 tatlı kaşığı harç koyup ağzını kapatın, iki ucu sivri şekil verin.", "Önceden ısıtılmış bol yağda (170 °C) 4–5 dakika, kızarana kadar kızartın; kağıt havluya alın.", "Haşlamalı yapmak için kaynar tuzlu suda yüzeye çıktıktan sonra 5 dakika pişirin."],
  "Şekil verilmiş köfteler tepside dondurulup poşetlenerek 2 ay saklanabilir.")
r("Ev baklavası", "Tatlılar", 150, 10, 180,
  ["40 yaprak baklavalık yufka", "250 g tereyağı", "2 su bardağı ince çekilmiş ceviz ya da Antep fıstığı", "Şerbet için: 3 su bardağı şeker", "2,5 su bardağı su", "Yarım limon suyu"],
  ["Şerbet için şeker ve suyu kaynatın, 12 dakika kısık ateşte pişirip limon suyunu ekleyin ve tamamen soğutun.", "Tereyağını eritin, köpüğünü alın.", "Tepsiyi yağlayın; yufkaların yarısını her birinin arasına fırçayla tereyağı sürerek serin.", "Cevizi eşit yayın, kalan yufkaları aynı şekilde yağlayarak üstüne serin.", "Keskin bıçakla baklava dilimi kesin, kalan sıcak tereyağını üzerine gezdirin.", "180 °C fırında 50–60 dakika, altın rengi olana kadar pişirin.", "Sıcak baklavaya soğuk şerbeti kepçeyle dökün; en az 4 saat dinlendirin."],
  "Şerbet soğuk, baklava sıcak olmalı; ikisi de sıcak olursa hamurlaşır.")
r("Künefe", "Tatlılar", 40, 4, 200,
  ["250 g tel kadayıf", "100 g tereyağı", "200 g tuzsuz künefe peyniri ya da taze kaşar", "Şerbet için: 1 su bardağı şeker", "1 su bardağı su", "Birkaç damla limon suyu", "Üzeri için 2 yemek kaşığı toz Antep fıstığı"],
  ["Şeker ve suyu 10 dakika kaynatıp limon ekleyin, ılık kalsın.", "Kadayıfı elle didikleyip kısa parçalar hâline getirin, eritilmiş tereyağıyla harmanlayın.", "Künefe tavasının tabanına kadayıfın yarısını bastırarak yayın.", "Peyniri ince dilimleyip kenarlara 1 cm boşluk bırakarak dizin; kalan kadayıfı kapatıp bastırın.", "Ocakta kısık ateşte alt yüzü kızarana kadar 6–7 dakika pişirin, tabakla çevirip diğer yüzü pişirin (ya da 200 °C fırında 20 dakika).", "Sıcakken ılık şerbeti dökün, fıstık serpip hemen servis edin."],
  "Peyniri tuzluysa birkaç saat suda bekletip tuzunu alın.")
r("İskender kebap", "Et yemekleri", 45, 4, None,
  ["500 g döner eti ya da ince dilimlenmiş dana bonfile", "4 pide", "Sos için: 2 yemek kaşığı tereyağı", "1 yemek kaşığı domates salçası", "3 domates rendesi", "1 su bardağı et suyu", "1,5 su bardağı süzme yoğurt", "2 yemek kaşığı tereyağı (kızdırmak için)", "Tuz"],
  ["Domates rendesi, salça ve tereyağını 10 dakika pişirip et suyuyla açın, tuzlayın.", "Eti az yağlı tavada yüksek ateşte, suyunu salmadan 3–4 dakika soteleyin.", "Pideleri küp doğrayıp tabaklara yayın, üzerine sosun bir kısmını gezdirin.", "Eti pidelerin üzerine yerleştirip kalan sosu dökün.", "Yanına yoğurt koyun; tereyağını köpürene kadar kızdırıp etin üzerine sıcak dökün."],
  "Tereyağını yakmayın; köpürüp hafif renk aldığında dökün.")
r("Adana kebap", "Et yemekleri", 50, 4, None,
  ["600 g kuzu kıyma (yüzde 20 yağlı, zırhla çekilmiş)", "2 kırmızı sivri biber", "1 tatlı kaşığı pul biber", "1 tatlı kaşığı tuz", "Yassı şiş", "Yanına lavaş, soğan, domates, sivri biber"],
  ["Biberi çok ince kıyın, suyunu sıkın.", "Kıymayı biber, pul biber ve tuzla 10 dakika, yapışkan bir kıvam alana kadar yoğurun.", "Buzdolabında 1 saat dinlendirin.", "Elinizi ıslatarak harcı yassı şişlere 1,5 cm kalınlıkta, parmak izleriyle bastırarak geçirin.", "Kızgın mangalda ya da ızgarada çevirerek 8–10 dakika pişirin.", "Lavaşla, közlenmiş domates ve biberle servis edin."],
  "Kıymanın yağsız olması kebabın şişten düşmesine neden olur.")
r("Etli ekmek", "Hamur işleri", 90, 6, 230,
  ["Hamur için: 4 su bardağı un", "1 paket kuru maya", "1 tatlı kaşığı tuz", "1,5 su bardağı ılık su", "Harç için: 400 g kıyma", "2 soğan", "2 domates", "2 sivri biber", "Yarım demet maydanoz", "1 yemek kaşığı biber salçası", "Tuz, karabiber, pul biber"],
  ["Un, maya, tuz ve suyu yoğurup 45 dakika mayalandırın.", "Soğan, domates, biber ve maydanozu çok ince kıyın; kıyma, salça ve baharatla iyice yoğurun.", "Hamuru 6 parçaya bölüp ince, uzun şeritler hâlinde açın.", "Harcı hamurun üzerine ince ve eşit yayın, kenarlara kadar bastırın.", "230 °C fırında taş ya da ters tepsi üzerinde 10–12 dakika pişirin.", "Dilimleyip sıcak servis edin."],
  "Konya usulü çok ince açılır; harç ince yayıldığı için hızlı pişer.")
r("Kayseri mantısı", "Hamur işleri", 120, 6, 200,
  ["Hamur için: 3 su bardağı un", "1 yumurta", "1 tatlı kaşığı tuz", "1 su bardağı su", "İç için: 250 g kıyma", "1 küçük soğan rendesi", "Tuz, karabiber", "Sos için: 2 su bardağı sarımsaklı yoğurt", "3 yemek kaşığı tereyağı", "1 tatlı kaşığı pul biber", "Kuru nane, sumak"],
  ["Un, yumurta, tuz ve suyu sert bir hamur olacak şekilde yoğurup 30 dakika dinlendirin.", "Kıyma, soğan rendesi ve baharatı karıştırın.", "Hamuru çok ince açıp 2 × 2 cm kareler kesin.", "Her kareye nohut tanesinden küçük iç koyup dört köşesini birleştirerek bohça yapın.", "Mantıları tepside 200 °C fırında 10 dakika hafif kızartın (isteğe bağlı).", "Kaynar tuzlu suda 10–12 dakika haşlayıp süzün.", "Üzerine sarımsaklı yoğurt, pul biberli kızdırılmış tereyağı, nane ve sumak ekleyin."],
  "Hazırlanan mantılar tepside dondurulup poşetlenerek 2 ay saklanabilir.")
r("Tulumba tatlısı", "Tatlılar", 60, 8, None,
  ["Hamur için: 1,5 su bardağı su", "125 g tereyağı", "2 su bardağı un", "1 yemek kaşığı irmik", "3 yumurta", "Şerbet için: 3 su bardağı şeker", "3 su bardağı su", "Yarım limon suyu", "Kızartmak için 1 litre ayçiçek yağı"],
  ["Şerbeti 15 dakika kaynatıp limon ekleyin, soğutun.", "Su ve tereyağını kaynatın; un ve irmiği bir kerede ekleyip 3–4 dakika, tencereden ayrılana kadar karıştırın.", "Ilıyan hamura yumurtaları teker teker yedirin.", "Hamuru yıldız uçlu sıkma torbasına alın.", "Ilık yağa (yaklaşık 130 °C) 5 cm boyunda sıkıp kesin; ocağı yavaş yavaş açarak 10–12 dakika kızartın.", "Kızaran tulumbaları soğuk şerbete atın, 5 dakika bekletip çıkarın."],
  "Yağ başta çok sıcak olursa tulumbanın içi çiğ kalır, şişmez.")
r("Şekerpare", "Tatlılar", 70, 10, 180,
  ["125 g oda sıcaklığında tereyağı", "Yarım su bardağı pudra şekeri", "1 yumurta", "2 yemek kaşığı irmik", "1 paket vanilya", "1 paket kabartma tozu", "2 su bardağı un", "Fındık içi", "Şerbet için: 2,5 su bardağı şeker", "3 su bardağı su", "Yarım limon suyu"],
  ["Şerbeti 15 dakika kaynatıp limonu ekleyin ve soğutun.", "Tereyağı ve pudra şekerini krema kıvamına gelene kadar çırpın, yumurtayı ekleyin.", "İrmik, vanilya, kabartma tozu ve unu ekleyip ele yapışmayan yumuşak bir hamur yoğurun.", "Ceviz büyüklüğünde yuvarlak şekil verip ortasına fındık bastırın, tepsiye dizin.", "180 °C fırında 25–30 dakika, altları kızarana kadar pişirin.", "Sıcak tatlıya soğuk şerbeti dökün, şerbeti çekene kadar bekletin."])
r("Un helvası", "Tatlılar", 35, 6, None,
  ["2 su bardağı un", "125 g tereyağı", "2 yemek kaşığı ayçiçek yağı", "Şerbet için: 1,5 su bardağı şeker", "2 su bardağı süt", "1 su bardağı su"],
  ["Süt, su ve şekeri şeker eriyene kadar ısıtın, sıcak tutun.", "Tereyağı ve sıvı yağı eritip unu ekleyin.", "Kısık ateşte sürekli karıştırarak 20–25 dakika, un kokusu gidip açık kahve rengini alana kadar kavurun.", "Ocağı kapatıp sıcak şerbeti dikkatle ekleyin, hızlıca karıştırın.", "Kapağı kapatıp 10 dakika demlendirin, kaşıkla şekil verip servis edin."],
  "Şerbet eklerken buhar çıkar; elinizi uzak tutun.")
r("İşkembe çorbası", "Çorbalar", 180, 6, None,
  ["1 kg temizlenmiş işkembe", "3 yemek kaşığı un", "2 yemek kaşığı tereyağı", "2 yumurta sarısı", "1 limon suyu", "Tuz", "Terbiye ve sunum için: sirkeli sarımsak, pul biber"],
  ["İşkembeyi soğuk suda birkaç kez yıkayın; düdüklü tencerede bol suyla 1 saat (normal tencerede 2,5 saat) yumuşayana kadar haşlayın.", "İşkembeyi çıkarıp küçük küçük doğrayın, haşlama suyunu süzün.", "Tereyağında unu 2 dakika kavurun, haşlama suyunu (yaklaşık 6 su bardağı) azar azar ekleyerek pürüzsüz karıştırın.", "Doğranmış işkembeyi ekleyip 15 dakika kaynatın, tuzlayın.", "Yumurta sarısı ve limonu çırpıp çorbadan birkaç kepçe alarak ılıştırın, tencereye ekleyin ve kaynatmadan ocaktan alın.", "Sirkeli sarımsak ve pul biberle servis edin."],
  "İşkembe mutlaka iyi pişmiş ve güvenilir kasaptan temizlenmiş olmalı.")
r("Beyran çorbası", "Çorbalar", 150, 6, None,
  ["600 g kemikli kuzu eti (gerdan ya da incik)", "1 su bardağı pirinç", "6 diş sarımsak", "2 yemek kaşığı tereyağı", "1 yemek kaşığı pul biber", "Tuz, karabiber"],
  ["Eti bol suda köpüğünü alarak 2 saat, kemikten ayrılana kadar haşlayın.", "Eti didikleyin, kemikleri ayırın; suyu süzün.", "Pirinci yıkayıp ayrı tencerede az suyla yarı pişirin.", "Her kaseye pirinç, didiklenmiş et ve dövülmüş sarımsak koyun.", "Kaynar et suyunu tuzlayıp kaselere doldurun.", "Tereyağında pul biberi kızdırıp üzerine gezdirin."],
  "Gaziantep'in sabah çorbasıdır; et suyu çok sıcak dökülür.")
r("Midye dolma", "Balık ve deniz ürünleri", 75, 6, None,
  ["30 adet büyük midye", "1,5 su bardağı pirinç", "3 soğan", "Yarım su bardağı zeytinyağı", "2 yemek kaşığı kuş üzümü", "1 yemek kaşığı dolmalık fıstık", "1 tatlı kaşığı yenibahar", "1 tatlı kaşığı tarçın", "1 tatlı kaşığı karabiber", "1 tatlı kaşığı toz şeker", "1 tatlı kaşığı domates salçası", "Tuz, limon"],
  ["Midyelerin kabuklarını tel fırçayla temizleyin, sakallarını çekin; bıçakla yan tarafından açın, kabukları ayırmayın.", "Pirinci 20 dakika ılık suda bekletip süzün.", "Soğanı zeytinyağında yumuşatın; fıstık, pirinç ve salçayı ekleyip 3 dakika kavurun.", "Baharatlar, kuş üzümü, şeker, tuz ve 1 su bardağı sıcak suyu ekleyip suyunu çekene kadar pişirin.", "Midyeleri harçla doldurup kapatın, tencereye sıkıca dizin.", "Üzerine ters tabak kapatıp 1,5 su bardağı sıcak su ekleyin; kısık ateşte 25 dakika pişirin.", "Soğuyunca limonla servis edin."],
  "Açılmadan önce kapalı olmayan ya da kokan midyeleri kullanmayın.")
r("Levrek buğulama", "Balık ve deniz ürünleri", 40, 4, None,
  ["4 levrek fileto", "2 domates", "1 soğan", "2 sivri biber", "4 diş sarımsak", "3 yemek kaşığı zeytinyağı", "1 limon", "Yarım demet maydanoz", "Defne yaprağı, tuz, karabiber"],
  ["Soğanı halka, domatesi küp, biberi halka doğrayın.", "Geniş tavaya zeytinyağı, soğan ve sarımsağı alıp 3 dakika çevirin.", "Balıkları sebzelerin üzerine yerleştirip domates ve biberle kapatın.", "Tuz, karabiber, defne ve limon dilimlerini ekleyin; yarım su bardağı sıcak su dökün.", "Kapağı kapalı, kısık ateşte 15–18 dakika buğulayın.", "Maydanoz serpip servis edin."])
r("Kabak musakka", "Sebze yemekleri", 55, 4, None,
  ["4 kabak", "250 g kıyma", "1 soğan", "2 domates", "1 yemek kaşığı domates salçası", "2 yemek kaşığı zeytinyağı", "1 su bardağı sıcak su", "Tuz, karabiber, pul biber"],
  ["Kabakları kalın halkalar hâlinde doğrayın.", "Soğanı yağda yumuşatıp kıymayı ekleyin, suyunu çekene kadar kavurun.", "Salça ve küp domatesi ekleyip 5 dakika pişirin.", "Kabakları ekleyip karıştırın, baharatları ve sıcak suyu ilave edin.", "Kapağı kapalı, kısık ateşte kabaklar yumuşayana kadar 25 dakika pişirin.", "Yoğurtla servis edin."])
r("İç pilav", "Pilavlar", 50, 6, None,
  ["2 su bardağı baldo pirinç", "100 g kuzu ciğeri", "2 yemek kaşığı dolmalık fıstık", "2 yemek kaşığı kuş üzümü", "1 soğan", "3 yemek kaşığı tereyağı", "3 su bardağı sıcak tavuk suyu", "1 tatlı kaşığı yenibahar", "1 tatlı kaşığı karabiber", "1 tatlı kaşığı tarçın", "1 tatlı kaşığı şeker", "Yarım demet dereotu, tuz"],
  ["Pirinci sıcak tuzlu suda 20 dakika bekletip berrak su akana kadar yıkayın.", "Ciğeri küçük küp doğrayıp tereyağında 2 dakika soteleyin, ayırın.", "Aynı tencerede fıstığı kavurup ince doğranmış soğanı ekleyin.", "Pirinci ekleyip 3 dakika kavurun; baharatlar, şeker, kuş üzümü ve tuzu ekleyin.", "Sıcak tavuk suyunu ekleyin, kaynayınca kısık ateşte suyunu çekene kadar 15 dakika pişirin.", "Ciğer ve dereotunu ekleyip kapağın altına kağıt havlu koyarak 15 dakika demlendirin."],
  "Ciğer istemeyenler aynı pilavı ciğersiz yapabilir.")
r("İzmir köfte", "Et yemekleri", 70, 4, 190,
  ["500 g kıyma", "1 soğan rendesi", "1 dilim bayat ekmek içi", "1 yumurta", "Tuz, karabiber, kimyon", "4 patates", "3 sivri biber", "2 domates", "Sos için: 1 yemek kaşığı salça", "2 su bardağı sıcak su", "2 yemek kaşığı zeytinyağı"],
  ["Kıyma, soğan, ıslatılıp sıkılmış ekmek, yumurta ve baharatları yoğurun; parmak köfte şekli verin.", "Patatesleri elma dilim doğrayın; köfte ve patatesleri az yağda hafifçe kızartın.", "Fırın kabına köfte, patates, domates dilimleri ve biberleri sırayla dizin.", "Salçayı sıcak su ve zeytinyağıyla açıp tuzlayarak üzerine dökün.", "190 °C fırında 35–40 dakika, patatesler yumuşayana kadar pişirin."])
r("Dalyan köfte", "Et yemekleri", 80, 6, 180,
  ["600 g kıyma", "1 soğan rendesi", "2 dilim bayat ekmek", "1 yumurta", "1 havuç", "Yarım su bardağı haşlanmış bezelye", "3 haşlanmış yumurta", "Tuz, karabiber, kimyon", "1 yemek kaşığı salça, 1 su bardağı su"],
  ["Kıyma, soğan, ıslatılıp sıkılmış ekmek, çiğ yumurta ve baharatları yoğurun.", "Havucu küçük küp doğrayıp bezelyeyle birlikte haşlayın.", "Köfte harcını yağlı kağıt üzerinde 1,5 cm kalınlıkta dikdörtgen açın.", "Ortasına havuç, bezelye ve uç uca dizilmiş haşlanmış yumurtaları koyun.", "Kağıt yardımıyla rulo yapıp kenarlarını kapatın, fırın kabına alın.", "Salçalı suyu üzerine dökün, 180 °C fırında 45 dakika pişirin; dinlendirip dilimleyin."])
r("Arnavut ciğeri", "Mezeler", 30, 4, None,
  ["500 g dana ciğeri", "3 yemek kaşığı un", "1 tatlı kaşığı pul biber", "1 tatlı kaşığı kimyon", "Kızartmak için ayçiçek yağı", "Yanına: 1 kırmızı soğan, yarım demet maydanoz, 1 tatlı kaşığı sumak", "Tuz"],
  ["Ciğerin zarını soyup 1,5 cm küpler hâlinde doğrayın, soğuk suda yıkayıp süzün.", "Soğanı piyazlık doğrayıp maydanoz ve sumakla karıştırın.", "Ciğeri un ve baharatla harmanlayıp fazla ununu eleyin.", "Kızgın yağda 3–4 dakika, dışı kızarıp içi pişene kadar kızartın.", "Tuzunu pişince serpin; soğan salatasıyla servis edin."],
  "Ciğeri tuzlayıp bekletmeyin; sertleşir.")
r("Hünkâr beğendi", "Et yemekleri", 120, 4, None,
  ["600 g kuşbaşı kuzu eti", "1 soğan", "2 domates", "1 yemek kaşığı salça", "2 yemek kaşığı tereyağı", "Beğendi için: 4 patlıcan", "2 yemek kaşığı tereyağı", "2 yemek kaşığı un", "1,5 su bardağı süt", "Yarım su bardağı rendelenmiş kaşar", "Tuz, karabiber"],
  ["Eti tereyağında suyunu çekene kadar kavurun, soğanı ekleyip 5 dakika çevirin.", "Salça ve rendelenmiş domatesi ekleyin; sıcak su ilave edip kapağı kapalı 1–1,5 saat et yumuşayana kadar pişirin.", "Patlıcanları közleyip kabuklarını soyun, limonlu suda bekletip ince kıyın.", "Tereyağında unu kavurun, sütü çırparak ekleyin; patlıcanı ve kaşarı katıp koyulaşana kadar karıştırın.", "Tabağa beğendiyi yayın, ortasına eti yerleştirip servis edin."])
r("Testi kebabı", "Et yemekleri", 180, 4, 220,
  ["600 g kuşbaşı dana eti", "10 arpacık soğan", "6 diş sarımsak", "2 domates", "2 sivri biber", "1 yemek kaşığı biber salçası", "2 yemek kaşığı tereyağı", "Tuz, karabiber, kekik", "Toprak testi ve kapatmak için hamur ya da folyo"],
  ["Testiyi en az 1 saat suda bekletin.", "Eti, soğanları, sarımsağı, doğranmış domates ve biberi, salça, tereyağı ve baharatlarla karıştırın.", "Harcı testiye doldurun; ağzını hamur ya da folyoyla sıkıca kapatın.", "Testiyi soğuk fırına koyup 220 °C'ye ayarlayın, 2,5 saat pişirin.", "Fırından çıkarıp ağzına yakın yerden dikkatle kırın, pilavla servis edin."],
  "Testiyi sıcak fırına koymayın; ani ısı farkı çatlatır.")
r("Su muhallebisi", "Tatlılar", 25, 6, None,
  ["4 su bardağı su", "Yarım su bardağı nişasta", "Yarım su bardağı şeker", "1 tatlı kaşığı gül suyu", "Üzeri için pudra şekeri"],
  ["Nişastayı soğuk suyun bir kısmında topak kalmayacak şekilde eritin.", "Kalan su ve şekeri tencereye alıp nişastayı ekleyin.", "Orta ateşte sürekli karıştırarak koyulaşıp şeffaflaşana kadar 10–12 dakika pişirin.", "Gül suyunu ekleyip ıslatılmış kaselere paylaştırın.", "Soğuyunca pudra şekeri serperek servis edin."])
r("Mıhlama (kuymak)", "Kahvaltılıklar", 20, 3, None,
  ["2 yemek kaşığı tereyağı", "2 yemek kaşığı mısır unu", "1,5 su bardağı su", "200 g çeçil ya da tuzsuz kolot peyniri", "Tuz"],
  ["Tereyağını tavada eritip mısır ununu ekleyin, kokusu çıkana kadar 3 dakika kavurun.", "Suyu ekleyip sürekli karıştırarak koyulaşana kadar pişirin.", "Rendelenmiş peyniri ekleyip karıştırmadan kısık ateşte bekletin.", "Peynir eriyip ipek gibi uzayınca ve yağ üstüne çıkınca sıcak servis edin."],
  "Karadeniz kahvaltısının vazgeçilmezidir; mısır ekmeğiyle yenir.")
r("Şalgam suyu (ev usulü)", "İçecekler", 40, 10, None,
  ["2 mor havuç", "1 şalgam", "1 su bardağı bulgur", "3 litre su", "2 yemek kaşığı kaya tuzu", "1 tatlı kaşığı pul biber (isteğe bağlı)"],
  ["Bulguru bez torbaya koyup 1 litre ılık suda 1 gün ekşimeye bırakın.", "Mor havuç ve şalgamı yıkayıp iri doğrayın, cam kavanoza koyun.", "Ekşimiş bulgur suyunu, kalan suyu ve tuzu kavanoza ekleyin.", "Ağzını tülbentle kapatıp serin yerde 5–7 gün, ekşi tadı oluşana kadar fermente edin.", "Süzüp buzdolabında saklayın; soğuk servis edin."],
  "Kavanozu her gün kontrol edin; küf görülürse dökün.")
r("Ev bozası", "İçecekler", 90, 8, None,
  ["1 su bardağı ince bulgur", "1 su bardağı pirinç", "4 litre su", "1,5 su bardağı şeker", "1 tatlı kaşığı kuru maya", "Üzeri için tarçın ve leblebi"],
  ["Bulgur ve pirinci yıkayıp 2 litre suyla 1 saat, iyice dağılana kadar pişirin.", "Blenderdan geçirip ince süzgeçten süzün; kalan suyu ekleyerek akışkan kıvama getirin.", "Ilıyınca mayayı ekleyip karıştırın; üzerini örtüp oda sıcaklığında 2 gün bekletin.", "Şekeri ekleyip karıştırın, buzdolabında 1 gün daha dinlendirin.", "Tarçın ve leblebiyle servis edin."],
  "Fermente içecektir; küçük çocuklara ve gebelere ölçülü verilmeli, ekşimiş bozayı tüketmeyin.")
r("Mücendere", "Bakliyat yemekleri", 45, 4, None,
  ["1 su bardağı yeşil mercimek", "1 su bardağı pirinç", "2 soğan", "Yarım su bardağı zeytinyağı", "Tuz, kimyon"],
  ["Mercimeği 3 su bardağı suda 15 dakika yarı yumuşayana kadar haşlayın.", "Yıkanmış pirinci, tuzu ve 1 su bardağı sıcak suyu ekleyip kısık ateşte suyunu çekene kadar pişirin.", "Soğanları piyazlık doğrayıp zeytinyağında koyu kahverengi olana kadar 15 dakika kavurun.", "Soğanın yarısını pilava karıştırın, kalanını üzerine koyun.", "Ilık ya da oda sıcaklığında yoğurtla servis edin."])
r("Yuvalama çorbası", "Çorbalar", 120, 6, None,
  ["500 g kuzu eti (kemikli)", "1 su bardağı haşlanmış nohut", "Yuvalama için: 200 g yağsız kıyma", "1 su bardağı pirinç unu", "Tuz", "1 kg süzme yoğurt", "1 yumurta", "1 yemek kaşığı un", "2 yemek kaşığı tereyağı", "1 yemek kaşığı kuru nane"],
  ["Eti haşlayıp didikleyin, suyunu süzün.", "Kıyma, pirinç unu, tuz ve azar azar su ile yoğrulmuş harçtan nohut büyüklüğünde yuvarlaklar yapın.", "Yuvalamaları et suyunda 10 dakika pişirin; nohut ve eti ekleyin.", "Yoğurt, yumurta ve unu çırpıp birkaç kepçe sıcak suyla ılıştırın, tencereye ekleyin.", "Sürekli karıştırarak kaynayana kadar pişirin, tuzlayın.", "Tereyağında naneyi kızdırıp üzerine gezdirin."],
  "Gaziantep bayram yemeğidir; yuvalamalar ne kadar küçük olursa o kadar makbuldür.")
r("Analı kızlı", "Çorbalar", 120, 6, None,
  ["Ana köfte için: 200 g yağsız kıyma, 1 su bardağı ince bulgur, 1 tatlı kaşığı salça", "İç için: 150 g kıyma, 1 soğan, 2 yemek kaşığı ceviz", "Kızlar için: aynı bulgur hamurundan nohut büyüklüğü toplar", "1 su bardağı haşlanmış nohut", "2 su bardağı yoğurt", "1 yumurta, 1 yemek kaşığı un", "2 yemek kaşığı tereyağı, kuru nane, tuz"],
  ["Bulguru ıslatıp kıyma ve salçayla ele yapışmayan bir hamur olana kadar yoğurun.", "Soğanlı kıymayı kavurup cevizi ekleyerek iç harcı hazırlayın.", "Hamurdan ceviz büyüklüğünde parçaları oyup iç harçla doldurun (ana); kalan hamurdan iç koymadan küçük toplar yapın (kız).", "Tuzlu suda nohutla birlikte ana ve kızları 15 dakika pişirin.", "Yoğurt, yumurta ve unu çırpıp ılıştırarak ekleyin, kaynayana kadar karıştırın.", "Naneli tereyağı gezdirip servis edin."])
r("Keşkek", "Et yemekleri", 300, 8, None,
  ["2 su bardağı aşurelik buğday (bir gece ıslatılmış)", "1 kg kemikli kuzu ya da tavuk", "3 yemek kaşığı tereyağı", "1 tatlı kaşığı pul biber", "Tuz"],
  ["Buğdayı ıslatıldığı suyu dökerek yeni suyla 1 saat haşlayın.", "Eti ayrı tencerede köpüğünü alarak kemikten ayrılana kadar haşlayın, didikleyin.", "Buğdayı et suyuyla birlikte kısık ateşte 2 saat, buğday tamamen dağılana kadar pişirin.", "Eti ekleyip tahta kaşıkla sürekli dövün, koyu ve uzayan bir kıvam elde edin; tuzlayın.", "Tabağa alıp pul biberli kızdırılmış tereyağı gezdirin."],
  "UNESCO somut olmayan kültürel miras listesindedir; düğün ve bayram yemeğidir.")
r("Hingel", "Hamur işleri", 90, 4, None,
  ["Hamur için: 2 su bardağı un", "1 yumurta", "Yarım su bardağı su", "Tuz", "İç için: 3 haşlanmış patates", "1 soğan", "Yarım demet maydanoz", "Tuz, karabiber", "Sos için: sarımsaklı yoğurt, tereyağında kızdırılmış soğan ve pul biber"],
  ["Hamuru yoğurup 30 dakika dinlendirin.", "Patatesleri ezip kavrulmuş soğan, maydanoz ve baharatla karıştırın.", "Hamuru ince açıp bardakla yuvarlaklar kesin.", "Her yuvarlağa iç koyup yarım ay şeklinde katlayın, kenarlarını bastırın.", "Kaynar tuzlu suda yüzeye çıkınca 3 dakika daha haşlayıp süzün.", "Sarımsaklı yoğurt ve soğanlı, pul biberli tereyağıyla servis edin."],
  "Kafkas ve Doğu Anadolu mutfağının patatesli mantısıdır.")
r("Kuru köfte", "Et yemekleri", 40, 4, None,
  ["500 g kıyma", "1 soğan rendesi", "2 dilim bayat ekmek içi", "1 yumurta", "Yarım demet maydanoz", "1 tatlı kaşığı kimyon", "Tuz, karabiber", "Kızartmak için yağ", "Bulamak için un"],
  ["Ekmeği ıslatıp sıkın; tüm malzemeyi 5 dakika iyice yoğurun.", "Harcı 30 dakika buzdolabında dinlendirin.", "Elinizi ıslatıp ceviz büyüklüğünde, yassı ve oval köfteler yapın.", "Hafifçe una bulayıp kızgın yağda iki yüzü kızarana kadar 6–8 dakika kızartın.", "Kağıt havluya alıp piyaz ya da patatesle servis edin."])
r("Tavuk suyu çorbası", "Çorbalar", 70, 6, None,
  ["2 tavuk but (kemikli)", "1 havuç", "Yarım su bardağı şehriye ya da pirinç", "2 yemek kaşığı tereyağı", "1 yemek kaşığı un", "1 yumurta sarısı", "Yarım limon suyu", "Tuz, karabiber"],
  ["Tavukları 2 litre suda köpüğünü alarak 45 dakika haşlayın; didikleyip suyunu süzün.", "Tereyağında unu kavurun, tavuk suyunu ekleyin.", "Rendelenmiş havuç ve şehriyeyi ekleyip 10 dakika pişirin.", "Tavuk etini ekleyin, tuz ve karabiberle tatlandırın.", "Yumurta sarısı ve limonu ılıştırıp ekleyin, kaynatmadan ocaktan alın."],
  "Hastalık dönemlerinde sıvı alımını desteklemek için iyi bir seçenektir.")
r("Karalahana çorbası", "Çorbalar", 60, 6, None,
  ["1 demet karalahana", "1 su bardağı haşlanmış barbunya ya da kuru fasulye", "1 soğan", "Yarım su bardağı mısır unu", "1 yemek kaşığı salça", "2 yemek kaşığı tereyağı", "Tuz, pul biber"],
  ["Karalahanayı yıkayıp saplarını ayıklayın, ince kıyın.", "Soğanı tereyağında kavurup salçayı ekleyin.", "Karalahanayı ve 6 su bardağı sıcak suyu ekleyip 25 dakika pişirin.", "Fasulyeyi ekleyin; mısır ununu azar azar serperek karıştırın.", "10 dakika daha pişirip tuz ve pul biberle tatlandırın."],
  "Karadeniz mutfağına özgüdür; mısır ekmeğiyle servis edilir.")
r("Hamsili ekmek", "Balık ve deniz ürünleri", 60, 6, 190,
  ["500 g hamsi (ayıklanmış)", "2 su bardağı mısır unu", "1 soğan", "1 demet pazı ya da karalahana", "Yarım demet maydanoz ve dereotu", "Yarım su bardağı sıcak su", "3 yemek kaşığı zeytinyağı", "Tuz, pul biber"],
  ["Hamsileri iyice yıkayıp ince doğrayın.", "Soğanı ve yeşillikleri ince kıyın.", "Mısır unu, sebzeler, hamsi, zeytinyağı, tuz ve sıcak suyu yoğurarak yumuşak bir harç yapın.", "Yağlanmış tepsiye 2 cm kalınlıkta yayın.", "190 °C fırında 40–45 dakika, üzeri kızarana kadar pişirin."])
r("Kelle paça çorbası", "Çorbalar", 240, 6, None,
  ["2 adet temizlenmiş kuzu paça", "1 kuzu kellesi (temizlenmiş)", "2 yemek kaşığı un", "2 yemek kaşığı tereyağı", "1 yumurta sarısı", "1 limon", "Sirkeli sarımsak, tuz"],
  ["Paça ve kelleyi soğuk suda yıkayıp bol suda köpüğünü alarak 3–4 saat (düdüklüde 1,5 saat) haşlayın.", "Etleri kemikten ayırıp didikleyin, suyunu süzün.", "Tereyağında unu kavurun, et suyunu ekleyerek pürüzsüz karıştırın.", "Etleri ekleyip 10 dakika kaynatın, tuzlayın.", "Yumurta sarısı ve limonla terbiyeleyin; sirkeli sarımsakla servis edin."],
  "Ürünü güvenilir kasaptan, temizlenmiş olarak alın.")
r("Ev usulü suşi rulo (pişmiş malzemeyle)", "Dünya mutfağı", 60, 4, None,
  ["1,5 su bardağı suşi pirinci", "2 yemek kaşığı pirinç sirkesi", "1 yemek kaşığı şeker", "1 tatlı kaşığı tuz", "4 yaprak nori", "1 salatalık", "1 havuç", "1 avokado", "150 g haşlanmış karides ya da füme somon", "Soya sosu"],
  ["Pirinci su berraklaşana kadar yıkayın; 1,8 su bardağı suyla kaynatıp kısık ateşte 12 dakika pişirin, 10 dakika demlendirin.", "Sirke, şeker ve tuzu eritip sıcak pirince karıştırın, oda sıcaklığına soğutun.", "Salatalık, havuç ve avokadoyu ince çubuklar hâlinde kesin.", "Bambu matın üzerine noriyi koyun, ıslak elle pirinci üst kenarda 2 cm boşluk bırakarak ince yayın.", "Sebzeleri ve karidesi alt kenara dizip matla sıkıca sarın.", "Islak bıçakla 8 parçaya kesip soya sosuyla servis edin."],
  "Gebelikte çiğ balık önerilmediği için pişmiş karides ya da füme ürün kullanılmıştır.")
r("Tavuklu tako", "Dünya mutfağı", 35, 4, None,
  ["8 küçük mısır ya da buğday tortilla", "400 g tavuk göğsü", "1 tatlı kaşığı kimyon", "1 tatlı kaşığı toz kırmızı biber", "1 kırmızı soğan", "2 domates", "1 avokado", "1 limon", "Yarım demet kişniş ya da maydanoz", "4 yemek kaşığı yoğurt", "Tuz"],
  ["Tavuğu şerit doğrayıp baharat ve tuzla harmanlayın, az yağda 8 dakika pişirin.", "Domates, soğan ve kişnişi ince doğrayıp limon ve tuzla salsa hazırlayın.", "Avokadoyu ezip limon ve tuzla karıştırın.", "Tortillaları kuru tavada her yüzünü 30 saniye ısıtın.", "Tortillaya tavuk, salsa, avokado ve bir kaşık yoğurt koyup katlayarak servis edin."])
r("Tavuklu ramen", "Dünya mutfağı", 50, 2, None,
  ["2 porsiyon ramen erişte", "4 su bardağı tavuk suyu", "1 tavuk göğsü", "2 yumurta", "2 yemek kaşığı soya sosu", "1 tatlı kaşığı rendelenmiş zencefil", "2 diş sarımsak", "1 avuç ıspanak", "2 dal taze soğan", "1 tatlı kaşığı susam yağı"],
  ["Yumurtaları kaynar suda 7 dakika haşlayıp soğuk suya alın, soyun.", "Tavuk suyunu sarımsak, zencefil ve soya sosuyla 10 dakika kaynatın.", "Tavuğu suda 15 dakika pişirip çıkarın ve dilimleyin.", "Erişteyi paket süresi kadar ayrı haşlayıp süzün.", "Ispanağı sıcak suya ekleyip 1 dakika pişirin.", "Kaselere erişte, tavuk, ıspanak koyup sıcak suyu dökün; yarım yumurta, taze soğan ve susam yağıyla servis edin."])
r("Ev yapımı simit", "Hamur işleri", 120, 8, 220,
  ["4 su bardağı un", "1 paket kuru maya", "1 tatlı kaşığı tuz", "1 tatlı kaşığı şeker", "1,5 su bardağı ılık su", "Yarım su bardağı üzüm pekmezi", "1 su bardağı su (pekmezli su için)", "1,5 su bardağı kavrulmuş susam"],
  ["Un, maya, tuz, şeker ve ılık suyu 10 dakika yoğurup 1 saat mayalandırın.", "Hamuru 8 parçaya bölüp her birini 50 cm'lik iki ince şerit hâline getirin; şeritleri burup halka yapın.", "Pekmezi suyla açın; simitleri pekmezli suya batırıp susama bulayın.", "Tepsiye dizip 15 dakika dinlendirin.", "220 °C fırında 18–20 dakika, koyu kızarana kadar pişirin."])
r("Kahvaltılık poğaça", "Hamur işleri", 90, 12, 190,
  ["1 su bardağı ılık süt", "Yarım su bardağı sıvı yağ", "1 yumurta (sarısı üzerine)", "1 paket kuru maya", "1 tatlı kaşığı şeker", "1 tatlı kaşığı tuz", "4 su bardağı un", "İç için: 200 g beyaz peynir, yarım demet maydanoz"],
  ["Süt, yağ, yumurta akı, maya, şeker ve tuzu karıştırın; unu azar azar ekleyerek yumuşak bir hamur yoğurun.", "Hamuru 40 dakika mayalandırın.", "Ceviz büyüklüğünde parçalar koparıp elinizde açın, peynirli harçtan koyup kapatın.", "Tepsiye dizip üzerine yumurta sarısı sürün, 15 dakika daha bekletin.", "190 °C fırında 25 dakika, üzeri kızarana kadar pişirin."])
r("Höşmerim", "Tatlılar", 30, 4, None,
  ["250 g tuzsuz taze peynir (lor ya da höşmerim peyniri)", "3 yemek kaşığı irmik", "3 yemek kaşığı un", "Yarım su bardağı şeker", "2 yemek kaşığı tereyağı", "Üzeri için ceviz ya da fıstık"],
  ["Tereyağını eritip irmik ve unu 5 dakika hafif renk alana kadar kavurun.", "Ufalanmış peyniri ekleyip kısık ateşte karıştırarak peynir eriyip yağ salana kadar 10 dakika pişirin.", "Şekeri ekleyip eriyene ve kıvam koyulaşana kadar karıştırın.", "Ilık servis edip ceviz serpin."],
  "Balıkesir ve Marmara yöresinin peynir helvasıdır.")
r("Kazandibi", "Tatlılar", 60, 8, None,
  ["4 su bardağı süt", "1 su bardağı şeker", "3 yemek kaşığı pirinç unu", "2 yemek kaşığı buğday nişastası", "1 paket vanilya", "1 yemek kaşığı tereyağı", "2 yemek kaşığı pudra şekeri (taban için)"],
  ["Süt, şeker, pirinç unu ve nişastayı soğukken çırpın.", "Orta ateşte sürekli karıştırarak koyu muhallebi kıvamına gelene kadar 15 dakika pişirin; vanilyayı ekleyin.", "Çelik tavayı tereyağıyla yağlayıp pudra şekeri serpin.", "Muhallebiyi tavaya dökün, kısık ateşte tabanı karamelize olana kadar 10–12 dakika tavayı çevirerek yakın.", "Soğuyunca buzdolabında 3 saat bekletin; dikdörtgen kesip rulo yaparak servis edin."])
r("Trileçe", "Tatlılar", 90, 10, 180,
  ["Kek için: 4 yumurta, 1 su bardağı şeker, 1 su bardağı un, 1 paket kabartma tozu, 1 paket vanilya", "Sütlü karışım için: 1 su bardağı süt, 1 su bardağı krema, 1 su bardağı süt tozu karışımı ya da kaymaklı süt", "Karamel için: Yarım su bardağı şeker, 1 su bardağı krema"],
  ["Yumurta ve şekeri 5 dakika köpürtün; un, kabartma tozu ve vanilyayı katlayarak karıştırın.", "Yağlı kağıt serilmiş kare kalıpta 180 °C fırında 25 dakika pişirin.", "Süt, krema ve süt karışımını çırpın.", "Kek ılıyınca kürdanla delip sütlü karışımı yavaş yavaş dökün; buzdolabında 4 saat bekletin.", "Şekeri karamelleştirip sıcak kremayı ekleyerek sos yapın, soğuyunca kekin üzerine yayın."])
r("Kabak tatlısı", "Tatlılar", 120, 6, None,
  ["1 kg bal kabağı", "1,5 su bardağı şeker", "Üzeri için ceviz içi ve kaymak ya da tahin"],
  ["Kabağı soyup 3 × 6 cm dilimler hâlinde kesin, tencereye dizin.", "Üzerine şekeri serpip bir gece ya da en az 6 saat suyunu salması için bekletin.", "Su eklemeden kapağı kapalı, kısık ateşte 40–50 dakika kabak yumuşayıp şeffaflaşana kadar pişirin.", "Soğumaya bırakın; ceviz, kaymak ya da tahinle servis edin."])
r("Ayva tatlısı", "Tatlılar", 90, 4, 180,
  ["2 büyük ayva", "1 su bardağı şeker", "1,5 su bardağı su", "4 karanfil", "Ayva çekirdekleri", "Yarım limon suyu", "Kaymak, ceviz"],
  ["Ayvaları soyup ikiye bölün, çekirdek yatağını oyun; çekirdekleri saklayın.", "Ayvaları fırın kabına dizin, oyuklara şeker koyun.", "Su, kalan şeker, karanfil ve tülbente sarılmış çekirdekleri ekleyin.", "Üzerini folyoyla kapatıp 180 °C fırında 50 dakika, ayvalar kırmızılaşana kadar pişirin; son 10 dakika folyoyu açın.", "Limon suyunu gezdirip soğutun; kaymak ve cevizle servis edin."],
  "Ayva çekirdekleri şerbete kıvam ve kırmızı renk verir.")
r("Kısır", "Salatalar", 25, 6, None,
  ["2 su bardağı ince bulgur", "1,5 su bardağı kaynar su", "1 yemek kaşığı domates salçası", "1 yemek kaşığı biber salçası", "4 dal taze soğan", "1 demet maydanoz", "Yarım demet nane", "2 domates", "Yarım su bardağı zeytinyağı", "2 yemek kaşığı nar ekşisi", "1 limon suyu", "Tuz, pul biber, kimyon"],
  ["Bulguru kaynar suyla ıslatıp üzerini kapatarak 15 dakika şişirin.", "Salçaları ve zeytinyağını ekleyip bulgura iyice yedirin.", "Taze soğan, maydanoz, nane ve domatesi ince doğrayın.", "Yeşillikleri, nar ekşisi, limon ve baharatları ekleyip karıştırın.", "Marul yaprağıyla servis edin."])
r("Çılbır", "Kahvaltılıklar", 15, 2, None,
  ["4 yumurta", "1 su bardağı süzme yoğurt", "1 diş sarımsak", "2 yemek kaşığı tereyağı", "1 tatlı kaşığı pul biber", "1 yemek kaşığı sirke", "Tuz"],
  ["Yoğurdu ezilmiş sarımsak ve tuzla karıştırıp oda sıcaklığına getirin, tabaklara yayın.", "Bir tencerede suyu kaynatıp sirke ekleyin, ateşi kısın.", "Yumurtaları tek tek kaseye kırıp suya bırakın, 3–4 dakika poşe edin.", "Kevgirle alıp yoğurdun üzerine koyun.", "Tereyağında pul biberi kızdırıp üzerine gezdirin."],
  "Gebelik ve küçük çocuklar için sarısı tam pişene kadar (5–6 dakika) poşe edin.")
r("Gavurdağı salatası", "Salatalar", 20, 4, None,
  ["4 domates", "2 sivri biber", "1 kırmızı soğan", "Yarım demet maydanoz", "Yarım su bardağı ceviz içi", "3 yemek kaşığı zeytinyağı", "2 yemek kaşığı nar ekşisi", "1 tatlı kaşığı sumak", "Tuz, pul biber"],
  ["Domatesleri çekirdeklerini alarak çok küçük küpler hâlinde doğrayın.", "Biber, soğan ve maydanozu ince kıyın; soğanı sumakla ovun.", "Cevizi iri parçalar hâlinde kırın.", "Tüm malzemeyi zeytinyağı, nar ekşisi, tuz ve pul biberle karıştırıp hemen servis edin."])
r("Atom (közlenmiş biberli yoğurt)", "Mezeler", 15, 4, None,
  ["1 su bardağı süzme yoğurt", "1 diş sarımsak", "3 kuru acı biber", "2 yemek kaşığı tereyağı", "Tuz"],
  ["Yoğurdu sarımsak ve tuzla karıştırıp tabağa yayın.", "Kuru biberleri tereyağında 30 saniye kızdırın, yakmayın.", "Biberli yağı yoğurdun üzerine gezdirip biberleri ortasına yerleştirin."],
  "Acılıdır; çocuklar için biberleri çıkarıp sadece tereyağı kullanın.")
r("Fava", "Mezeler", 60, 6, None,
  ["2 su bardağı kuru bakla (kabuksuz)", "1 soğan", "Yarım su bardağı zeytinyağı", "1 tatlı kaşığı şeker", "1 limon suyu", "Yarım demet dereotu", "Tuz"],
  ["Baklayı bir gece ıslatıp süzün.", "Soğanı zeytinyağında yumuşatın, baklayı ve üzerini 2 parmak geçecek kadar sıcak suyu ekleyin.", "Kısık ateşte bakla dağılana kadar 45 dakika pişirin.", "Şeker, tuz ve limonu ekleyip blenderdan pürüzsüz geçirin.", "Kalıba döküp buzdolabında 3 saat dondurun; ters çevirip zeytinyağı ve dereotuyla servis edin."])
r("Babagannuş", "Mezeler", 30, 4, None,
  ["3 patlıcan", "2 yemek kaşığı tahin", "1 diş sarımsak", "1 limon suyu", "2 yemek kaşığı zeytinyağı", "Yarım demet maydanoz", "Nar taneleri", "Tuz"],
  ["Patlıcanları ocakta ya da ızgarada kabukları kararıp içi yumuşayana kadar közleyin.", "Kabuklarını soyup süzgeçte acı suyunu akıtın.", "Patlıcanı bıçakla kıyın; tahin, sarımsak, limon ve tuzla karıştırın.", "Tabağa yayıp zeytinyağı, maydanoz ve narla süsleyin."])
r("Hamsili pilav", "Pilavlar", 70, 6, 200,
  ["1 kg hamsi", "2 su bardağı baldo pirinç", "1 soğan", "2 yemek kaşığı dolmalık fıstık", "2 yemek kaşığı kuş üzümü", "3 yemek kaşığı tereyağı", "1 tatlı kaşığı yenibahar", "1 tatlı kaşığı karabiber", "1 tatlı kaşığı tarçın", "Yarım demet dereotu", "Tuz"],
  ["Hamsilerin kılçığını ayıklayıp kelebek gibi açın, yıkayıp süzün.", "Soğanı tereyağında kavurup fıstığı ekleyin; yıkanmış pirinci 3 dakika kavurun.", "Baharatlar, kuş üzümü, tuz ve 3 su bardağı sıcak suyu ekleyip pilavı suyunu çekene kadar pişirin; dereotunu karıştırın.", "Yağlanmış yuvarlak kalıba hamsileri derileri dışa gelecek şekilde, kenarlardan taşırarak dizin.", "Pilavı doldurup taşan hamsilerle kapatın, üstüne de hamsi dizin.", "200 °C fırında 30 dakika pişirin; 5 dakika dinlendirip ters çevirerek servis edin."])
r("Su böreği", "Hamur işleri", 150, 10, 200,
  ["Hamur için: 5 yumurta", "1 tatlı kaşığı tuz", "Aldığı kadar un (yaklaşık 4 su bardağı)", "İç için: 300 g beyaz peynir, 1 demet maydanoz", "200 g tereyağı"],
  ["Yumurta, tuz ve unla sert bir hamur yoğurup 9 bezeye bölün, 30 dakika dinlendirin.", "Her bezeyi nişasta yardımıyla tepsi büyüklüğünde, çok ince açın.", "Bir yufkayı tepsiye serin; kalanları kaynar tuzlu suda 30 saniye haşlayıp soğuk suya alın.", "Haşlanmış yufkaları süzüp tepsiye kat kat serin, her kata eritilmiş tereyağı sürün.", "Ortaya peynirli harcı yayıp kalan katları aynı şekilde serin; en üste çiğ yufka koyup tereyağı sürün.", "200 °C fırında 35–40 dakika, üzeri kızarana kadar pişirin; 15 dakika dinlendirip dilimleyin."])
r("Lokma tatlısı", "Tatlılar", 75, 8, None,
  ["2 su bardağı un", "1 paket kuru maya", "1 tatlı kaşığı şeker", "1 çay kaşığı tuz", "1,5 su bardağı ılık su", "Şerbet için: 2 su bardağı şeker, 2 su bardağı su, birkaç damla limon", "Kızartmak için ayçiçek yağı"],
  ["Şerbeti 10 dakika kaynatıp limonu ekleyin, soğutun.", "Un, maya, şeker, tuz ve suyu çırparak akışkan bir hamur yapın; 45 dakika kabarmaya bırakın.", "Hamuru avucunuzdan sıkarak ıslak kaşıkla kesin, kızgın yağa bırakın.", "Altın rengi olana kadar çevirerek 3–4 dakika kızartın.", "Kızaran lokmaları soğuk şerbete atıp 1 dakika bekletip çıkarın."])
r("Revani", "Tatlılar", 60, 12, 180,
  ["4 yumurta", "1 su bardağı şeker", "1 su bardağı yoğurt", "1 su bardağı irmik", "1 su bardağı un", "1 paket kabartma tozu", "1 limon kabuğu rendesi", "Şerbet için: 2,5 su bardağı şeker, 3 su bardağı su, yarım limon"],
  ["Şerbeti 10 dakika kaynatıp limonu ekleyin, soğutun.", "Yumurta ve şekeri 5 dakika köpürtün, yoğurdu ekleyin.", "İrmik, un, kabartma tozu ve limon kabuğunu katlayarak karıştırın.", "Yağlanmış tepsiye döküp 180 °C fırında 30–35 dakika pişirin.", "Sıcak revaniyi dilimleyip soğuk şerbeti dökün, 2 saat dinlendirin."])
r("Kaygana", "Kahvaltılıklar", 15, 2, None,
  ["3 yumurta", "3 yemek kaşığı un", "Yarım su bardağı süt", "Yarım demet maydanoz ve dereotu", "1 yemek kaşığı tereyağı", "Tuz"],
  ["Yumurta, un, süt ve tuzu pürüzsüz çırpın.", "İnce kıyılmış yeşillikleri ekleyin.", "Tavada tereyağını eritip karışımı ince yayın.", "Altı kızarınca çevirip diğer yüzünü 1 dakika pişirin.", "Rulo yapıp sıcak servis edin."])
r("Ali nazik", "Et yemekleri", 60, 4, None,
  ["4 patlıcan", "1 su bardağı süzme yoğurt", "1 diş sarımsak", "400 g kuşbaşı kuzu eti ya da kıyma", "1 soğan", "1 yemek kaşığı biber salçası", "2 yemek kaşığı tereyağı", "Tuz, karabiber, pul biber"],
  ["Patlıcanları közleyip kabuklarını soyun, ince kıyın; sarımsaklı ve tuzlu yoğurtla karıştırın.", "Eti tereyağında suyunu çekene kadar kavurun, soğanı ekleyin.", "Salça ve baharatları ekleyip yarım su bardağı sıcak suyla et yumuşayana kadar pişirin.", "Patlıcanlı yoğurdu tabağa yayın, eti ortasına koyun.", "Pul biberli tereyağı gezdirip servis edin."])
r("Tas kebabı", "Et yemekleri", 120, 4, None,
  ["600 g kuşbaşı dana eti", "2 soğan", "2 domates", "1 yemek kaşığı salça", "2 yemek kaşığı tereyağı", "2 patates (isteğe bağlı)", "Tuz, karabiber, kekik"],
  ["Eti tencerede kendi suyunu çekene kadar kavurun.", "Tereyağı ve doğranmış soğanı ekleyip 5 dakika çevirin.", "Salça ve rendelenmiş domatesi ekleyin; üzerini geçecek kadar sıcak su ilave edin.", "Kapağı kapalı, kısık ateşte et yumuşayana kadar 1–1,5 saat pişirin.", "İsterseniz son 25 dakikada küp patates ekleyin; tuz ve baharatla tatlandırıp pilavla servis edin."])
r("Orman kebabı", "Et yemekleri", 100, 4, None,
  ["500 g kuşbaşı dana eti", "10 arpacık soğan", "2 havuç", "1 su bardağı bezelye", "2 patates", "1 yemek kaşığı salça", "2 yemek kaşığı tereyağı", "Tuz, karabiber, kekik"],
  ["Eti kendi suyunu çekene kadar kavurun, tereyağı ve arpacık soğanları ekleyin.", "Salçayı ekleyip 2 dakika kavurun; sıcak su ilave edip 45 dakika pişirin.", "Küp havuç ve patatesi, bezelyeyi ekleyin.", "Sebzeler yumuşayana kadar 25 dakika daha pişirip baharatlarla tatlandırın."])
r("Tantuni", "Et yemekleri", 40, 4, None,
  ["500 g dana but (çok ince şerit doğranmış)", "2 yemek kaşığı pamuk yağı", "1 tatlı kaşığı pul biber", "Tuz", "4 lavaş", "Yanına: 2 domates, 1 soğan, maydanoz, sumak, limon"],
  ["Eti az tuzlu suda 10 dakika haşlayıp süzün.", "Geniş tavada yağı kızdırıp eti ekleyin, pul biber ve az haşlama suyuyla 10 dakika soteleyin.", "Domates, soğan ve maydanozu ince kıyıp sumakla karıştırın.", "Lavaşı tavadaki yağa bastırıp ısıtın; et ve salatayı koyup sarın.", "Limonla servis edin."])
r("Kumpir", "Pratik tarifler", 70, 4, 200,
  ["4 büyük patates", "4 yemek kaşığı tereyağı", "1 su bardağı rendelenmiş kaşar", "İç seçenekleri: mısır, bezelye, Rus salatası, zeytin, turşu, sosis dilimleri", "Tuz"],
  ["Patatesleri yıkayıp folyoya sarın, 200 °C fırında 60 dakika, şiş kolayca girene kadar pişirin.", "Patatesleri uzunlamasına yarın, içini çatalla kabuklarından ayırmadan kabartın.", "Sıcakken tereyağı, tuz ve kaşarı ekleyip kaşar eriyene kadar karıştırın.", "Seçtiğiniz malzemeleri üzerine dizip servis edin."])
r("Profiterol", "Tatlılar", 90, 8, 200,
  ["Hamur için: 1 su bardağı su, 125 g tereyağı, 1 su bardağı un, 4 yumurta", "Krema için: 2 su bardağı süt, 3 yemek kaşığı un, 2 yemek kaşığı nişasta, 1 yumurta sarısı, 1 su bardağı şeker, 1 paket vanilya", "Sos için: 2 su bardağı süt, 3 yemek kaşığı kakao, 2 yemek kaşığı un, 1 su bardağı şeker, 50 g bitter çikolata"],
  ["Su ve tereyağını kaynatıp unu bir kerede ekleyin, hamur tencereden ayrılana kadar karıştırın.", "Ilıyınca yumurtaları teker teker yedirin; sıkma torbasıyla ceviz büyüklüğünde tepsiye sıkın.", "200 °C fırında 25 dakika, fırın kapağını açmadan pişirin.", "Krema malzemelerini muhallebi kıvamına gelene kadar pişirip soğutun.", "Topların içini kremayla doldurup servis kasesine dizin.", "Sos malzemelerini koyulaşana kadar pişirip ılık hâlde üzerine dökün."])
r("Lahmacun", "Hamur işleri", 90, 8, 250,
  ["Hamur için: 3 su bardağı un", "1 tatlı kaşığı kuru maya", "1 tatlı kaşığı tuz", "1 su bardağı ılık su", "Harç için: 300 g kıyma", "2 soğan", "2 domates", "1 kırmızı biber", "Yarım demet maydanoz", "1 yemek kaşığı biber salçası", "1 tatlı kaşığı pul biber, tuz", "Yanına: limon, maydanoz, soğan"],
  ["Hamuru yoğurup 30 dakika dinlendirin.", "Soğan, domates, biber ve maydanozu robottan geçirip kıyma, salça ve baharatla yoğurun.", "Hamuru 8 bezeye ayırıp çok ince yuvarlaklar hâlinde açın.", "Harcı ince ve kenarlara kadar yayın.", "En yüksek ısıdaki fırında (250 °C) ters tepsi ya da taş üzerinde 6–8 dakika pişirin.", "Limon ve yeşillikle sarıp servis edin."])
