import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.dirname(__import__('os').path.abspath(__file__))))
from recipes_dsl import R, dump
SA='Salatalar'
def sal(id,t,ing,steps,tip):
    return R(id,t,SA,4,15,0 if 'haşla' not in ' '.join(steps) and 'közle' not in ' '.join(steps) else 20,'Kolay',None,ing,steps,[tip],'Soğuk servis edin.','Sossuz hâli buzdolabında 1 gün saklanır.')
rs=[
sal('p39a16_025','Roka ve armut salatası',['1 demet roka','2 armut','Yarım su bardağı ceviz','80 g beyaz peynir veya keçi peyniri','3 yemek kaşığı zeytinyağı','1 yemek kaşığı bal','1 yemek kaşığı balzamik sirke','Tuz'],
 ['Rokayı yıkayıp kurulayın.','Armutları ince dilimleyin.','Cevizi kuru tavada 2 dakika kavurun.','Zeytinyağı, bal, sirke ve tuzu çırpın.','Roka, armut, ceviz ve ufalanmış peyniri sosla harmanlayın.'],'Armudu son anda dilimleyin; kararmaz.'),
sal('p39a16_026','Pancar ve portakal salatası',['3 haşlanmış pancar','2 portakal','1 küçük kırmızı soğan','Birkaç dal nane','3 yemek kaşığı zeytinyağı','1 yemek kaşığı nar ekşisi','Tuz'],
 ['Pancarı çiğse kabuğuyla 40 dakika haşlayıp soyun; dilimleyin.','Portakalları kabuğundan ve beyaz zarından ayırıp dilimleyin.','Soğanı ince halka doğrayın.','Zeytinyağı, nar ekşisi ve tuzu çırpın.','Tabağa dizip sosu ve naneyi ekleyin.'],'Pancar suyu ellerinizi boyar; eldiven kullanın.'),
sal('p39a16_027','Bulgur ve nar salatası',['1 su bardağı ince bulgur','1 su bardağı sıcak su','1 nar','4 dal taze soğan','Yarım demet maydanoz ve nane','2 yemek kaşığı nar ekşisi','3 yemek kaşığı zeytinyağı','1 tatlı kaşığı tuz, pul biber'],
 ['Bulguru sıcak suyla ıslatıp üzeri kapalı 15 dakika şişirin.','Narı taneleyin.','Yeşillikleri ve taze soğanı ince doğrayın.','Bulguru nar ekşisi, zeytinyağı, tuz ve pul biberle yoğurun.','Yeşillik ve nar tanelerini ekleyip karıştırın.'],'Bulgur soğuyunca yeşillikleri ekleyin; solmaz.'),
sal('p39a16_029','Nohut ve salatalık salatası',['2 su bardağı haşlanmış nohut','2 salatalık','1 kırmızı biber','Yarım kırmızı soğan','Yarım demet maydanoz','3 yemek kaşığı zeytinyağı','1 limon suyu','1 tatlı kaşığı kimyon, tuz'],
 ['Nohutları süzün.','Salatalık ve biberi küp doğrayın.','Soğanı ince kıyın.','Zeytinyağı, limon, kimyon ve tuzla sos hazırlayın.','Hepsini harmanlayıp 10 dakika dinlendirin.'],'Kimyon nohudun sindirimini kolaylaştırır.'),
sal('p39a16_030','Yeşil mercimekli köz biber salatası',['1 su bardağı yeşil mercimek','3 köz kırmızı biber','Yarım demet maydanoz','2 dal taze soğan','2 yemek kaşığı nar ekşisi','3 yemek kaşığı zeytinyağı','Tuz, kimyon'],
 ['Mercimeği 20 dakika diri kalacak şekilde haşlayıp süzün.','Köz biberlerin kabuğunu soyup şerit doğrayın.','Yeşillikleri kıyın.','Sos malzemelerini çırpın.','Hepsini karıştırıp servis edin.'],'Biberleri sıcakken poşete koyarsanız kabuğu kolay soyulur.'),
sal('p39a16_031','Semizotu ve çilek salatası',['1 demet semizotu','1 su bardağı çilek','Yarım su bardağı lor','2 yemek kaşığı ceviz','2 yemek kaşığı zeytinyağı','1 yemek kaşığı limon suyu','1 tatlı kaşığı bal','Tuz'],
 ['Semizotunun kalın saplarını ayıklayıp yıkayın.','Çilekleri dörde bölün.','Zeytinyağı, limon, bal ve tuzu çırpın.','Semizotu ve çileği sosla harmanlayın.','Lor ve cevizi üzerine serpin.'],'Semizotunu iyice kurulayın; sos tutunur.'),
sal('p39a16_033','Beyaz fasulye ve dereotu salatası',['2 su bardağı haşlanmış kuru fasulye','1 kırmızı soğan','Yarım demet dereotu','1 domates','3 yemek kaşığı zeytinyağı','2 yemek kaşığı limon suyu','1 haşlanmış yumurta','Tuz, sumak'],
 ['Fasulyeyi süzün.','Soğanı piyazlık doğrayıp sumak ve tuzla ovun.','Domates ve dereotunu doğrayın.','Zeytinyağı ve limonla sos hazırlayıp malzemeleri karıştırın.','Üzerine dilimlenmiş yumurta koyun.'],'Sumakla ovulan soğanın acılığı azalır.'),
sal('p39a16_035','Mor lahana ve elma salatası',['Yarım küçük mor lahana','1 yeşil elma','1 havuç','3 yemek kaşığı yoğurt','1 yemek kaşığı zeytinyağı','1 yemek kaşığı limon suyu','Tuz','2 yemek kaşığı ceviz'],
 ['Lahanayı çok ince doğrayıp tuzla ovun, 10 dakika bekletip suyunu sıkın.','Elma ve havucu jülyen doğrayın.','Yoğurt, zeytinyağı ve limonu çırpın.','Hepsini harmanlayın.','Cevizle süsleyin.'],'Tuzla ovmak lahanayı yumuşatır.'),
sal('p39a16_036','Brokoli ve ceviz salatası',['1 brokoli','Yarım su bardağı ceviz','2 yemek kaşığı kuru üzüm','1 küçük kırmızı soğan','3 yemek kaşığı yoğurt','1 yemek kaşığı zeytinyağı','1 yemek kaşığı limon suyu','Tuz'],
 ['Brokoliyi küçük çiçeklere ayırıp 3 dakika haşlayın ve soğuk suya alın.','Soğanı ince doğrayın.','Yoğurt, zeytinyağı, limon ve tuzla sos hazırlayın.','Brokoli, üzüm ve soğanı sosla karıştırın.','Cevizi ekleyip servis edin.'],'Soğuk suya almak brokolinin rengini korur.'),
]
PI='Pilavlar'
def pil(id,t,ing,steps,tip):
    return R(id,t,PI,4,15,25,'Kolay',None,ing,steps,[tip],'Ana yemeğin yanında sıcak servis edin.','Buzdolabında 3 gün saklanır.')
