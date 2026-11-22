import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../i18n/i18n.dart' show t;

/// Tarif görselleri: bu uygulama için kodla çizilen özgün yemek çizimleri.
///
/// Fotoğraf, hazır görsel, yazı tipi veya emoji kullanılmaz; bu yüzden
/// herhangi bir lisans ya da telif hakkı gerektirmez. Çizim tarifin adı,
/// kategorisi ve malzemelerinden üretilir: kap (kâse, tabak, bardak,
/// dilim, tava...), yemeğin rengi ve üstündeki parçalar (bakliyat taneleri,
/// makarna telleri, yeşillik, balık, köfte, yumurta...) tarife göre seçilir.
/// Aynı tarif her zaman aynı görünür.

enum DishVessel { bowl, plate, glass, cakeSlice, cookies, pastry, skillet, tray, jar }

enum DishTopping {
  smooth, legumes, pasta, noodles, rice, leaves, fish, drumstick, meatballs,
  steak, egg, veggieChunks, berries, herbs, cream, dumplings, slices, nuts,
  sesame, chocolate, ice, fruitSlice
}

@immutable
class DishLook {
  const DishLook({
    required this.vessel,
    required this.food,
    required this.accent,
    required this.toppings,
    required this.background,
    required this.hot,
    required this.seed,
  });

  final DishVessel vessel;
  final Color food, accent;
  final List<DishTopping> toppings;
  final List<Color> background;

  /// Sıcak servis edilen yemeklerde buhar çizilir.
  final bool hot;
  final int seed;
}

String _norm(String s) =>
    s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

bool _has(String text, List<String> words) => words.any(text.contains);

// Renkler: yemeğin baskın malzemesine göre (sıra önemlidir: ilk eşleşen).
const _foodColors = <(List<String>, Color)>[
  (['çikolata', 'kakao', 'brownie'], Color(0xFF6B3F2A)),
  (['çilek', 'kırmızı meyve', 'frambuaz', 'vişne', 'kiraz', 'nar'], Color(0xFFE2475C)),
  (['ıspanak', 'brokoli', 'bezelye', 'semizotu', 'roka', 'kabak', 'pırasa', 'fesleğen', 'avokado', 'yeşil'], Color(0xFF7DBA5A)),
  (['mercimek', 'ezogelin', 'havuç', 'balkabağı', 'bal kabağı', 'tatlı patates', 'portakal', 'kayısı', 'şeftali'], Color(0xFFF2994A)),
  (['domates', 'salça', 'kırmızı biber', 'pancar', 'menemen', 'şakşuka', 'kızartma'], Color(0xFFE05A3A)),
  (['muz', 'mısır', 'limon', 'zerdeçal', 'irmik', 'patates'], Color(0xFFF4CF5B)),
  (['somon'], Color(0xFFF59E7E)),
  (['yoğurt', 'ayran', 'süt', 'sütlaç', 'muhallebi', 'beşamel', 'tarhana', 'yayla', 'cacık', 'labne', 'lor', 'krema', 'peynir'], Color(0xFFF6F1E6)),
  (['mantar'], Color(0xFFB79B7E)),
  (['et', 'kıyma', 'köfte', 'kuzu', 'dana', 'kebap', 'biftek', 'kavurma'], Color(0xFF8A4B32)),
  (['tavuk', 'hindi'], Color(0xFFE3B47A)),
  (['balık', 'levrek', 'çipura', 'hamsi', 'ton', 'karides', 'midye', 'kalamar'], Color(0xFFCBD5DB)),
  (['nohut', 'fasulye', 'barbunya', 'börülce', 'humus', 'bulgur', 'kinoa', 'yulaf', 'karabuğday'], Color(0xFFD9B77E)),
  (['elma', 'armut'], Color(0xFFE8D27A)),
  (['pirinç', 'pilav', 'risotto'], Color(0xFFFAF4E4)),
  (['makarna', 'erişte', 'şehriye', 'spagetti', 'mantı', 'lazanya'], Color(0xFFF1D27F)),
  (['kahve'], Color(0xFF7A5038)),
  (['çay', 'ıhlamur', 'papatya'], Color(0xFFC9783A)),
];

Color? _colorFor(String text) {
  for (final (words, color) in _foodColors) {
    for (final w in words) {
      // "et" gibi kısa kelimeler başka kelimelerin içinde eşleşmesin.
      if (w.length <= 3) {
        if (RegExp('(^|[^a-zçğıöşü])$w([^a-zçğıöşü]|\$)').hasMatch(text)) return color;
      } else if (text.contains(w)) {
        return color;
      }
    }
  }
  return null;
}

