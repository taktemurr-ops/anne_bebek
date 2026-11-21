/// Bebek ismi önerileri. Anlamlar yaygın kullanılan sözlük anlamlarıdır;
/// köken bilgisi genel bir yönlendirmedir.
class BabyName {
  final String name;
  /// 'K' kız, 'E' erkek, 'U' her ikisi
  final String gender;
  final String meaning;
  final String origin;
  const BabyName(this.name, this.gender, this.meaning, this.origin);
}

const babyNames = <BabyName>[
  // Kız
  BabyName('Ada', 'K', 'Ada; ilk kadının adı (Havva) ile de ilişkilendirilir', 'Türkçe'),
  BabyName('Asel', 'K', 'Bal; tatlı', 'Arapça'),
  BabyName('Asya', 'K', 'Asya kıtası; doğuş', 'Yunanca kökenli'),
  BabyName('Aybüke', 'K', 'Ay gibi güzel, bilge kadın', 'Türkçe'),
  BabyName('Ayça', 'K', 'Küçük ay, hilal', 'Türkçe'),
  BabyName('Aylin', 'K', 'Ay ışığı, ayın çevresindeki hale', 'Türkçe'),
  BabyName('Aysu', 'K', 'Ay gibi güzel ve su gibi duru', 'Türkçe'),
  BabyName('Azra', 'K', 'Bakire, el değmemiş; saf', 'Arapça'),
  BabyName('Begüm', 'K', 'Hanımefendi, prenses', 'Türkçe'),
  BabyName('Belinay', 'K', 'Ay gibi parlak', 'Türkçe'),
  BabyName('Beren', 'K', 'Güçlü, akıllı', 'Türkçe'),
  BabyName('Betül', 'K', 'Kendini Allah’a adamış, iffetli', 'Arapça'),
  BabyName('Beyza', 'K', 'Çok beyaz, ak', 'Arapça'),
  BabyName('Buse', 'K', 'Öpücük', 'Farsça'),
  BabyName('Ceren', 'K', 'Ceylan yavrusu', 'Türkçe'),
  BabyName('Cemre', 'K', 'Şubatta havaya, suya ve toprağa düştüğüne inanılan sıcaklık', 'Arapça'),
  BabyName('Damla', 'K', 'Su damlası', 'Türkçe'),
  BabyName('Defne', 'K', 'Defne ağacı; zafer simgesi', 'Yunanca'),
  BabyName('Derin', 'K', 'Derin, engin', 'Türkçe'),
  BabyName('Dila', 'K', 'Gönül, yürek', 'Farsça'),
  BabyName('Duru', 'K', 'Berrak, saf', 'Türkçe'),
  BabyName('Ece', 'K', 'Kraliçe, güzel kadın', 'Türkçe'),
  BabyName('Ecrin', 'K', 'Ödül, sevap', 'Arapça'),
  BabyName('Ela', 'K', 'Açık kahverengi, ela göz', 'Türkçe'),
  BabyName('Elif', 'K', 'Arap alfabesinin ilk harfi; ince, düzgün', 'Arapça'),
  BabyName('Elisa', 'K', 'Tanrı’ya adanmış', 'İbranice'),
  BabyName('Eylül', 'K', 'Yılın dokuzuncu ayı', 'Süryanice'),
  BabyName('Esila', 'K', 'Asil, soylu', 'Arapça'),
  BabyName('Feyza', 'K', 'Bolluk, bereket', 'Arapça'),
  BabyName('Gökçe', 'K', 'Göğe ait, mavi; güzel', 'Türkçe'),
  BabyName('Hira', 'K', 'Hira dağı; ilk vahyin geldiği mağara', 'Arapça'),
  BabyName('Irmak', 'K', 'Akarsu', 'Türkçe'),
  BabyName('İkra', 'K', 'Oku', 'Arapça'),
  BabyName('İpek', 'K', 'İpek kumaş; yumuşak', 'Türkçe'),
  BabyName('Lara', 'K', 'Koruyan; neşeli', 'Latince'),
  BabyName('Lina', 'K', 'Hurma ağacı; yumuşak', 'Arapça'),
  BabyName('Mira', 'K', 'Prenses, emir kızı', 'Farsça'),
  BabyName('Melis', 'K', 'Bal arısı', 'Yunanca'),
  BabyName('Merve', 'K', 'Mekke’deki tepelerden biri', 'Arapça'),
  BabyName('Meryem', 'K', 'Hz. İsa’nın annesi; sevilen', 'İbranice'),
  BabyName('Mina', 'K', 'Mavi mine; değerli taş', 'Farsça'),
  BabyName('Nehir', 'K', 'Akarsu, ırmak', 'Arapça'),
  BabyName('Nil', 'K', 'Nil nehri; mavi', 'Arapça'),
  BabyName('Nisa', 'K', 'Kadınlar', 'Arapça'),
  BabyName('Öykü', 'K', 'Hikâye', 'Türkçe'),
  BabyName('Pelin', 'K', 'Pelin otu', 'Türkçe'),
  BabyName('Rüya', 'K', 'Düş', 'Arapça'),
  BabyName('Selin', 'K', 'Akarsu, sel', 'Türkçe'),
  BabyName('Sena', 'K', 'Övgü, yüceltme', 'Arapça'),
  BabyName('Su', 'K', 'Su; duruluk', 'Türkçe'),
  BabyName('Tuana', 'K', 'Cennette bir ağaç', 'Arapça'),
  BabyName('Yağmur', 'K', 'Yağmur', 'Türkçe'),
  BabyName('Yaren', 'K', 'Dost, arkadaş', 'Farsça'),
  BabyName('Zehra', 'K', 'Parlak, aydın; Hz. Fatma’nın lakabı', 'Arapça'),
  BabyName('Zeynep', 'K', 'Güzel kokulu ağaç; süs', 'Arapça'),
  BabyName('Zümra', 'K', 'Topluluk, bölük', 'Arapça'),
  BabyName('Hiranur', 'K', 'Hira’nın nuru', 'Arapça'),
  BabyName('Eslem', 'K', 'Daha esenlikli, en sağlam', 'Arapça'),
  BabyName('Alya', 'K', 'Yüksek, yüce', 'Arapça'),
  BabyName('Nisan', 'K', 'Yılın dördüncü ayı', 'Süryanice'),
  // Erkek
  BabyName('Alp', 'E', 'Yiğit, kahraman', 'Türkçe'),
  BabyName('Alparslan', 'E', 'Aslan yürekli yiğit', 'Türkçe'),
  BabyName('Aras', 'E', 'Aras nehri', 'Türkçe'),
  BabyName('Arda', 'E', 'Meriç’in kolu olan ırmak', 'Türkçe'),
  BabyName('Atlas', 'E', 'Atlas dağları; ipek kumaş', 'Yunanca'),
  BabyName('Ayaz', 'E', 'Kuru soğuk; açık hava', 'Türkçe'),
  BabyName('Aybars', 'E', 'Ay gibi parlak, pars gibi güçlü', 'Türkçe'),
  BabyName('Baran', 'E', 'Yağmur', 'Farsça'),
  BabyName('Barış', 'E', 'Huzur, sulh', 'Türkçe'),
  BabyName('Batuhan', 'E', 'Güçlü, sağlam han', 'Türkçe'),
  BabyName('Berat', 'E', 'Beraat; temize çıkma', 'Arapça'),
  BabyName('Berk', 'E', 'Sağlam, güçlü', 'Türkçe'),
  BabyName('Burak', 'E', 'Miraç gecesindeki binek; şimşek', 'Arapça'),
  BabyName('Can', 'E', 'Ruh, hayat', 'Farsça'),
  BabyName('Çınar', 'E', 'Çınar ağacı', 'Türkçe'),
  BabyName('Demir', 'E', 'Demir; sağlam', 'Türkçe'),
  BabyName('Doruk', 'E', 'Zirve', 'Türkçe'),
  BabyName('Ege', 'E', 'Ege denizi; yaşlı, olgun', 'Türkçe'),
  BabyName('Efe', 'E', 'Ağabey; yiğit', 'Türkçe'),
  BabyName('Emir', 'E', 'Buyruk; bey, yönetici', 'Arapça'),
  BabyName('Emirhan', 'E', 'Buyruk veren han', 'Arapça-Türkçe'),
  BabyName('Eren', 'E', 'Ermiş, olgun kişi', 'Türkçe'),
  BabyName('Eymen', 'E', 'Uğurlu, bereketli', 'Arapça'),
  BabyName('Furkan', 'E', 'Doğruyu yanlıştan ayıran; Kur’an', 'Arapça'),
  BabyName('Göktuğ', 'E', 'Göğün sancağı', 'Türkçe'),
  BabyName('Hamza', 'E', 'Keskin, güçlü; aslan', 'Arapça'),
  BabyName('Harun', 'E', 'Bir peygamber adı; dağ', 'İbranice'),
  BabyName('Kaan', 'E', 'Hükümdar', 'Türkçe'),
  BabyName('Kerem', 'E', 'Cömertlik, iyilik', 'Arapça'),
  BabyName('Kuzey', 'E', 'Kuzey yönü', 'Türkçe'),
  BabyName('Mert', 'E', 'Yiğit, sözünün eri', 'Farsça'),
  BabyName('Mete', 'E', 'Hun hükümdarı Mete Han', 'Türkçe'),
  BabyName('Miraç', 'E', 'Yükseliş; merdiven', 'Arapça'),
  BabyName('Mustafa', 'E', 'Seçilmiş', 'Arapça'),
  BabyName('Ömer', 'E', 'Yaşayan, uzun ömürlü', 'Arapça'),
  BabyName('Ozan', 'E', 'Şair, halk ozanı', 'Türkçe'),
  BabyName('Poyraz', 'E', 'Kuzeydoğu rüzgârı', 'Yunanca'),
  BabyName('Rüzgar', 'E', 'Rüzgâr', 'Farsça'),
  BabyName('Selim', 'E', 'Kusursuz, esen', 'Arapça'),
  BabyName('Sarp', 'E', 'Zor geçilen; dik', 'Türkçe'),
  BabyName('Taha', 'E', 'Kur’an’da bir sure adı', 'Arapça'),
  BabyName('Tuna', 'E', 'Tuna nehri', 'Türkçe'),
  BabyName('Tunç', 'E', 'Bronz; sağlam', 'Türkçe'),
  BabyName('Umut', 'E', 'Ümit, beklenti', 'Türkçe'),
  BabyName('Yağız', 'E', 'Yağız; esmer, yiğit', 'Türkçe'),
  BabyName('Yiğit', 'E', 'Cesur, kahraman', 'Türkçe'),
  BabyName('Yusuf', 'E', 'Bir peygamber adı; artan', 'İbranice'),
  BabyName('Yunus', 'E', 'Bir peygamber adı; güvercin', 'İbranice'),
  BabyName('Yamaç', 'E', 'Dağın eteği', 'Türkçe'),
  BabyName('Mirza', 'E', 'Bey oğlu, soylu', 'Farsça'),
  BabyName('Ali', 'E', 'Yüce, yüksek', 'Arapça'),
  BabyName('Ahmet', 'E', 'Çok övülmüş', 'Arapça'),
  BabyName('Mehmet', 'E', 'Övülmeye değer', 'Arapça'),
  BabyName('Asaf', 'E', 'Bilgin, akıllı vezir', 'İbranice'),
  BabyName('Alaz', 'E', 'Alev', 'Türkçe'),
  BabyName('Toprak', 'E', 'Toprak; bereket', 'Türkçe'),
  BabyName('Kayra', 'E', 'İyilik, lütuf', 'Türkçe'),
  // Her ikisi
  BabyName('Deniz', 'U', 'Deniz', 'Türkçe'),
  BabyName('Derya', 'U', 'Deniz, engin', 'Farsça'),
  BabyName('Ekin', 'U', 'Ekin, tahıl', 'Türkçe'),
  BabyName('Evren', 'U', 'Kâinat', 'Türkçe'),
  BabyName('Ilgın', 'U', 'Ilgın ağacı', 'Türkçe'),
  BabyName('Nur', 'U', 'Işık, aydınlık', 'Arapça'),
  BabyName('Özgür', 'U', 'Hür, bağımsız', 'Türkçe'),
  BabyName('Toygar', 'U', 'Doğan, yükselen', 'Türkçe'),
  BabyName('Umay', 'U', 'Eski Türklerde çocukları koruyan iyilik tanrıçası', 'Türkçe'),
  BabyName('Yüce', 'U', 'Yüksek, ulu', 'Türkçe'),
  BabyName('Bora', 'U', 'Fırtına', 'Türkçe'),
  BabyName('Güneş', 'U', 'Güneş', 'Türkçe'),
];

String _fold(String s) {
  const from = 'ÇçĞğİıÖöŞşÜüÂâÎîÛû';
  const to = 'ccggiioossuuaaiiuu';
  final b = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch.toLowerCase());
  }
  return b.toString();
}

/// [gender]: null hepsi; 'K'/'E' seçilince o cinsiyet ve 'U' isimleri döner.
List<BabyName> searchBabyNames(String query, {String? gender, String? initial}) {
  final q = _fold(query.trim());
  final ini = initial == null ? null : _fold(initial);
  final out = babyNames.where((n) {
    if (gender != null && n.gender != gender && n.gender != 'U') return false;
    if (ini != null && !_fold(n.name).startsWith(ini)) return false;
    if (q.isEmpty) return true;
    return _fold(n.name).contains(q) || _fold(n.meaning).contains(q);
  }).toList();
  out.sort((a, b) => _fold(a.name).compareTo(_fold(b.name)));
  return out;
}
