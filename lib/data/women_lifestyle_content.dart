/// Editoryal başlangıç içerikleri. Tıbbi tavsiye değildir.
class LifestyleArticle {
  final String category;
  final String title;
  final String body;
  final String caution;
  const LifestyleArticle(this.category, this.title, this.body, this.caution);
  String get id => '$category::$title';
}

const lifestyleArticles = <LifestyleArticle>[
  LifestyleArticle("Güzellik & Bakım", "Nazik cilt temizliği", "Sabah ve akşam cildinizi tahriş etmeden temizleyin. Çok sıcak su yerine ılık su tercih edin. Temizlik sonrası cildinize uygun nemlendirici uygulayın.", "Yeni bir ürün kullanırken küçük bir bölgede deneyin; kalıcı kızarıklıkta dermatoloğa danışın."),
  LifestyleArticle("Güzellik & Bakım", "Güneşten korunma", "Günlük bakımda geniş spektrumlu SPF 30 veya üzeri güneş koruyucu kullanın. Açık havada ürünün etiketine göre yenileyin; gölge ve şapka gibi fiziksel önlemleri ekleyin.", "Gebelik ve emzirme döneminde içerik konusunda hekiminize danışın."),
  LifestyleArticle("Güzellik & Bakım", "Saç ve saç derisi", "Saç tipinize uygun temizleme sıklığı belirleyin. Isı işlemlerini azaltın, saç derisini sertçe ovalamayın. Ani veya belirgin saç kaybını not edin.", "Yamalı dökülme veya saç derisinde iltihap varsa değerlendirme alın."),
  LifestyleArticle("Güzellik & Bakım", "El ve tırnak bakımı", "Ellerinizi yıkadıktan sonra nemlendirin. Tırnakları temiz ve kısa tutun; keskin aletlerle tırnak etini zorlamayın.", "Tırnak çevresinde şişlik ve ağrı olursa sağlık uzmanına başvurun."),
  LifestyleArticle("Güzellik & Bakım", "Basit sabah rutini", "Yüz temizliği, nemlendirme ve güneşten korunmayı üç kısa adıma bölün. Yeni ürünleri tek tek ekleyerek cildinizin tepkisini gözlemleyin.", "Cilt bakımında çok ürün kullanmak zorunlu değildir."),
  LifestyleArticle("Güzellik & Bakım", "Akşam dinlenme bakımı", "Akşam cildinizi nazikçe temizleyin, nemlendirin ve uyku öncesi ekran süresini azaltın. Sürdürülebilir kısa rutinler tercih edin.", "Tahriş oluşturan ürünleri bırakıp profesyonel görüş alın."),
  LifestyleArticle("Sağlık & Wellness", "Düzenli kontrol planı", "Yaşınıza, sağlık geçmişinize ve risklerinize uygun taramaları aile hekiminizle planlayın. Randevularda sorularınızı ve kullandığınız ilaçları listeleyin.", "Tarama aralıkları kişiye göre değişir."),
  LifestyleArticle("Sağlık & Wellness", "Uyku hijyeni", "Mümkün olduğunca benzer saatlerde yatıp kalkın. Uyku ortamını serin, karanlık ve sessiz tutun. Geç saatlerde kafein tüketimini sınırlayın.", "Uzun süren uykusuzluk için profesyonel destek alın."),
  LifestyleArticle("Sağlık & Wellness", "Günlük hareket", "Gün içine kısa yürüyüşler ve esneme molaları yerleştirin. Hareket süresini mevcut kondisyonunuza göre kademeli artırın.", "Gebelik, doğum sonrası dönem veya kronik hastalıkta kişisel öneri alın."),
  LifestyleArticle("Sağlık & Wellness", "Stres işaretleri", "Gerginlik, uyku değişimi ve dikkat güçlüğünü gözlemleyin. Dinlenme, sosyal destek ve görev paylaşımı planlayın.", "Günlük işlevleri etkileyen yoğun sıkıntıda uzman desteği alın."),
  LifestyleArticle("Sağlık & Wellness", "Sağlık notlarını düzenleme", "Belirtiyi, başlangıç zamanını, süresini ve günlük etkisini not edin. Randevu öncesinde sorularınızı bir araya getirin.", "Uygulamadaki notlar tıbbi kayıtların yerine geçmez."),
  LifestyleArticle("Sağlık & Wellness", "Sıvı tüketimini izleme", "Susuzluk hissinizi ve gün içindeki koşulları göz önünde bulundurun. Fiziksel aktivite ve sıcak havalarda ihtiyacınız değişebilir.", "Sıvı kısıtlaması gerektiren hastalığınız varsa hekim önerisini izleyin."),
  LifestyleArticle("Moda & Stil", "Kapsül gardırop", "Sık giydiğiniz parçaları belirleyin. Birbirleriyle uyumlu birkaç temel renk seçerek kombin oluşturmayı kolaylaştırın.", "Alışverişten önce dolabınızdakileri değerlendirin."),
  LifestyleArticle("Moda & Stil", "Günlük rahat kombin", "Günlük hareketliliğe uygun kumaş ve kalıpları seçin. Mevsim ve gün içindeki sıcaklık değişimine göre katmanlı giyinin.", "Rahatlık kişisel tercihinizle belirlenir."),
  LifestyleArticle("Moda & Stil", "Kıyafet bakım etiketleri", "Yıkama ve ütü talimatlarını kontrol edin. Hassas kumaşları uygun programda yıkayın; kurutma talimatlarına uyun.", "Ürünün kendi etiketini esas alın."),
  LifestyleArticle("Moda & Stil", "Dolap düzenleme", "Kıyafetleri kullanım sıklığına göre gruplandırın. Kullanmadıklarınızı bağışlama veya onarma seçeneklerini değerlendirin.", "Satın almadan önce ihtiyaç listesi oluşturun."),
  LifestyleArticle("Moda & Stil", "Aksesuar seçimi", "Az sayıda çok yönlü aksesuarla farklı kombinler oluşturabilirsiniz. Günlük kullanımda ağırlık ve rahatlığı dikkate alın.", "Çocukların erişebileceği küçük parçaları güvenli saklayın."),
  LifestyleArticle("Moda & Stil", "Mevsim geçişi", "Dolabınızı hava koşullarına göre yeniden düzenleyin. İnce ve kalın katmanları birlikte kullanabileceğiniz seçenekler hazırlayın.", "Hava koşullarını dikkate alın."),
  LifestyleArticle("Diyet & Beslenme", "Dengeli tabak yaklaşımı", "Öğünlerde sebze, tam tahıl ve protein kaynaklarına yer vermeye çalışın. Besin çeşitliliği ve kişisel ihtiyaçlar önemlidir.", "Gebelik ve emzirme döneminde özel beslenme gereksinimlerini uzmanla görüşün."),
  LifestyleArticle("Diyet & Beslenme", "Pratik öğün planlama", "Haftanın birkaç günü için basit ana öğünler belirleyin. Evdeki malzemeleri kontrol ederek alışveriş listenizi hazırlayın.", "Tek tip veya aşırı kısıtlayıcı beslenme planlarından kaçının."),
  LifestyleArticle("Diyet & Beslenme", "Etiket okuma", "Paketli gıdalarda porsiyon, içerik, alerjen ve son tüketim bilgilerini kontrol edin. Benzer ürünleri ihtiyacınıza göre karşılaştırın.", "Gıda alerjisinde ürün etiketini her alışverişte yeniden inceleyin."),
  LifestyleArticle("Diyet & Beslenme", "Ara öğün fikirleri", "Meyve, yoğurt, uygun porsiyonda kuruyemiş veya tam tahıllı seçenekler pratik olabilir. Açlık durumunuza göre tercih yapın.", "Alerjiler ve özel diyet gereksinimleri önemlidir."),
  LifestyleArticle("Diyet & Beslenme", "Gıda güvenliği", "Çiğ ve pişmiş gıdaları ayrı hazırlayın. Soğuk zincire dikkat edin ve yiyecekleri uygun sıcaklıkta saklayın.", "Gebelikte yüksek riskli gıdalar için güncel sağlık önerilerini izleyin."),
  LifestyleArticle("Diyet & Beslenme", "Sürdürülebilir alışkanlıklar", "Keskin diyetler yerine uygulanabilir küçük değişiklikler belirleyin. Öğünlerinizi günlük rutininize göre planlayın.", "Kilo ve sağlık hedeflerini bireysel değerlendirin."),
  LifestyleArticle("Kişisel Gelişim", "Küçük hedef belirleme", "Büyük bir hedefi haftalık, ölçülebilir adımlara bölün. Aynı anda çok fazla alışkanlık değiştirmek yerine birini seçin.", "İlerlemeyi mükemmellik üzerinden değerlendirmeyin."),
  LifestyleArticle("Kişisel Gelişim", "Günlük zaman planı", "Günün en önemli üç işini belirleyin. Beklenmedik durumlar için takvimde esnek zaman bırakın.", "Dinlenmeyi de planın bir parçası olarak görün."),
  LifestyleArticle("Kişisel Gelişim", "Öğrenme rutini", "İlgilendiğiniz bir konu seçin. Her gün kısa okuma veya uygulama zamanı ayırın. Öğrendiklerinizi kendi cümlelerinizle not edin.", "Hedeflerinizi gerçekçi tutun."),
  LifestyleArticle("Kişisel Gelişim", "Sınır koyma", "İhtiyaçlarınızı açık ve saygılı biçimde ifade etmeye çalışın. Yapamayacağınız işlere hemen söz vermek zorunda değilsiniz.", "Güvenlik kaygısı içeren ilişkilerde profesyonel destek alın."),
  LifestyleArticle("Kişisel Gelişim", "Destek ağı", "İletişimde kalmak istediğiniz kişileri belirleyin. Düzenli kısa görüşmeler için uygun zamanlar planlayın.", "Destek istemek günlük yaşamın olağan parçasıdır."),
  LifestyleArticle("Kişisel Gelişim", "Haftalık değerlendirme", "Bu hafta iyi giden bir şeyi ve geliştirmek istediğiniz bir alanı yazın. Gelecek hafta için tek bir uygulanabilir adım seçin.", "Kendinizi başkalarıyla kıyaslamayın."),
  LifestyleArticle("Rahatlama", "Kısa nefes molası", "Rahat bir pozisyonda oturun ve birkaç dakika doğal nefesinizi izleyin. Nefesi zorlamadan dikkatinizi bulunduğunuz ana getirin.", "Baş dönmesi olursa uygulamayı bırakın."),
  LifestyleArticle("Rahatlama", "Ekransız mola", "Gün içinde kısa bir süre bildirimleri kapatın. Bu zamanı sessizlik, müzik veya hafif bir yürüyüş için kullanın.", "Mola süresini kendi koşullarınıza göre ayarlayın."),
  LifestyleArticle("Rahatlama", "Gevşeme rutini", "Omuz ve çene gerginliğinizi fark edin. Rahat bir pozisyonda kasları zorlamadan gevşetin.", "Ağrı veren hareketlerden kaçının."),
  LifestyleArticle("Rahatlama", "Akşam sakinleşme", "Yatmadan önce ışığı azaltın ve ertesi günün önemli işlerini kısaca not edin. Rahatlatıcı bir kitap veya müzik seçin.", "Uyku sorunları sürerse sağlık uzmanına danışın."),
  LifestyleArticle("Rahatlama", "Doğada kısa yürüyüş", "Güvenli bir alanda kısa yürüyüş yapın. Çevredeki sesleri, renkleri ve kokuları fark etmeye odaklanın.", "Hava ve fiziksel koşullara göre hareket edin."),
  LifestyleArticle("Rahatlama", "Duyguları adlandırma", "Günün sonunda nasıl hissettiğinizi birkaç kelimeyle yazın. Duygunuzu değiştirmeye zorlamadan fark etmeye çalışın.", "Yoğun veya uzun süren sıkıntıda destek alın."),
  LifestyleArticle("Aile ve Yaşam", "Ev içi görev paylaşımı", "Haftalık işleri görünür bir listeye yazın. Sorumlulukları zaman ve imkânlara göre paylaşın.", "Planı düzenli olarak birlikte gözden geçirin."),
  LifestyleArticle("Aile ve Yaşam", "Aile iletişimi", "Gün içinde kısa ve dikkat dağıtıcı olmayan bir sohbet zamanı oluşturun. Dinlerken söz kesmemeye özen gösterin.", "Fikir ayrılıklarında saygılı dil kullanın."),
  LifestyleArticle("Aile ve Yaşam", "Acil durum hazırlığı", "Önemli telefonları, ilaç listesini ve temel ihtiyaçları erişilebilir tutun. Aile üyeleriyle buluşma planını konuşun.", "Yerel resmî afet rehberlerini esas alın."),
  LifestyleArticle("Aile ve Yaşam", "Ev düzeni", "Sık kullanılan eşyalar için sabit yer belirleyin. Küçük günlük düzenleme adımlarıyla birikmeyi azaltın.", "Temizlik ürünlerini çocuklardan uzak tutun."),
  LifestyleArticle("Aile ve Yaşam", "Ortak etkinlik", "Ailenin yaşına ve ilgi alanlarına uygun kısa etkinlikler planlayın. Ekransız oyun ve sohbet seçenekleri ekleyin.", "Çocukların güvenliğini gözetin."),
  LifestyleArticle("Aile ve Yaşam", "Haftalık bütçe notu", "Düzenli harcamaları ve yaklaşan ihtiyaçları yazın. Alışveriş öncesinde evdeki stokları kontrol edin.", "Bu içerik finansal danışmanlık değildir."),
];
