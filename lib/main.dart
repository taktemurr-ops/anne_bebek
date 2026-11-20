import 'screens/notification_preferences_page.dart';
import 'screens/family_recipe_notebook_page.dart';
import 'screens/shopping_checklist_page.dart';
import 'screens/reproductive_calendar_page.dart';
import 'screens/recipe_explorer_page.dart';
import 'screens/daily_meal_suggestions_page.dart';
import 'screens/smart_shopping_page.dart';
import 'screens/pantry_recipe_page.dart';
import 'screens/weekly_meal_planner_page.dart';
import 'screens/ai_assistant_page.dart';
import 'screens/cloud_account_page.dart';
import 'screens/women_lifestyle_page.dart';
import 'screens/postpartum_care_page.dart';
import 'screens/baby_recipes_page.dart';
import 'screens/smart_discovery_page.dart';
import 'screens/local_admin_preview_page.dart';
import 'screens/admin_dashboard_page.dart';
import 'screens/membership_page.dart';
import 'screens/baby_online_forum_page.dart';
import 'screens/women_online_forum_page.dart';
import 'screens/child_profiles_page.dart';
import 'screens/activity_planner_page.dart';
import 'screens/age_guides_page.dart';
import 'screens/today_insights_page.dart';
import 'screens/womens_health_journal_page.dart';
import 'screens/baby_health_page.dart';
import 'screens/reminders_page.dart';
import 'screens/release_check_page.dart';
import 'widgets/quick_access.dart';
import 'sleep_journal.dart';
import 'dart:convert';
import 'extra_features.dart';
import 'life_hub.dart';
import 'guide_content.dart';
import 'cycle_tracker.dart';
import 'tracking_journal.dart';
import 'screens/backup_page.dart';
import 'services/privacy_service.dart';
import 'services/secure_health_store.dart';
import 'data/product_catalog.dart';
import 'data/general_recipe_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const AnneBebekApp());

const mor = Color(0xFF48235F);
const pembe = Color(0xFFFFD9ED);
const arka = Color(0xFFFFF7FC);

class AnneBebekApp extends StatelessWidget {
  const AnneBebekApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Anne & Bebek', debugShowCheckedModeBanner: false,
    // Cihaz diline göre Türkçe veya İngilizce; desteklenmeyen dillerde Türkçe.
    localeResolutionCallback: (device, supported) => device?.languageCode == 'en' ? const Locale('en', 'US') : const Locale('tr', 'TR'),
    supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: arka,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF0449B), brightness: Brightness.light),
      dividerColor: const Color(0xFFF2E5F0),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFCFF),
        indicatorColor: const Color(0xFFFFD9ED),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: mor)),
      ),
      cardTheme: CardThemeData(color: const Color(0xFFFFFCFF), elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
      appBarTheme: const AppBarTheme(backgroundColor: arka, foregroundColor: mor,
        elevation: 0, centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFF0449B), foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFFF7EAF4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none)),
    ),
    home: const AnaUygulama(),
  );
}

class AnaUygulama extends StatefulWidget {
  const AnaUygulama({super.key});
  @override
  State<AnaUygulama> createState() => _AnaUygulamaState();
}

class _AnaUygulamaState extends State<AnaUygulama> {
  int sekme = 0;
  String bebekAdi = '';
  DateTime? dogum;
  DateTime? sonAdet;
  final List<Map<String, String>> olaylar = [];
  final List<Map<String, String>> olcumler = [];
  final List<String> alisveris = [];
  final Set<String> favoriler = {};
  bool yuklendi = false;
  String? yuklemeHatasi;
  String arama = '';
  String tarifFiltre = 'Tümü';
  int tarifSureSiniri = 0; // 0: tüm süreler
  bool sadeceFavoriTarifler = false;
  final List<String> sepet = [];
  final Set<String> tamamlanan = {};


  @override
  void initState() { super.initState(); _yukle(); }

  Future<void> _yukle() async {
    try {
    final p = await SharedPreferences.getInstance();
    final savedName = await SecureHealthStore.read('bebekAdi');
    final savedBirth = await SecureHealthStore.read('dogum');
    final savedPeriod = await SecureHealthStore.read('sonAdet');
    final savedEvents = await SecureHealthStore.read('olaylar');
    final savedMeasurements = await SecureHealthStore.read('olcumler');
    if (!mounted) return;
    setState(() {
      bebekAdi = savedName ?? '';
      dogum = DateTime.tryParse(savedBirth ?? '');
      sonAdet = DateTime.tryParse(savedPeriod ?? '');
      for (final item in jsonDecode(savedEvents ?? '[]') as List) { olaylar.add(Map<String, String>.from(item as Map)); }
      for (final item in jsonDecode(savedMeasurements ?? '[]') as List) { olcumler.add(Map<String, String>.from(item as Map)); }
      alisveris.addAll((jsonDecode(p.getString('alisveris') ?? '[]') as List).cast<String>());
      favoriler.addAll((jsonDecode(p.getString('favoriler') ?? '[]') as List).cast<String>());
      sepet.addAll((jsonDecode(p.getString('sepet') ?? '[]') as List).cast<String>());
      tamamlanan.addAll((jsonDecode(p.getString('tamamlanan') ?? '[]') as List).cast<String>());
      yuklendi = true;
      yuklemeHatasi = null;
    });
    } catch (_) {
      if (!mounted) return;
      setState(() { yuklendi = false; yuklemeHatasi = 'Kayıtlar yüklenemedi. Lütfen tekrar deneyin.'; });
    }
  }

  // Mevcut depolama anahtarları ve veri biçimleri korunur.
  Future<bool> _kaydet() async {
    try {
      final p = await SharedPreferences.getInstance();
      await Future.wait([
        SecureHealthStore.write('bebekAdi', bebekAdi),
        SecureHealthStore.write('dogum', dogum?.toIso8601String() ?? ''),
        SecureHealthStore.write('sonAdet', sonAdet?.toIso8601String() ?? ''),
        SecureHealthStore.write('olaylar', jsonEncode(olaylar)),
        SecureHealthStore.write('olcumler', jsonEncode(olcumler)),
        p.setString('alisveris', jsonEncode(alisveris)),
        p.setString('favoriler', jsonEncode(favoriler.toList())),
        p.setString('sepet', jsonEncode(sepet)),
        p.setString('tamamlanan', jsonEncode(tamamlanan.toList())),
      ]);
      return true;
    } catch (error, stackTrace) {
      debugPrint('Kayıt başarısız: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  void _kayitBildir(bool basarili, {String basariMesaji = 'Kayıt tamamlandı.'}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(basarili ? basariMesaji : 'Kayıt kaydedilemedi. Lütfen tekrar deneyin.'),
    ));
  }

