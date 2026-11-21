import 'package:flutter/material.dart';

/// Alışveriş ekranındaki ihtiyaç kataloğu (Paket 39 Alışveriş referansı).
///
/// Bebek / Anne / Aile bölümleri ve alt kategoriler. Ürünler marka, fiyat
/// veya stok bilgisi içermez; kullanıcının listesine eklenen ihtiyaç adlarıdır.
class ShoppingSubcategory {
  const ShoppingSubcategory(this.name, this.icon, this.items);

  final String name;
  final IconData icon;
  final List<String> items;
}

class ShoppingSegment {
  const ShoppingSegment(this.name, this.subcategories);

  final String name;
  final List<ShoppingSubcategory> subcategories;
}

const shoppingSegments = <ShoppingSegment>[
  ShoppingSegment('Bebek Ürünleri', [
    ShoppingSubcategory('Bez', Icons.baby_changing_station_outlined, [
      'Bebek bezi', 'Islak mendil', 'Pişik kremi', 'Alt açma örtüsü', 'Bez çantası',
      'Kirli bez poşeti', 'Pamuk',
    ]),
    ShoppingSubcategory('Beslenme', Icons.local_drink_outlined, [
      'Biberon', 'Biberon emziği', 'Biberon fırçası', 'Mama', 'Mama sandalyesi', 'Mama önlüğü',
      'Silikon kaşık', 'Alıştırma bardağı', 'Mama kabı', 'Sterilizatör', 'Termos', 'Mama saklama kabı',
    ]),
    ShoppingSubcategory('Giyim', Icons.checkroom_outlined, [
      'Zıbın', 'Body', 'Tulum', 'Pijama takımı', 'Çorap', 'Patik', 'Şapka', 'Eldiven', 'Hırka',
      'Battaniye', 'Kundak',
    ]),
    ShoppingSubcategory('Banyo', Icons.bathtub_outlined, [
      'Bebek şampuanı', 'Bebek küveti', 'Banyo termometresi', 'Bebek havlusu', 'Bornoz',
      'Tırnak makası', 'Bebek tarağı', 'Bebek losyonu', 'Banyo süngeri',
    ]),
    ShoppingSubcategory('Gezi', Icons.stroller_outlined, [
      'Bebek arabası', 'Oto koltuğu', 'Kanguru / ergonomik taşıyıcı', 'Puset yağmurluğu',
      'Puset sineklik', 'Seyahat yatağı', 'Güneşlik',
    ]),
    ShoppingSubcategory('Uyku', Icons.bedtime_outlined, [
      'Beşik çarşafı', 'Alez', 'Uyku tulumu', 'Gece lambası', 'Bebek telsizi', 'Müzikli dönence',
    ]),
    ShoppingSubcategory('Oyun', Icons.toys_outlined, [
      'Diş kaşıyıcı', 'Çıngırak', 'Oyun halısı', 'Yumuşak kitap', 'Peluş oyuncak',
      'Büyük parçalı bloklar', 'Aktivite küpü',
    ]),
    ShoppingSubcategory('Sağlık', Icons.medical_services_outlined, [
      'Ateş ölçer', 'Burun aspiratörü', 'Serum fizyolojik', 'İlaç ölçü kaşığı', 'İlk yardım çantası',
    ]),
  ]),
  ShoppingSegment('Anne Ürünleri', [
    ShoppingSubcategory('Emzirme', Icons.favorite_border_rounded, [
      'Emzirme yastığı', 'Göğüs pedi', 'Göğüs pompası', 'Süt saklama poşeti', 'Meme ucu kremi',
      'Emzirme sütyeni', 'Emzirme örtüsü',
    ]),
    ShoppingSubcategory('Gebelik', Icons.pregnant_woman_rounded, [
      'Hamile yastığı', 'Hamile pantolonu', 'Destek çorabı', 'Çatlak kremi', 'Rahat ayakkabı',
    ]),
    ShoppingSubcategory('Doğum', Icons.local_hospital_outlined, [
      'Hastane çantası', 'Lohusa pedi', 'Doğum sonrası korse', 'Rahat gecelik', 'Terlik',
      'Kimlik ve belgeler dosyası',
    ]),
    ShoppingSubcategory('Bakım', Icons.spa_outlined, [
      'Nemlendirici', 'Güneş koruyucu', 'Dudak kremi', 'El kremi', 'Saç tokası', 'Su matarası',
    ]),
  ]),
  ShoppingSegment('Aile Ürünleri', [
    ShoppingSubcategory('Market', Icons.shopping_basket_outlined, [
      'Süt', 'Yoğurt', 'Yumurta', 'Ekmek', 'Meyve', 'Sebze', 'Peynir', 'Zeytinyağı', 'Pirinç',
      'Mercimek', 'Makarna',
    ]),
    ShoppingSubcategory('Temizlik', Icons.cleaning_services_outlined, [
      'Bebek çamaşır deterjanı', 'Yumuşatıcı (hassas)', 'Bulaşık deterjanı', 'Yüzey temizleyici',
      'Çöp poşeti', 'Kâğıt havlu', 'Tuvalet kâğıdı',
    ]),
    ShoppingSubcategory('Ev güvenliği', Icons.shield_outlined, [
      'Priz koruyucu', 'Köşe koruyucu', 'Dolap kilidi', 'Merdiven kapısı', 'Kapı stoperi',
      'Duman dedektörü',
    ]),
    ShoppingSubcategory('Mutfak', Icons.kitchen_outlined, [
      'Saklama kabı', 'Buzdolabı poşeti', 'Streç film', 'Fırın kağıdı', 'Kesme tahtası',
    ]),
  ]),
];
