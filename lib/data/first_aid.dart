// İlk yardım kartları. Avrupa Resüsitasyon Konseyi (ERC 2021) ve Amerikan
// Kalp Derneği çocuk temel yaşam desteği önerileri ile Türkiye Ulusal Zehir
// Danışma Merkezi (114) bilgileri temel alınmıştır. Uygulamalı ilk yardım
// kursunun yerini tutmaz.

class FirstAidCard {
  final String id;
  final String title;
  final String when; // ne zaman 112
  final List<String> steps;
  final List<String> dont;
  final String? call; // önerilen numara
  const FirstAidCard(this.id, this.title, {required this.when, required this.steps, this.dont = const [], this.call = '112'});
}

const firstAidCards = <FirstAidCard>[
  FirstAidCard('choke_infant', 'Bebekte boğulma (1 yaş altı)',
    when: 'Bebek öksüremiyor, ağlayamıyor, nefes alamıyor ya da morarıyorsa hemen başla ve birine 112’yi aratın.',
    steps: [
      'Bebek öksürüyor ve ağlıyorsa öksürmesine izin ver, yanından ayrılma.',
      'Öksüremiyorsa: bebeği yüzüstü, başı gövdesinden aşağıda olacak şekilde ön kolunun üzerine yatır; çenesini elinle destekle.',
      'Kürek kemiklerinin arasına avucunun topuğuyla 5 kez sert vur.',
      'Cisim çıkmadıysa bebeği sırtüstü çevir; göğsün ortasına, meme başı hizasının hemen altına iki parmağınla 5 kez sert bastır.',
      'Cisim çıkana kadar 5 sırt vuruşu ve 5 göğüs basısını sırayla tekrarla.',
      'Bebek bilincini kaybederse 112’yi ara, telefonu hoparlöre al ve temel yaşam desteğine başla.',
    ],
    dont: ['Bebeği ayaklarından tutup sallama.', 'Görmediğin bir cismi parmağınla ağızdan çıkarmaya çalışma.']),
  FirstAidCard('choke_child', 'Çocukta boğulma (1 yaş üstü)',
    when: 'Çocuk konuşamıyor, öksüremiyor ya da nefes alamıyorsa hemen başla ve 112’yi aratın.',
    steps: [
      'Öksürebiliyorsa öksürmeye teşvik et.',
      'Öksüremiyorsa: çocuğu öne eğ, kürek kemiklerinin arasına avucunun topuğuyla 5 kez sert vur.',
      'Çıkmadıysa arkasına geç, kollarını beline dola; yumruğunu göbeğin biraz üstüne koy, diğer elinle kavrayıp içeri ve yukarı doğru 5 kez sert çek (Heimlich).',
      'Cisim çıkana kadar 5 sırt vuruşu ve 5 karın basısını sırayla tekrarla.',
      'Bilincini kaybederse 112’yi ara ve temel yaşam desteğine başla.',
      'Karın basısı uygulandıysa çocuğu mutlaka doktora göster.',
    ]),
  FirstAidCard('cpr', 'Temel yaşam desteği (bebek ve çocuk)',
    when: 'Çocuk tepki vermiyor ve normal nefes almıyorsa: 112’yi ara, telefonu hoparlöre al, görevlinin yönlendirmesini izle.',
    steps: [
      'Seslen ve omzuna dokun; tepki yoksa yardım iste ve 112’yi ara.',
      'Başını hafifçe geriye eğip çenesini kaldırarak hava yolunu aç (bebekte baş düz konumda kalsın); 10 saniye nefesini kontrol et.',
      'Normal nefes almıyorsa 5 kurtarıcı nefes ver: bebekte ağız ve burnunu birlikte, çocukta burnunu kapatıp ağzını kapsayarak.',
      'Göğüs basısına başla: göğsün alt yarısına, dakikada 100–120 hızla; bebekte iki parmakla yaklaşık 4 cm, çocukta tek ya da iki elle yaklaşık 5 cm.',
      '15 bası, 2 nefes şeklinde devam et. Eğitim almadıysan 112 görevlisinin söylediği gibi yalnızca bası yapabilirsin.',
      'Yardım gelene ya da çocuk normal nefes almaya başlayana kadar durma.',
    ]),
  FirstAidCard('seizure', 'Ateşli havale (nöbet)',
    when: 'Nöbet 5 dakikadan uzun sürerse, ilk kez oluyorsa, çocuk nöbetten sonra uyanmıyor ya da nefes almakta zorlanıyorsa 112’yi ara.',
    steps: [
      'Sakin kal ve saati not et.',
      'Çocuğu güvenli bir yere, yan yatır; başının altına yumuşak bir şey koy.',
      'Çevresindeki sert ve sivri eşyaları uzaklaştır, sıkı giysilerini gevşet.',
      'Nöbet bitince yan yatış pozisyonunda tut ve nefesini izle.',
      'İlk kez havale geçiren çocuğu nöbet bitse de doktora götür.',
    ],
    dont: ['Ağzına parmak, kaşık ya da başka bir şey sokma.', 'Hareketlerini zorla durdurmaya çalışma.', 'Soğuk suya sokma, alkollü bezle silme.']),
  FirstAidCard('poison', 'Zehirlenme (ilaç, temizlik ürünü, bitki)',
    when: 'Çocuk bilinçsizse, nöbet geçiriyorsa ya da nefes almakta zorlanıyorsa 112’yi ara. Diğer durumlarda hemen 114 Ulusal Zehir Danışma Merkezi’ni ara.',
    call: '114',
    steps: [
      'Çocuğun elinde ve ağzında kalanları al, ağzını suyla çalkala.',
      'Ürünün kutusunu ya da şişesini yanına al; adını, miktarını ve saatini söyleyebilmelisin.',
      '114’ü ara ve verilen talimatlara uy.',
      'Cilde ya da göze bulaştıysa 15 dakika bol akan suyla yıka.',
    ],
    dont: ['Kendiliğinden kusturmaya çalışma.', 'Süt, yoğurt ya da başka bir şey içirme (114 söylemedikçe).']),
  FirstAidCard('burn', 'Yanık ve haşlanma',
    when: 'Yanık bebeğin avucundan büyükse; yüz, el, ayak, eklem ya da genital bölgedeyse; kabarcıklıysa, beyaz ya da kömürleşmişse; elektrik veya kimyasal yanıksa acile git ya da 112’yi ara.',
    steps: [
      'Yanan bölgeyi hemen 20 dakika serin (buz gibi olmayan) akan suyun altında tut.',
      'Yapışmamışsa giysileri ve takıları çıkar; yapışan giysiyi çekme.',
      'Çocuğu üşütmemeye dikkat et.',
      'Yanığı temiz streç film ya da yapışmayan temiz bir bezle gevşekçe ört.',
    ],
    dont: ['Buz, diş macunu, yoğurt, yağ ya da salça sürme.', 'Kabarcıkları patlatma.']),
  FirstAidCard('head', 'Başını çarptı / düştü',
    when: 'Bilinç kaybı, nöbet, birden fazla kusma, aşırı uyku hâli, dengesizlik, kulak ya da burundan kan veya sıvı gelmesi varsa 112’yi ara. 1 yaşından küçük bebekte belirgin şişlik varsa doktora git.',
    steps: [
      'Çocuğu sakinleştir, çarpan bölgeye bir beze sarılı soğuk uygula.',
      'Sonraki 24 saat yakından izle; uyuyabilir ama birkaç saatte bir uyandığını kontrol et.',
      'Davranışında olağan dışı bir değişiklik olursa doktora başvur.',
    ]),
  FirstAidCard('nose', 'Burun kanaması',
    when: '20 dakikada durmuyorsa, çok fazlaysa ya da ciddi bir darbeden sonra olduysa acile git.',
    steps: [
      'Çocuğu oturt ve başını hafifçe öne eğ.',
      'Burnun yumuşak kısmını iki parmakla 10 dakika aralıksız sıkıştır; ağzından nefes alsın.',
      'Durunca birkaç saat burnunu sümkürmemesini söyle.',
    ],
    dont: ['Başını geriye yatırma (kan yutulur).', 'Burna pamuk tıkama.']),
  FirstAidCard('allergy', 'Ciddi alerjik tepki (anafilaksi)',
    when: 'Nefes darlığı, hırıltı, dudak ya da dil şişmesi, ses kısıklığı, yaygın döküntüyle birlikte halsizlik veya bayılma varsa hemen 112’yi ara.',
    steps: [
      'Doktorun yazdığı adrenalin oto-enjektörü varsa hemen uyluğun dış yanına uygula.',
      'Nefes almakta zorlanıyorsa oturt; halsizse sırtüstü yatırıp bacaklarını kaldır.',
      'Düzelmezse 5 dakika sonra ikinci enjektör (varsa) uygulanabilir.',
      'Düzelse bile mutlaka acil serviste değerlendirilmeli.',
    ]),
  FirstAidCard('dehydration', 'İshal, kusma ve sıvı kaybı',
    when: '6 aydan küçük bebekte tekrarlayan kusma ya da ishal; 6–8 saattir ıslak bez olmaması; çökük bıngıldak, gözyaşsız ağlama, aşırı uyku hâli; kanlı ishal ya da yeşil kusma varsa doktora ya da acile git.',
    call: null,
    steps: [
      'Emzirmeye ya da mamaya devam et; daha sık ve az az ver.',
      'Doktorun önerdiği ağızdan sıvı tedavisi (ORS) çözeltisini küçük yudumlarla ver.',
      'Islak bez sayısını ve ateşi takip et.',
    ],
    dont: ['Meyve suyu, gazlı içecek ya da şekerli içecek verme.']),
];

const firstAidIntro =
    'Acil bir durumda önce kendi güvenliğini sağla, sonra yardım çağır. Türkiye’de acil yardım: 112, zehirlenme danışma: 114. '
    'Bu kartlar hatırlatma içindir; bebek ve çocuk ilk yardım kursuna katılmanı öneririz.';