  String _tarih(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  String get yas {
    if (dogum == null) return 'Doğum tarihi eklenmedi';
    final gun = DateTime.now().difference(dogum!).inDays;
    if (gun < 0) return 'Doğum bekleniyor';
    return gun < 30 ? '$gun günlük' : '${(gun / 30.44).floor()} aylık (yaklaşık)';
  }

  void _profillerAc() => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const ChildProfilesPage()));

  Future<void> _profil() async {
    final ad = TextEditingController(text: bebekAdi);
    DateTime? secilen = dogum;
    await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, yenile) => AlertDialog(
      title: const Text('Bebek profili'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: ad, decoration: const InputDecoration(labelText: 'Bebeğin adı')),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () async {
          final d = await showDatePicker(context: ctx, initialDate: secilen ?? DateTime.now(), firstDate: DateTime(2010), lastDate: DateTime.now());
          if (d != null) yenile(() => secilen = d);
        }, icon: const Icon(Icons.calendar_month), label: Text(secilen == null ? 'Doğum tarihi seç' : _tarih(secilen!))),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () async {
          final oncekiAd = bebekAdi;
          final oncekiDogum = dogum;
          setState(() { bebekAdi = ad.text.trim(); dogum = secilen; });
          final basarili = await _kaydet();
          if (!basarili && mounted) setState(() { bebekAdi = oncekiAd; dogum = oncekiDogum; });
          if (!mounted || !ctx.mounted) return;
          if (basarili) Navigator.of(ctx).pop();
          _kayitBildir(basarili, basariMesaji: 'Bebek profili kaydedildi.');
        }, child: const Text('Kaydet'))],
    )));
    ad.dispose();
  }

  Future<void> _olayEkle(String tur) async {
    final not = TextEditingController();
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text('$tur kaydı'),
      content: TextField(controller: not, autofocus: true, decoration: const InputDecoration(labelText: 'Açıklama / miktar (isteğe bağlı)'), maxLines: 2),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () async {
          final yeniKayit = {'tur': tur, 'not': not.text.trim(), 'zaman': DateTime.now().toIso8601String()};
          setState(() => olaylar.insert(0, yeniKayit));
          final basarili = await _kaydet();
          if (!basarili && mounted) setState(() => olaylar.remove(yeniKayit));
          if (!mounted || !ctx.mounted) return;
          if (basarili) Navigator.of(ctx).pop();
          _kayitBildir(basarili, basariMesaji: '$tur kaydı eklendi.');
        }, child: const Text('Kaydet'))],
    ));
    not.dispose();
  }

  Future<void> _olcumEkle() async {
    final boy = TextEditingController(); final kilo = TextEditingController(); final bas = TextEditingController();
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Büyüme ölçümü'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: boy, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Boy (cm)')),
        TextField(controller: kilo, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Kilo (kg)')),
        TextField(controller: bas, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Baş çevresi (cm)')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () async {
          final b = double.tryParse(boy.text.replaceAll(',', '.'));
          final k = double.tryParse(kilo.text.replaceAll(',', '.'));
          final bc = double.tryParse(bas.text.replaceAll(',', '.'));
          if (!_olcumGecerli(boy.text, b, 20, 230) || !_olcumGecerli(kilo.text, k, 0.3, 200) || !_olcumGecerli(bas.text, bc, 15, 75)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ölçümleri kontrol edin: boy 20–230 cm, kilo 0,3–200 kg, baş çevresi 15–75 cm.'))); return;
          }
          if (b == null && k == null && bc == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('En az bir ölçüm girin.'))); return; }
          final yeniOlcum = {'boy': b?.toString() ?? '', 'kilo': k?.toString() ?? '', 'basCevresi': bc?.toString() ?? '', 'tarih': DateTime.now().toIso8601String()};
          setState(() => olcumler.insert(0, yeniOlcum));
          final basarili = await _kaydet();
          if (!basarili && mounted) setState(() => olcumler.remove(yeniOlcum));
          if (!mounted || !ctx.mounted) return;
          if (basarili) Navigator.of(ctx).pop();
          _kayitBildir(basarili, basariMesaji: 'Büyüme ölçümü kaydedildi.');
        }, child: const Text('Kaydet'))],
    ));
    boy.dispose(); kilo.dispose(); bas.dispose();
  }

  // Boş alan serbesttir; girilen değer ise sayısal ve makul aralıkta olmalıdır.
  bool _olcumGecerli(String metin, double? deger, double min, double max) =>
      metin.trim().isEmpty || (deger != null && deger.isFinite && deger >= min && deger <= max);

  Future<void> _urunEkle() async {
    final urun = TextEditingController();
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Alışveriş listesine ekle'),
      content: TextField(controller: urun, autofocus: true, decoration: const InputDecoration(labelText: 'Ürün adı')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () async {
          final yeniUrun = urun.text.trim();
          if (yeniUrun.isEmpty) return;
          setState(() => alisveris.add(yeniUrun));
          final basarili = await _kaydet();
          if (!basarili && mounted) setState(() => alisveris.removeLast());
          if (!mounted || !ctx.mounted) return;
          if (basarili) Navigator.of(ctx).pop();
          _kayitBildir(basarili, basariMesaji: 'Ürün listeye eklendi.');
        }, child: const Text('Ekle'))],
    ));
    urun.dispose();
  }

  Widget _kart(String baslik, String alt, IconData ikon, Color renk, VoidCallback tikla) => Card(
    color: renk, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: InkWell(borderRadius: BorderRadius.circular(22), onTap: tikla,
      child: Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(ikon, size: 37, color: mor), const SizedBox(height: 12),
        Text(baslik, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: mor, fontSize: 16)),
        const SizedBox(height: 5), Text(alt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: mor)),
      ])),
    ),
  );


  Widget _baslik(String s, {String? action, VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.fromLTRB(3, 20, 3, 12),
    child: Row(children: [Expanded(child: Text(s, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: mor))),
      if (action != null) TextButton(onPressed: onTap, child: Text(action))]));

  Widget _panel({required Widget child, Color color = Colors.white, EdgeInsets? padding}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: color,
        elevation: 2,
        shadowColor: mor.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

  Widget _hero(String title, String subtitle, IconData icon, {VoidCallback? onTap, String button = 'Keşfet'}) =>
    Container(
      constraints: const BoxConstraints(minHeight: 184),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFFFB8D8), Color(0xFFF8D6EB), Color(0xFFE4D6FF)]),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: const Color(0xFFECA5CB).withValues(alpha: .20), blurRadius: 16, offset: const Offset(0, 7))],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: const TextStyle(fontSize: 23, height: 1.13, fontWeight: FontWeight.w900, color: mor)),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: mor, fontSize: 12.5, height: 1.45)),
          if (onTap != null) ...[const SizedBox(height: 14), FilledButton(onPressed: onTap,
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: mor,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)), child: Text(button))],
        ])),
        const SizedBox(width: 8),
        Container(width: 96, height: 112, decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .33), borderRadius: BorderRadius.circular(25)),
          child: Icon(icon, size: 68, color: const Color(0xFFD44A9A))),
      ]),
    );

  Widget _search(String hint, ValueChanged<String> change) => TextField(onChanged: change,
    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: hint,
      filled: true, fillColor: const Color(0xFFF8EDF7), border: OutlineInputBorder(
        borderSide: BorderSide.none, borderRadius: BorderRadius.circular(28))));

  void _sayfa(String title, Widget child) => Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => Scaffold(appBar: AppBar(title: Text(title)), body: SafeArea(child: child))));

  Widget _ana() => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
    const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Merhaba Anne 💕', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: mor))),
    Padding(padding: const EdgeInsets.only(bottom: 14), child: Text(bebekAdi.isEmpty ? 'Bugün kendine ve bebeğine güzel bir an ayır 🌷' : '$bebekAdi ile güzel bir gün seni bekliyor 🌷', style: const TextStyle(fontSize: 13, color: mor))),
    _panel(padding: EdgeInsets.zero, color: const Color(0xFFF7EAF5), child: ListTile(
      leading: const Icon(Icons.search_rounded, color: mor),
      title: const Text('Aramak istediğin şeyi yaz...', style: TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: mor),
      onTap: () => _sayfa('A’dan Z’ye Rehber', _rehber()))),
    _hero('Bebeğinizin Sağlığı İçin\nTüm Rehber Burada',
      bebekAdi.isEmpty ? 'Beslenme, bakım, gelişim ve sağlık bir arada.' : '$bebekAdi • $yas',
      Icons.child_friendly_rounded, onTap: () => setState(() => sekme = 1), button: 'Keşfet →'),
    _baslik('Kategorileri keşfet 🌸'),
    LayoutBuilder(builder: (context, constraints) => GridView.count(
      crossAxisCount: constraints.maxWidth < 350 ? 2 : 4,
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10,
      childAspectRatio: constraints.maxWidth < 350 ? 1.8 : .78, children: [
        _mini('Alışveriş', Icons.shopping_cart, const Color(0xFFECDFFF), () => setState(() => sekme = 3)),
        _mini('Yemek', Icons.restaurant, const Color(0xFFFFE5CF), () => setState(() => sekme = 2)),
        _mini('Bebek', Icons.child_care, const Color(0xFFDDF5F4), () => setState(() => sekme = 1)),
        _mini('Sağlık', Icons.favorite, const Color(0xFFFFDCE9), () => _sayfa('Sağlık', _saglik())),
        _mini('Moda', Icons.checkroom, const Color(0xFFF7DDF0), () => _rehberKonuAc('Moda & Stil')),
        _mini('Eğitim', Icons.school, const Color(0xFFE3E6FF), () => _rehberKonuAc('Eğitim & Oyun')),
        _mini('Oyunlar', Icons.toys, const Color(0xFFFFE3D6), () => _rehberKonuAc('Eğitim & Oyun')),
        _mini('Tüm Kategoriler', Icons.apps, const Color(0xFFEDE0FF), () => _sayfa('A’dan Z’ye Rehber', _rehber())),
      ])),
    _panel(color: const Color(0xFFFFE6F3), child: ListTile(leading: const Icon(Icons.auto_awesome_outlined, color: mor), title: const Text('AI Bilgi Asistanı'), subtitle: const Text('İsteğe bağlı soru gönderimi · sunucu kurulumu gerekir'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AiAssistantPage())))),
    _panel(color: const Color(0xFFF3E6FF), child: ListTile(leading: const Icon(Icons.manage_search_outlined, color: mor), title: const Text('Akıllı içerik keşfi'), subtitle: const Text('Bebek, kadın ve yaşam konularında çevrimdışı arama'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SmartDiscoveryPage())))),
    _baslik('Bugünün önerileri ✨', action: 'Tümünü gör', onTap: () => setState(() => sekme = 2)),
    Row(children: [Expanded(child: _oner('Bebeğiniz için 5 sağlıklı tarif', 'Pratik ve besleyici öneriler', Icons.ramen_dining_rounded, () => setState(() => sekme = 2))),
      const SizedBox(width: 10), Expanded(child: _oner('Bebek bakımı', 'Günlük gelişimi takip et', Icons.child_care_rounded, () => setState(() => sekme = 1)))]),
    _baslik('Bebek profilleri 💗'),
    _panel(color: const Color(0xFFFFEAF5), child: ListTile(
      leading: const Icon(Icons.add_circle_rounded, color: Color(0xFFF0449B), size: 34),
      title: const Text('Yeni bebek ekle', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Çocuk profilleri ve kişisel günlükler'),
      trailing: const Icon(Icons.chevron_right), onTap: _profillerAc)),
    _panel(color: const Color(0xFFF3E6FF), child: ListTile(leading: const Icon(Icons.insights, color: mor), title: const Text('Bugün ve analizler'), subtitle: const Text('Günlük kayıtlar ve gelişim özeti'), trailing: const Icon(Icons.chevron_right), onTap: _analizAc)),
    _panel(color: const Color(0xFFFFF0E2), child: ListTile(
      leading: const Icon(Icons.shopping_basket_outlined, color: mor),
      title: const Text('Güvenli alışveriş listem'),
      subtitle: const Text('Ürünleri ekle, tamamla ve kaydet'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const ShoppingChecklistPage())))),
    _panel(color: const Color(0xFFFFEAF5), child: ListTile(
      leading: const Icon(Icons.calendar_month_outlined, color: mor),
      title: const Text('Gebelik ve döngü takvimi'),
      subtitle: const Text('Özel takvim ve tahmini tarihler'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const ReproductiveCalendarPage())))),
    _panel(color: const Color(0xFFFFF3E7), child: ListTile(
      leading: const Icon(Icons.restaurant_menu, color: mor),
      title: const Text('Aile tarif defterim'),
      subtitle: const Text('Kendi tariflerini güvenli şekilde kaydet'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const FamilyRecipeNotebookPage())))),
    _panel(color: const Color(0xFFEAF4FF), child: ListTile(
      leading: const Icon(Icons.nights_stay_outlined, color: mor),
      title: const Text('Günlük yaşam günlüğü'),
      subtitle: const Text('Önce çocuk profilini seçerek kayıt aç'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _profillerAc)),
    _panel(color: const Color(0xFFE9F7F5), child: ListTile(
      leading: const Icon(Icons.notifications_active_outlined, color: mor),
      title: const Text('Bildirim tercihlerim'),
      subtitle: const Text('İzinleri ve sessiz saatleri yönet'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const NotificationPreferencesPage())))),
    _baslik('Yaşam merkezim ✨'),
    _panel(color: const Color(0xFFF3E6FF), child: ListTile(
      leading: const Icon(Icons.dashboard_customize, color: mor),
      title: const Text('Tüm günlük yaşam araçları'),
      subtitle: const Text('Bebek, hamilelik, kadın, aile, anılar • Kaydet, takip et, tamamla'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LifeHubPage())),
    )),
    _baslik('Yeni: Aile yaşamı ✨'),
    Row(children: [
      Expanded(child: _oner('Hamilelik', 'Hafta hafta takip', Icons.pregnant_woman,
        () => _sayfa('Hamilelik', const PregnancyPage()))),
      const SizedBox(width: 10),
      Expanded(child: _oner('Aile Takvimi', 'Randevu ve planlar', Icons.calendar_month,
        () => _sayfa('Aile Takvimi', const FamilyCalendarPage()))),
    ]),
    _panel(color: const Color(0xFFF3E6FF), child: ListTile(
      leading: const Icon(Icons.insights, color: mor),
      title: const Text('Büyüme grafikleri'),
      subtitle: const Text('Kaydettiğin boy ve kilo ölçümlerini görüntüle'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _sayfa('Büyüme Grafikleri', GrowthChartsPage(measurements: olcumler)),
    )),
    _baslik('A’dan Z’ye rehber', action: 'Hepsini aç', onTap: () => _sayfa('A’dan Z’ye Rehber', _rehber())),
    _panel(child: ListTile(leading: const Icon(Icons.auto_stories_rounded, color: mor), title: const Text('Konuları alfabetik keşfet'), subtitle: const Text('Arama, kategori ve detaylı rehber içerikleri'), trailing: const Icon(Icons.chevron_right), onTap: () => _sayfa('A’dan Z’ye Rehber', _rehber()))),
    const SizedBox(height: 15),
  ]);

  Widget _mini(String label, IconData icon, Color color, VoidCallback tap) => InkWell(onTap: tap,
    borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .62), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: mor, size: 25)),
        const SizedBox(height: 7), Text(label, textAlign: TextAlign.center, maxLines: 2,
          style: const TextStyle(fontSize: 10.5, color: mor, fontWeight: FontWeight.w700))])));

  Widget _oner(String title, String desc, IconData icon, VoidCallback tap) => ExpandedSuggestionCard(
    title: title, description: desc, icon: icon, onTap: tap);

  Widget _bebek() => ListView(padding: const EdgeInsets.all(15), children: [
    _hero('Bebek Bakımı 👶', 'Bebeğinin tüm bakım ihtiyaçlarını takip edin.', Icons.child_care,
      onTap: _profillerAc, button: 'Bebek profillerim'),
    const SizedBox(height: 8),
    _panel(color: const Color(0xFFFFEAF5), child: const Text(
      'Beslenme, uyku, bez değişimi ve büyüme kayıtlarını tek yerden takip et.',
      textAlign: TextAlign.center, style: TextStyle(color: mor, fontWeight: FontWeight.w600))),
    _panel(color: const Color(0xFFFFE6F3), child: ListTile(
      leading: const Icon(Icons.group_add_rounded, color: mor, size: 32),
      title: const Text('Bebek profillerini yönet', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Yeni bebek ekle, profiller arasında geçiş yap ve kayıtları görüntüle'),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18), onTap: _profillerAc)),
    _panel(color: const Color(0xFFF1E5FF), child: ListTile(leading: const Icon(Icons.forum_outlined, color: mor), title: const Text('Bebeğim Forumu'), subtitle: const Text('Sorular ve ebeveyn deneyimleri'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BabyOnlineForumPage())))),
    _baslik('Bebek profili'),
    _panel(color: pembe, child: ListTile(leading: const Icon(Icons.face, size: 37, color: mor),
      title: Text(bebekAdi.isEmpty ? 'Bebek profili ekle' : bebekAdi), subtitle: Text(yas),
      trailing: const Icon(Icons.edit), onTap: _profil)),
    _panel(color: const Color(0xFFFFEAF5), child: ListTile(leading: const Icon(Icons.restaurant_menu, color: mor), title: const Text('300 bebek tarifi varyasyonu'), subtitle: const Text('Yaş, kategori ve malzemeye göre arama'), trailing: const Icon(Icons.chevron_right), onTap: () => _sayfa('Bebek Tarifleri', const BabyRecipesPage()))),
    _baslik('Günlük takip'),
    GridView.count(crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .86, children: [
      _mini('Beslenme', Icons.local_drink, const Color(0xFFFFE5D4), () => _sayfa('Beslenme günlüğüm', const TrackingJournalPage())),
      _mini('Uyku', Icons.bedtime, const Color(0xFFE4DFFF), () => _sayfa('Uyku günlüğüm', const SleepJournalPage())),
      _mini('Bez', Icons.baby_changing_station, const Color(0xFFE0E9FF), () => _olayEkle('Bez değişimi')),
      _mini('Büyüme', Icons.trending_up, const Color(0xFFFFDFEB), _olcumEkle),
    ]),
    _baslik('Bugünkü özet'),
    _panel(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _sayac('Beslenme', 'Beslenme'), _sayac('Uyku', 'Uyku'), _sayac('Bez', 'Bez değişimi')])),
    _baslik('Son kayıtlar'),
    if (olaylar.isEmpty) _panel(child: const Text('Henüz kayıt bulunmuyor. Yukarıdan bir takip ekleyebilirsin.')),
    ...olaylar.take(30).map((o) => _panel(child: ListTile(
      leading: const Icon(Icons.check_circle_outline, color: mor), title: Text(o['tur'] ?? ''),
      subtitle: Text('${_guvenliTarih(o['zaman'])}  ${o['not'] ?? ''}'),
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {setState(() => olaylar.remove(o)); _kaydet();})))),
    _panel(color: const Color(0xFFF1E6FF), child: ListTile(
      leading: const Icon(Icons.show_chart, color: mor),
      title: const Text('Boy / kilo grafiklerini görüntüle'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _sayfa('Büyüme Grafikleri', GrowthChartsPage(measurements: olcumler)),
    )),
    _baslik('Büyüme ölçümleri', action: 'Ölçüm ekle', onTap: _olcumEkle),
    if (olcumler.isEmpty) _panel(child: const Text('Boy ve kilo ölçümü eklediğinde burada görünecek.')),
    ...olcumler.map((o) => _panel(child: ListTile(leading: const Icon(Icons.show_chart, color: mor),
      title: Text('Boy: ${_olcumMetni(o['boy'], 'cm')}  •  Kilo: ${_olcumMetni(o['kilo'], 'kg')}\nBaş çevresi: ${_olcumMetni(o['basCevresi'], 'cm')}'),
      subtitle: Text(_guvenliTarih(o['tarih'])),
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {setState(() => olcumler.remove(o)); _kaydet();})))),
    _baslik('Bakım rehberi'),
    _rehberKart('Bebek Masajı', Icons.spa), _rehberKart('Bebek Gelişimi', Icons.auto_graph),
    _rehberKart('Beslenme', Icons.restaurant), _rehberKart('Uyku Düzeni', Icons.bedtime),
    const Padding(padding: EdgeInsets.all(10), child: Text('Takip kayıtları kişisel kullanım içindir; sağlık değerlendirmesi yerine geçmez.', style: TextStyle(fontSize: 11))),
  ]);

  String _olcumMetni(String? deger, String birim) => (deger == null || deger.isEmpty) ? '—' : '$deger $birim';
  String _guvenliTarih(String? s) {final d = DateTime.tryParse(s ?? ''); return d == null ? '' : _tarih(d);}
  Widget _sayac(String label, String type) => Column(children: [Text('${olaylar.where((e) => e['tur'] == type && _guvenliTarih(e['zaman']) == _tarih(DateTime.now())).length}',
    style: const TextStyle(fontSize: 23, color: mor, fontWeight: FontWeight.bold)), Text(label)]);

  // Genel tarifler ayrı katalogdan gelir; bebek tarifleri Bebeğim bölümündedir.
  Widget _tarifKarti(GeneralRecipe t) {
    final isFavorite = favoriler.contains(t.title);
    final simge = t.category.contains('Çorba') ? Icons.soup_kitchen_outlined
        : t.category.contains('Tatlı') ? Icons.cake_outlined
        : t.category.contains('Kahvaltı') ? Icons.breakfast_dining_outlined
        : Icons.restaurant_menu;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => _sayfa(t.title, ListView(padding: const EdgeInsets.all(18), children: [
          _hero(t.title, '${t.category} • ${t.minutes} dk', simge),
          _panel(color: const Color(0xFFFFEAF5), child: ListTile(
            leading: const Icon(Icons.add_shopping_cart, color: mor),
            title: const Text('Malzemeleri alışveriş listeme ekle'),
            subtitle: const Text('Mevcut listenizdeki ürünler korunur.'),
            onTap: () {
              var added = 0;
              setState(() {
                for (final ingredient in t.ingredients) {
                  if (!alisveris.contains(ingredient)) {
                    alisveris.add(ingredient);
                    added++;
                  }
                }
              });
              _kaydet();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$added malzeme alışveriş listene eklendi.'),
              ));
            },
          )),
          _baslik('Malzemeler'),
          ...t.ingredients.map((m) => ListTile(dense: true,
            leading: const Icon(Icons.check_circle_outline, color: mor), title: Text(m))),
          _baslik('Hazırlanışı'),
          ...t.steps.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(fontSize: 15)))),
        ])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: Container(color: const Color(0xFFFFEAF5), child: Stack(children: [
            Center(child: Icon(simge, size: 56, color: mor)),
            Positioned(right: 2, top: 2, child: IconButton(
              tooltip: 'Favorilere ekle / çıkar',
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                color: const Color(0xFFF0449B)),
              onPressed: () {
                setState(() {
                  if (!favoriler.add(t.title)) favoriler.remove(t.title);
                });
                _kaydet();
              },
            )),
          ]))),
          Padding(padding: const EdgeInsets.all(10), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, color: mor)),
              const SizedBox(height: 5),
              Text('${t.category} • ${t.minutes} dk', maxLines: 1,
                overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
            ],
          )),
        ]),
      ),
    );
  }

  Future<void> _tarifFavorileriniYenile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonDecode(prefs.getString('favoriler') ?? '[]');
      if (raw is List && mounted) {
        setState(() { favoriler..clear()..addAll(raw.whereType<String>()); });
      }
    } catch (_) { /* Eski veriyi koru. */ }
  }

  Widget _tarif() {
    final categories = <String>['Tümü',
      ...{for (final t in generalRecipes) t.category}];
    final selected = categories.contains(tarifFiltre) ? tarifFiltre : 'Tümü';
    final query = arama.trim().toLowerCase();
    final gorunen = generalRecipes.where((t) =>
      (selected == 'Tümü' || t.category == selected) &&
      (tarifSureSiniri == 0 || t.minutes <= tarifSureSiniri) &&
      (!sadeceFavoriTarifler || favoriler.contains(t.title)) &&
      (query.isEmpty ||
        t.title.toLowerCase().contains(query) ||
        t.ingredients.any((m) => m.toLowerCase().contains(query)))).toList();
    final gununTarifi = generalRecipes.isEmpty ? null :
      generalRecipes[DateTime.now().difference(DateTime(2026, 1, 1)).inDays.abs() % generalRecipes.length];
    return ListView(padding: const EdgeInsets.all(15), children: [
      const Center(child: Icon(Icons.soup_kitchen_outlined, size: 57, color: mor)),
      const SizedBox(height: 7),
      const Center(child: Text('Bugün Ne Pişirsem?', style: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w900, color: mor))),
      const SizedBox(height: 6),
      Center(child: Text('${generalRecipes.length} genel tarif • ${gorunen.length} sonuç',
        style: const TextStyle(color: mor))),
      const SizedBox(height: 12),
      if (gununTarifi != null) _panel(color: const Color(0xFFFFEAF5),
        child: ListTile(
          leading: const Icon(Icons.auto_awesome, color: mor),
          title: const Text('Günün tarifi', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${gununTarifi.title} • ${gununTarifi.minutes} dk'),
          trailing: const Icon(Icons.chevron_right, color: mor),
          onTap: () => _sayfa('Günün tarifi', ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tarifKartiDetay(gununTarifi),
            ],
          )),
        )),
      const SizedBox(height: 12),
      _panel(color: const Color(0xFFFFF0F8), child: ListTile(
        leading: const Icon(Icons.wb_sunny_outlined, color: mor),
        title: const Text('Günlük yemek önerilerim', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Kahvaltı, öğle ve akşam için tarif önerileri'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const DailyMealSuggestionsPage())),
      )),
      _panel(color: const Color(0xFFFFEAF5), child: ListTile(
        leading: const Icon(Icons.tune, color: mor),
        title: const Text('Gelişmiş tarif keşfi', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Hızlı arama, sıralama, favoriler ve tarif detayları'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const RecipeExplorerPage())).then((_) => _tarifFavorileriniYenile()),
      )),
      _panel(color: const Color(0xFFF1E6FF), child: ListTile(
        leading: const Icon(Icons.calendar_month_outlined, color: mor),
        title: const Text('Haftalık yemek planım', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('7 gün, 3 öğün ve alışveriş listesi'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const WeeklyMealPlannerPage())),
      )),
      _panel(color: const Color(0xFFFFEAF5), child: ListTile(
        leading: const Icon(Icons.kitchen_outlined, color: mor),
        title: const Text('Evdeki malzemelerle ne pişirsem?', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Malzemelerini kaydet, uygun tarifleri bul'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PantryRecipePage())),
      )),
      const SizedBox(height: 12),
      _search('Tarif veya malzeme ara...', (v) => setState(() => arama = v)),
      const SizedBox(height: 12),
      SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(children: categories.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(f), selected: selected == f,
            selectedColor: const Color(0xFF9E60C8),
            labelStyle: TextStyle(color: selected == f ? Colors.white : mor),
            onSelected: (_) => setState(() => tarifFiltre = f)),
        )).toList())),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ChoiceChip(label: const Text('Tüm süreler'), selected: tarifSureSiniri == 0,
            onSelected: (_) => setState(() => tarifSureSiniri = 0)),
          ChoiceChip(label: const Text('≤ 15 dk'), selected: tarifSureSiniri == 15,
            onSelected: (_) => setState(() => tarifSureSiniri = 15)),
          ChoiceChip(label: const Text('≤ 30 dk'), selected: tarifSureSiniri == 30,
            onSelected: (_) => setState(() => tarifSureSiniri = 30)),
          ChoiceChip(label: const Text('≤ 60 dk'), selected: tarifSureSiniri == 60,
            onSelected: (_) => setState(() => tarifSureSiniri = 60)),
          FilterChip(label: const Text('Yalnızca favorilerim'),
            selected: sadeceFavoriTarifler,
            onSelected: (v) => setState(() => sadeceFavoriTarifler = v)),
        ]),
      _baslik('Genel yemek tarifleri'),
      if (gorunen.isEmpty) _panel(child: const Text('Filtrelere uygun tarif bulunamadı.')),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: gorunen.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240, childAspectRatio: .82,
          mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemBuilder: (_, i) => _tarifKarti(gorunen[i])),
      _baslik('Favori tariflerim'),
      _panel(child: Text(favoriler.isEmpty
        ? 'Henüz favori tarif eklemedin.'
        : generalRecipes.where((t) => favoriler.contains(t.title))
            .map((t) => t.title).toSet().join(' • '))),
    ]);
  }

  Widget _tarifKartiDetay(GeneralRecipe t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _hero(t.title, '${t.category} • ${t.minutes} dk', Icons.restaurant_menu),
      _baslik('Malzemeler'),
      ...t.ingredients.map((m) => ListTile(dense: true,
        leading: const Icon(Icons.check_circle_outline, color: mor), title: Text(m))),
      _baslik('Hazırlanışı'),
      ...t.steps.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Text('${e.key + 1}. ${e.value}'))),
    ],
  );

  final urunler = productCatalog;

  // Alt ekranların aynı SharedPreferences listesini değiştirmesinden sonra
  // bellekteki kopyayı yenile; sonraki kayıtlarda yeni ürünler kaybolmasın.
  Future<void> _alisverisYenile() async {
    final p = await SharedPreferences.getInstance();
    try {
      final items = (jsonDecode(p.getString('alisveris') ?? '[]') as List).cast<String>();
      final done = (jsonDecode(p.getString('tamamlanan') ?? '[]') as List).cast<String>();
      if (!mounted) return;
      setState(() {
        alisveris..clear()..addAll(items);
        tamamlanan..clear()..addAll(done);
      });
    } catch (e) { debugPrint('Alışveriş yenileme hatası: $e'); }
  }

  Widget _alisveris() => ListView(padding: const EdgeInsets.all(15), children: [
    Row(children: [const Expanded(child: Text('Alışveriş', style: TextStyle(
      fontSize: 25, fontWeight: FontWeight.w900, color: mor))),
      IconButton(tooltip: 'Sepetim', onPressed: () => _sayfa('Sepetim', _sepet()),
        icon: Badge(label: Text('${sepet.length}'), isLabelVisible: sepet.isNotEmpty,
          child: const Icon(Icons.shopping_cart_outlined, color: mor)))]),
    const SizedBox(height: 12),
    _panel(color: const Color(0xFFF7EAF5), child: const Row(children: [
      Icon(Icons.search, color: mor), SizedBox(width: 10),
      Expanded(child: Text('Bir kategori seçerek ürünleri keşfet',
        style: TextStyle(color: mor, fontSize: 13)))])),
    _baslik('Kategoriler'),
    GridView.count(crossAxisCount: 4, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 8,
      crossAxisSpacing: 8, childAspectRatio: .76, children: [
        _mini('Bebek Ürünleri', Icons.child_care, const Color(0xFFDDF4EF),
          () => _sayfa('Bebek Ürünleri', _urunKategori('Bebek Ürünleri'))),
        _mini('Anne Ürünleri', Icons.pregnant_woman, const Color(0xFFFFD9EE),
          () => _sayfa('Anne Ürünleri', _urunKategori('Anne Ürünleri'))),
        _mini('Ev & Yaşam', Icons.home_outlined, const Color(0xFFE2E9FF),
          () => _sayfa('Ev & Yaşam', _urunKategori('Ev & Yaşam'))),
        _mini('Kozmetik', Icons.spa, const Color(0xFFFFE5D7),
          () => _sayfa('Kozmetik & Bakım', _urunKategori('Kozmetik & Bakım'))),
        _mini('Giyim', Icons.checkroom, const Color(0xFFE6D8FF),
          () => _sayfa('Giyim', _urunKategori('Giyim'))),
        _mini('Oyuncak', Icons.toys, const Color(0xFFFFE8B7),
          () => _sayfa('Oyuncak', _urunKategori('Oyuncak'))),
        _mini('Sağlık', Icons.medical_services_outlined, const Color(0xFFD7F3EF),
          () => _sayfa('Sağlık', _urunKategori('Sağlık'))),
        _mini('Diğer', Icons.apps, const Color(0xFFF9DBEE),
          () => _sayfa('Diğer', _urunKategori('Diğer'))),
      ]),
    _baslik('Fırsat ürünleri ✨', action: 'Sepetim (${sepet.length})',
      onTap: () => _sayfa('Sepetim', _sepet())),
    GridView.builder(itemCount: urunler.length, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: .83, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemBuilder: (ctx, i) => _urunKarti(urunler[i])),
    _panel(color: const Color(0xFFF8D7ED), child: const ListTile(
      leading: Icon(Icons.card_giftcard, color: mor, size: 34),
      title: Text('Sana özel bir alışveriş listesi 💝',
        style: TextStyle(fontWeight: FontWeight.w800, color: mor)),
      subtitle: Text('İhtiyaçlarını kaydet, alışverişte kolayca işaretle.'))),
    _panel(color: const Color(0xFFFFEAF5), child: ListTile(
      leading: const Icon(Icons.auto_awesome, color: mor),
      title: const Text('Akıllı alışveriş listesi', style: TextStyle(fontWeight: FontWeight.w800)),
      subtitle: const Text('Kategoriler, miktar notları, arama ve tamamlananlar'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const SmartShoppingPage()));
        await _alisverisYenile();
      },
    )),
    _baslik('Alışveriş listem', action: 'Ürün ekle', onTap: _urunEkle),
    FilledButton.icon(onPressed: _urunEkle, icon: const Icon(Icons.add),
      label: const Text('Listeye ürün ekle')),
    if (alisveris.isEmpty) _panel(child: const Text('Alışveriş listen boş.')),
    ...alisveris.map((u) => _panel(child: CheckboxListTile(title: Text(u),
      value: tamamlanan.contains(u), onChanged: (v) {
        setState(() {if (v == true) {tamamlanan.add(u);} else {tamamlanan.remove(u);}});
        _kaydet();
      }, secondary: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {
        setState(() {alisveris.remove(u); tamamlanan.remove(u);}); _kaydet();
      })))),
    const Text('Ürünler örnek katalogdur; gerçek satış, stok, fiyat veya ödeme bağlantısı henüz yoktur.',
      style: TextStyle(fontSize: 12)),
  ]);

  Widget _urunKategori(String cat) => ListView(padding: const EdgeInsets.all(15), children: [
    ...urunler.where((u) => u[1] == cat).map(_urunKarti),
    if (!urunler.any((u) => u[1] == cat)) const Text('Bu kategoride kayıtlı ürün bulunmuyor.'),
  ]);
  Widget _urunKarti(List<String> u) => _panel(color: const Color(0xFFFFEAF3), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(u[2], style: const TextStyle(fontSize: 42)), const SizedBox(height: 7),
    Text(u[0], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    Text(u[1], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
    const SizedBox(height: 7), FilledButton.tonal(onPressed: () {setState(() => sepet.add(u[0])); _kaydet();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${u[0]} sepete eklendi')));}, child: const Text('Sepete ekle')),
  ]));
  Widget _sepet() => ListView(padding: const EdgeInsets.all(15), children: [
    _baslik('Sepetim (${sepet.length})'),
    if (sepet.isEmpty) _panel(child: const Text('Sepetinde ürün bulunmuyor.')),
    ...sepet.asMap().entries.map((e) => _panel(child: ListTile(title: Text(e.value), trailing: IconButton(
      icon: const Icon(Icons.delete), onPressed: () {setState(() => sepet.removeAt(e.key)); _kaydet(); Navigator.pop(context); _sayfa('Sepetim', _sepet());})))),
    const Text('Bu sepet yalnızca taslak kaydıdır. Sipariş veya ödeme işlemi yapmaz.'),
  ]);

  Future<void> _adetTarihi() async {
    final d = await showDatePicker(context: context, initialDate: sonAdet ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (d != null) {setState(() => sonAdet = d); _kaydet();}
  }
  Widget _kadin() => ListView(padding: const EdgeInsets.all(15), children: [
    _hero('Kadınlara Özel 👑', 'Sağlıklı, mutlu ve güçlü senin için...', Icons.favorite),
    _panel(color: const Color(0xFFF1E5FF), child: ListTile(leading: const Icon(Icons.forum_outlined, color: mor), title: const Text('Kadınlar Forumu'), subtitle: const Text('Konular, deneyimler ve sohbet'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenOnlineForumPage())))),
    _baslik('Kendine iyi bak'),
    GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.15, children: [
        _kart('Güzellik & Bakım', 'Öneriler', Icons.spa, const Color(0xFFFFE0E8), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Güzellik & Bakım')))),
        _kart('Sağlık & Wellness', 'Kişisel sağlık', Icons.health_and_safety, const Color(0xFFECDFFF), () => _sayfa('Sağlık', _saglik())),
        _kart('Moda & Stil', 'İlham', Icons.checkroom, const Color(0xFFE5E3FF), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Moda & Stil')))),
        _kart('Diyet & Beslenme', 'Sağlıklı yaşam', Icons.local_dining, const Color(0xFFFFE9C8), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Diyet & Beslenme')))),
        _kart('Kişisel Gelişim', 'Kendine yatırım', Icons.psychology, const Color(0xFFE3F3FF), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Kişisel Gelişim')))),
        _kart('Rahatlama', 'Stres yönetimi', Icons.self_improvement, const Color(0xFFE3F3E5), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Rahatlama')))),
    ]),
    _panel(color: const Color(0xFFFFE5F0), child: ListTile(leading: const Icon(Icons.spa_outlined, color: mor), title: const Text('Doğum sonrası ve annelik'), subtitle: const Text('12 haftalık rehber, destek listesi ve kişisel notlar'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PostpartumCarePage())))),
    _panel(color: const Color(0xFFF3E7FF), child: ListTile(leading: const Icon(Icons.menu_book_outlined, color: mor), title: const Text('Kadın yaşamı içerik kütüphanesi'), subtitle: const Text('42 konu, arama, favoriler ve okundu takibi'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage())))),
    _baslik('Kadın sağlığı takibim'),
    _panel(color: const Color(0xFFFFE3F1), child: ListTile(leading: const Icon(Icons.edit_note, color: mor), title: const Text('Kadın sağlığı günlüğüm'), subtitle: const Text('Döngü, gebelik, doğum sonrası ve belirtiler'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomensHealthJournalPage())))),
    _panel(color: pembe, child: ListTile(leading: const Icon(Icons.calendar_month, color: mor),
      title: const Text('Son adet başlangıç tarihi'), subtitle: Text(sonAdet == null ? 'Henüz kaydedilmedi' : _tarih(sonAdet!)),
      trailing: const Icon(Icons.edit), onTap: _adetTarihi)),
    if (sonAdet != null) _panel(child: Text('Son kayıt üzerinden ${DateTime.now().difference(sonAdet!).inDays} gün geçti.')),
    _panel(child: ListTile(leading: const Icon(Icons.history, color: mor),
      title: const Text('Adet döngüsü geçmişim'),
      subtitle: const Text('Başlangıç tarihlerini ekle, görüntüle ve sil'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const CycleTrackerPage())))),
    _hero('Kendinize zaman ayırın 💕', 'Çünkü siz de değerlisiniz!', Icons.spa),
    const Padding(padding: EdgeInsets.all(12), child: Text('Döngü veya doğurganlık tahmini yapılmaz. Bu alan tıbbi danışmanlık sunmaz.', style: TextStyle(fontSize: 12))),
  ]);

  Widget _saglik() => ListView(padding: const EdgeInsets.all(15), children: [
    _hero('Sağlık 💗', 'Bebeğinizin ve sizin sağlığınız için güvenilir takip araçları', Icons.medical_services_outlined),
    const SizedBox(height: 10),
    _baslik('Bebek sağlığı'),
    _panel(color: const Color(0xFFFFE4F0), child: ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFFF6C9E6), child: Icon(Icons.child_care, color: mor)),
      title: const Text('Bebek sağlık günlüğü'), subtitle: const Text('Aşı, kontrol, belirti, alerji ve gelişim kayıtları'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BabyHealthPage())))),
    _panel(color: const Color(0xFFE9E0FF), child: ListTile(
      leading: const Icon(Icons.auto_stories_outlined, color: mor),
      title: const Text('Yaşa uygun gelişim rehberi'), subtitle: const Text('Beslenme, uyku, oyun ve güvenlik önerileri'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => AgeGuidesPage(birth: dogum))))),
    _baslik('Sık kullanılan sağlık konuları'),
    for (final t in ['Hastalıklar ve Belirtiler', 'Aşı Takvimi', 'Beslenme', 'Uyku Düzeni']) _rehberKart(t, Icons.health_and_safety_outlined),
    _baslik('Kadın sağlığı'),
    _panel(color: const Color(0xFFFFE4F0), child: ListTile(
      leading: const Icon(Icons.favorite_border, color: mor), title: const Text('Kadın sağlığı günlüğü'),
      subtitle: const Text('Döngü, gebelik, doğum sonrası ve kontrol notları'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomensHealthJournalPage())))),
    for (final t in ['Adet Dönemi', 'Gebelik', 'Doğum Sonrası', 'Rahatlama']) _rehberKart(t, Icons.favorite_outline),
    const Padding(padding: EdgeInsets.all(12), child: Text('Sağlık içerikleri bilgilendirme amaçlıdır; tanı veya tedavi yerine geçmez.', style: TextStyle(color: Colors.black54))),
  ]);

  final rehberKonular = const ['Adet Dönemi', 'Alerji', 'Anne Sütü', 'Aşı Takvimi', 'Bebek Bakımı',
    'Bebek Gelişimi', 'Bebek Masajı', 'Bebek Ürünleri', 'Beslenme', 'Doğum', 'Doğum Sonrası',
    'Eğitim & Oyun', 'Ev Düzeni', 'Gebelik', 'Güzellik & Bakım', 'Hastalıklar ve Belirtiler',
    'Kişisel Gelişim', 'Moda & Stil', 'Rahatlama', 'Uyku Düzeni'];

  void _rehberKonuAc(String konu) => _sayfa(konu, _icerik(konu));

  Widget _rehber() => _RehberSayfasi(konular: rehberKonular, ac: (konu) => _sayfa(konu, _icerik(konu)));
  Widget _rehberKart(String t, IconData icon) => _panel(child: ListTile(
    leading: Icon(icon, color: mor), title: Text(t), trailing: const Icon(Icons.chevron_right),
    onTap: () => _sayfa(t, _icerik(t))));
  Widget _icerik(String konu) => ListView(padding: const EdgeInsets.all(16), children: [
    _hero(konu, 'Anne & Bebek yaşam rehberi', Icons.menu_book),
    _baslik('Bu bölüm hakkında'),
    for (final bilgi in guideContent[konu] ?? const <String>['Bu başlıkla ilgili kişisel durumunuzu değerlendirmek için ilgili uzmana danışın.']) _panel(child: ListTile(leading: const Icon(Icons.check_circle_outline, color: mor), title: Text(bilgi))),
    _baslik('İlgili alanlar'), _rehberKart('Bebek Gelişimi', Icons.child_care),
    _rehberKart('Beslenme', Icons.restaurant), _rehberKart('Sağlık', Icons.favorite),
  ]);

  Future<void> _verilerimiSil() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tüm yerel kayıtlar silinsin mi?'),
        content: const Text('Bebek, gebelik, adet, beslenme, alışveriş ve yaşam araçlarındaki kayıtlar bu cihazdan kalıcı olarak silinecek. Bu işlem geri alınamaz. Önce şifreli yedek alman önerilir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kayıtları sil')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await PrivacyService.deleteLocalRecords();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AnaUygulama()),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bazı kayıtlar silinemedi. Lütfen tekrar dene.')),
      );
    }
  }

  void _analizAc() => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => TodayInsightsPage(babyName: bebekAdi, birth: dogum, events: List.of(olaylar), measurements: List.of(olcumler))));

  void _hizliErisim() {
    void sekmeyeGit(int index) { if (mounted) setState(() => sekme = index); }
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, showDragHandle: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .80),
      builder: (_) => QuickAccessSheet(items: [
        QuickAccessItem(title: 'Bugün ve analizler', description: 'Günlük özet ve doktor raporu', icon: Icons.insights, onOpen: () => _analizAc()),
        QuickAccessItem(title: 'Ana Sayfa', description: 'Genel görünüm', icon: Icons.home_outlined, onOpen: () => sekmeyeGit(0)),
        QuickAccessItem(title: 'Bebeğim', description: 'Bebek gelişimi ve kayıtları', icon: Icons.child_care, onOpen: () => sekmeyeGit(1)),
        QuickAccessItem(title: 'Bebek sağlığı', description: 'Aşı, gelişim, hastalık ve alerji günlüğü', icon: Icons.medical_information_outlined, onOpen: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BabyHealthPage()))),
        QuickAccessItem(title: 'Çocuk profilleri', description: 'Ek çocukların ad ve doğum tarihleri', icon: Icons.people_outline, onOpen: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ChildProfilesPage()))),
        QuickAccessItem(title: 'Günlük etkinlik planı', description: 'Oyun, kitap ve aile etkinliklerini planla', icon: Icons.event_note_outlined, onOpen: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ActivityPlannerPage()))),
        QuickAccessItem(title: 'Yaşa uygun rehber', description: 'Beslenme, oyun, uyku ve güvenlik önerileri', icon: Icons.auto_stories_outlined, onOpen: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => AgeGuidesPage(birth: dogum)))),
        QuickAccessItem(title: 'Tarifler', description: 'Yemek ve ek gıda tarifleri', icon: Icons.restaurant_menu, onOpen: () => sekmeyeGit(2)),
        QuickAccessItem(title: 'Alışveriş', description: 'Liste ve sepet', icon: Icons.shopping_bag_outlined, onOpen: () => sekmeyeGit(3)),
        QuickAccessItem(title: 'Kadın sağlığı günlüğü', description: 'Döngü, gebelik, doğum sonrası ve menopoz notları', icon: Icons.health_and_safety_outlined, onOpen: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomensHealthJournalPage()))),
        QuickAccessItem(title: 'Kadınlar', description: 'Kadın sağlığı ve gebelik', icon: Icons.favorite_outline, onOpen: () => sekmeyeGit(4)),
        QuickAccessItem(title: 'Beslenme kaydı', description: 'Yeni beslenme kaydı oluştur', icon: Icons.local_drink_outlined, onOpen: () => _olayEkle('Beslenme')),
        QuickAccessItem(title: 'Uyku kaydı', description: 'Yeni uyku kaydı oluştur', icon: Icons.bedtime_outlined, onOpen: () => _olayEkle('Uyku')),
        QuickAccessItem(title: 'Büyüme ölçümü', description: 'Boy, kilo ve baş çevresi', icon: Icons.monitor_weight_outlined, onOpen: _olcumEkle),
        QuickAccessItem(title: 'Bebek profili', description: 'Ad ve doğum tarihi', icon: Icons.account_circle_outlined, onOpen: _profil),
        QuickAccessItem(title: 'Yaşam araçları', description: 'Aile yaşam merkezi', icon: Icons.dashboard_customize_outlined,
          onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LifeHubPage()))),
        QuickAccessItem(title: 'Yedekleme', description: 'Verileri yedekle veya geri yükle', icon: Icons.backup_outlined,
          onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BackupPage()))),
        QuickAccessItem(title: 'Aile hatırlatıcıları', description: 'Tarihli kontrol ve aile notları', icon: Icons.event_note_outlined,
          onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RemindersPage()))),
        QuickAccessItem(title: 'Yayın öncesi kontrol', description: 'Android test ve yayın kontrol listesi', icon: Icons.fact_check_outlined,
          onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReleaseCheckPage()))),
        QuickAccessItem(title: 'Rehber', description: 'A’dan Z’ye bilgi rehberi', icon: Icons.menu_book_outlined,
          onOpen: () => _sayfa('A’dan Z’ye Rehber', _rehber())),
      ]),
    );
  }

  Widget _profilSayfasi() => ListView(padding: const EdgeInsets.all(16), children: [
    _hero('Profilim', 'Kişisel kayıtlar ve uygulama ayarları', Icons.account_circle),
    _baslik('Hesabım'), _rehberKart('Bebek profilim', Icons.child_care),
    _panel(child: ListTile(title: Text(bebekAdi.isEmpty ? 'Bebek profili oluştur' : bebekAdi),
      subtitle: Text(yas), trailing: const Icon(Icons.edit), onTap: _profil)),
    _baslik('Üyelik'), _panel(child: ListTile(
      leading: const Icon(Icons.account_circle_outlined, color: Color(0xFFF0449B)),
      title: const Text('Bulut hesabım'),
      subtitle: const Text('Kayıt ol, giriş yap, şifreni sıfırla'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CloudAccountPage())),
    )), _panel(child: ListTile(
      leading: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFF0449B)),
      title: const Text('Üyelik seçenekleri'),
      subtitle: const Text('Ücretsiz, Premium ve Aile paketlerini incele'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MembershipPage())),
    )),
    _baslik('Keşif ve yönetim'),
    _panel(child: ListTile(leading: const Icon(Icons.manage_search_outlined, color: mor),
      title: const Text('Akıllı içerik keşfi'), subtitle: const Text('Çevrimdışı konu arama ve öneriler'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SmartDiscoveryPage())))),
    _panel(child: ListTile(leading: const Icon(Icons.admin_panel_settings, color: mor),
      title: const Text('Merkezi yönetim paneli'),
      subtitle: const Text('Sunucu yetkisi gerektirir; forum ve toplu istatistikler'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminDashboardPage())))),
    _panel(child: ListTile(leading: const Icon(Icons.admin_panel_settings_outlined, color: mor),
      title: const Text('Yerel yönetim özeti (ön izleme)'),
      subtitle: const Text('Bu cihazdaki kayıt sayıları; gerçek yönetici paneli değildir'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LocalAdminPreviewPage())))),
    _baslik('Kaydedilenler'), _panel(child: Text('${favoriler.length} favori tarif • ${olaylar.length} bakım kaydı • ${olcumler.length} büyüme ölçümü')),
    _baslik('Verilerim'), _panel(child: ListTile(leading: const Icon(Icons.backup_outlined),
      title: const Text('Yedekleme ve geri yükleme'),
      subtitle: const Text('Kayıtları dışa aktar veya geri yükle'),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupPage())))),
    _baslik('Gizlilik'), _panel(child: const Text('Sağlık kayıtları güvenli depolama üzerinden korunur; bazı tercihler ve alışveriş verileri cihazın yerel depolamasında tutulur. Uygulama hesap, bulut eşitleme veya otomatik bulut yedekleme sunmaz. Daha önce dışa aktarılan yedekler ve panoya kopyalanan içerikler ayrıca silinmelidir.')),
    _panel(child: ListTile(
      leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
      title: const Text('Bu cihazdaki kayıtlarımı sil'),
      subtitle: const Text('Onay sonrası uygulama kayıtlarını kalıcı siler'),
      onTap: _verilerimiSil,
    )),
  ]);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Anne & Bebek 💕', style: TextStyle(fontWeight: FontWeight.w900, color: mor, fontSize: 19)),
      actions: [
        IconButton(tooltip: 'Ara ve hızlı erişim', icon: const Icon(Icons.search_rounded), onPressed: _hizliErisim),
        IconButton(tooltip: 'Bebek profilleri', icon: const Icon(Icons.child_care_rounded), onPressed: _profillerAc),
        PopupMenuButton<String>(tooltip: 'Diğer bölümler', icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            switch (value) {
              case 'guide': _sayfa('A’dan Z’ye Rehber', _rehber());
              case 'tools': Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LifeHubPage()));
              case 'profile': _sayfa('Profilim', _profilSayfasi());
              case 'membership': Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MembershipPage()));
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'guide', child: ListTile(leading: Icon(Icons.menu_book_outlined), title: Text('A’dan Z’ye Rehber'))),
            PopupMenuItem(value: 'tools', child: ListTile(leading: Icon(Icons.dashboard_customize_outlined), title: Text('Yaşam araçları'))),
            PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.person_outline), title: Text('Profilim'))),
            PopupMenuItem(value: 'membership', child: ListTile(leading: Icon(Icons.workspace_premium_outlined), title: Text('Üyelik seçenekleri'))),
          ]),
      ],
    ),
    body: yuklendi ? [_ana, _bebek, _tarif, _alisveris, _kadin][sekme]()
      : yuklemeHatasi != null
        ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
            mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_outlined, size: 44, color: mor),
              const SizedBox(height: 12),
              Text(yuklemeHatasi!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: () {
                setState(() => yuklemeHatasi = null);
                _yukle();
              }, icon: const Icon(Icons.refresh), label: const Text('Tekrar dene')),
            ])))
        : const Center(child: CircularProgressIndicator()),
    floatingActionButton: FloatingActionButton.small(backgroundColor: const Color(0xFFFF5A9C), foregroundColor: Colors.white,
      onPressed: () => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (ctx) =>
        SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.local_drink), title: const Text('Beslenme kaydı'), onTap: () {Navigator.pop(ctx); _olayEkle('Beslenme');}),
          ListTile(leading: const Icon(Icons.bedtime), title: const Text('Uyku kaydı'), onTap: () {Navigator.pop(ctx); _olayEkle('Uyku');}),
          ListTile(leading: const Icon(Icons.monitor_weight), title: const Text('Boy / kilo kaydı'), onTap: () {Navigator.pop(ctx); _olcumEkle();}),
          ListTile(leading: const Icon(Icons.add_shopping_cart), title: const Text('Alışveriş listesi'), onTap: () {Navigator.pop(ctx); _urunEkle();}),
        ]))), child: const Icon(Icons.add)),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    bottomNavigationBar: NavigationBar(height: 76, selectedIndex: sekme, onDestinationSelected: (i) => setState(() => sekme = i),
      backgroundColor: const Color(0xFFFFF9FD), indicatorColor: pembe,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
        NavigationDestination(icon: Icon(Icons.child_care_outlined), selectedIcon: Icon(Icons.child_care), label: 'Bebeğim'),
        NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Tarifler'),
        NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Alışveriş'),
        NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Kadınlar'),
      ]),
  );
}


