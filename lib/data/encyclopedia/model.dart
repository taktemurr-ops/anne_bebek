/// A'dan Z'ye ansiklopedi: bebek, çocuk, gebelik, doğum, lohusalık,
/// kadın sağlığı, ruh sağlığı, güvenlik ve aile yaşamı.
///
/// İçerik genel bilgilendirme amaçlıdır; Sağlık Bakanlığı ve Dünya Sağlık
/// Örgütü'nün yerleşik önerileriyle uyumlu, ihtiyatlı bir dille yazılmıştır.
/// Tanı veya tedavi önerisi değildir. Uzman incelemesinden geçirilmelidir.
class EncyclopediaTopic {
  final String id;
  final String title;
  final String category;
  final String summary;

  /// Bilmen gerekenler.
  final List<String> know;

  /// Ne yapabilirsin.
  final List<String> todo;

  /// Ne zaman doktora / acile.
  final List<String> doctor;

  /// Arama için ek anahtar kelimeler.
  final List<String> tags;

  const EncyclopediaTopic(this.id, this.title, this.category, this.summary,
      this.know, this.todo, this.doctor, [this.tags = const []]);
}

/// Kategoriler, gösterim sırasıyla (ad, renkli simge).
const encyclopediaCategories = <(String, String)>[
  ('Bebek (0–12 ay)', '👶'),
  ('Çocuk (1–6 yaş)', '🧒'),
  ('Gebelik', '🤰'),
  ('Doğum', '🏥'),
  ('Lohusalık ve Emzirme', '🤱'),
  ('Kadın Sağlığı', '🌸'),
  ('Ruh Sağlığı', '💗'),
  ('Beslenme', '🥗'),
  ('Güvenlik ve İlk Yardım', '🩹'),
  ('Aile ve Yaşam', '🏡'),
];