rs+=[
pil('p39a16_049','Mantarlı karabuğday pilavı',['1,5 su bardağı karabuğday','250 g mantar','1 soğan','2 yemek kaşığı zeytinyağı','1 yemek kaşığı tereyağı','2,5 su bardağı sıcak su','1 tatlı kaşığı tuz, karabiber'],
 ['Karabuğdayı yıkayıp süzün.','Soğanı ve dilimlenmiş mantarı yağda suyunu çekene kadar 8 dakika soteleyin.','Karabuğdayı ekleyip 2 dakika kavurun.','Sıcak su ve tuzu ekleyip kısık ateşte 15 dakika pişirin.','Tereyağını ekleyip 10 dakika demlendirin.'],'Karabuğday glutensizdir.'),
pil('p39a16_050','Nohutlu esmer pirinç pilavı',['1,5 su bardağı esmer pirinç','1 su bardağı haşlanmış nohut','2 yemek kaşığı tereyağı','3 su bardağı sıcak su','1 tatlı kaşığı tuz'],
 ['Esmer pirinci 1 saat ılık suda bekletip süzün.','Tereyağında pirinci 3 dakika kavurun.','Nohut, sıcak su ve tuzu ekleyin.','Kaynayınca kısık ateşte kapağı kapalı 35 dakika pişirin.','10 dakika demlendirin.'],'Esmer pirinç beyazdan uzun pişer; ıslatmak süreyi kısaltır.'),
pil('p39a16_051','Biberli bulgur pilavı',['1,5 su bardağı pilavlık bulgur','2 sivri biber, 1 kırmızı biber','1 soğan','1 yemek kaşığı biber salçası','2 yemek kaşığı zeytinyağı','3 su bardağı sıcak su','1 tatlı kaşığı tuz'],
 ['Soğan ve biberleri yağda 5 dakika kavurun.','Salçayı ekleyip 1 dakika çevirin.','Bulguru ekleyip 2 dakika kavurun.','Su ve tuzu ekleyip 15 dakika pişirin.','10 dakika demlendirin.'],'Bulguru yıkamayın; pilav lapa olur.'),
pil('p39a16_052','Bezelyeli pirinç pilavı',['1,5 su bardağı baldo pirinç','1 su bardağı bezelye','2 yemek kaşığı tereyağı','1 yemek kaşığı sıvı yağ','2,5 su bardağı sıcak su','1 tatlı kaşığı tuz'],
 ['Pirinci 20 dakika sıcak tuzlu suda bekletip nişastası gidene kadar yıkayın.','Yağlarda pirinci 4 dakika kavurun.','Bezelye, su ve tuzu ekleyin.','Kısık ateşte 15 dakika pişirin.','15 dakika demlendirin.'],'Pirinci iyice yıkamak tane tane pilav verir.'),
pil('p39a16_053','Domatesli kinoa pilavı',['1,5 su bardağı kinoa','2 domates (rendelenmiş)','1 soğan','2 yemek kaşığı zeytinyağı','2 su bardağı sıcak su','Tuz, kekik'],
 ['Kinoayı ince süzgeçte iyice yıkayın.','Soğanı yağda kavurun, domatesi ekleyip 5 dakika pişirin.','Kinoayı ekleyip 1 dakika çevirin.','Su, tuz ve kekiği ekleyip 15 dakika pişirin.','5 dakika demlendirip çatalla kabartın.'],'Kinoa piştiğinde taneler etrafında beyaz halka görünür.'),
pil('p39a16_054','Havuçlu arpa şehriye pilavı',['1,5 su bardağı arpa şehriye','1 havuç (rendelenmiş)','2 yemek kaşığı tereyağı','2,5 su bardağı sıcak tavuk suyu veya su','1 tatlı kaşığı tuz'],
 ['Tereyağında şehriyeyi pembeleşene kadar 4 dakika kavurun.','Havucu ekleyip 2 dakika çevirin.','Sıcak su ve tuzu ekleyin.','Kısık ateşte 12 dakika pişirin.','10 dakika demlendirin.'],'Şehriyeyi kavururken sürekli karıştırın; çabuk yanar.'),
pil('p39a16_055','Ispanaklı bulgur pilavı',['1,5 su bardağı bulgur','300 g ıspanak','1 soğan','1 yemek kaşığı domates salçası','2 yemek kaşığı zeytinyağı','2,5 su bardağı sıcak su','Tuz, pul biber'],
 ['Soğanı yağda kavurup salçayı ekleyin.','Bulguru ekleyip 2 dakika çevirin.','Su ve tuzu ekleyip 10 dakika pişirin.','Doğranmış ıspanağı üstüne yayıp kapağı kapatın, 5 dakika daha pişirin.','Karıştırıp 10 dakika demlendirin.'],'Ispanak son 5 dakikada eklenince rengini korur.'),
pil('p39a16_057','Patlıcanlı bulgur pilavı',['1,5 su bardağı bulgur','2 patlıcan','1 soğan','2 domates','3 yemek kaşığı zeytinyağı','2,5 su bardağı sıcak su','Tuz, karabiber'],
 ['Patlıcanları küp doğrayıp tuzlu suda 15 dakika bekletin, kurulayın.','Patlıcanları 2 yemek kaşığı yağda kızartıp alın.','Kalan yağda soğan ve domatesi pişirin, bulguru ekleyin.','Su ve tuzu ekleyip 12 dakika pişirin, patlıcanı ekleyin.','10 dakika demlendirin.'],'Patlıcanı tuzlu suda bekletmek acılığı ve yağ çekmesini azaltır.'),
pil('p39a16_058','Mercimekli karabuğday pilavı',['1 su bardağı karabuğday','Yarım su bardağı yeşil mercimek','1 soğan','2 yemek kaşığı zeytinyağı','2,5 su bardağı sıcak su','Tuz, kimyon'],
 ['Mercimeği 15 dakika ön haşlayıp süzün.','Soğanı yağda kavurun.','Karabuğday ve mercimeği ekleyip 2 dakika çevirin.','Su, tuz ve kimyonu ekleyip 15 dakika pişirin.','10 dakika demlendirin.'],'Bitkisel protein açısından zengin bir pilavdır.'),
pil('p39a16_059','Kabaklı pirinç pilavı',['1,5 su bardağı pirinç','1 kabak (küp)','2 yemek kaşığı tereyağı','2,5 su bardağı sıcak su','1 tatlı kaşığı tuz','Dereotu'],
 ['Pirinci ıslatıp yıkayın.','Tereyağında kabağı 3 dakika soteleyin.','Pirinci ekleyip 3 dakika kavurun.','Su ve tuzla 15 dakika pişirin.','Dereotunu ekleyip demlendirin.'],'Kabağı fazla pişirmeyin; dağılır.'),
pil('p39a16_060','Pırasalı bulgur pilavı',['1,5 su bardağı bulgur','2 pırasa','1 havuç','2 yemek kaşığı zeytinyağı','1 tatlı kaşığı biber salçası','2,5 su bardağı sıcak su','Tuz'],
 ['Pırasayı ince halka, havucu küp doğrayın.','Yağda 6 dakika soteleyin, salçayı ekleyin.','Bulguru ekleyip 2 dakika kavurun.','Su ve tuzla 15 dakika pişirin.','10 dakika demlendirin.'],'Pırasanın arasındaki toprağı bol suda yıkayın.'),
]
MA='Makarnalar'
def mak(id,t,ing,steps,tip):
    return R(id,t,MA,4,10,15,'Kolay',None,ing,steps,[tip],'Pişer pişmez sıcak servis edin.','Buzdolabında 2 gün saklanır.')
