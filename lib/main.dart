import 'utils/privacy_log_sanitizer.dart';
import 'utils/dialog_helpers.dart';
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
import 'widgets/daily_quick_actions.dart';
import 'utils/baby_age.dart';
import 'utils/child_profile_validator.dart';
import 'sleep_journal.dart';
import 'dart:convert';
import 'extra_features.dart';
import 'life_hub.dart';
import 'guide_content.dart';
import 'cycle_tracker.dart';
import 'tracking_journal.dart';
import 'screens/backup_page.dart';
import 'services/privacy_service.dart';
import 'widgets/consent_gate.dart';
import 'screens/encyclopedia_page.dart';
import 'data/encyclopedia/encyclopedia.dart';
import 'widgets/visuals.dart';
import 'widgets/add_to_notebook_tile.dart';
import 'services/recipe_notebook_bridge.dart';
import 'services/local_reminder_notifications.dart';
import 'services/secure_health_store.dart';
import 'data/product_catalog.dart';
import 'data/general_recipe_catalog.dart';
import 'data/shopping_needs.dart';
import 'widgets/recipe_info_sections.dart';
import 'widgets/pastel_shell.dart';
import 'widgets/reference_widgets.dart';
import 'services/cycle_estimate.dart';
import 'screens/monthly_baby_guide_page.dart';
import 'screens/baby_activity_catalog_page.dart';
import 'screens/baby_nutrition_page.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // Renkli simgeler: sistemin emoji yazı tipi (cihazda zaten mevcut).
      fontFamilyFallback: const ['Noto Color Emoji', 'Apple Color Emoji'],
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
        elevation: 0, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent,
        centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFF0449B), foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFFF7EAF4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none)),
    ),
    home: const ConsentGate(child: AnaUygulama()),
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
  Object? _sonKayitHatasi;
  String? yuklemeHatasi;
  String arama = '';
  String tarifFiltre = 'Tümü';
  int tarifSureSiniri = 0; // 0: tüm süreler
  int tarifGosterimSiniri = 40; // Izgarada aynı anda çizilen tarif sayısı
  bool sadeceFavoriTarifler = false;
  DateTime takipGunu = DateTime.now(); // Günlük Takip ekranındaki gün
  int bebekSekme = 0;
  int kadinSekme = 0; // Kadınlar: Döngü Takibi/Sağlık/İyi Hisset
  DateTime donguAyi = DateTime.now();
  final List<DateTime> donguTarihleri = []; // Bebeğim: Gelişim/Sağlık/Aşılar/Notlar
  final List<String> sepet = [];
  final Map<String, int> alisverisAdet = {}; // Alışveriş listesindeki adetler
  int alisverisSekme = 0; // Bebek/Anne/Aile Ürünleri
  String? alisverisAltKategori;
  final Set<String> tamamlanan = {};


  @override
  void initState() { super.initState(); _yukle(); _donguYukle(); }

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
      final adetler = jsonDecode(p.getString('alisveris_adet') ?? '{}');
      if (adetler is Map) {
        for (final e in adetler.entries) {
          if (e.key is String && e.value is int && (e.value as int) >= 1) alisverisAdet[e.key as String] = e.value as int;
        }
      }
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
        p.setString('alisveris_adet', jsonEncode(alisverisAdet)),
      ]);
      _sonKayitHatasi = null;
      return true;
    } catch (error) {
      _sonKayitHatasi = error;
      logSafeError('Kayıt başarısız', error);
      return false;
    }
  }

  void _kayitBildir(bool basarili, {String basariMesaji = 'Kayıt tamamlandı.', Object? hata}) {
    if (!mounted) return;
    // Hata türü (içerik değil) gösterilir; cihazdaki sorunları bildirmek için.
    final e = hata ?? _sonKayitHatasi;
    final kod = e == null ? '' : ' (Hata kodu: ${e is PlatformException ? 'PE-${e.code}' : e.runtimeType})';
    // Önceki bildirim beklemeden yenisi gösterilir (art arda işlemler).
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
      content: Text(basarili ? basariMesaji : 'Kayıt kaydedilemedi. Lütfen tekrar deneyin.$kod'),
    ));
  }

  String _tarih(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  String get yas => BabyAge.label(dogum, DateTime.now());

  void _profillerAc() => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const ChildProfilesPage()));

  Future<void> _profil() async {
    final ad = TextEditingController(text: bebekAdi);
    DateTime? secilen = dogum;
    ModalRoute<dynamic>? profileRoute;
    var kaydediliyor = false; // Çift dokunuşta ikinci kayıt/pop engellenir.
    await showDialog<void>(context: context, builder: (ctx) {
      profileRoute = ModalRoute.of(ctx);
      return StatefulBuilder(builder: (ctx, yenile) => AlertDialog(
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
          if (kaydediliyor) return;
          kaydediliyor = true;
          try {
          // GP-02: ad ve doğum tarihi kaydetmeden önce doğrulanır.
          final adHatasi = ChildProfileValidator.validateName(ad.text);
          if (adHatasi != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(adHatasi)));
            return;
          }
          final kayitTarihleri = [
            for (final o in [...olaylar, ...olcumler])
              ?DateTime.tryParse(o['zaman'] ?? o['tarih'] ?? ''),
          ];
          if (secilen != null && ChildProfileValidator.hasRecordsBeforeBirth(secilen!, kayitTarihleri)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(
              'Bu doğum tarihinden önceye ait kayıtlar var. Tarihi kontrol edin veya önce o kayıtları düzenleyin.')));
            return;
          }
          final oncekiAd = bebekAdi;
          final oncekiDogum = dogum;
          setState(() { bebekAdi = ad.text.trim(); dogum = secilen; });
          final basarili = await _kaydet();
          if (!basarili && mounted) setState(() { bebekAdi = oncekiAd; dogum = oncekiDogum; });
          if (!mounted || !ctx.mounted) return;
          if (basarili && (ModalRoute.of(ctx)?.isCurrent ?? false)) Navigator.of(ctx).pop();
          _kayitBildir(basarili, basariMesaji: 'Bebek profili kaydedildi.');
                  } finally {
            kaydediliyor = false;
          }
        }, child: const Text('Kaydet'))],
    )); });
    await profileRoute?.completed;
    ad.dispose();
  }

  Future<void> _olayEkle(String tur, {DateTime? zaman}) async {
    final not = TextEditingController();
    ModalRoute<dynamic>? recordRoute;
    var kaydediliyor = false; // Çift dokunuşta ikinci kayıt/pop engellenir.
    await showDialog<void>(context: context, builder: (ctx) {
      recordRoute = ModalRoute.of(ctx);
      return AlertDialog(
      title: Text('$tur kaydı'),
      content: TextField(controller: not, autofocus: true, decoration: const InputDecoration(labelText: 'Açıklama / miktar (isteğe bağlı)'), maxLines: 2),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () async {
          if (kaydediliyor) return;
          kaydediliyor = true;
          try {
          final yeniKayit = {'tur': tur, 'not': not.text.trim(), 'zaman': (zaman ?? DateTime.now()).toIso8601String()};
          setState(() => olaylar.insert(0, yeniKayit));
          final basarili = await _kaydet();
          if (!basarili && mounted) setState(() => olaylar.remove(yeniKayit));
          if (!mounted || !ctx.mounted) return;
          if (basarili && (ModalRoute.of(ctx)?.isCurrent ?? false)) Navigator.of(ctx).pop();
          _kayitBildir(basarili, basariMesaji: '$tur kaydı eklendi.');
                  } finally {
            kaydediliyor = false;
          }
        }, child: const Text('Kaydet'))],
    ); });
    await recordRoute?.completed;
    not.dispose();
  }

  Future<void> _olcumEkle() async {
    final boy = TextEditingController(); final kilo = TextEditingController(); final bas = TextEditingController();
    ModalRoute<dynamic>? measureRoute;
    var kaydediliyor = false; // Çift dokunuşta ikinci kayıt/pop engellenir.
    await showDialog<void>(context: context, builder: (ctx) {
      measureRoute = ModalRoute.of(ctx);
      return AlertDialog(
      title: const Text('Büyüme ölçümü'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: boy, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Boy (cm)')),
        TextField(controller: kilo, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Kilo (kg)')),
        TextField(controller: bas, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Baş çevresi (cm)')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () async {
          if (kaydediliyor) return;
          kaydediliyor = true;
          try {
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
          if (basarili && (ModalRoute.of(ctx)?.isCurrent ?? false)) Navigator.of(ctx).pop();
          _kayitBildir(basarili, basariMesaji: 'Büyüme ölçümü kaydedildi.');
                  } finally {
            kaydediliyor = false;
          }
        }, child: const Text('Kaydet'))],
    ); });
    await measureRoute?.completed;
    boy.dispose(); kilo.dispose(); bas.dispose();
  }

  // Boş alan serbesttir; girilen değer ise sayısal ve makul aralıkta olmalıdır.
  bool _olcumGecerli(String metin, double? deger, double min, double max) =>
      metin.trim().isEmpty || (deger != null && deger.isFinite && deger >= min && deger <= max);

  // Kayıt başarısız olursa silinen öğeyi eski konumuna geri koy.
  Future<void> _kayitSil(
    List<Map<String, String>> liste,
    Map<String, String> kayit,
  ) async {
    final index = liste.indexOf(kayit);
    if (index < 0) return;
    setState(() => liste.removeAt(index));
    final basarili = await _kaydet();
    if (!mounted) return;
    if (!basarili) {
      setState(() => liste.insert(index.clamp(0, liste.length), kayit));
    }
    _kayitBildir(basarili,
        basariMesaji: 'Kayıt silindi.');
  }

  Future<void> _urunEkle() async {
    final urun = TextEditingController();
    await showDialogAndDispose<void>(disposables: [urun], context: context, builder: (ctx) => AlertDialog(
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
          if (basarili && (ModalRoute.of(ctx)?.isCurrent ?? false)) Navigator.of(ctx).pop();
          _kayitBildir(basarili, basariMesaji: 'Ürün listeye eklendi.');
        }, child: const Text('Ekle'))],
    ));
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

  Widget _hero(String title, String subtitle, IconData icon, {VoidCallback? onTap, String button = 'Keşfet', String? emoji}) =>
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
          alignment: Alignment.center,
          child: emoji != null
            ? Text(emoji, textScaler: TextScaler.noScaling, style: const TextStyle(fontSize: 60))
            : IconGlyph(icon, size: 66, color: const Color(0xFFD44A9A))),
      ]),
    );

  Widget _search(String hint, ValueChanged<String> change) => TextField(onChanged: change,
    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: hint,
      filled: true, fillColor: const Color(0xFFF8EDF7), border: OutlineInputBorder(
        borderSide: BorderSide.none, borderRadius: BorderRadius.circular(28))));

  void _sayfa(String title, Widget child) => Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => Scaffold(appBar: AppBar(title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFE94791)))),
      body: SafeArea(child: child))));

  Widget _ana() => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
    PastelGreetingCard(
      greeting: 'Merhaba 👋',
      subtitle: bebekAdi.isEmpty ? 'İyi ki buradasın!\nBebek profilini ekleyerek başla.' : 'İyi ki buradasın!'),
    const SizedBox(height: 12),
    _panel(
      color: const Color(0xFFFFFCFF),
      child: ListTile(
        leading: const BabyFaceAvatar(size: 48),
        title: Text(bebekAdi.isEmpty ? 'Bebek profilini tamamla' : '$bebekAdi 💗',
          style: const TextStyle(fontWeight: FontWeight.w800, color: mor)),
        subtitle: Text(yas),
        trailing: const Icon(Icons.chevron_right_rounded, color: mor),
        onTap: _profillerAc,
      ),
    ),
    const SizedBox(height: 4),
    LayoutBuilder(builder: (context, c) {
      // Dar ekranlarda (ör. 280 px) tek sütuna düşer; taşma olmaz.
      final columns = c.maxWidth < 300 ? 1 : 2;
      final tiles = <Widget>[
        PastelModuleTile(icon: Icons.event_note_rounded, color: const Color(0xFFEDE4FF),
          title: 'Günlük Takip', subtitle: 'Uyku • Beslenme • Bez',
          onTap: () => setState(() { takipGunu = DateTime.now(); sekme = 6; })),
        PastelModuleTile(icon: Icons.child_care_rounded, color: const Color(0xFFFFE3F0),
          title: 'Bebeğim', subtitle: 'Gelişim • Sağlık',
          onTap: () => setState(() => sekme = 1)),
        PastelModuleTile(icon: Icons.restaurant_menu_rounded, color: const Color(0xFFFFEBD9),
          title: 'Yemek Tarifleri', subtitle: 'Aile için lezzetler',
          onTap: () => setState(() => sekme = 2)),
        PastelModuleTile(icon: Icons.pregnant_woman_rounded, color: const Color(0xFFFFE3F0),
          title: 'Gebelik', subtitle: 'Hafta hafta takip',
          onTap: () => _sayfa('Gebelik', const PregnancyPage())),
        PastelModuleTile(icon: Icons.local_florist_rounded, color: const Color(0xFFFFE6EE),
          title: 'Kadınlar', subtitle: 'Döngü • Sağlık',
          onTap: () => setState(() => sekme = 4)),
        PastelModuleTile(icon: Icons.shopping_cart_outlined, color: const Color(0xFFEDE4FF),
          title: 'Alışveriş', subtitle: 'Bebek • Anne • Aile',
          onTap: () => setState(() => sekme = 3)),
      ];
      return GridView.count(
        crossAxisCount: columns, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10,
        childAspectRatio: columns == 1 ? c.maxWidth / 72 : ((c.maxWidth - 10) / 2) / 72,
        children: tiles);
    }),
    const SizedBox(height: 6),
    _panel(padding: EdgeInsets.zero, color: const Color(0xFFF7EAF5), child: ListTile(
      leading: const Icon(Icons.search_rounded, color: mor),
      title: const Text('A’dan Z’ye Rehber’de ara...', style: TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: mor),
      onTap: () => _ansiklopediAc())),
    _baslik('Bugünkü takip özeti'),
    _panel(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sayac('Beslenme', 'Beslenme'),
          _sayac('Uyku', 'Uyku'),
          _sayac('Bez', 'Bez değişimi'),
        ],
      ),
    ),
    _baslik('Hızlı günlük kayıt ✨'),
    DailyQuickActions(
      // Hızlı işlemler, ana ekrandaki günlük sayacıyla aynı kaydı kullanır.
      onFeeding: () => _olayEkle('Beslenme'),
      onSleep: () => _olayEkle('Uyku'),
      onDiaper: () => _olayEkle('Bez değişimi'),
      onMeasurement: _olcumEkle,
    ),
    _baslik('Gelişim ve beslenme'),
    _panel(
      child: Column(children: [
        ListTile(
          leading: const Icon(Icons.monitor_weight_outlined, color: mor),
          title: const Text('Büyüme geçmişi'),
          subtitle: Text(olcumler.isEmpty
              ? 'Henüz ölçüm eklenmedi'
              : '${olcumler.length} ölçüm kaydı • grafiklere göz at'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _sayfa('Büyüme Grafikleri',
              GrowthChartsPage(measurements: olcumler)),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.restaurant_menu_rounded, color: mor),
          title: const Text('Bebeğime uygun tarifler'),
          subtitle: const Text('Yaş, kategori ve malzemeye göre keşfet'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BabyRecipesPage())),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.security_outlined, color: mor),
          title: const Text('Şifreli yedekleme ve geri yükleme'),
          subtitle: const Text('Kayıtlarını güvenli biçimde dışa aktar'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BackupPage())),
        ),
      ]),
    ),
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
        _mini('Tüm Kategoriler', Icons.apps, const Color(0xFFEDE0FF), () => _ansiklopediAc()),
      ])),
    _panel(color: const Color(0xFFFFE6F3), child: ListTile(leading: const Icon(Icons.auto_awesome_outlined, color: mor), title: const Text('Bilgi Asistanı'), subtitle: const Text('Bebek, gebelik, aşı ve tarif soruların · çevrimdışı'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AiAssistantPage())))),
    _panel(color: const Color(0xFFF3E6FF), child: ListTile(leading: const Icon(Icons.manage_search_outlined, color: mor), title: const Text('Akıllı içerik keşfi'), subtitle: const Text('Bebek, kadın ve yaşam konularında çevrimdışı arama'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SmartDiscoveryPage())))),
    _baslik('Bugünün önerileri ✨', action: 'Tümünü gör', onTap: () => setState(() => sekme = 2)),
    Row(children: [Expanded(child: _oner('Bebeğiniz için sağlıklı tarifler', 'Yaşa uygun bebek yemekleri', Icons.ramen_dining_rounded, () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BabyRecipesPage())))),
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
    _baslik('A’dan Z’ye rehber', action: 'Hepsini aç', onTap: () => _ansiklopediAc()),
    _panel(child: ListTile(leading: const Icon(Icons.auto_stories_rounded, color: mor), title: const Text('Konuları alfabetik keşfet'), subtitle: const Text('Arama, kategori ve detaylı rehber içerikleri'), trailing: const Icon(Icons.chevron_right), onTap: () => _ansiklopediAc())),
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

  // Paket 39 referansı: çocuk kartı + Gelişim/Sağlık/Aşılar/Notlar sekmeleri.
  // Önceki sürümdeki tüm bağlantılar ilgili sekmenin altında korunur.
  Widget _bebek() {
    final ay = BabyAge.completedMonths(dogum, DateTime.now()) ?? 0;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      ChildHeaderCard(
        name: bebekAdi.isEmpty ? 'Bebek profili ekle' : bebekAdi,
        age: yas,
        onTap: bebekAdi.isEmpty ? _profil : _profillerAc,
      ),
      PastelSegmentTabs(
        labels: const ['Gelişim', 'Sağlık', 'Aşılar', 'Notlar'],
        selected: bebekSekme,
        onChanged: (i) => setState(() => bebekSekme = i),
      ),
      const SizedBox(height: 12),
      ...switch (bebekSekme) {
        1 => _bebekSaglik(ay),
        2 => _bebekAsilar(),
        3 => _bebekNotlar(),
        _ => _bebekGelisim(ay),
      },
      const Padding(padding: EdgeInsets.all(10), child: Text('Takip kayıtları kişisel kullanım içindir; sağlık değerlendirmesi yerine geçmez.', style: TextStyle(fontSize: 11))),
    ]);
  }

  List<Widget> _bebekGelisim(int ay) {
    final sirali = [...olcumler]..sort((a, b) => (a['tarih'] ?? '').compareTo(b['tarih'] ?? ''));
    String son(String alan, String birim) {
      for (final o in sirali.reversed) {
        final v = double.tryParse(o[alan] ?? '');
        if (v != null) return '${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1).replaceAll('.', ',')} $birim';
      }
      return '—';
    }
    final kilolar = sirali.map((o) => double.tryParse(o['kilo'] ?? '')).whereType<double>().toList();
    return [
      GrowthSummaryCard(
        weights: kilolar,
        weight: son('kilo', 'kg'),
        height: son('boy', 'cm'),
        head: son('basCevresi', 'cm'),
        onOpen: () => _sayfa('Büyüme Grafikleri', GrowthChartsPage(measurements: olcumler)),
        onAdd: _olcumEkle,
      ),
      PastelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PastelSectionHeader(icon: Icons.volunteer_activism_outlined, title: 'Günlük Bakım'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: CareShortcut(icon: Icons.local_drink_outlined, label: 'Beslenme', color: const Color(0xFFFFE9D2), onTap: () => _olayEkle('Beslenme'))),
          const SizedBox(width: 8),
          Expanded(child: CareShortcut(icon: Icons.bedtime_outlined, label: 'Uyku', color: const Color(0xFFEDE4FF), onTap: () => _olayEkle('Uyku'))),
          const SizedBox(width: 8),
          Expanded(child: CareShortcut(icon: Icons.baby_changing_station_outlined, label: 'Bez', color: const Color(0xFFE0EEFF), onTap: () => _olayEkle('Bez değişimi'))),
          const SizedBox(width: 8),
          Expanded(child: CareShortcut(icon: Icons.medication_outlined, label: 'İlaç / Vitamin', color: const Color(0xFFFFE3EC), onTap: () => _olayEkle('İlaç / Vitamin'))),
        ]),
      ])),
      PastelLinkCard(icon: Icons.event_note_rounded, title: 'Günlük Takip',
        subtitle: 'Uyku, beslenme, bez ve ilaç kayıtları tarih tarih',
        iconColor: const Color(0xFFEDE4FF), onTap: () => setState(() => sekme = 6)),
      PastelLinkCard(icon: Icons.auto_graph_rounded, title: 'Aylık gelişim rehberi',
        subtitle: dogum == null ? 'Doğum tarihi girildiğinde bebeğin ayına göre açılır' : '$ay. ay için gelişim, oyun ve bakım önerileri',
        onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => MonthlyBabyGuidePage(initialMonth: ay.clamp(0, 72))))),
      PastelLinkCard(icon: Icons.toys_outlined, title: 'Yaşa uygun aktiviteler',
        subtitle: 'Gelişimi destekleyen oyun ve etkinlikler', iconColor: const Color(0xFFFFEBD9),
        onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BabyActivityCatalogPage()))),
      _baslik('Büyüme ölçümleri', action: 'Ölçüm ekle', onTap: _olcumEkle),
      if (olcumler.isEmpty) _panel(child: const Text('Boy ve kilo ölçümü eklediğinde burada görünecek.')),
      ...olcumler.map((o) => _panel(child: ListTile(leading: const Icon(Icons.show_chart, color: mor),
        title: Text('Boy: ${_olcumMetni(o['boy'], 'cm')}  •  Kilo: ${_olcumMetni(o['kilo'], 'kg')}\nBaş çevresi: ${_olcumMetni(o['basCevresi'], 'cm')}'),
        subtitle: Text(_guvenliTarih(o['tarih'])),
        trailing: IconButton(tooltip: 'Ölçümü sil', icon: const Icon(Icons.delete_outline), onPressed: () => _kayitSil(olcumler, o))))),
      _baslik('Bakım rehberi'),
      _rehberKart('Bebek Masajı', Icons.spa), _rehberKart('Bebek Gelişimi', Icons.auto_graph),
      _rehberKart('Uyku Düzeni', Icons.bedtime),
    ];
  }

  List<Widget> _bebekSaglik(int ay) => [
    PastelLinkCard(icon: Icons.health_and_safety_outlined, title: 'Bebek sağlık günlüğü',
      subtitle: 'Kontrol, belirti, alerji ve gelişim kayıtları',
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BabyHealthPage()))),
    PastelLinkCard(icon: Icons.auto_stories_outlined, title: 'Yaşa uygun gelişim rehberi',
      subtitle: 'Beslenme, uyku, oyun ve güvenlik önerileri', iconColor: const Color(0xFFEDE4FF),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => AgeGuidesPage(birth: dogum)))),
    PastelLinkCard(icon: Icons.restaurant_outlined, title: 'Bebek beslenme rehberi',
      subtitle: 'Aya göre ek gıda ve öğün önerileri', iconColor: const Color(0xFFFFEBD9),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => BabyNutritionPage(initialMonth: ay.clamp(6, 72))))),
    PastelLinkCard(icon: Icons.restaurant_menu_rounded, title: 'Bebek tarifleri',
      subtitle: 'Yaş, kategori ve malzemeye göre arama',
      onTap: () => _sayfa('Bebek Tarifleri', const BabyRecipesPage())),
    _baslik('Sık kullanılan sağlık konuları'),
    for (final t in ['Hastalıklar ve Belirtiler', 'Alerji', 'Beslenme', 'Uyku Düzeni']) _rehberKart(t, Icons.health_and_safety_outlined),
  ];

  List<Widget> _bebekAsilar() => [
    PastelCard(color: const Color(0xFFFFF4FA), child: const Text(
      'Aşı kayıtlarını bebeğin sağlık günlüğünde, resmî aşı takvimini ise çocuk profilinde görebilirsin. '
      'Aşı zamanlaması için her zaman doktorunun ve Sağlık Bakanlığı takviminin önerisini esas al.',
      style: TextStyle(fontSize: 13))),
    PastelLinkCard(icon: Icons.vaccines_outlined, title: 'Aşı kayıtlarım',
      subtitle: 'Yapılan aşıları tarih ve notla kaydet',
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BabyHealthPage()))),
    PastelLinkCard(icon: Icons.calendar_month_outlined, title: 'Resmî aşı takvimi',
      subtitle: 'Çocuk profilini seç, yaşına göre aşı takvimini aç', iconColor: const Color(0xFFEDE4FF),
      onTap: _profillerAc),
    PastelLinkCard(icon: Icons.notifications_active_outlined, title: 'Aşı ve kontrol hatırlatıcıları',
      subtitle: 'Yaklaşan randevular için hatırlatıcı kur', iconColor: const Color(0xFFFFEBD9),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const RemindersPage()))),
    _rehberKart('Aşı Takvimi', Icons.vaccines_outlined),
  ];

  List<Widget> _bebekNotlar() => [
    PastelLinkCard(icon: Icons.group_add_rounded, title: 'Bebek profillerini yönet',
      subtitle: 'Yeni bebek ekle, profiller arasında geçiş yap; günlük ve bakım planı',
      onTap: _profillerAc),
    PastelLinkCard(icon: Icons.edit_outlined, title: 'Bebek profilini düzenle',
      subtitle: bebekAdi.isEmpty ? 'Ad ve doğum tarihi ekle' : '$bebekAdi • $yas', iconColor: const Color(0xFFEDE4FF),
      onTap: _profil),
    PastelLinkCard(icon: Icons.forum_outlined, title: 'Bebeğim Forumu',
      subtitle: 'Sorular ve ebeveyn deneyimleri', iconColor: const Color(0xFFEDE4FF),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BabyOnlineForumPage()))),
    _baslik('Son kayıtlar'),
    if (olaylar.isEmpty) _panel(child: const Text('Henüz kayıt bulunmuyor. Ortadaki + butonundan kayıt ekleyebilirsin.')),
    ...olaylar.take(30).map((o) => _panel(child: ListTile(
      leading: const Icon(Icons.check_circle_outline, color: mor), title: Text(o['tur'] ?? ''),
      subtitle: Text('${_guvenliTarih(o['zaman'])}  ${o['not'] ?? ''}'),
      trailing: IconButton(tooltip: 'Kaydı sil', icon: const Icon(Icons.delete_outline), onPressed: () => _kayitSil(olaylar, o))))),
  ];

  // Paket 39 referansı: Günlük Takip (tarih gezinme, + ile kayıt, günün özeti).
  Widget _gunlukTakip() {
    final bugun = DateTime.now();
    final gun = takipGunu;
    final bugunMu = DateUtils.isSameDay(gun, bugun);
    final gunKayitlari = olaylar.where((o) {
      final z = DateTime.tryParse(o['zaman'] ?? '');
      return z != null && DateUtils.isSameDay(z, gun);
    }).toList()
      ..sort((a, b) => (b['zaman'] ?? '').compareTo(a['zaman'] ?? ''));
    int say(String tur) => gunKayitlari.where((o) => o['tur'] == tur).length;
    String sonKayit(String tur) {
      for (final o in gunKayitlari) {
        if (o['tur'] != tur) continue;
        final z = DateTime.parse(o['zaman']!);
        final saat = '${z.hour.toString().padLeft(2, '0')}:${z.minute.toString().padLeft(2, '0')}';
        final not = (o['not'] ?? '').trim();
        return not.isEmpty ? 'Son: $saat' : 'Son: $saat – $not';
      }
      return bugunMu ? 'Bugün kayıt yok' : 'Bu gün kayıt yok';
    }
    // Geçmiş bir gün görüntülenirken eklenen kayıt o güne, şimdiki saatle yazılır.
    DateTime kayitZamani() => bugunMu ? DateTime.now()
        : DateTime(gun.year, gun.month, gun.day, bugun.hour, bugun.minute);
    const satirlar = <(IconData, Color, String, String)>[
      (Icons.bed_outlined, Color(0xFFEDE4FF), 'Uyku', 'Uyku'),
      (Icons.local_drink_outlined, Color(0xFFFFE9D2), 'Beslenme', 'Beslenme'),
      (Icons.baby_changing_station_outlined, Color(0xFFE0EEFF), 'Bez', 'Bez değişimi'),
      (Icons.medication_outlined, Color(0xFFFFE3EC), 'İlaç / Vitamin', 'İlaç / Vitamin'),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      DateNavigator(date: gun, today: bugun, onChanged: (d) => setState(() => takipGunu = d)),
      for (final (ikon, renk, baslik, tur) in satirlar)
        TrackingRow(icon: ikon, color: renk, title: baslik, subtitle: sonKayit(tur),
          onAdd: () => _olayEkle(tur, zaman: kayitZamani())),
      SummaryStatsCard(title: bugunMu ? 'Bugünkü Özet' : 'Günün Özeti', items: [
        (Icons.bed_outlined, '${say('Uyku')} uyku'),
        (Icons.local_drink_outlined, '${say('Beslenme')} beslenme'),
        (Icons.baby_changing_station_outlined, '${say('Bez değişimi')} bez'),
      ]),
      _baslik('Günün kayıtları'),
      if (gunKayitlari.isEmpty) _panel(child: const Text('Bu güne ait kayıt yok. Satırlardaki + butonuyla ekleyebilirsin.')),
      ...gunKayitlari.map((o) {
        final z = DateTime.parse(o['zaman']!);
        return _panel(child: ListTile(
          leading: const Icon(Icons.check_circle_outline, color: mor),
          title: Text(o['tur'] ?? ''),
          subtitle: Text('${z.hour.toString().padLeft(2, '0')}:${z.minute.toString().padLeft(2, '0')}  ${o['not'] ?? ''}'),
          trailing: IconButton(tooltip: 'Kaydı sil', icon: const Icon(Icons.delete_outline), onPressed: () => _kayitSil(olaylar, o))));
      }),
      _baslik('Ayrıntılı günlükler'),
      PastelLinkCard(icon: Icons.local_drink_outlined, title: 'Beslenme günlüğüm',
        subtitle: 'Emzirme, mama ve ek gıda ayrıntıları', iconColor: const Color(0xFFFFE9D2),
        onTap: () => _sayfa('Beslenme günlüğüm', const TrackingJournalPage())),
      PastelLinkCard(icon: Icons.bedtime_outlined, title: 'Uyku günlüğüm',
        subtitle: 'Başlangıç–bitiş saatleri ve toplam uyku', iconColor: const Color(0xFFEDE4FF),
        onTap: () => _sayfa('Uyku günlüğüm', const SleepJournalPage())),
    ]);
  }

  String _olcumMetni(String? deger, String birim) => (deger == null || deger.isEmpty) ? '—' : '$deger $birim';
  String _guvenliTarih(String? s) {final d = DateTime.tryParse(s ?? ''); return d == null ? '' : _tarih(d);}
  Widget _sayac(String label, String type) => Column(children: [Text('${olaylar.where((e) => e['tur'] == type && _guvenliTarih(e['zaman']) == _tarih(DateTime.now())).length}',
    style: const TextStyle(fontSize: 23, color: mor, fontWeight: FontWeight.bold)), Text(label)]);

  // Genel tarifler ayrı katalogdan gelir; bebek tarifleri Bebeğim bölümündedir.
  // Tarif kartı görseli: lisanslı fotoğraf eklenene kadar kategoriye özgü
  // simge ve renk geçişi kullanılır.
  static (IconData, List<Color>) _tarifGorseli(String kategori) => switch (kategori) {
    'Çorbalar' => (Icons.soup_kitchen_rounded, const [Color(0xFFFFC37A), Color(0xFFF29A4A)]),
    'Et yemekleri' => (Icons.kebab_dining_rounded, const [Color(0xFFE59A8C), Color(0xFFC0614F)]),
    'Tavuk yemekleri' => (Icons.set_meal_rounded, const [Color(0xFFFFD39A), Color(0xFFE8A15A)]),
    'Balık ve deniz ürünleri' => (Icons.phishing_rounded, const [Color(0xFF9FD3E8), Color(0xFF5BA4C7)]),
    'Sebze yemekleri' => (Icons.eco_rounded, const [Color(0xFFB7E3A1), Color(0xFF6FB35A)]),
    'Bakliyat yemekleri' => (Icons.grain_rounded, const [Color(0xFFE8C99A), Color(0xFFBF8E4F)]),
    'Makarnalar' => (Icons.ramen_dining_rounded, const [Color(0xFFFFE29A), Color(0xFFE9B949)]),
    'Pilavlar' => (Icons.rice_bowl_rounded, const [Color(0xFFF3E6C8), Color(0xFFD6B97A)]),
    'Kahvaltılıklar' => (Icons.egg_alt_rounded, const [Color(0xFFFFE9A8), Color(0xFFF5C84C)]),
    'Hamur işleri' => (Icons.bakery_dining_rounded, const [Color(0xFFF2CF9E), Color(0xFFD39B57)]),
    'Salatalar' => (Icons.grass_rounded, const [Color(0xFFC8EBA8), Color(0xFF86C26A)]),
    'Mezeler' => (Icons.tapas_rounded, const [Color(0xFFF7C6D6), Color(0xFFE38AA8)]),
    'Tatlılar' => (Icons.cake_rounded, const [Color(0xFFF8C6DD), Color(0xFFE07FAE)]),
    'Kek ve kurabiyeler' => (Icons.cookie_rounded, const [Color(0xFFE8C4A6), Color(0xFFB5835C)]),
    'İçecekler' => (Icons.local_cafe_rounded, const [Color(0xFFD9C8FF), Color(0xFFA084E8)]),
    'Dünya mutfağı' => (Icons.public_rounded, const [Color(0xFFBFD7FF), Color(0xFF7E9FE6)]),
    'Diyet ve sağlıklı tarifler' => (Icons.spa_rounded, const [Color(0xFFC9F0E0), Color(0xFF72C6A4)]),
    _ => (Icons.restaurant_menu_rounded, const [Color(0xFFFFD6E8), Color(0xFFE94791)]),
  };

  Widget _tarifKarti(GeneralRecipe t) {
    final isFavorite = favoriler.contains(t.title);
    final (simge, renkler) = _tarifGorseli(t.category);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => _sayfa(t.title, ListView(padding: const EdgeInsets.all(18), children: [
          _hero(t.title, '${t.category} • ${t.minutes} dk', simge, emoji: recipeEmoji(t.title, t.category)),
          RecipeSummaryChips(recipe: t),
          const SizedBox(height: 8),
          AddToNotebookTile(build: () => RecipeNotebookBridge.fromGeneral(t)),
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
          RecipeExtraSections(recipe: t),
          const SizedBox(height: 24),
        ])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: renkler,
              begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Stack(children: [
            Center(child: Container(
              width: 84, height: 84, alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .55), shape: BoxShape.circle),
              child: Text(recipeEmoji(t.title, t.category), textScaler: TextScaler.noScaling,
                style: const TextStyle(fontSize: 46)))),
            Positioned(right: 4, top: 4, child: IconButton(
              tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
              style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .9)),
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
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.schedule_rounded, size: 14, color: Colors.black54),
                const SizedBox(width: 3),
                Text('${t.minutes} dk', style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
                const SizedBox(width: 10),
                const Icon(Icons.restaurant_outlined, size: 14, color: Colors.black54),
                const SizedBox(width: 3),
                Flexible(child: Text(t.difficulty, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54))),
              ]),
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
    final categories = <String>['Tümü', ...generalRecipeCategories];
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
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      _search('Tarif ara (ör. mercimek çorbası)', (v) => setState(() { arama = v; tarifGosterimSiniri = 40; })),
      const SizedBox(height: 12),
      SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(children: categories.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(f), selected: selected == f,
            selectedColor: const Color(0xFFE94791),
            shape: const StadiumBorder(), showCheckmark: false,
            labelStyle: TextStyle(color: selected == f ? Colors.white : mor),
            onSelected: (_) => setState(() { tarifFiltre = f; tarifGosterimSiniri = 40; })),
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
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${generalRecipes.length} genel tarif • ${gorunen.length} sonuç',
        style: const TextStyle(color: mor, fontSize: 12.5))),
      if (gorunen.isEmpty) _panel(child: const Text('Filtrelere uygun tarif bulunamadı.')),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        // Tüm katalog tek seferde çizilmez; performans için parça parça yüklenir.
        itemCount: gorunen.length.clamp(0, tarifGosterimSiniri),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240, childAspectRatio: .82,
          mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemBuilder: (_, i) => _tarifKarti(gorunen[i])),
      if (gorunen.length > tarifGosterimSiniri)
        Padding(padding: const EdgeInsets.only(top: 12), child: OutlinedButton.icon(
          onPressed: () => setState(() => tarifGosterimSiniri += 40),
          icon: const Icon(Icons.expand_more),
          label: Text('Daha fazla tarif göster (${gorunen.length - tarifGosterimSiniri} kaldı)'))),
      _baslik('Tarif araçları'),
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
      RecipeSummaryChips(recipe: t),
      _baslik('Malzemeler'),
      ...t.ingredients.map((m) => ListTile(dense: true,
        leading: const Icon(Icons.check_circle_outline, color: mor), title: Text(m))),
      _baslik('Hazırlanışı'),
      ...t.steps.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Text('${e.key + 1}. ${e.value}'))),
      RecipeExtraSections(recipe: t),
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
      // Akıllı Alışveriş aynı adet kaydını değiştirebilir; ikisi tek kaynaktır.
      final adetler = jsonDecode(p.getString('alisveris_adet') ?? '{}');
      if (!mounted) return;
      setState(() {
        alisveris..clear()..addAll(items);
        tamamlanan..clear()..addAll(done);
        alisverisAdet.clear();
        if (adetler is Map) {
          for (final e in adetler.entries) {
            if (e.key is String && e.value is int && (e.value as int) >= 1 && (e.value as int) <= 99) {
              alisverisAdet[e.key as String] = e.value as int;
            }
          }
        }
      });
    } catch (e) { logSafeError('Alışveriş yenileme hatası', e); }
  }

  int _adet(String urun) => alisverisAdet[urun] ?? 1;

  Future<void> _listeyeEkle(String urun) async {
    final vardi = alisveris.contains(urun);
    final oncekiAdet = alisverisAdet[urun];
    setState(() {
      if (vardi) {
        alisverisAdet[urun] = (_adet(urun) + 1).clamp(1, 99);
      } else {
        alisveris.add(urun);
      }
    });
    final basarili = await _kaydet();
    if (!mounted) return;
    if (!basarili) {
      setState(() {
        if (!vardi) alisveris.remove(urun);
        if (oncekiAdet == null) { alisverisAdet.remove(urun); } else { alisverisAdet[urun] = oncekiAdet; }
      });
    }
    _kayitBildir(basarili, basariMesaji: vardi ? '$urun adedi artırıldı.' : '$urun listeye eklendi.');
  }

  // Paket 39 referansı: Bebek / Anne / Aile sekmeleri, kategori kutuları,
  // adet seçicili liste ve liste toplamı. Önceki bölümler alttadır.
  Widget _alisveris() {
    final segment = shoppingSegments[alisverisSekme.clamp(0, shoppingSegments.length - 1)];
    final altKategori = segment.subcategories.where((c) => c.name == alisverisAltKategori).firstOrNull;
    final toplamAdet = alisveris.fold<int>(0, (t, u) => t + _adet(u));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelSegmentTabs(
        labels: [for (final s in shoppingSegments) s.name],
        selected: alisverisSekme,
        onChanged: (i) => setState(() { alisverisSekme = i; alisverisAltKategori = null; }),
      ),
      const SizedBox(height: 12),
      SizedBox(height: 82, child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: segment.subcategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = segment.subcategories[i];
          return CategoryIconTile(icon: c.icon, label: c.name,
            selected: c.name == alisverisAltKategori,
            onTap: () => setState(() => alisverisAltKategori = c.name == alisverisAltKategori ? null : c.name));
        })),
      if (altKategori != null) PastelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${altKategori.name}: listeye eklemek için dokun',
          style: const TextStyle(fontWeight: FontWeight.w700, color: mor)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final urun in altKategori.items)
            ActionChip(
              avatar: Icon(alisveris.contains(urun) ? Icons.check_rounded : Icons.add_rounded, size: 18, color: const Color(0xFFE94791)),
              label: Text(urun),
              onPressed: () => _listeyeEkle(urun)),
        ]),
      ])) else const SizedBox(height: 4),
      PastelCard(child: Column(children: [
        PastelSectionHeader(icon: Icons.checklist_rounded, title: 'Alışveriş Listem',
          action: 'Yeni Ürün Ekle', onAction: _urunEkle),
        const SizedBox(height: 4),
        if (alisveris.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('Alışveriş listen boş. Kategorilerden veya "Yeni Ürün Ekle" ile ekleyebilirsin.')),
        for (final u in alisveris) Row(children: [
          Checkbox(value: tamamlanan.contains(u), activeColor: const Color(0xFFE94791),
            onChanged: (v) {
              setState(() {if (v == true) {tamamlanan.add(u);} else {tamamlanan.remove(u);}});
              _kaydet();
            }),
          Expanded(child: Text(u, style: TextStyle(
            decoration: tamamlanan.contains(u) ? TextDecoration.lineThrough : null))),
          QuantityStepper(value: _adet(u), onChanged: (v) {
            setState(() => alisverisAdet[u] = v);
            _kaydet();
          }),
          IconButton(tooltip: '$u ürününü sil', visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_outline, size: 20), onPressed: () {
            setState(() {alisveris.remove(u); tamamlanan.remove(u); alisverisAdet.remove(u);}); _kaydet();
          }),
        ]),
      ])),
      PastelLinkCard(icon: Icons.shopping_cart_outlined,
        title: 'Liste Toplamı (${alisveris.length} ürün)',
        subtitle: '$toplamAdet adet • ${alisveris.where(tamamlanan.contains).length} ürün alındı',
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SmartShoppingPage()));
          await _alisverisYenile();
        }),
      _baslik('Diğer alışveriş araçları'),
      PastelLinkCard(icon: Icons.auto_awesome, title: 'Akıllı alışveriş listesi',
        subtitle: 'Kategoriler, miktar notları, arama ve tamamlananlar', iconColor: const Color(0xFFEDE4FF),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SmartShoppingPage()));
          await _alisverisYenile();
        }),
      PastelLinkCard(icon: Icons.shopping_bag_outlined, title: 'Sepetim (${sepet.length})',
        subtitle: 'Taslak sepet; sipariş veya ödeme yapılmaz', iconColor: const Color(0xFFFFEBD9),
        onTap: () => _sayfa('Sepetim', _sepet())),
      _baslik('Ürün kataloğu'),
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
      const SizedBox(height: 10),
      const Text('Ürünler ihtiyaç listesi içindir; gerçek satış, stok, fiyat veya ödeme bağlantısı yoktur.',
        style: TextStyle(fontSize: 12)),
    ]);
  }

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

  // Döngü geçmişi CycleTrackerPage ile aynı güvenli anahtarda tutulur.
  static const _donguAnahtari = 'cycle_history_v1';

  Future<void> _donguYukle() async {
    try {
      final tarihler = decodeCycleDates(await SecureHealthStore.read(_donguAnahtari));
      if (!mounted) return;
      setState(() => donguTarihleri..clear()..addAll(tarihler));
    } catch (_) {
      // Döngü geçmişi okunamazsa takvim yalnızca son adet tarihini kullanır.
    }
  }

  CycleEstimate get _donguTahmini => CycleEstimate.from([
    ...donguTarihleri,
    ?sonAdet,
  ]);

  /// Tarih seçtirip adet başlangıcı olarak kaydeder (düğmeler ve + menüsü).
  Future<void> _adetGunuSec() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context,
      helpText: 'Adet başlangıç günü',
      initialDate: now, firstDate: DateTime(now.year - 3), lastDate: now);
    if (d != null && mounted) await _adetBaslangiciKaydet(d, onayIste: false);
  }

  Future<void> _adetBaslangiciKaydet(DateTime gun, {bool onayIste = true}) async {
    final secilen = DateTime(gun.year, gun.month, gun.day);
    if (secilen.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gelecek bir gün adet başlangıcı olarak kaydedilemez.')));
      return;
    }
    if (donguTarihleri.any((d) => d.year == secilen.year && d.month == secilen.month && d.day == secilen.day)) {
      ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text('${_tarih(secilen)} zaten kayıtlı. Silmek için "Adet döngüsü geçmişim"i aç.')));
      return;
    }
    final onay = !onayIste ? true : await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Adet başlangıcı'),
      content: Text('${_tarih(secilen)} adet başlangıç günü olarak kaydedilsin mi?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kaydet')),
      ]));
    if (onay != true || !mounted) return;
    final onceki = List<DateTime>.of(donguTarihleri);
    final oncekiSonAdet = sonAdet;
    final yeni = {...donguTarihleri, secilen}.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      donguTarihleri..clear()..addAll(yeni);
      if (sonAdet == null || secilen.isAfter(sonAdet!)) sonAdet = secilen;
    });
    try {
      await SecureHealthStore.write(_donguAnahtari, jsonEncode(yeni.map((d) => d.toIso8601String()).toList()));
      final basarili = await _kaydet();
      if (!basarili) throw _sonKayitHatasi ?? StateError('kayıt');
      _kayitBildir(true, basariMesaji: 'Adet başlangıcı kaydedildi: ${_tarih(secilen)}');
    } catch (e) {
      if (!mounted) return;
      setState(() { donguTarihleri..clear()..addAll(onceki); sonAdet = oncekiSonAdet; });
      _kayitBildir(false, hata: e);
    }
  }

  // Paket 39 referansı: Döngü Takibi / Sağlık / İyi Hisset sekmeleri.
  Widget _kadin() => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
    PastelSegmentTabs(
      labels: const ['Döngü Takibi', 'Sağlık', 'İyi Hisset'],
      selected: kadinSekme,
      onChanged: (i) => setState(() => kadinSekme = i),
    ),
    const SizedBox(height: 12),
    ...switch (kadinSekme) {
      1 => _kadinSaglik(),
      2 => _kadinIyiHisset(),
      _ => _kadinDongu(),
    },
  ]);

  List<Widget> _kadinDongu() {
    final tahmin = _donguTahmini;
    final sonraki = tahmin.nextPeriod;
    final yumurtlama = tahmin.nextOvulation;
    return [
      Row(children: [
        Expanded(child: FilledButton.icon(
          key: const ValueKey('adet_bugun'),
          onPressed: () => _adetBaslangiciKaydet(DateTime.now()),
          icon: const Icon(Icons.water_drop_rounded, size: 18),
          label: const Text('Bugün başladı'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(
          key: const ValueKey('adet_tarih'),
          onPressed: _adetGunuSec,
          icon: const Icon(Icons.edit_calendar_rounded, size: 18),
          label: const Text('Gün seç'))),
      ]),
      const Padding(padding: EdgeInsets.fromLTRB(4, 6, 4, 10), child: Text(
        'İpucu: takvimde bir güne dokunarak da adet başlangıcı ekleyebilirsin.',
        style: TextStyle(fontSize: 11.5, color: Colors.black54))),
      CycleMonthCalendar(
        month: donguAyi,
        today: DateTime.now(),
        kindOf: tahmin.kindOf,
        onMonthChanged: (m) => setState(() => donguAyi = m),
        onDayTap: _adetBaslangiciKaydet,
      ),
      if (!tahmin.hasData)
        PastelCard(color: const Color(0xFFFFF4FA), child: const Text(
          'Takvimde adet başladığı güne dokunarak ilk kaydını ekle. '
          'İki veya daha fazla kayıttan sonra döngü süren kayıtlarından hesaplanır.',
          style: TextStyle(fontSize: 13)))
      else
        PastelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sonraki adet (tahmini): ${_tarih(sonraki!)}',
            style: const TextStyle(fontWeight: FontWeight.w800, color: mor)),
          const SizedBox(height: 4),
          Text('Tahmini yumurtlama: ${_tarih(yumurtlama!)}'),
          Text(tahmin.measured
            ? 'Döngü süresi: ortalama ${tahmin.cycleLength} gün (${tahmin.starts.length} kayıttan)'
            : 'Döngü süresi: ${tahmin.cycleLength} gün (varsayılan; daha fazla kayıt girince ölçülür)'),
        ])),
      PastelLinkCard(icon: Icons.edit_note_rounded, title: 'Bugünkü Notun',
        leading: const WomanPortraitArt(size: 56), background: const Color(0xFFFFEEF6),
        subtitle: 'Enerji seviyen nasıl? Belirti ve ruh halini kaydet',
        onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomensHealthJournalPage()))),
      PastelLinkCard(icon: Icons.history_rounded, title: 'Adet döngüsü geçmişim',
        subtitle: 'Başlangıç tarihlerini ekle, görüntüle ve sil', iconColor: const Color(0xFFEDE4FF),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const CycleTrackerPage()));
          await _donguYukle();
        }),
      PastelLinkCard(icon: Icons.calendar_month_outlined, title: 'Son adet başlangıç tarihi',
        subtitle: sonAdet == null ? 'Henüz kaydedilmedi' : '${_tarih(sonAdet!)} • ${DateTime.now().difference(sonAdet!).inDays} gün önce',
        iconColor: const Color(0xFFFFEBD9), onTap: _adetGunuSec),
      const Padding(padding: EdgeInsets.all(10), child: Text(
        'Yumurtlama ve verimli dönem, ortalama döngü süresine göre yaklaşık hesaplanır. '
        'Doğum kontrolü veya gebelik planlaması için güvenilir bir yöntem değildir; tıbbi değerlendirme yerine geçmez.',
        style: TextStyle(fontSize: 11.5, color: Colors.black54))),
    ];
  }

  List<Widget> _kadinSaglik() => [
    PastelLinkCard(icon: Icons.favorite_border_rounded, title: 'Kadın sağlığı günlüğüm',
      subtitle: 'Döngü, gebelik, doğum sonrası ve belirtiler',
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomensHealthJournalPage()))),
    PastelLinkCard(icon: Icons.pregnant_woman_rounded, title: 'Gebelik',
      subtitle: 'Hafta hafta takip, kontroller ve hazırlık listesi', iconColor: const Color(0xFFEDE4FF),
      onTap: () => _sayfa('Gebelik', const PregnancyPage())),
    PastelLinkCard(icon: Icons.spa_outlined, title: 'Doğum sonrası ve annelik',
      subtitle: '12 haftalık rehber, destek listesi ve kişisel notlar', iconColor: const Color(0xFFFFEBD9),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PostpartumCarePage()))),
    PastelLinkCard(icon: Icons.medical_services_outlined, title: 'Sağlık merkezi',
      subtitle: 'Bebek ve kadın sağlığı araçları bir arada',
      onTap: () => _sayfa('Sağlık', _saglik())),
    _baslik('Kadın sağlığı konuları'),
    for (final t in ['Adet Dönemi', 'Gebelik', 'Doğum Sonrası', 'Anne Sütü']) _rehberKart(t, Icons.favorite_outline),
  ];

  List<Widget> _kadinIyiHisset() => [
    GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.15, children: [
        _kart('Güzellik & Bakım', 'Öneriler', Icons.spa, const Color(0xFFFFE0E8), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Güzellik & Bakım')))),
        _kart('Sağlık & Wellness', 'Kişisel sağlık', Icons.health_and_safety, const Color(0xFFECDFFF), () => _sayfa('Sağlık', _saglik())),
        _kart('Moda & Stil', 'İlham', Icons.checkroom, const Color(0xFFE5E3FF), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Moda & Stil')))),
        _kart('Diyet & Beslenme', 'Sağlıklı yaşam', Icons.local_dining, const Color(0xFFFFE9C8), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Diyet & Beslenme')))),
        _kart('Kişisel Gelişim', 'Kendine yatırım', Icons.psychology, const Color(0xFFE3F3FF), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Kişisel Gelişim')))),
        _kart('Rahatlama', 'Stres yönetimi', Icons.self_improvement, const Color(0xFFE3F3E5), () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage(initialCategory: 'Rahatlama')))),
    ]),
    const SizedBox(height: 12),
    PastelLinkCard(icon: Icons.menu_book_outlined, title: 'Kadın yaşamı içerik kütüphanesi',
      subtitle: '42 konu, arama, favoriler ve okundu takibi', iconColor: const Color(0xFFEDE4FF),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenLifestylePage()))),
    PastelLinkCard(icon: Icons.forum_outlined, title: 'Kadınlar Forumu',
      subtitle: 'Konular, deneyimler ve sohbet',
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomenOnlineForumPage()))),
    _hero('Kendinize zaman ayırın 💕', 'Çünkü siz de değerlisiniz!', Icons.spa),
  ];

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

  // Ansiklopedide karşılığı olan konular orada, diğerleri kısa rehberde açılır.
  void _rehberKonuAc(String konu) => searchEncyclopedia(konu).isEmpty
    ? _sayfa(konu, _icerik(konu))
    : Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => EncyclopediaPage(initialQuery: konu)));

  void _ansiklopediAc() => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const EncyclopediaPage()));

  Widget _rehberKart(String t, IconData icon) => _panel(child: ListTile(
    leading: Icon(icon, color: mor), title: Text(t), trailing: const Icon(Icons.chevron_right),
    onTap: () => _rehberKonuAc(t)));
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
      try {
        await LocalReminderNotifications.cancelAll();
      } catch (_) {
        // Bildirim eklentisi olmayan platformlarda (web) yok sayılır.
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const ConsentGate(child: AnaUygulama())),
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
        if (!kReleaseMode) QuickAccessItem(title: 'Yayın öncesi kontrol', description: 'Android test ve yayın kontrol listesi', icon: Icons.fact_check_outlined,
          onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReleaseCheckPage()))),
        QuickAccessItem(title: 'Rehber', description: 'A’dan Z’ye bilgi rehberi', icon: Icons.menu_book_outlined,
          onOpen: () => _ansiklopediAc()),
      ]),
    );
  }

  Widget _profilSatiri(IconData icon, String title, VoidCallback onTap, {Widget? badge}) => ListTile(
    leading: Icon(icon, color: mor),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      ?badge,
      const Icon(Icons.chevron_right_rounded, color: mor),
    ]),
    onTap: onTap);

  Widget _profilSayfasi() => ListView(padding: const EdgeInsets.all(16), children: [
    _panel(color: const Color(0xFFFFFCFF), child: Column(children: [
      ListTile(
        title: const Text('Çocuk Profillerim', style: TextStyle(fontWeight: FontWeight.w800, color: mor, fontSize: 17)),
        trailing: TextButton.icon(onPressed: _profillerAc, icon: const Icon(Icons.add_rounded),
          label: const Text('Profil Ekle'))),
      ListTile(
        leading: const BabyFaceAvatar(size: 44),
        title: Text(bebekAdi.isEmpty ? 'Bebek profili oluştur' : bebekAdi,
          style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(yas),
        trailing: const Icon(Icons.chevron_right_rounded, color: mor),
        onTap: _profillerAc),
    ])),
    _panel(color: const Color(0xFFFFFCFF), padding: EdgeInsets.zero, child: Column(children: [
      _profilSatiri(Icons.person_outline_rounded, 'Hesap Bilgilerim', () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CloudAccountPage()))),
      _profilSatiri(Icons.workspace_premium_outlined, 'Premium Üyelik', () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const MembershipPage())),
        badge: Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFE94791), borderRadius: BorderRadius.circular(10)),
          child: const Text('Pro', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)))),
      _profilSatiri(Icons.notifications_none_rounded, 'Bildirim Ayarları', () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const NotificationPreferencesPage()))),
      _profilSatiri(Icons.shield_outlined, 'Gizlilik ve Güvenlik', () => Navigator.push(context,
        MaterialPageRoute<void>(builder: (_) => const BackupPage()))),
      _profilSatiri(Icons.info_outline_rounded, 'Uygulama Hakkında', () => showAboutDialog(context: context,
        applicationName: 'Anne & Bebek', applicationVersion: '1.0.0',
        applicationLegalese: 'Takip kayıtları kişisel kullanım içindir; sağlık değerlendirmesi yerine geçmez.')),
    ])),
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
    // Yönetici araçları yalnızca geliştirme sürümlerinde görünür.
    if (!kReleaseMode)
    _panel(child: ListTile(leading: const Icon(Icons.admin_panel_settings, color: mor),
      title: const Text('Merkezi yönetim paneli'),
      subtitle: const Text('Sunucu yetkisi gerektirir; forum ve toplu istatistikler'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminDashboardPage())))),
    // Yönetici araçları yalnızca geliştirme sürümlerinde görünür.
    if (!kReleaseMode)
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
    _baslik('Gizlilik ve açık rıza'), _panel(child: const PrivacySummary()),
    _panel(child: const Text('Daha önce dışa aktarılan yedekler ve panoya kopyalanan içerikler ayrıca silinmelidir. Kayıtları silmek açık rızanı geri almak anlamına gelir; uygulama bir sonraki açılışta yeniden onay ister.')),
    _panel(child: ListTile(
      leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
      title: const Text('Bu cihazdaki kayıtlarımı sil'),
      subtitle: const Text('Onay sonrası uygulama kayıtlarını kalıcı siler'),
      onTap: _verilerimiSil,
    )),
  ]);

  // Bölüm sırası: 0 Ana Sayfa, 1 Bebeğim, 2 Tarifler, 3 Alışveriş, 4 Kadınlar, 5 Profil.
  // Alt menüde referans tasarıma göre Ana Sayfa • Bebeğim • (+) • Tarifler • Profil vardır;
  // Alışveriş ve Kadınlar ana sayfadaki modül kartlarından açılır.
  static const _bolumBasliklari = <(IconData, String)>[
    (Icons.favorite_rounded, 'Anne & Bebek'),
    (Icons.child_care_rounded, 'Bebeğim'),
    (Icons.restaurant_menu_rounded, 'Yemek Tarifleri'),
    (Icons.shopping_cart_outlined, 'Alışveriş'),
    (Icons.local_florist_rounded, 'Kadınlar'),
    (Icons.person_outline_rounded, 'Profil'),
    (Icons.event_note_rounded, 'Günlük Takip'),
  ];
  static const _altMenuBolumleri = [0, 1, 2, 5];

  void _hizliKayitMenusu() => showModalBottomSheet<void>(context: context, showDragHandle: true,
    builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('Hızlı kayıt',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: mor))),
      ListTile(leading: const Icon(Icons.local_drink, color: Color(0xFFE94791)), title: const Text('Beslenme kaydı'), onTap: () {Navigator.pop(ctx); _olayEkle('Beslenme');}),
      ListTile(leading: const Icon(Icons.bedtime, color: Color(0xFFE94791)), title: const Text('Uyku kaydı'), onTap: () {Navigator.pop(ctx); _olayEkle('Uyku');}),
      ListTile(leading: const Icon(Icons.baby_changing_station, color: Color(0xFFE94791)), title: const Text('Bez değişimi'), onTap: () {Navigator.pop(ctx); _olayEkle('Bez değişimi');}),
      ListTile(leading: const Icon(Icons.medication_outlined, color: Color(0xFFE94791)), title: const Text('İlaç / vitamin'), onTap: () {Navigator.pop(ctx); _olayEkle('İlaç / Vitamin');}),
      ListTile(leading: const Icon(Icons.monitor_weight, color: Color(0xFFE94791)), title: const Text('Boy / kilo kaydı'), onTap: () {Navigator.pop(ctx); _olcumEkle();}),
      ListTile(leading: const Icon(Icons.add_shopping_cart, color: Color(0xFFE94791)), title: const Text('Alışveriş listesine ürün'), onTap: () {Navigator.pop(ctx); _urunEkle();}),
      ListTile(leading: const Icon(Icons.water_drop_rounded, color: Color(0xFFE94791)), title: const Text('Adet başlangıcı'), onTap: () {Navigator.pop(ctx); _adetGunuSec();}),
      ListTile(leading: const Icon(Icons.edit_note_rounded, color: Color(0xFFE94791)), title: const Text('Kadın sağlığı notu'), onTap: () {Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WomensHealthJournalPage()));}),
    ])));

  @override
  Widget build(BuildContext context) {
    final bolum = sekme.clamp(0, 6);
    final (baslikIkonu, baslik) = _bolumBasliklari[bolum];
    final altBolum = bolum == 3 || bolum == 4 || bolum == 6;
    return PopScope(
      // Alt bölümlerdeyken sistem geri tuşu önce ana sayfaya döner.
      canPop: bolum == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && mounted) setState(() => sekme = 0);
      },
      child: Scaffold(
    appBar: AppBar(
      toolbarHeight: 64,
      leading: altBolum ? IconButton(tooltip: 'Ana sayfaya dön', icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => setState(() => sekme = 0)) : null,
      title: PastelTitle(icon: baslikIkonu, title: baslik),
      actions: [
        IconButton(tooltip: 'Ara ve hızlı erişim', icon: const Icon(Icons.search_rounded), onPressed: _hizliErisim),
        IconButton(tooltip: 'Bildirim ayarları', icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NotificationPreferencesPage()))),
        PopupMenuButton<String>(tooltip: 'Diğer bölümler', icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            switch (value) {
              case 'guide': _ansiklopediAc();
              case 'tools': Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LifeHubPage()));
              case 'profile': setState(() => sekme = 5);
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
    body: yuklendi ? [_ana, _bebek, _tarif, _alisveris, _kadin, _profilSayfasi, _gunlukTakip][bolum]()
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
    bottomNavigationBar: PastelBottomBar(
      selected: _altMenuBolumleri.indexOf(bolum),
      onSelect: (i) => setState(() => sekme = _altMenuBolumleri[i]),
      onAdd: _hizliKayitMenusu,
    ),
  ));
  }
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