/// Tarifin adı, kategorisi ve malzemelerinden çizim bilgisi üretir.
DishLook dishLookFor(String title, String category, [List<String> ingredients = const []]) {
  final t = _norm(title);
  final c = _norm(category);
  final ing = _norm(ingredients.join(' '));
  final seed = title.codeUnits.fold<int>(17, (a, b) => (a * 31 + b) & 0x7fffffff);

  // 1) Kap
  DishVessel vessel;
  if (_has(t, ['smoothie', 'limonata', 'ayran', 'şerbet', 'kompost', 'komposto', 'milkshake', 'içecek', 'suyu', 'kefir', 'çay', 'kahve', 'süt ']) ||
      c.contains('içecek')) {
    vessel = DishVessel.glass;
  } else if (_has(t, ['kurabiye', 'bisküvi', 'cookie', 'kraker'])) {
    vessel = DishVessel.cookies;
  } else if (_has(t, ['kek', 'pasta', 'cheesecake', 'turta', 'brownie', 'muffin', 'tart', 'revani', 'islak kek']) &&
      !_has(t, ['makarna', 'pastırma'])) {
    vessel = DishVessel.cakeSlice;
  } else if (_has(t, ['börek', 'poğaça', 'açma', 'simit', 'pide', 'ekmek', 'gözleme', 'lahmacun', 'pizza', 'çörek', 'krep', 'pankek', 'tost', 'sandviç', 'dürüm', 'wrap', 'katmer'])) {
    vessel = DishVessel.pastry;
  } else if (_has(t, ['menemen', 'omlet', 'sahanda', 'şakşuka', 'yumurta', 'frittata', 'kavurma', 'sote'])) {
    vessel = DishVessel.skillet;
  } else if (_has(t, ['fırın', 'güveç', 'graten', 'musakka', 'lazanya', 'karnıyarık', 'tepsi', 'kumpir'])) {
    vessel = DishVessel.tray;
  } else if (_has(t, ['reçel', 'turşu', 'marmelat', 'sos'])) {
    vessel = DishVessel.jar;
  } else if (_has(t, ['çorba', 'püre', 'lapa', 'muhallebi', 'sütlaç', 'puding', 'humus', 'cacık', 'haşlama', 'yoğurt', 'mama', 'kaşık']) ||
      c.contains('çorba') || c.contains('süt ürünü') || c.contains('yoğurt') || c.contains('tahıl') ||
      (c.contains('bakliyat') && !_has(t, ['salata', 'köfte', 'piyaz']))) {
    vessel = DishVessel.bowl;
  } else if (c.contains('tatlı') && _has(t, ['helva', 'kazandibi', 'aşure', 'keşkül', 'supangle', 'dondurma'])) {
    vessel = DishVessel.bowl;
  } else if (c.contains('kek') || (c.contains('fırın') && _has(t, ['kek', 'muffin']))) {
    vessel = DishVessel.cakeSlice;
  } else if (c.contains('hamur')) {
    vessel = DishVessel.pastry;
  } else if (c.contains('kahvaltı') && _has(ing, ['yumurta'])) {
    vessel = DishVessel.skillet;
  } else {
    vessel = DishVessel.plate;
  }

  // 2) Renk
  final food = _colorFor(t) ?? _colorFor(ing) ?? switch (c) {
        _ when c.contains('tatlı') => const Color(0xFFF2C6A0),
        _ when c.contains('salata') => const Color(0xFF8CC46A),
        _ when c.contains('meze') => const Color(0xFFEFE4CC),
        _ => const Color(0xFFE9B872),
      };

  // 3) Üstündeki parçalar
  final toppings = <DishTopping>[];
  void add(DishTopping d) {
    if (!toppings.contains(d)) toppings.add(d);
  }

  if (vessel == DishVessel.glass) {
    if (_has(t + ing, ['buz', 'limonata', 'soğuk', 'smoothie'])) add(DishTopping.ice);
    if (_has(t + ing, ['limon', 'portakal', 'çilek', 'meyve', 'smoothie'])) add(DishTopping.fruitSlice);
  } else if (vessel == DishVessel.cookies || vessel == DishVessel.pastry || vessel == DishVessel.cakeSlice) {
    if (_has(t + ing, ['çikolata', 'kakao', 'damla'])) add(DishTopping.chocolate);
    if (_has(t + ing, ['susam', 'çörek otu'])) add(DishTopping.sesame);
    if (_has(t + ing, ['ceviz', 'fındık', 'badem', 'fıstık'])) add(DishTopping.nuts);
    if (_has(t + ing, ['çilek', 'meyve', 'frambuaz', 'yaban mersini', 'vişne', 'kiraz'])) add(DishTopping.berries);
    if (_has(t, ['krema', 'cheesecake', 'pasta'])) add(DishTopping.cream);
  } else {
    if (_has(t, ['makarna', 'spagetti', 'erişte', 'şehriye', 'noodle', 'lazanya'])) {
      add(_has(t, ['erişte', 'noodle', 'şehriye']) ? DishTopping.noodles : DishTopping.pasta);
    }
    if (_has(t, ['mantı', 'ravioli', 'dumpling'])) add(DishTopping.dumplings);
    if (_has(t, ['pilav', 'risotto', 'pirinç', 'sushi'])) add(DishTopping.rice);
    if (_has(t, ['nohut', 'fasulye', 'barbunya', 'börülce', 'bakla', 'bezelye'])) add(DishTopping.legumes);
    if (_has(t, ['balık', 'somon', 'levrek', 'çipura', 'hamsi', 'alabalık', 'uskumru', 'palamut', 'mezgit'])) add(DishTopping.fish);
    if (_has(t, ['köfte', 'misket'])) add(DishTopping.meatballs);
    if (_has(t, ['tavuk but', 'baget', 'kanat', 'fırın tavuk', 'hindi'])) add(DishTopping.drumstick);
    if (_has(t, ['biftek', 'bonfile', 'pirzola', 'antrikot', 'şiş', 'kebap', 'tavuk göğsü', 'şnitzel'])) add(DishTopping.steak);
    if (_has(t, ['yumurta', 'menemen', 'omlet', 'çılbır', 'şakşuka'])) add(DishTopping.egg);
    if (_has(t, ['salata', 'roka', 'marul', 'semizotu', 'yeşillik'])) add(DishTopping.leaves);
    if (_has(t, ['dolma', 'sarma'])) add(DishTopping.dumplings);
    if (_has(t, ['çilek', 'muz', 'meyve', 'elma', 'armut', 'şeftali', 'kayısı'])) add(DishTopping.fruitSlice);
    if (_has(t, ['çorba', 'püre', 'lapa', 'muhallebi', 'sütlaç', 'puding', 'humus', 'mama'])) add(DishTopping.smooth);
    if (_has(t + ing, ['ceviz', 'fındık', 'badem', 'fıstık']) && c.contains('tatlı')) add(DishTopping.nuts);
    if (_has(t, ['tarçın', 'kakao']) || (c.contains('tatlı') && vessel == DishVessel.bowl)) add(DishTopping.cream);
    if (toppings.isEmpty) {
      if (c.contains('et')) add(DishTopping.steak);
      if (c.contains('tavuk')) add(DishTopping.drumstick);
      if (c.contains('balık')) add(DishTopping.fish);
      if (c.contains('salata') || c.contains('diyet')) add(DishTopping.leaves);
      if (c.contains('makarna')) add(DishTopping.pasta);
      if (c.contains('pilav')) add(DishTopping.rice);
      if (c.contains('bakliyat') || c.contains('baklagil')) add(DishTopping.legumes);
      if (c.contains('meyve')) add(DishTopping.fruitSlice);
      if (c.contains('tatlı')) add(DishTopping.berries);
    }
    if (toppings.isEmpty || c.contains('sebze') || c.contains('meze')) add(DishTopping.veggieChunks);
    if (vessel == DishVessel.bowl || vessel == DishVessel.plate || vessel == DishVessel.skillet || vessel == DishVessel.tray) {
      if (!c.contains('tatlı') && !_has(t, ['muhallebi', 'sütlaç', 'puding', 'meyve'])) add(DishTopping.herbs);
    }
  }

  final accent = _has(t + ing, ['maydanoz', 'dereotu', 'nane', 'fesleğen', 'roka', 'yeşil'])
      ? const Color(0xFF4E9F3D)
      : HSLColor.fromColor(food).withLightness((HSLColor.fromColor(food).lightness * .72).clamp(0, 1)).toColor();

  final hue = HSLColor.fromColor(food).hue;
  final bg = [
    HSLColor.fromAHSL(1, hue, .65, .93).toColor(),
    HSLColor.fromAHSL(1, (hue + 40) % 360, .55, .86).toColor(),
  ];
  final hot = vessel != DishVessel.glass &&
      !_has(t, ['salata', 'soğuk', 'dondurma', 'cacık', 'meyve', 'smoothie', 'muhallebi', 'sütlaç', 'puding', 'piyaz']) &&
      !c.contains('salata') && !c.contains('meze') && !c.contains('tatlı') && !c.contains('kek') &&
      !c.contains('meyve') && vessel != DishVessel.cookies && vessel != DishVessel.jar;

  return DishLook(vessel: vessel, food: food, accent: accent, toppings: toppings,
      background: bg, hot: hot, seed: seed);
}