/// Pastel öneri kartı: tüm yüzey tıklanabilir ve dar ekranlarda taşmayı önler.
class ExpandedSuggestionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  const ExpandedSuggestionCard({super.key, required this.title, required this.description,
    required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFFE9F3),
    borderRadius: BorderRadius.circular(24),
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 28, backgroundColor: Colors.white70,
          child: Icon(icon, color: mor, size: 30)),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center, maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: mor, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 5),
        Text(description, textAlign: TextAlign.center, maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: mor, fontSize: 11)),
      ]),
    )),
  );
}

class _RehberSayfasi extends StatefulWidget {
  final List<String> konular;
  final ValueChanged<String> ac;
  const _RehberSayfasi({required this.konular, required this.ac});
  @override
  State<_RehberSayfasi> createState() => _RehberSayfasiState();
}
class _RehberSayfasiState extends State<_RehberSayfasi> {
  String q = '';
  String filtre = 'Tümü';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.konular.where((topic) {
      final normalized = topic.toLowerCase();
      if (!normalized.contains(q.trim().toLowerCase())) return false;
      if (filtre == 'Tümü') return true;
      final first = topic.toUpperCase().substring(0, 1);
      if (filtre == 'A-H') return 'ABCDEFGH'.contains(first);
      if (filtre == 'I-R') return 'IİJKLMNOÖPR'.contains(first);
      return 'SŞTUÜVYZ'.contains(first);
    }).toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFD8E9), Color(0xFFE8D9FF)]),
        borderRadius: BorderRadius.circular(28)),
        child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('A’dan Z’ye Rehber 📚', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: mor)),
          SizedBox(height: 8), Text('Anne, bebek ve aile yaşamı için güvenilir başlangıç bilgileri.', style: TextStyle(color: mor, height: 1.4)),
        ])), SizedBox(width: 10), Icon(Icons.auto_stories_rounded, color: mor, size: 54)])),
      const SizedBox(height: 18),
      TextField(onChanged: (v) => setState(() => q = v),
        decoration: InputDecoration(hintText: 'Konu ara: uyku, beslenme, gelişim...', prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none))),
      const SizedBox(height: 14),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['Tümü', 'A-H', 'I-R', 'S-Z'].map((f) =>
        Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(f), selected: filtre == f,
          selectedColor: pembe, onSelected: (_) => setState(() => filtre = f)))).toList())),
      const SizedBox(height: 18),
      Text('${filtered.length} konu', style: const TextStyle(color: mor, fontWeight: FontWeight.w800, fontSize: 17)),
      const SizedBox(height: 8),
      for (final topic in filtered) Padding(padding: const EdgeInsets.only(bottom: 8), child: Card(
        color: Colors.white, child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFFFE6F2), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.menu_book_rounded, color: mor)),
          title: Text(topic, style: const TextStyle(fontWeight: FontWeight.w700, color: mor)),
          subtitle: const Text('Bilgileri ve önerileri oku'),
          trailing: const Icon(Icons.chevron_right_rounded, color: mor), onTap: () => widget.ac(topic)))),
      if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Aradığınız konuda içerik bulunamadı. Başka bir kelime deneyin.', textAlign: TextAlign.center)),
      const SizedBox(height: 12),
      const Text('Bu rehber genel bilgilendirme amaçlıdır; tıbbi tanı ve tedavi yerine geçmez.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: mor)),
    ]);
  }
}