base=['350 g makarna','Tuz']
rs+=[
mak('p39a16_097','Ispanaklı lorlu makarna',['350 g kalem makarna','300 g ıspanak','150 g lor','2 diş sarımsak','2 yemek kaşığı zeytinyağı','Tuz, karabiber, muskat'],
 ['Makarnayı tuzlu suda haşlayın, 1 bardak suyunu ayırın.','Sarımsağı yağda 1 dakika çevirin.','Ispanağı ekleyip 2 dakika soldurun.','Lor ve biraz haşlama suyuyla kremamsı sos yapın.','Makarnayı ekleyip karıştırın.'],'Muskat ıspanağın tadını açar.'),
mak('p39a16_099','Domatesli fesleğenli makarna',['350 g spagetti','4 olgun domates','3 diş sarımsak','4 yemek kaşığı zeytinyağı','1 demet fesleğen','Tuz','Parmesan'],
 ['Domateslerin kabuğunu çizip kaynar suda 30 sn bekletin, soyup doğrayın.','Sarımsağı yağda 1 dakika çevirin, domatesi ekleyip 10 dakika pişirin.','Makarnayı haşlayın.','Makarnayı sosa ekleyin.','Fesleğen ve parmesanla servis edin.'],'Fesleğeni en son ekleyin; kararmaz.'),
mak('p39a16_100','Kabaklı limonlu makarna',['350 g penne','2 kabak','1 limon (kabuğu ve suyu)','2 diş sarımsak','3 yemek kaşığı zeytinyağı','Parmesan','Tuz, karabiber'],
 ['Makarnayı haşlayın.','Kabağı yarım ay doğrayıp yağda yüksek ateşte 5 dakika soteleyin.','Sarımsağı ekleyin.','Makarna, limon kabuğu ve suyunu ekleyin.','Parmesanla karıştırın.'],'Limon kabuğu ferah bir aroma verir.'),
mak('p39a16_101','Brokolili sarımsaklı makarna',['350 g burgu makarna','1 brokoli','4 diş sarımsak','4 yemek kaşığı zeytinyağı','Pul biber','Parmesan','Tuz'],
 ['Makarnayı haşlarken son 4 dakikada brokoliyi ekleyin.','Yağda dilim sarımsak ve pul biberi 1 dakika çevirin.','Süzülen makarna ve brokoliyi ekleyin.','Biraz haşlama suyuyla karıştırın.','Parmesanla servis edin.'],'Sarımsağı yakmayın; acılaşır.'),
mak('p39a16_102','Köz biberli cevizli makarna',['350 g fiyonk makarna','3 köz kırmızı biber','Yarım su bardağı ceviz','1 diş sarımsak','3 yemek kaşığı zeytinyağı','Yarım su bardağı süt','Tuz'],
 ['Makarnayı haşlayın.','Köz biber, ceviz, sarımsak, yağ ve sütü blenderda pürüzsüz çekin.','Sosu tavada 2 dakika ısıtın.','Makarnayı ekleyin.','Kalan cevizle süsleyin.'],'Sos koyuysa haşlama suyuyla açın.'),
mak('p39a16_103','Bezelyeli naneli makarna',['350 g kısa makarna','1,5 su bardağı bezelye','1 soğan','2 yemek kaşığı tereyağı','Birkaç dal taze nane','Parmesan','Tuz'],
 ['Makarnayı haşlayın.','Tereyağında soğanı 3 dakika kavurun.','Bezelyeyi ekleyip 5 dakika pişirin.','Makarna ve kıyılmış naneyi ekleyin.','Parmesanla servis edin.'],'Dondurulmuş bezelye de kullanılabilir.'),
mak('p39a16_104','Patlıcanlı domatesli makarna',['350 g penne','2 patlıcan','3 domates','2 diş sarımsak','4 yemek kaşığı zeytinyağı','Fesleğen','Tuz'],
 ['Patlıcanı küp doğrayıp tuzlu suda bekletip kurulayın.','Yağda kızarana kadar soteleyin.','Sarımsak ve domatesi ekleyip 10 dakika pişirin.','Haşlanmış makarnayı ekleyin.','Fesleğenle servis edin.'],'Patlıcanı kalabalık etmeden kızartın.'),
mak('p39a16_105','Pırasalı mantarlı makarna',['350 g tagliatelle','1 pırasa','200 g mantar','2 yemek kaşığı tereyağı','Yarım su bardağı krema','Tuz, karabiber'],
 ['Makarnayı haşlayın.','Pırasayı ince doğrayıp tereyağında 5 dakika soteleyin.','Mantarı ekleyip suyunu çekene kadar pişirin.','Kremayı ekleyip 2 dakika kaynatın.','Makarnayla karıştırın.'],'Krema yerine süt + 1 kaşık un kullanabilirsiniz.'),
mak('p39a16_106','Karnabaharlı peynirli makarna',['350 g dirsek makarna','Yarım karnabahar','2 yemek kaşığı tereyağı','2 yemek kaşığı un','2 su bardağı süt','1 su bardağı kaşar','Tuz, muskat'],
 ['Makarna ve küçük karnabahar çiçeklerini birlikte haşlayın.','Tereyağında unu kavurup sütü ekleyerek beşamel yapın.','Kaşarı ekleyip eritin.','Makarna ve karnabaharı sosla karıştırın.','İsteğe göre fırında 10 dakika gratine edin.'],'Beşamel topaklanırsa telle çırpın.'),
mak('p39a16_107','Havuçlu zencefilli makarna',['350 g penne','3 havuç','1 soğan','1 tatlı kaşığı rendelenmiş zencefil','2 yemek kaşığı zeytinyağı','1 su bardağı sebze suyu','Tuz'],
 ['Makarnayı haşlayın.','Soğan ve doğranmış havucu yağda 5 dakika soteleyin.','Zencefil ve sebze suyunu ekleyip havuç yumuşayana kadar 10 dakika pişirin.','Blenderdan geçirip sos yapın.','Makarnayla karıştırın.'],'Zencefil miktarını damak tadınıza göre ayarlayın.'),
mak('p39a16_108','Nohutlu ıspanaklı makarna',['350 g kısa makarna','1 su bardağı haşlanmış nohut','200 g ıspanak','2 diş sarımsak','3 yemek kaşığı zeytinyağı','Pul biber','Tuz'],
 ['Makarnayı haşlayın.','Yağda sarımsak ve nohudu 4 dakika kavurun.','Ispanağı ekleyip soldurun.','Makarnayı ve biraz haşlama suyunu ekleyin.','Pul biberle servis edin.'],'Nohut makarnaya protein katar.'),
mak('p39a19_051','Köz biberli ricottalı makarna',['350 g penne','2 köz kırmızı biber','200 g ricotta veya lor','2 diş sarımsak','2 yemek kaşığı zeytinyağı','Fesleğen','Tuz'],
 ['Makarnayı haşlayın.','Köz biberi şerit doğrayın.','Sarımsağı yağda çevirip biberi ekleyin.','Ricottayı biraz haşlama suyuyla kremamsı hâle getirin.','Makarnayla karıştırıp fesleğenle servis edin.'],'Ricotta sıcakta kolay erir; ateşi kısın.'),
]
ME='Mezeler'
def mez(id,t,ing,steps,tip):
    return R(id,t,ME,4,15,15,'Kolay',None,ing,steps,[tip],'Soğuk servis edin; ekmekle sunun.','Buzdolabında 2–3 gün saklanır.')
