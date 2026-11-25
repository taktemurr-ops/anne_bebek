// Doğum planı: tercihler ve serbest notlar. Ekiple paylaşılacak metin üretir.

class BirthPlanSection {
  final String id;
  final String title;
  final List<String> options;
  final bool freeText;
  const BirthPlanSection(this.id, this.title, {this.options = const [], this.freeText = false});
}

const birthPlanSections = <BirthPlanSection>[
  BirthPlanSection('team', 'Doğum yeri, doktor ve ebe', freeText: true),
  BirthPlanSection('companion', 'Yanımda olmasını istediğim kişi(ler)', freeText: true),
  BirthPlanSection('room', 'Ortam', options: [
    'Loş ışık', 'Müzik dinlemek', 'Sessiz ortam', 'Kendi kıyafetlerim', 'Fotoğraf / video çekilmesi', 'Fotoğraf çekilmemesi']),
  BirthPlanSection('labour', 'Doğum eylemi sırasında', options: [
    'Hareket etmek ve pozisyon değiştirmek', 'Su içmek ve hafif yiyecekler', 'Doğum topu kullanmak',
    'Uygunsa sürekli değil aralıklı izlem', 'Duş ya da ılık su']),
  BirthPlanSection('pain', 'Ağrı yönetimi', options: [
    'Nefes ve gevşeme teknikleri', 'Masaj ve sıcak uygulama', 'Epidural istiyorum',
    'Epidurala karar vermeden önce beklemek istiyorum', 'İlaçsız doğumu denemek istiyorum']),
  BirthPlanSection('birth', 'Doğum anı', options: [
    'Ikınmaya kendi hissimle başlamak', 'Mümkünse epizyotomiden kaçınılması', 'Kordonu eşimin kesmesi',
    'Doğum pozisyonunu kendim seçmek']),
  BirthPlanSection('baby', 'Bebek doğunca', options: [
    'Hemen ten tene temas', 'Kordon klempinin geciktirilmesi', 'İlk saat içinde emzirme',
    'Bebeğin muayenesinin yanımda yapılması', 'K vitamini iğnesi', 'Hepatit B aşısı']),
  BirthPlanSection('feeding', 'Beslenme', options: [
    'Yalnızca anne sütü', 'Gerekirse mama verilebilir', 'Sormadan biberon ya da emzik verilmemesi',
    'Emzirme desteği istiyorum']),
  BirthPlanSection('csection', 'Sezaryen gerekirse', options: [
    'Eşimin yanımda olması', 'Bebeği hemen görmek', 'Ameliyathanede ten tene temas',
    'Mümkünse bölgesel (spinal/epidural) anestezi']),
  BirthPlanSection('notes', 'Diğer notlar (alerjiler, kan grubu, kültürel istekler)', freeText: true),
];

class BirthPlan {
  final Map<String, Set<String>> choices;
  final Map<String, String> texts;
  const BirthPlan({this.choices = const {}, this.texts = const {}});

  Map<String, dynamic> toJson() => {
        'choices': choices.map((k, v) => MapEntry(k, v.toList())),
        'texts': texts,
      };

  static BirthPlan fromJson(Map<String, dynamic> raw) {
    final choices = <String, Set<String>>{};
    final texts = <String, String>{};
    final c = raw['choices'];
    final tx = raw['texts'];
    for (final s in birthPlanSections) {
      if (c is Map && c[s.id] is List) {
        final set = (c[s.id] as List).whereType<String>().where(s.options.contains).toSet();
        if (set.isNotEmpty) choices[s.id] = set;
      }
      if (tx is Map && tx[s.id] is String && (tx[s.id] as String).trim().isNotEmpty) texts[s.id] = tx[s.id] as String;
    }
    return BirthPlan(choices: choices, texts: texts);
  }

  bool get isEmpty => choices.isEmpty && texts.isEmpty;

  /// Paylaşım metni. [tr] seçili dile çevirir.
  String render(String Function(String) tr, {String name = ''}) {
    final b = StringBuffer()..writeln(tr('DOĞUM PLANIM'));
    if (name.trim().isNotEmpty) b.writeln(name.trim());
    b.writeln();
    for (final s in birthPlanSections) {
      final sel = choices[s.id];
      final txt = texts[s.id];
      if ((sel == null || sel.isEmpty) && (txt == null || txt.isEmpty)) continue;
      b.writeln(tr(s.title));
      for (final o in s.options.where((o) => sel?.contains(o) ?? false)) {
        b.writeln('• ${tr(o)}');
      }
      if (txt != null && txt.isNotEmpty) b.writeln(txt.trim());
      b.writeln();
    }
    b.writeln(tr('Bu plan tercihlerimi gösterir. Benim ya da bebeğimin güvenliği için farklı bir karar gerekirse ekibimin bunu bana açıklamasını rica ederim.'));
    return b.toString();
  }
}