/// Tarif için özgün yemek çizimi.
class RecipeArt extends StatelessWidget {
  const RecipeArt({
    super.key,
    required this.title,
    required this.category,
    this.ingredients = const [],
    this.size,
    this.borderRadius = 18,
    this.showBackground = true,
  });

  final String title, category;
  final List<String> ingredients;

  /// Kare boyut; verilmezse yerleştiği alanı doldurur.
  final double? size;
  final double borderRadius;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final look = dishLookFor(title, category, ingredients);
    final art = Semantics(
      image: true,
      label: t(title),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomPaint(painter: DishPainter(look, showBackground: showBackground)),
      ),
    );
    if (size == null) return SizedBox.expand(child: art);
    return SizedBox.square(dimension: size, child: art);
  }
}

class DishPainter extends CustomPainter {
  DishPainter(this.look, {this.showBackground = true});

  final DishLook look;
  final bool showBackground;

  @override
  bool shouldRepaint(covariant DishPainter old) =>
      old.look.seed != look.seed || old.showBackground != showBackground;

  static Color _shade(Color c, double f) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness * f).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final dx = (size.width - s) / 2, dy = (size.height - s) / 2;
    if (showBackground) {
      final rect = Offset.zero & size;
      canvas.drawRect(rect, Paint()
        ..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: look.background).createShader(rect));
      // Hafif masa örtüsü deseni.
      final dot = Paint()..color = Colors.white.withValues(alpha: .35);
      final step = s / 7;
      for (var x = step / 2; x < size.width; x += step) {
        for (var y = step / 2; y < size.height; y += step) {
          canvas.drawCircle(Offset(x, y), s * .012, dot);
        }
      }
    }
    canvas.save();
    canvas.translate(dx, dy);
    final rnd = math.Random(look.seed);
    switch (look.vessel) {
      case DishVessel.bowl:
        _bowl(canvas, s, rnd);
      case DishVessel.plate:
        _plate(canvas, s, rnd);
      case DishVessel.glass:
        _glass(canvas, s, rnd);
      case DishVessel.cakeSlice:
        _cake(canvas, s, rnd);
      case DishVessel.cookies:
        _cookies(canvas, s, rnd);
      case DishVessel.pastry:
        _pastry(canvas, s, rnd);
      case DishVessel.skillet:
        _skillet(canvas, s, rnd);
      case DishVessel.tray:
        _tray(canvas, s, rnd);
      case DishVessel.jar:
        _jar(canvas, s, rnd);
    }
    if (look.hot) _steam(canvas, s);
    canvas.restore();
  }

  void _shadow(Canvas canvas, Offset c, double w, double h) {
    canvas.drawOval(Rect.fromCenter(center: c, width: w, height: h),
        Paint()..color = Colors.black.withValues(alpha: .10)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  void _steam(Canvas canvas, double s) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: .8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .018
      ..strokeCap = StrokeCap.round;
    for (final x in [.40, .50, .60]) {
      final path = Path()..moveTo(s * x, s * .26);
      path.cubicTo(s * (x - .04), s * .21, s * (x + .04), s * .17, s * x, s * .11);
      canvas.drawPath(path, p);
    }
  }

  // ---- Kaplar ----

  void _bowl(Canvas canvas, double s, math.Random rnd) {
    final c = Offset(s * .5, s * .52);
    _shadow(canvas, Offset(s * .5, s * .84), s * .62, s * .08);
    final rim = Rect.fromCenter(center: c, width: s * .78, height: s * .26);
    // Gövde
    final body = Path()
      ..moveTo(rim.left, c.dy)
      ..quadraticBezierTo(rim.left + s * .02, s * .86, s * .5, s * .86)
      ..quadraticBezierTo(rim.right - s * .02, s * .86, rim.right, c.dy)
      ..close();
    canvas.drawPath(body, Paint()..color = Colors.white);
    canvas.drawPath(body, Paint()
      ..shader = LinearGradient(colors: [Colors.white, const Color(0xFFE9E3F0)])
          .createShader(Rect.fromLTRB(rim.left, c.dy, rim.right, s * .86)));
    // Kâse bandı
    final band = Paint()
      ..color = _shade(look.background.last, .85).withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .02;
    canvas.drawArc(Rect.fromCenter(center: Offset(s * .5, s * .58), width: s * .70, height: s * .32),
        .25, math.pi - .5, false, band);
    canvas.drawOval(rim, Paint()..color = const Color(0xFFF7F4FA));
    final surface = Rect.fromCenter(center: c, width: s * .70, height: s * .2);
    canvas.drawOval(surface, Paint()
      ..shader = RadialGradient(colors: [_shade(look.food, 1.08), look.food])
          .createShader(surface));
    _toppings(canvas, surface, s, rnd);
  }

  void _plate(Canvas canvas, double s, math.Random rnd) {
    final c = Offset(s * .5, s * .56);
    _shadow(canvas, Offset(s * .5, s * .66), s * .86, s * .42);
    canvas.drawOval(Rect.fromCenter(center: c, width: s * .86, height: s * .5), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: c, width: s * .86, height: s * .5), Paint()
      ..color = const Color(0xFFE4DDEA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .008);
    canvas.drawOval(Rect.fromCenter(center: c, width: s * .64, height: s * .36),
        Paint()..color = const Color(0xFFF4F0F7));
    final food = Rect.fromCenter(center: c.translate(0, -s * .015), width: s * .54, height: s * .28);
    final mound = Path()..addOval(food);
    canvas.drawPath(mound, Paint()
      ..shader = RadialGradient(center: const Alignment(-.3, -.4),
              colors: [_shade(look.food, 1.12), look.food, _shade(look.food, .9)])
          .createShader(food));
    _toppings(canvas, food, s, rnd);
  }

  void _skillet(Canvas canvas, double s, math.Random rnd) {
    final c = Offset(s * .46, s * .56);
    _shadow(canvas, Offset(s * .5, s * .7), s * .86, s * .34);
    final handle = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * .78, s * .5, s * .2, s * .07), Radius.circular(s * .03));
    canvas.drawRRect(handle, Paint()..color = const Color(0xFF3B3340));
    canvas.drawOval(Rect.fromCenter(center: c, width: s * .74, height: s * .5),
        Paint()..color = const Color(0xFF4A414F));
    final inner = Rect.fromCenter(center: c, width: s * .64, height: s * .41);
    canvas.drawOval(inner, Paint()..color = const Color(0xFF2E2833));
    final food = Rect.fromCenter(center: c, width: s * .58, height: s * .35);
    canvas.drawOval(food, Paint()..color = look.food);
    _toppings(canvas, food, s, rnd);
  }

  void _tray(Canvas canvas, double s, math.Random rnd) {
    _shadow(canvas, Offset(s * .5, s * .8), s * .86, s * .12);
    final outer = RRect.fromRectAndRadius(Rect.fromLTWH(s * .08, s * .32, s * .84, s * .48), Radius.circular(s * .08));
    canvas.drawRRect(outer, Paint()..color = const Color(0xFFD9825B));
    canvas.drawRRect(outer.deflate(s * .02), Paint()..color = const Color(0xFFC56C45));
    final foodRect = Rect.fromLTWH(s * .14, s * .37, s * .72, s * .36);
    final food = RRect.fromRectAndRadius(foodRect, Radius.circular(s * .05));
    canvas.drawRRect(food, Paint()..color = look.food);
    // Kızarmış üst yüzey lekeleri
    final brown = Paint()..color = _shade(look.food, .78).withValues(alpha: .55);
    for (var i = 0; i < 9; i++) {
      canvas.drawOval(Rect.fromCenter(
          center: Offset(foodRect.left + rnd.nextDouble() * foodRect.width, foodRect.top + rnd.nextDouble() * foodRect.height),
          width: s * (.05 + rnd.nextDouble() * .05), height: s * (.03 + rnd.nextDouble() * .03)), brown);
    }
    _toppings(canvas, foodRect, s, rnd);
  }

  void _glass(Canvas canvas, double s, math.Random rnd) {
    _shadow(canvas, Offset(s * .5, s * .88), s * .4, s * .06);
    final top = s * .2, bottom = s * .86;
    final glass = Path()
      ..moveTo(s * .3, top)
      ..lineTo(s * .7, top)
      ..lineTo(s * .64, bottom)
      ..quadraticBezierTo(s * .5, bottom + s * .02, s * .36, bottom)
      ..close();
    canvas.drawPath(glass, Paint()..color = Colors.white.withValues(alpha: .55));
    final level = s * .32;
    final liquid = Path()
      ..moveTo(s * .3 + (level - top) / (bottom - top) * s * .06, level)
      ..lineTo(s * .7 - (level - top) / (bottom - top) * s * .06, level)
      ..lineTo(s * .64, bottom - s * .01)
      ..quadraticBezierTo(s * .5, bottom + s * .01, s * .36, bottom - s * .01)
      ..close();
    canvas.drawPath(liquid, Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [_shade(look.food, 1.1), look.food])
          .createShader(Rect.fromLTRB(s * .3, level, s * .7, bottom)));
    if (look.toppings.contains(DishTopping.ice)) {
      final ice = Paint()..color = Colors.white.withValues(alpha: .7);
      for (var i = 0; i < 3; i++) {
        canvas.save();
        canvas.translate(s * (.4 + i * .1), s * (.38 + rnd.nextDouble() * .08));
        canvas.rotate(rnd.nextDouble() - .5);
        canvas.drawRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: s * .08, height: s * .08), Radius.circular(s * .015)), ice);
        canvas.restore();
      }
    }
    // Pipet
    canvas.drawLine(Offset(s * .56, s * .5), Offset(s * .68, s * .08), Paint()
      ..color = const Color(0xFFF0449B)
      ..strokeWidth = s * .03
      ..strokeCap = StrokeCap.round);
    // Cam parlaması
    canvas.drawLine(Offset(s * .35, s * .26), Offset(s * .39, s * .78), Paint()
      ..color = Colors.white.withValues(alpha: .6)
      ..strokeWidth = s * .015
      ..strokeCap = StrokeCap.round);
    canvas.drawPath(glass, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .012);
    if (look.toppings.contains(DishTopping.fruitSlice)) {
      final c = Offset(s * .3, s * .22);
      canvas.drawCircle(c, s * .085, Paint()..color = _shade(look.accent, 1.2));
      canvas.drawCircle(c, s * .065, Paint()..color = _shade(look.food, 1.15));
      final seg = Paint()..color = Colors.white.withValues(alpha: .7)..strokeWidth = s * .006;
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3;
        canvas.drawLine(c, c + Offset(math.cos(a), math.sin(a)) * s * .06, seg);
      }
    }
  }

  void _cake(Canvas canvas, double s, math.Random rnd) {
    _shadow(canvas, Offset(s * .5, s * .82), s * .74, s * .1);
    // Tabak
    canvas.drawOval(Rect.fromCenter(center: Offset(s * .5, s * .78), width: s * .84, height: s * .18),
        Paint()..color = Colors.white);
    final a = Offset(s * .16, s * .5), b = Offset(s * .62, s * .36), tip = Offset(s * .84, s * .52);
    final h = s * .26;
    final side = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(tip.dx, tip.dy + h)
      ..lineTo(a.dx, a.dy + h)
      ..close();
    canvas.drawPath(side, Paint()..color = look.food);
    // Katlar
    final cream = Paint()..color = const Color(0xFFFFF6EC);
    for (final f in [.33, .66]) {
      canvas.drawRect(Rect.fromLTRB(a.dx, a.dy + h * f - s * .015, tip.dx, a.dy + h * f + s * .015), cream);
    }
    final topFace = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(tip.dx, tip.dy)
      ..close();
    final topColor = look.toppings.contains(DishTopping.chocolate)
        ? const Color(0xFF5A3322)
        : look.toppings.contains(DishTopping.cream)
            ? const Color(0xFFFFF8F0)
            : _shade(look.food, 1.12);
    canvas.drawPath(topFace, Paint()..color = topColor);
    final top = Rect.fromPoints(Offset(a.dx + s * .1, b.dy + s * .02), Offset(tip.dx - s * .1, tip.dy - s * .02));
    if (look.toppings.contains(DishTopping.berries)) {
      canvas.drawCircle(Offset(s * .55, s * .42), s * .05, Paint()..color = const Color(0xFFD8344F));
      canvas.drawCircle(Offset(s * .55, s * .395), s * .015, Paint()..color = const Color(0xFF4E9F3D));
    }
    if (look.toppings.contains(DishTopping.nuts)) _nuts(canvas, top, s, rnd, 4);
    if (look.toppings.contains(DishTopping.chocolate) && !look.toppings.contains(DishTopping.berries)) {
      _chips(canvas, top, s, rnd, 5, Colors.white.withValues(alpha: .8));
    }
  }

  void _cookies(Canvas canvas, double s, math.Random rnd) {
    _shadow(canvas, Offset(s * .5, s * .76), s * .84, s * .16);
    canvas.drawOval(Rect.fromCenter(center: Offset(s * .5, s * .66), width: s * .86, height: s * .36),
        Paint()..color = Colors.white);
    final centers = [Offset(s * .32, s * .6), Offset(s * .62, s * .58), Offset(s * .48, s * .7)];
    for (final c in centers) {
      final r = Rect.fromCenter(center: c, width: s * .3, height: s * .2);
      canvas.drawOval(r.shift(Offset(0, s * .02)), Paint()..color = _shade(look.food, .8));
      canvas.drawOval(r, Paint()..color = look.food);
      if (look.toppings.contains(DishTopping.chocolate)) {
        _chips(canvas, r.deflate(s * .03), s, rnd, 4, const Color(0xFF4A2A1C));
      } else if (look.toppings.contains(DishTopping.nuts)) {
        _nuts(canvas, r.deflate(s * .04), s, rnd, 2);
      } else {
        _dots(canvas, r.deflate(s * .04), s, rnd, 5, _shade(look.food, .75), .008);
      }
    }
  }

  void _pastry(Canvas canvas, double s, math.Random rnd) {
    _shadow(canvas, Offset(s * .5, s * .78), s * .84, s * .14);
    // Ahşap servis tahtası
    final board = RRect.fromRectAndRadius(Rect.fromLTWH(s * .08, s * .5, s * .84, s * .26), Radius.circular(s * .05));
    canvas.drawRRect(board, Paint()..color = const Color(0xFFD8A774));
    final grain = Paint()..color = const Color(0xFFC08E5C)..strokeWidth = s * .006;
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(Offset(s * .12, s * (.5 + i * .06)), Offset(s * .88, s * (.5 + i * .06)), grain);
    }
    final golden = look.food.computeLuminance() > .6 ? const Color(0xFFE7B663) : look.food;
    for (var i = 0; i < 2; i++) {
      final r = Rect.fromCenter(center: Offset(s * (.34 + i * .32), s * .52), width: s * .3, height: s * .22);
      final rr = RRect.fromRectAndRadius(r, Radius.circular(s * .1));
      canvas.drawRRect(rr.shift(Offset(0, s * .02)), Paint()..color = _shade(golden, .75));
      canvas.drawRRect(rr, Paint()
        ..shader = RadialGradient(center: const Alignment(-.3, -.5),
                colors: [_shade(golden, 1.18), golden]).createShader(r));
      // Kat çizgileri
      final fold = Paint()
        ..color = _shade(golden, .8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .008;
      canvas.drawArc(r.deflate(s * .04), math.pi * 1.1, math.pi * .8, false, fold);
      if (look.toppings.contains(DishTopping.sesame) || rnd.nextBool()) {
        _dots(canvas, r.deflate(s * .05), s, rnd, 7, const Color(0xFFFFF3D6), .007);
      }
      if (look.toppings.contains(DishTopping.chocolate)) {
        _chips(canvas, r.deflate(s * .05), s, rnd, 3, const Color(0xFF4A2A1C));
      }
    }
  }

  void _jar(Canvas canvas, double s, math.Random rnd) {
    _shadow(canvas, Offset(s * .5, s * .86), s * .5, s * .07);
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(s * .27, s * .3, s * .46, s * .55), Radius.circular(s * .08));
    canvas.drawRRect(body, Paint()..color = Colors.white.withValues(alpha: .6));
    canvas.drawRRect(body.deflate(s * .025), Paint()..color = look.food);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * .3, s * .2, s * .4, s * .1), Radius.circular(s * .025)),
        Paint()..color = const Color(0xFFF0449B));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * .33, s * .5, s * .34, s * .16), Radius.circular(s * .02)),
        Paint()..color = const Color(0xFFFFFBF2));
    _dots(canvas, Rect.fromLTWH(s * .32, s * .34, s * .36, s * .12), s, rnd, 6, _shade(look.food, .75), .012);
  }

  // ---- Üstündekiler ----

  void _toppings(Canvas canvas, Rect area, double s, math.Random rnd) {
    for (final t in look.toppings) {
      switch (t) {
        case DishTopping.smooth:
          final swirl = Paint()
            ..color = Colors.white.withValues(alpha: .55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * .012
            ..strokeCap = StrokeCap.round;
          canvas.drawArc(Rect.fromCenter(center: area.center, width: area.width * .45, height: area.height * .45),
              .3, math.pi * 1.3, false, swirl);
        case DishTopping.legumes:
          _dots(canvas, area.deflate(s * .02), s, rnd, 16, _shade(look.food, .82), .022, highlight: true);
        case DishTopping.pasta:
          _strands(canvas, area, s, rnd, 9, _shade(look.food, .92), .016, curly: false);
        case DishTopping.noodles:
          _strands(canvas, area, s, rnd, 12, _shade(look.food, .9), .01, curly: true);
        case DishTopping.rice:
          final grain = Paint()..color = Colors.white;
          final edge = Paint()..color = _shade(look.food, .85);
          for (var i = 0; i < 40; i++) {
            final p = _inOval(area.deflate(s * .02), rnd);
            canvas.save();
            canvas.translate(p.dx, p.dy);
            canvas.rotate(rnd.nextDouble() * math.pi);
            final r = Rect.fromCenter(center: Offset.zero, width: s * .03, height: s * .012);
            canvas.drawOval(r.shift(Offset(0, s * .003)), edge);
            canvas.drawOval(r, grain);
            canvas.restore();
          }
        case DishTopping.leaves:
          for (var i = 0; i < 9; i++) {
            final p = _inOval(area, rnd);
            final greens = [const Color(0xFF6DB54B), const Color(0xFF8CCB5E), const Color(0xFF4E9F3D), const Color(0xFFB3D96B)];
            _leaf(canvas, p, s * (.06 + rnd.nextDouble() * .04), rnd.nextDouble() * math.pi * 2,
                greens[rnd.nextInt(greens.length)]);
          }
          for (var i = 0; i < 4; i++) {
            final p = _inOval(area.deflate(s * .03), rnd);
            canvas.drawCircle(p, s * .025, Paint()..color = const Color(0xFFE5483E));
            canvas.drawCircle(p.translate(-s * .007, -s * .007), s * .007, Paint()..color = Colors.white.withValues(alpha: .6));
          }
        case DishTopping.fish:
          _fish(canvas, area.center, s, look.food == const Color(0xFFF59E7E) ? const Color(0xFFF59E7E) : const Color(0xFFC9D2D9));
        case DishTopping.drumstick:
          _drumstick(canvas, area.center.translate(-s * .06, 0), s, -.4);
          _drumstick(canvas, area.center.translate(s * .08, s * .02), s, .5);
        case DishTopping.meatballs:
          for (var i = 0; i < 5; i++) {
            final p = _inOval(area.deflate(s * .06), rnd);
            canvas.drawCircle(p.translate(0, s * .008), s * .045, Paint()..color = const Color(0xFF5E3121));
            canvas.drawCircle(p, s * .045, Paint()..color = const Color(0xFF8A4B32));
            canvas.drawCircle(p.translate(-s * .014, -s * .014), s * .012, Paint()..color = Colors.white.withValues(alpha: .35));
          }
        case DishTopping.steak:
          final r = Rect.fromCenter(center: area.center, width: area.width * .62, height: area.height * .55);
          canvas.drawOval(r.shift(Offset(0, s * .012)), Paint()..color = const Color(0xFF4D2618));
          canvas.drawOval(r, Paint()..color = const Color(0xFF8A4B32));
          final grill = Paint()
            ..color = const Color(0xFF4D2618)
            ..strokeWidth = s * .012
            ..strokeCap = StrokeCap.round;
          for (var i = -1; i <= 1; i++) {
            canvas.drawLine(r.center.translate(-r.width * .3 + i * s * .05, -r.height * .3),
                r.center.translate(-r.width * .05 + i * s * .05, r.height * .3), grill);
          }
        case DishTopping.egg:
          final e = area.center.translate(rnd.nextDouble() * s * .04, -s * .01);
          final white = Path()
            ..addOval(Rect.fromCenter(center: e, width: s * .24, height: s * .16))
            ..addOval(Rect.fromCenter(center: e.translate(s * .05, s * .02), width: s * .16, height: s * .12));
          canvas.drawPath(white, Paint()..color = Colors.white);
          canvas.drawCircle(e, s * .042, Paint()..color = const Color(0xFFF7B32B));
          canvas.drawCircle(e.translate(-s * .012, -s * .012), s * .012, Paint()..color = Colors.white.withValues(alpha: .7));
        case DishTopping.veggieChunks:
          final colors = [const Color(0xFFF2994A), const Color(0xFF7DBA5A), const Color(0xFFE05A3A), const Color(0xFFF4CF5B)];
          for (var i = 0; i < 9; i++) {
            final p = _inOval(area.deflate(s * .03), rnd);
            canvas.save();
            canvas.translate(p.dx, p.dy);
            canvas.rotate(rnd.nextDouble() * math.pi);
            final col = colors[rnd.nextInt(colors.length)];
            canvas.drawRRect(RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset.zero, width: s * .045, height: s * .035), Radius.circular(s * .008)),
                Paint()..color = col);
            canvas.restore();
          }
        case DishTopping.berries:
          for (var i = 0; i < 5; i++) {
            final p = _inOval(area.deflate(s * .04), rnd);
            canvas.drawCircle(p, s * .025, Paint()..color = i.isEven ? const Color(0xFFD8344F) : const Color(0xFF5B4BA8));
          }
        case DishTopping.herbs:
          for (var i = 0; i < 7; i++) {
            final p = _inOval(area.deflate(s * .02), rnd);
            _leaf(canvas, p, s * .028, rnd.nextDouble() * math.pi * 2, look.accent.computeLuminance() > .5 ? const Color(0xFF4E9F3D) : look.accent);
          }
        case DishTopping.cream:
          final c = area.center;
          canvas.drawOval(Rect.fromCenter(center: c, width: s * .16, height: s * .08),
              Paint()..color = const Color(0xFFFFFBF4));
          _dots(canvas, Rect.fromCenter(center: c, width: area.width * .7, height: area.height * .6), s, rnd, 10,
              const Color(0xFF9B5A32), .006);
        case DishTopping.dumplings:
          for (var i = 0; i < 6; i++) {
            final p = _inOval(area.deflate(s * .05), rnd);
            final r = Rect.fromCenter(center: p, width: s * .08, height: s * .055);
            canvas.drawOval(r.shift(Offset(0, s * .006)), Paint()..color = _shade(look.food, .8));
            canvas.drawOval(r, Paint()..color = look.food == const Color(0xFFF1D27F) ? const Color(0xFFFFF1CF) : _shade(look.food, 1.12));
          }
          canvas.drawOval(Rect.fromCenter(center: area.center, width: area.width * .5, height: area.height * .3),
              Paint()..color = const Color(0xFFE05A3A).withValues(alpha: .35));
        case DishTopping.slices:
        case DishTopping.fruitSlice:
          for (var i = 0; i < 3; i++) {
            final p = _inOval(area.deflate(s * .05), rnd);
            canvas.drawCircle(p, s * .04, Paint()..color = _shade(look.food, .85));
            canvas.drawCircle(p, s * .032, Paint()..color = _shade(look.food, 1.15));
            canvas.drawCircle(p, s * .008, Paint()..color = const Color(0xFF5A3A2A));
          }
        case DishTopping.nuts:
          _nuts(canvas, area, s, rnd, 5);
        case DishTopping.sesame:
          _dots(canvas, area, s, rnd, 14, const Color(0xFFFFF3D6), .006);
        case DishTopping.chocolate:
          _chips(canvas, area, s, rnd, 6, const Color(0xFF4A2A1C));
        case DishTopping.ice:
          break;
      }
    }
  }

  Offset _inOval(Rect r, math.Random rnd) {
    final a = rnd.nextDouble() * math.pi * 2;
    final d = math.sqrt(rnd.nextDouble()) * .82;
    return r.center + Offset(math.cos(a) * r.width / 2 * d, math.sin(a) * r.height / 2 * d);
  }

  void _dots(Canvas canvas, Rect area, double s, math.Random rnd, int n, Color color, double radius,
      {bool highlight = false}) {
    final p = Paint()..color = color;
    final hi = Paint()..color = Colors.white.withValues(alpha: .45);
    for (var i = 0; i < n; i++) {
      final o = _inOval(area, rnd);
      canvas.drawCircle(o, s * radius, p);
      if (highlight) canvas.drawCircle(o.translate(-s * radius * .35, -s * radius * .35), s * radius * .35, hi);
    }
  }

  void _chips(Canvas canvas, Rect area, double s, math.Random rnd, int n, Color color) {
    final p = Paint()..color = color;
    for (var i = 0; i < n; i++) {
      final o = _inOval(area, rnd);
      final path = Path()
        ..moveTo(o.dx, o.dy - s * .018)
        ..lineTo(o.dx + s * .016, o.dy + s * .012)
        ..lineTo(o.dx - s * .016, o.dy + s * .012)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  void _nuts(Canvas canvas, Rect area, double s, math.Random rnd, int n) {
    for (var i = 0; i < n; i++) {
      final o = _inOval(area, rnd);
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(rnd.nextDouble() * math.pi);
      final r = Rect.fromCenter(center: Offset.zero, width: s * .05, height: s * .035);
      canvas.drawOval(r, Paint()..color = const Color(0xFFB07A45));
      canvas.drawLine(Offset(-s * .02, 0), Offset(s * .02, 0), Paint()
        ..color = const Color(0xFF7A4E28)
        ..strokeWidth = s * .005);
      canvas.restore();
    }
  }

  void _strands(Canvas canvas, Rect area, double s, math.Random rnd, int n, Color color, double width,
      {required bool curly}) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * width
      ..strokeCap = StrokeCap.round;
    final light = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * width * .35
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < n; i++) {
      final a = _inOval(area.deflate(s * .03), rnd);
      final b = _inOval(area.deflate(s * .03), rnd);
      final path = Path()..moveTo(a.dx, a.dy);
      final mid = Offset((a.dx + b.dx) / 2 + (rnd.nextDouble() - .5) * s * .12,
          (a.dy + b.dy) / 2 + (rnd.nextDouble() - .5) * s * .08);
      if (curly) {
        path.cubicTo(a.dx + s * .05, a.dy - s * .04, mid.dx - s * .05, mid.dy + s * .04, b.dx, b.dy);
      } else {
        path.quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
      }
      canvas.drawPath(path, p);
      canvas.drawPath(path, light);
    }
    // Sos
    canvas.drawOval(Rect.fromCenter(center: area.center, width: area.width * .35, height: area.height * .3),
        Paint()..color = const Color(0xFFD9452F).withValues(alpha: look.food == const Color(0xFFF1D27F) ? .55 : .0));
  }

  void _leaf(Canvas canvas, Offset c, double len, double angle, Color color) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(-len / 2, 0)
      ..quadraticBezierTo(0, -len * .45, len / 2, 0)
      ..quadraticBezierTo(0, len * .45, -len / 2, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawLine(Offset(-len / 2, 0), Offset(len / 2, 0), Paint()
      ..color = Colors.white.withValues(alpha: .4)
      ..strokeWidth = len * .06);
    canvas.restore();
  }

  void _fish(Canvas canvas, Offset c, double s, Color color) {
    final body = Path()
      ..moveTo(c.dx - s * .2, c.dy)
      ..quadraticBezierTo(c.dx - s * .02, c.dy - s * .1, c.dx + s * .14, c.dy)
      ..quadraticBezierTo(c.dx - s * .02, c.dy + s * .1, c.dx - s * .2, c.dy)
      ..close();
    final tail = Path()
      ..moveTo(c.dx + s * .12, c.dy)
      ..lineTo(c.dx + s * .22, c.dy - s * .06)
      ..lineTo(c.dx + s * .22, c.dy + s * .06)
      ..close();
    canvas.drawPath(tail, Paint()..color = _shade(color, .85));
    canvas.drawPath(body, Paint()..color = color);
    final grill = Paint()
      ..color = _shade(color, .6)
      ..strokeWidth = s * .008
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final x = c.dx - s * .08 + i * s * .06;
      canvas.drawLine(Offset(x, c.dy - s * .04), Offset(x + s * .03, c.dy + s * .04), grill);
    }
    canvas.drawCircle(Offset(c.dx - s * .15, c.dy - s * .012), s * .01, Paint()..color = const Color(0xFF2E2833));
    // Limon dilimi
    final l = Offset(c.dx + s * .02, c.dy + s * .09);
    canvas.drawCircle(l, s * .04, Paint()..color = const Color(0xFFF4CF5B));
    canvas.drawCircle(l, s * .03, Paint()..color = const Color(0xFFFFF2B0));
  }

  void _drumstick(Canvas canvas, Offset c, double s, double angle) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    canvas.drawLine(Offset(s * .04, 0), Offset(s * .12, 0), Paint()
      ..color = const Color(0xFFF7F0E6)
      ..strokeWidth = s * .025
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(s * .125, -s * .01), s * .015, Paint()..color = const Color(0xFFF7F0E6));
    canvas.drawCircle(Offset(s * .125, s * .01), s * .015, Paint()..color = const Color(0xFFF7F0E6));
    canvas.drawOval(Rect.fromCenter(center: Offset(-s * .02, 0), width: s * .16, height: s * .1),
        Paint()..color = const Color(0xFFC98B4A));
    canvas.drawOval(Rect.fromCenter(center: Offset(-s * .035, -s * .015), width: s * .07, height: s * .03),
        Paint()..color = Colors.white.withValues(alpha: .3));
    canvas.restore();
  }
}