rs+=[
mez('p39a16_109','Yoğurtlu pancar mezesi',['2 haşlanmış pancar','1 su bardağı süzme yoğurt','1 diş sarımsak','1 yemek kaşığı zeytinyağı','Tuz','Dereotu'],
 ['Pancarı rendeleyin.','Sarımsağı ezin.','Yoğurdu sarımsak ve tuzla çırpın.','Pancarı ekleyip karıştırın.','Zeytinyağı ve dereotuyla süsleyin.'],'Pancarı fırında közlemek tadını yoğunlaştırır.'),
mez('p39a16_110','Dereotlu kabak mezesi',['3 kabak','1 su bardağı süzme yoğurt','1 diş sarımsak','Yarım demet dereotu','2 yemek kaşığı zeytinyağı','Tuz'],
 ['Kabağı rendeleyin.','Yağda suyunu çekene kadar 8 dakika soteleyip soğutun.','Yoğurt ve sarımsağı çırpın.','Kabak ve dereotunu ekleyin.','Tuzunu ayarlayın.'],'Kabak soğumadan yoğurda eklenmesin.'),
mez('p39a16_111','Köz patlıcanlı tahinli meze (baba gannuş)',['3 patlıcan','3 yemek kaşığı tahin','1 limon suyu','1 diş sarımsak','2 yemek kaşığı zeytinyağı','Tuz, nar taneleri'],
 ['Patlıcanları ocakta veya fırında kabuğu kararana kadar közleyin.','Kabuğunu soyup süzgeçte 10 dakika süzün.','Bıçakla ince kıyın.','Tahin, limon, sarımsak ve tuzla karıştırın.','Zeytinyağı ve narla süsleyin.'],'Süzmek mezenin sulanmasını önler.'),
mez('p39a16_112','Havuçlu cevizli meze',['4 havuç','1 su bardağı süzme yoğurt','Yarım su bardağı ceviz','1 diş sarımsak','2 yemek kaşığı zeytinyağı','Tuz'],
 ['Havucu rendeleyin.','Yağda 6 dakika soteleyip soğutun.','Cevizi iri kıyın.','Yoğurt, sarımsak ve tuzla karıştırın.','Ceviz ekleyip servis edin.'],'Havucu soteleyince tatlılığı artar.'),
mez('p39a16_113','Köz biberli lor mezesi',['3 köz kırmızı biber','200 g lor','1 diş sarımsak','2 yemek kaşığı zeytinyağı','1 tatlı kaşığı pul biber','Maydanoz'],
 ['Biberlerin kabuğunu soyup ince kıyın.','Loru çatalla ezin.','Sarımsak ve yağı ekleyin.','Biberi karıştırın.','Pul biber ve maydanozla süsleyin.'],'Lorun tuzu azdır; tadına bakarak tuz ekleyin.'),
mez('p39a16_114','Kimyonlu nohut mezesi',['2 su bardağı haşlanmış nohut','1 kırmızı soğan','2 yemek kaşığı zeytinyağı','1 limon suyu','1 tatlı kaşığı kimyon','Maydanoz','Tuz'],
 ['Nohutları süzün.','Soğanı ince doğrayın.','Yağ, limon, kimyon ve tuzla sos yapın.','Nohutları sosla harmanlayın.','Maydanozla servis edin.'],'Biraz bekletince lezzeti oturur.'),
mez('p39a16_115','Yoğurtlu semizotu mezesi',['1 demet semizotu','1,5 su bardağı süzme yoğurt','1 diş sarımsak','1 yemek kaşığı zeytinyağı','Tuz'],
 ['Semizotunun yapraklarını ayıklayıp yıkayın.','İri doğrayın.','Yoğurdu sarımsak ve tuzla çırpın.','Semizotunu ekleyin.','Zeytinyağı gezdirin.'],'Semizotu omega-3 açısından zengindir.'),
mez('p39a16_116','Sarımsaklı brokoli mezesi',['1 brokoli','1 su bardağı yoğurt','2 diş sarımsak','2 yemek kaşığı zeytinyağı','Pul biber','Tuz'],
 ['Brokoliyi 4 dakika haşlayıp soğuk suya alın.','İnce kıyın.','Yoğurt, sarımsak ve tuzu çırpın.','Brokoliyi ekleyin.','Kızdırılmış pul biberli yağ gezdirin.'],'Fazla haşlanan brokoli kükürt kokusu yapar.'),
mez('p39a16_117','Tahinli karnabahar mezesi',['Yarım karnabahar','3 yemek kaşığı tahin','1 limon suyu','1 diş sarımsak','2 yemek kaşığı zeytinyağı','Tuz, kimyon'],
 ["Karnabaharı çiçeklerine ayırıp 220 °C fırında 25 dakika kızartın.",'Soğutup ezin.','Tahin, limon, sarımsak ve kimyonu çırpın.','Karnabaharla karıştırın.','Zeytinyağıyla servis edin.'],'Fırınlamak haşlamaktan daha lezzetli olur.'),
mez('p39a16_118','Yoğurtlu pazı mezesi',['1 demet pazı','1 su bardağı süzme yoğurt','1 diş sarımsak','2 yemek kaşığı zeytinyağı','Tuz'],
 ['Pazıyı ince doğrayın.','Yağda soldurup suyunu çekene kadar pişirin.','Soğutun.','Yoğurt ve sarımsakla karıştırın.','Tuzunu ayarlayın.'],'Kalın sapları ayrı doğrayıp önce pişirin.'),
mez('p39a16_119','Patlıcanlı domatesli meze (közlü ezme)',['3 patlıcan','2 domates','2 sivri biber','2 diş sarımsak','3 yemek kaşığı zeytinyağı','1 yemek kaşığı nar ekşisi','Tuz'],
 ['Patlıcan ve biberleri közleyip soyun.','Domatesi kabuğunu soyup küçük doğrayın.','Hepsini ince kıyın.','Sarımsak, yağ, nar ekşisi ve tuzla karıştırın.','Soğuk servis edin.'],'Közleme dumanlı tat verir.'),
mez('p39a16_120','Kereviz ve elma mezesi',['1 kereviz kökü','1 yeşil elma','1 su bardağı yoğurt','2 yemek kaşığı mayonez (isteğe bağlı)','Yarım su bardağı ceviz','Tuz'],
 ['Kerevizi ve elmayı rendeleyin; kararmasın diye limon gezdirin.','Yoğurt (ve mayonez) ile karıştırın.','Cevizi ekleyin.','Tuzunu ayarlayın.','30 dakika dinlendirin.'],'Limon kerevizin kararmasını önler.'),
mez('p39a19_091','Köz patlıcanlı yoğurtlu meze (alinazik usulü)',['3 patlıcan','1,5 su bardağı süzme yoğurt','2 diş sarımsak','2 yemek kaşığı tereyağı','1 tatlı kaşığı pul biber','Tuz'],
 ['Patlıcanları közleyip soyun ve ezin.','Sarımsaklı yoğurdu hazırlayın.','Patlıcanı yoğurtla karıştırın.','Tereyağını kızdırıp pul biber ekleyin.','Mezeye gezdirin.'],'Ilık da servis edilebilir.'),
]
rs+=[
R('p39a19_061','Ispanaklı lorlu rulo omlet','Kahvaltılıklar',2,10,10,'Kolay',None,['4 yumurta','1 su bardağı ıspanak','100 g lor','1 yemek kaşığı tereyağı','Tuz, karabiber'],
 ['Ispanağı tereyağında soldurun.','Yumurtaları tuz ve karabiberle çırpın.','Geniş tavada ince bir omlet pişirin.','Üzerine ıspanak ve loru yayın.','Rulo yapıp dilimleyin.'],['Kısık ateş omletin yırtılmasını önler.'],'Sıcak servis edin.','Taze tüketin.'),
R('p39a19_002','Köz kırmızı biberli mercimek çorbası','Çorbalar',4,10,30,'Kolay',None,['1 su bardağı kırmızı mercimek','2 köz kırmızı biber','1 soğan','1 havuç','2 yemek kaşığı zeytinyağı','6 su bardağı sıcak su','Tuz, kimyon'],
 ['Soğan ve havucu yağda 5 dakika kavurun.','Mercimek ve biberi ekleyin.','Su ve tuzla 25 dakika pişirin.','Blenderdan geçirin.','Kimyonla servis edin.'],['Köz biber çorbaya dumanlı bir tat verir.'],'Limon ve kıtır ekmekle.','Buzdolabında 3 gün.'),
R('p39a19_012','Zeytinyağlı kabak ve havuç','Sebze yemekleri',4,15,25,'Kolay',None,['4 kabak','2 havuç','1 soğan','1 domates','4 yemek kaşığı zeytinyağı','1 su bardağı sıcak su','Tuz, dereotu'],
 ['Soğanı yağda kavurun.','Havucu ekleyip 5 dakika pişirin.','Kabak ve domatesi ekleyin.','Su ve tuzla kısık ateşte 20 dakika pişirin.','Dereotuyla soğumaya bırakın.'],['Zeytinyağlılar tencerede soğutulur.'],'Ilık veya soğuk.','Buzdolabında 3 gün.'),
R('p39a19_132','Patlıcanlı biberli fırın tepsi','Sebze yemekleri',4,15,40,'Kolay',200,['3 patlıcan','3 biber','2 domates','1 soğan','4 diş sarımsak','4 yemek kaşığı zeytinyağı','Tuz, kekik'],
 ["Fırını 200 °C'ye ısıtın.",'Sebzeleri iri doğrayın.','Yağ, tuz ve kekikle harmanlayın.','Tepsiye yayın.','40 dakika pişirin.'],['Tek kat yayın; buharda pişmesin.'],'Yoğurtla.','Buzdolabında 2 gün.'),
R('p39a19_082','Patlıcanlı dana güveç','Et yemekleri',4,20,90,'Orta',180,['500 g kuşbaşı dana eti','2 patlıcan','2 domates','2 biber','1 soğan','1 yemek kaşığı salça','2 yemek kaşığı zeytinyağı','Tuz, karabiber'],
 ['Eti yağda suyunu çekene kadar kavurun.','Soğan ve salçayı ekleyin.','Güvece eti ve doğranmış sebzeleri yerleştirin.','1 su bardağı sıcak su ekleyip üzerini kapatın.',"180 °C fırında 90 dakika pişirin."],['Güveci soğuk fırına koyun; çatlamaz.'],'Pilavla.','Buzdolabında 3 gün.'),
R('p39a19_121','Nohutlu ıspanak yemeği','Bakliyat yemekleri',4,15,25,'Kolay',None,['500 g ıspanak','1 su bardağı haşlanmış nohut','1 soğan','1 yemek kaşığı salça','2 yemek kaşığı zeytinyağı','1 su bardağı sıcak su','Tuz'],
 ['Soğanı yağda kavurun, salçayı ekleyin.','Nohudu ekleyip 2 dakika çevirin.','Doğranmış ıspanak ve suyu ekleyin.','15 dakika pişirin.','Yoğurtla servis edin.'],['Ispanağı birkaç suda yıkayın.'],'Yoğurtla sıcak.','Buzdolabında 2 gün.'),
]
dump('06b_tekil',rs)
