/// Çevrimdışı ihtiyaç planlama kataloğu. Fiyat/stok veya satış vaadi içermez.
const List<String> productCategories = [
  'Bebek Ürünleri', 'Anne Ürünleri', 'Ev & Yaşam', 'Kozmetik & Bakım',
  'Giyim', 'Oyuncak', 'Sağlık', 'Diğer',
];

/// [ad, kategori, simge] - kullanıcıların alışveriş listesine ekleyebileceği örnek ihtiyaçlar.
const List<List<String>> productCatalog = [
  ['Bebek Bezi', 'Bebek Ürünleri', '🧷'],
  ['Islak Mendil', 'Bebek Ürünleri', '🧻'],
  ['Biberon', 'Bebek Ürünleri', '🍼'],
  ['Emzik', 'Bebek Ürünleri', '🍼'],
  ['Alt Açma Örtüsü', 'Bebek Ürünleri', '🧺'],
  ['Anne Bakım Çantası', 'Anne Ürünleri', '👜'],
  ['Emzirme Yastığı', 'Anne Ürünleri', '🛏️'],
  ['Göğüs Pedi', 'Anne Ürünleri', '💗'],
  ['Su Matarası', 'Anne Ürünleri', '🥤'],
  ['Bebek Havlusu', 'Ev & Yaşam', '🛁'],
  ['Çamaşır Sepeti', 'Ev & Yaşam', '🧺'],
  ['Saklama Kabı', 'Ev & Yaşam', '🥣'],
  ['Gece Lambası', 'Ev & Yaşam', '💡'],
  ['Bebek Şampuanı', 'Kozmetik & Bakım', '🫧'],
  ['Nemlendirici', 'Kozmetik & Bakım', '🧴'],
  ['Güneş Koruyucu', 'Kozmetik & Bakım', '☀️'],
  ['Bebek Tulumu', 'Giyim', '👶'],
  ['Çorap', 'Giyim', '🧦'],
  ['Mevsimlik Hırka', 'Giyim', '🧥'],
  ['Oyuncak Ayı', 'Oyuncak', '🧸'],
  ['Yumuşak Kitap', 'Oyuncak', '📖'],
  ['Büyük Parçalı Bloklar', 'Oyuncak', '🧱'],
  ['Dijital Termometre', 'Sağlık', '🌡️'],
  ['İlk Yardım Çantası', 'Sağlık', '🩹'],
  ['Serum Fizyolojik', 'Sağlık', '💧'],
  ['Not Defteri', 'Diğer', '📒'],
  ['Pil', 'Diğer', '🔋'],
  ['Hediye Paketi', 'Diğer', '🎁'],
];
