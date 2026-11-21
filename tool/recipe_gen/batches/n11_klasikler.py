import sys, os
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, HERE); sys.path.insert(0, os.path.join(HERE, 'batches'))
from recipes_dsl import R, dump
from classic_data import R as DATA
SKIP = {'İmam bayıldı','İç pilav','İzmir köfte','Mıhlama (kuymak)','Ev yapımı simit','Höşmerim','Kazandibi','Trileçe',
 'Kabak tatlısı','Ayva tatlısı','Kısır','Çılbır','Gavurdağı salatası','Atom (közlenmiş biberli yoğurt)','Fava','Babagannuş',
 'Hamsili pilav','Su böreği','Revani','Kaygana','Ali nazik','Tas kebabı','Orman kebabı','Kumpir','Profiterol','Lahmacun'}
RENAME = {'Tantuni': 'Dana tantuni (Mersin usulü)', 'Su muhallebisi': 'Su muhallebisi (gül sulu)'}
SERVE = {'Tatlılar': ('Soğuk ya da oda sıcaklığında.', 'Buzdolabında kapalı kapta 3 gün.'),
         'Çorbalar': ('Sıcak servis edin.', 'Buzdolabında 2 gün; bir kez ısıtın.'),
         'İçecekler': ('Soğuk servis edin.', 'Buzdolabında kapalı şişede 1 hafta.'),
         'Mezeler': ('Soğuk ya da oda sıcaklığında.', 'Buzdolabında 2 gün.'),
         'Salatalar': ('Hazırlanır hazırlanmaz.', 'Aynı gün tüketin.'),
         'Hamur işleri': ('Sıcak ya da ılık.', 'Kapalı kapta 2 gün; dondurucuda 1 ay.')}
FIX = {**{'Ayva çekirdekleri': '1 avuç ayva çekirdeği (tülbente sarılı)', 'Birkaç damla limon suyu': '1 tatlı kaşığı limon suyu', 'Bulamak için un': 'Bulamak için 3 yemek kaşığı un', 'Defne yaprağı, tuz, karabiber': '2 defne yaprağı, 1 tatlı kaşığı tuz, 1 çay kaşığı karabiber', 'Fındık içi': '30 adet fındık içi', 'Kaymak, ceviz': '4 yemek kaşığı kaymak, 3 yemek kaşığı ceviz', 'Kuru nane, sumak': '1 tatlı kaşığı kuru nane, 1 tatlı kaşığı sumak', 'Kızartmak için ayçiçek yağı': 'Kızartmak için 3 su bardağı ayçiçek yağı', 'Kızartmak için yağ': 'Kızartmak için 1 su bardağı ayçiçek yağı', 'Kızlar için: aynı bulgur hamurundan nohut büyüklüğü toplar': 'Kızlar için: aynı hamurdan 1 su bardağı kadar ayrılır', 'Nar taneleri': '3 yemek kaşığı nar tanesi', 'Sirkeli sarımsak, tuz': 'Sunum için 3 diş sarımsak ve yarım su bardağı sirke, 1 tatlı kaşığı tuz', 'Sos için: sarımsaklı yoğurt, tereyağında kızdırılmış soğan ve pul biber': 'Sos için: 1,5 su bardağı sarımsaklı yoğurt, 2 yemek kaşığı tereyağı, 1 soğan, 1 tatlı kaşığı pul biber', 'Soya sosu': '4 yemek kaşığı soya sosu', 'Terbiye ve sunum için: sirkeli sarımsak, pul biber': 'Sunum için 3 diş sarımsak ve yarım su bardağı sirke, 1 tatlı kaşığı pul biber', 'Toprak testi ve kapatmak için hamur ya da folyo': '1 toprak testi; ağzını kapatmak için 1 avuç hamur ya da folyo', 'Yanına lavaş, soğan, domates, sivri biber': 'Yanına 4 lavaş, 1 soğan, 2 domates, 4 sivri biber', 'Yanına: limon, maydanoz, soğan': 'Yanına: 2 limon, 1 demet maydanoz, 1 soğan', 'Yassı şiş': '4 yassı şiş', 'Üzeri için ceviz içi ve kaymak ya da tahin': 'Üzeri için 3 yemek kaşığı ceviz içi ve 4 yemek kaşığı kaymak ya da tahin', 'Üzeri için ceviz ya da fıstık': 'Üzeri için 2 yemek kaşığı ceviz ya da fıstık', 'Üzeri için pudra şekeri': 'Üzeri için 1 yemek kaşığı pudra şekeri', 'Üzeri için tarçın ve leblebi': 'Üzeri için 1 tatlı kaşığı tarçın ve 3 yemek kaşığı leblebi', 'İç seçenekleri: mısır, bezelye, Rus salatası, zeytin, turşu, sosis dilimleri': 'İç için: 4 yemek kaşığı mısır, 4 yemek kaşığı bezelye, 4 yemek kaşığı Rus salatası, 8 zeytin, 2 turşu'}, 'Tuz': '1 tatlı kaşığı tuz', 'Tuz, karabiber': '1 tatlı kaşığı tuz, yarım çay kaşığı karabiber'}
rs = []
for i, d in enumerate(DATA, 1):
    if d['title'] in SKIP: continue
    title = RENAME.get(d['title'], d['title'])
    total = d['minutes']; prep = max(5, min(40, round(total * .3))); cook = max(0, total - prep)
    diff = 'Kolay' if total <= 30 and len(d['steps']) <= 5 else ('Orta' if total <= 90 else 'Zor')
    ing = []
    for x in d['ing']:
        x = FIX.get(x, x)
        if x.startswith('Tuz') or x.endswith(', tuz') or x.endswith(', Tuz'):
            x = x if any(c.isdigit() for c in x) else x + ' (1 tatlı kaşığı tuz)'
        ing.append(x)
    serving, storage = SERVE.get(d['cat'], ('Sıcak servis edin.', 'Buzdolabında kapalı kapta 2 gün.'))
    tips = [d['tip']] if d['tip'] else ['Malzemeleri önceden hazırlamak pişirmeyi kolaylaştırır.']
    rs.append(R(f'n11_{i:03d}', title, d['cat'], d['serv'], prep, cook, diff, d['oven'], ing, d['steps'], tips, serving, storage))
dump('n11_klasikler', rs)
