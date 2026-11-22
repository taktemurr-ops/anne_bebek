// Bebek gelmeden ve geldikten sonra yapılacaklar. Tarama ve takviye
// zamanlamaları T.C. Sağlık Bakanlığı programlarına göredir; diğer ülkelerde
// farklı olabilir.

class ChecklistItem {
  final String id;
  final String phase;
  final String title;
  final String detail;
  const ChecklistItem(this.id, this.phase, this.title, [this.detail = '']);
}

const checklistPhases = ['Doğumdan önce', 'Hastanede', 'İlk hafta', 'İlk aylar', 'Anne için'];

const newbornChecklist = <ChecklistItem>[
  ChecklistItem('bag', 'Doğumdan önce', 'Hastane çantasını hazırla', '36. haftaya kadar; anne, bebek ve eş için.'),
  ChecklistItem('carseat', 'Doğumdan önce', 'Araç koltuğunu (ana kucağı) al ve tak', 'Hastaneden eve dönüşte bebek kucakta değil, arkaya bakan koltukta taşınmalı.'),
  ChecklistItem('bed', 'Doğumdan önce', 'Güvenli uyku alanı hazırla', 'Sert, düz yatak; yastık, yorgan, oyuncak ve kenar koruyucu olmadan.'),
  ChecklistItem('doctor', 'Doğumdan önce', 'Çocuk doktorunu ve aile hekimini belirle'),
  ChecklistItem('plan', 'Doğumdan önce', 'Doğum planını doktorun ve ebenle konuş'),
  ChecklistItem('leave', 'Doğumdan önce', 'Doğum izni ve iş yeri bildirimlerini planla'),
  ChecklistItem('hepb1', 'Hastanede', 'Hepatit B aşısının ilk dozu', 'Doğumdan sonra ilk 72 saat içinde.'),
  ChecklistItem('vitk', 'Hastanede', 'K vitamini iğnesi', 'Doğumdan hemen sonra; yenidoğanda kanamayı önler.'),
  ChecklistItem('hearing', 'Hastanede', 'İşitme taraması', 'Taburcu olmadan; yapılmadıysa ilk ay içinde.'),
  ChecklistItem('heel', 'Hastanede', 'Topuk kanı taraması', 'Genellikle 3–5. günler arasında; tekrar istenirse geciktirme.'),
  ChecklistItem('eyes', 'Hastanede', 'Göz (kırmızı refle) muayenesi'),
  ChecklistItem('jaundice', 'Hastanede', 'Sarılık kontrolü', 'Taburculuktan sonra sarılık artarsa ya da bebek emmiyorsa hemen doktora görün.'),
  ChecklistItem('register', 'İlk hafta', 'Nüfus kaydını kontrol et', 'Türkiye’de doğum 30 gün içinde nüfusa bildirilmeli; hastanenin bildirimini e-Devlet’ten kontrol et.'),
  ChecklistItem('family_doc', 'İlk hafta', 'Aile hekimine kayıt ve ilk muayene', 'Taburculuktan sonraki ilk günlerde.'),
  ChecklistItem('vitd', 'İlk hafta', 'D vitamini damlasına başla', 'Sağlık Bakanlığı programına göre ilk günlerden 1 yaşına kadar günde 400 ünite.'),
  ChecklistItem('insurance', 'İlk hafta', 'Bebeği sağlık güvencesine ekle'),
  ChecklistItem('hepb2', 'İlk aylar', 'Hepatit B ikinci doz (1. ay)'),
  ChecklistItem('hip', 'İlk aylar', 'Kalça ultrasonu', 'Genellikle 4–6. haftalar arasında.'),
  ChecklistItem('vaccines2', 'İlk aylar', '2. ay aşıları', 'Aşı takvimi için bebek sağlığı bölümüne bak.'),
  ChecklistItem('iron', 'İlk aylar', 'Demir damlasına başla (4. ay)', 'Sağlık Bakanlığı programına göre 4. aydan 1 yaşına kadar.'),
  ChecklistItem('benefit', 'İlk aylar', 'Doğum yardımı ve izin haklarını kontrol et', 'Güncel başvuru koşulları için e-Devlet’e bak.'),
  ChecklistItem('mom6', 'Anne için', 'Doğum sonrası 6. hafta kontrolü'),
  ChecklistItem('mood', 'Anne için', 'Ruh halini değerlendir', 'Doğumdan sonra 2. haftada ve 6. haftada ruh hali testini yap.'),
  ChecklistItem('pelvic', 'Anne için', 'Pelvik taban egzersizlerine başla'),
  ChecklistItem('contraception', 'Anne için', 'Doğum kontrolü yöntemini doktorunla konuş', 'Emzirmek tek başına güvenilir bir korunma yöntemi değildir.'),
];
