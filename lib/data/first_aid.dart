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
  FirstAidCard('battery', 'Düğme pil veya mıknatıs yuttu',
    when: 'Düğme (para) pil ya da birden fazla mıknatıs yuttuğundan şüpheleniyorsan, belirti olmasa bile hemen acile git ya da 112’yi ara. Pil yemek borusunda 2 saatte ciddi yanığa yol açabilir.',
    steps: [
      'Çocuğu hemen en yakın acil servise götür; pilin paketini ya da benzerini yanına al.',
      '12 aydan büyükse ve pil yuttuğu 12 saatten kısa süre önceyse, yolda doktorun ya da 112’nin önerisiyle 10 dakikada bir 2 tatlı kaşığı bal verilebilir (en fazla 6 kez).',
      'Yuttuğu saati not et.',
      'Kumandalar, tartılar, oyuncaklar ve doğum günü kartlarındaki pil kapaklarının vidalı olduğundan emin ol.',
    ],
    dont: ['Kusturmaya çalışma.', '12 aydan küçük bebeğe bal verme.', 'Belirti yok diye beklemeye geçme.']),
  FirstAidCard('drowning', 'Suda boğulma',
    when: 'Sudan çıkarılan çocuk tepki vermiyor ya da normal nefes almıyorsa hemen 112’yi ara ve temel yaşam desteğine başla.',
    steps: [
      'Kendini tehlikeye atmadan çocuğu sudan çıkar.',
      'Tepki vermiyor ve normal nefes almıyorsa: 5 kurtarıcı nefesle başla, ardından temel yaşam desteğini sürdür.',
      'Nefes alıyorsa yan yatır, ıslak giysilerini çıkarıp ört ve yanından ayrılma.',
      'Kendine gelse ve iyi görünse bile çocuğu mutlaka doktora götür; saatler sonra nefes sorunu gelişebilir.',
    ],
    dont: ['Midesine bastırıp su çıkarmaya çalışma.', 'Küçük çocuğu küvette ya da havuz başında birkaç saniye bile yalnız bırakma.']),
  FirstAidCard('bleeding', 'Kesik ve kanama',
    when: 'Kanama 10 dakikalık sürekli baskıyla durmuyorsa, fışkırıyorsa, yara derin, geniş ya da yüzdeyse 112’yi ara ya da acile git.',
    steps: [
      'Ellerini yıka ya da eldiven giy.',
      'Temiz bir bez ya da gazlı bezle yaranın üzerine 10 dakika kesintisiz bastır.',
      'Bez kanla ıslanırsa kaldırma; üstüne yenisini koyup baskıyı sürdür.',
      'Kanama durunca küçük yarayı akan suyla yıka ve temiz bir bantla kapat.',
      'Hayvan ısırığı, paslı ya da kirli cisimle yaralanmada aynı gün sağlık kuruluşuna başvur (tetanoz ve enfeksiyon değerlendirmesi).',
    ],
    dont: ['Yaraya pamuk, tütün, kahve gibi maddeler koyma.', 'Saplanmış cismi çıkarmaya çalışma; çevresine baskı uygulayarak acile git.']),
  FirstAidCard('eye', 'Göze kimyasal veya yabancı cisim kaçması',
    when: 'Göze temizlik ürünü, kireç çözücü gibi kimyasal kaçtıysa yıkamaya hemen başla ve 112 ya da 114’ü ara. Göze saplanmış cisim, görme kaybı ya da şiddetli ağrıda acile git.',
    steps: [
      'Kimyasalda: gözü hemen ılık akan suyla en az 15 dakika, göz kapaklarını açık tutarak yıka.',
      'Suyu burun tarafından dış kenara doğru akıt ki diğer göze geçmesin.',
      'Ürünün kutusunu yanına al.',
      'Toz ya da kirpik gibi küçük cisimde: göz kırptır ya da temiz suyla yıka.',
    ],
    dont: ['Gözü ovuşturma.', 'Saplanmış cismi çıkarmaya çalışma.', 'Doktor önermeden göz damlası kullanma.'],
    call: '114'),
  FirstAidCard('fracture', 'Kırık, çıkık ve burkulma şüphesi',
    when: 'Kemik dışarı çıkmışsa, uzuv şekil bozukluğu varsa, boyun ya da sırt yaralanmasından şüpheleniyorsan 112’yi ara; diğer durumlarda acile götür.',
    steps: [
      'Yaralı bölgeyi hareket ettirme; bulduğun pozisyonda destekle.',
      'Kol yaralanmasında kolu karnın önünde bir eşarpla askıya al.',
      'Şişlik için ince bir beze sarılı soğuk uygulamayı 15–20 dakika yap.',
      'Boyun ya da sırt yaralanması şüphesinde çocuğu kımıldatma; başını düz tut ve 112’yi bekle.',
      'Ağrı kesici ya da yiyecek-içecek vermeden önce doktora danış; ameliyat gerekebilir.',
    ],
    dont: ['Kırık kemiği yerine oturtmaya çalışma.', 'Buzu doğrudan cilde koyma.']),
  FirstAidCard('electric', 'Elektrik çarpması',
    when: 'Bilinç kaybı, nefes almama, yanık ya da çarpıntı varsa hemen 112. Çocuk iyi görünse bile her elektrik çarpmasından sonra doktora başvur.',
    steps: [
      'Dokunmadan önce sigortayı kapat ya da fişi çek.',
      'Akım kesilemiyorsa kuru tahta gibi iletken olmayan bir cisimle çocuğu kaynaktan uzaklaştır.',
      'Tepki vermiyor ve normal nefes almıyorsa temel yaşam desteğine başla.',
      'Yanık varsa 20 dakika serin akan suyla soğut ve temiz, yapışmayan bir örtüyle kapat.',
    ],
    dont: ['Akım kesilmeden çocuğa çıplak elle dokunma.', 'Islak zeminde müdahale etme.']),
  FirstAidCard('tooth', 'Diş kırılması veya yerinden çıkması',
    when: 'Ağızda durmayan kanama, çene yaralanması ya da kafa travması belirtisi varsa acile git. Kalıcı diş çıktıysa 30–60 dakika içinde diş hekimine ulaş.',
    steps: [
      'Ağızdaki kanamaya temiz gazlı bezle 10 dakika bastır.',
      'Çıkan dişi kökünden değil, taç (beyaz) kısmından tut.',
      'Kalıcı diş kirliyse sütle kısa süre çalkala; fırçalama, kurulama.',
      'Dişi süt dolu küçük bir kapta taşıyıp hemen diş hekimine git.',
      'Süt dişi çıktıysa yerine takmaya çalışma; yine de diş hekimine göster.',
    ],
    dont: ['Dişi kuru mendile sarma.', 'Kökü ovma ya da sabunla yıkama.'],
    call: null),
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
