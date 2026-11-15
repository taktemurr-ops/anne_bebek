class CatalogProduct {
  final String id, name, category, description, note;
  final List<String> features;
  const CatalogProduct(this.id, this.name, this.category, this.description, this.features, this.note);
}

class ProductCatalog {
  static const categories = ['Bebek bakımı', 'Beslenme', 'Uyku', 'Güvenlik', 'Anne ihtiyaçları', 'Ev ve yaşam'];
  static const products = <CatalogProduct>[
    CatalogProduct('bb01','Bebek bezi','Bebek bakımı','Beden ve emicilik ihtiyacına göre seçilir.',['Beden uyumu','Emicilik','Cilt hassasiyeti'],'Ciltte tahriş olursa sağlık uzmanına danışın.'),
    CatalogProduct('bb02','Islak mendil','Bebek bakımı','Hassas cilt temizliği için seçenekler.',['Parfüm içeriği','Paket adedi','Cilt uyumu'],'İçerik etiketini inceleyin.'),
    CatalogProduct('bb03','Alt değiştirme örtüsü','Bebek bakımı','Taşınabilir alt değiştirme yüzeyi.',['Yıkanabilirlik','Katlanabilirlik','Boyut'],'Temiz ve güvenli düz yüzey kullanın.'),
    CatalogProduct('bb04','Bebek küveti','Bebek bakımı','Banyo için destekleyici ekipman.',['Kaymaz taban','Boyut','Kolay temizlik'],'Bebeği suda asla yalnız bırakmayın.'),
    CatalogProduct('bb05','Bebek havlusu','Bebek bakımı','Yumuşak banyo havlusu.',['Kumaş','Yıkama talimatı','Boyut'],'Cilt hassasiyetine uygun ürün seçin.'),
    CatalogProduct('bb06','Tırnak bakım seti','Bebek bakımı','Yaşa uygun tırnak bakımı.',['Uç tasarımı','Temizlik','Taşıma kutusu'],'Keskin uçları dikkatle kullanın.'),
    CatalogProduct('bs01','Biberon','Beslenme','Beslenme ekipmanı seçenekleri.',['Hacim','Malzeme','Temizlik'],'Yaşa uygun kullanım ve hijyen önemlidir.'),
    CatalogProduct('bs02','Biberon temizleme fırçası','Beslenme','Biberon parçalarını temizlemek için.',['Fırça boyu','Başlık','Kuruma'],'Üretici temizleme talimatlarını izleyin.'),
    CatalogProduct('bs03','Mama sandalyesi','Beslenme','Destekli öğün oturma alanı.',['Emniyet kemeri','Denge','Temizlik'],'Çocuğu sandalyede gözetimsiz bırakmayın.'),
    CatalogProduct('bs04','Mama önlüğü','Beslenme','Öğünlerde kıyafet koruması.',['Yıkanabilirlik','Boyun ayarı','Malzeme'],'Boyun çevresinde güvenli uyuma dikkat edin.'),
    CatalogProduct('bs05','Bebek kaşığı','Beslenme','Ek gıdaya uygun kaşık seçenekleri.',['Uç yumuşaklığı','Boyut','Temizlik'],'Yaşa uygun ve hasarsız ürün kullanın.'),
    CatalogProduct('bs06','Saklama kabı','Beslenme','Gıda porsiyonlarını saklamak için.',['Gıda teması uygunluğu','Kapak','Hacim'],'Güvenli saklama sıcaklıklarına uyun.'),
    CatalogProduct('uy01','Bebek yatağı','Uyku','Güvenli uyku alanı seçimi.',['Sert düz yüzey','Boyut uyumu','Standartlar'],'Güvenli uyku rehberlerine uyun; yumuşak nesnelerden kaçının.'),
    CatalogProduct('uy02','Uyku tulumu','Uyku','Uyku sırasında uygun giyim seçeneği.',['Beden','Mevsim uygunluğu','Fermuar'],'Aşırı ısınmayı önleyin.'),
    CatalogProduct('uy03','Oda termometresi','Uyku','Oda sıcaklığını izleme aracı.',['Ölçüm aralığı','Ekran','Pil'],'Ölçümün doğruluğunu kontrol edin.'),
    CatalogProduct('uy04','Gece lambası','Uyku','Düşük ışıklı gece aydınlatması.',['Parlaklık','Güç kaynağı','Konum'],'Kablo ve küçük parçaları erişim dışında tutun.'),
    CatalogProduct('uy05','Bebek telsizi','Uyku','Ses veya görüntü izleme ekipmanı.',['Bağlantı türü','Menzil','Pil'],'Doğrudan yetişkin gözetiminin yerini almaz.'),
    CatalogProduct('uy06','Karartma perde','Uyku','Oda ışığını azaltan perde.',['Ölçü','Montaj','Temizlik'],'Perde iplerini çocuk erişiminden uzak tutun.'),
    CatalogProduct('gv01','Araç çocuk koltuğu','Güvenlik','Boy ve ağırlığa uygun araç güvenliği.',['Onay standardı','Montaj uyumu','Boy-kilo aralığı'],'Araca ve çocuğa uygun onaylı model seçin.'),
    CatalogProduct('gv02','Dolap kilidi','Güvenlik','Dolap erişimini sınırlama aracı.',['Montaj','Uyum','Dayanıklılık'],'Güvenlik önlemleri gözetimin yerini almaz.'),
    CatalogProduct('gv03','Priz koruyucu','Güvenlik','Elektrik prizleri için koruma.',['Uyum','Sabitlik','Standartlar'],'Elektrik güvenliğinde profesyonel önerilere uyun.'),
    CatalogProduct('gv04','Merdiven güvenlik kapısı','Güvenlik','Merdiven geçişlerini sınırlamak için.',['Montaj tipi','Genişlik','Kilit'],'Merdiven üstünde uygun sabit montaj önemlidir.'),
    CatalogProduct('gv05','Köşe koruyucu','Güvenlik','Sert mobilya köşelerine destek.',['Yapışma','Malzeme','Uyum'],'Kopabilecek küçük parçaları kontrol edin.'),
    CatalogProduct('gv06','İlk yardım çantası','Güvenlik','Temel acil durum malzemeleri.',['İçerik','Son kullanma','Taşınabilirlik'],'İlk yardım eğitimi ve acil yardım erişimi önemlidir.'),
    CatalogProduct('an01','Emzirme yastığı','Anne ihtiyaçları','Besleme sırasında pozisyon desteği.',['Kılıf','Destek','Temizlik'],'Bebek uyku alanında yastık bırakmayın.'),
    CatalogProduct('an02','Göğüs pedi','Anne ihtiyaçları','Sızıntı yönetimi için.',['Emicilik','Cilt uyumu','Paket'],'Tahrişte ürünü değiştirin ve destek alın.'),
    CatalogProduct('an03','Süt saklama poşeti','Anne ihtiyaçları','Sağılmış süt saklama ekipmanı.',['Gıda uygunluğu','Ölçek','Sızdırmazlık'],'Süt saklama süresi ve sıcaklık kurallarına uyun.'),
    CatalogProduct('an04','Göğüs pompası','Anne ihtiyaçları','Süt sağımı için ekipman.',['Manuel/elektrikli','Başlık uyumu','Temizlik'],'Kullanım talimatlarına ve hijyene uyun.'),
    CatalogProduct('an05','Anne bakım çantası','Anne ihtiyaçları','Dışarı çıkarken malzeme taşıma.',['Bölmeler','Temizlik','Ağırlık'],'Ağır çantaları güvenli taşıyın.'),
    CatalogProduct('an06','Su matarası','Anne ihtiyaçları','Günlük su taşımaya yardımcı.',['Hacim','Temizlik','Sızdırmazlık'],'Kişisel sıvı ihtiyacı değişebilir.'),
    CatalogProduct('ev01','Hava temizleyici','Ev ve yaşam','İç mekân hava filtreleme seçeneği.',['Filtre türü','Oda kapasitesi','Ses'],'Filtre bakımını üreticiye göre yapın.'),
    CatalogProduct('ev02','Nem ölçer','Ev ve yaşam','Ortam nemini izlemek için.',['Ölçüm aralığı','Ekran','Kalibrasyon'],'Ölçüm hataları olabileceğini unutmayın.'),
    CatalogProduct('ev03','Termos','Ev ve yaşam','İçecek sıcaklığını koruyan kap.',['Hacim','Kapak','Yalıtım'],'Sıcak sıvıları çocuklardan uzak tutun.'),
    CatalogProduct('ev04','Saklama organizeri','Ev ve yaşam','Ev eşyalarını düzenleme ürünü.',['Bölme sayısı','Boyut','Temizlik'],'Küçük parçaları erişim dışında saklayın.'),
    CatalogProduct('ev05','Çamaşır sepeti','Ev ve yaşam','Çamaşır ayırma ve taşıma.',['Hacim','Malzeme','Taşıma'],'Sepetleri oyun alanı olarak kullanmayın.'),
    CatalogProduct('ev06','Dijital mutfak tartısı','Ev ve yaşam','Mutfakta ölçüm için.',['Hassasiyet','Kapasite','Temizlik'],'Pil ve küçük parçaları çocuklardan uzak tutun.'),
  ];
  static CatalogProduct? byId(String id) { for (final p in products) { if (p.id == id) return p; } return null; }
}
