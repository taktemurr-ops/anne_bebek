import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paket 39 referans tasarımı: renkli ikon ve özgün çizimler.
///
/// Renkli ikonlar için platformun kendi renkli emoji yazı tipi kullanılır
/// (Android: Noto Color Emoji, iOS: Apple Color Emoji); lisans gerektirmez.
/// Eski cihazlarda kutu görünmemesi için yalnızca Unicode 12 ve öncesi
/// emojiler seçilmiştir. Çizimler bu uygulama için çizilmiş vektörlerdir.

/// Tarif adından (yoksa kategoriden) renkli bir yemek simgesi seçer.
String recipeEmoji(String title, String category) {
  final t = title.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
  const byKeyword = <(String, String)>[
    ('çorba', '🍲'), ('tarhana', '🍲'), ('kurabiye', '🍪'), ('pasta', '🎂'),
    ('cheesecake', '🍰'), ('kek', '🍰'), ('muffin', '🧁'), ('brownie', '🍫'),
    ('çikolata', '🍫'), ('kakao', '🍫'), ('sütlaç', '🍮'), ('muhallebi', '🍮'),
    ('puding', '🍮'), ('dondurma', '🍨'), ('baklava', '🥮'), ('lokma', '🍩'),
    ('pankek', '🥞'), ('krep', '🥞'), ('waffle', '🧇'), ('pizza', '🍕'),
    ('hamburger', '🍔'), ('lahmacun', '🍕'), ('pide', '🥙'), ('dürüm', '🌯'),
    ('wrap', '🌯'), ('tost', '🥪'), ('sandviç', '🥪'), ('börek', '🥐'),
    ('poğaça', '🥐'), ('açma', '🥐'), ('simit', '🥯'), ('ekmek', '🍞'),
    ('makarna', '🍝'), ('spagetti', '🍝'), ('erişte', '🍜'), ('noodle', '🍜'),
    ('mantı', '🥟'), ('pilav', '🍚'), ('risotto', '🍚'), ('sushi', '🍣'),
    ('somon', '🐟'), ('levrek', '🐟'), ('çipura', '🐟'), ('hamsi', '🐟'),
    ('balık', '🐟'), ('ton ', '🐟'), ('karides', '🦐'), ('kalamar', '🦑'),
    ('midye', '🦪'), ('tavuk', '🍗'), ('hindi', '🍗'), ('köfte', '🍖'),
    ('kebap', '🍢'), ('şiş', '🍢'), ('kuzu', '🍖'), ('dana', '🥩'),
    ('biftek', '🥩'), ('et ', '🥩'), ('omlet', '🍳'), ('menemen', '🍳'),
    ('yumurta', '🥚'), ('salata', '🥗'), ('cacık', '🥒'), ('humus', '🥣'),
    ('smoothie', '🥤'), ('limonata', '🍋'), ('ayran', '🥛'), ('süt', '🥛'),
    ('çay', '🍵'), ('kahve', '☕'), ('kompost', '🍹'), ('meyve', '🍓'),
    ('patates', '🥔'), ('patlıcan', '🍆'), ('mantar', '🍄'), ('domates', '🍅'),
    ('havuç', '🥕'), ('brokoli', '🥦'), ('ıspanak', '🥬'), ('pırasa', '🥬'),
    ('lahana', '🥬'), ('kabak', '🥒'), ('mısır', '🌽'), ('biber', '🌶️'),
    ('avokado', '🥑'), ('muz', '🍌'), ('çilek', '🍓'), ('elma', '🍎'),
    ('armut', '🍐'), ('şeftali', '🍑'), ('kiraz', '🍒'), ('portakal', '🍊'),
    ('peynir', '🧀'), ('dolma', '🥘'), ('sarma', '🥘'), ('mercimek', '🥘'),
    ('nohut', '🥘'), ('fasulye', '🥘'), ('bulgur', '🥘'), ('güveç', '🥘'),
  ];
  for (final (k, e) in byKeyword) {
    if (t.contains(k)) return e;
  }
  return switch (category) {
    'Çorbalar' => '🍲',
    'Et yemekleri' => '🥩',
    'Tavuk yemekleri' => '🍗',
    'Balık ve deniz ürünleri' => '🐟',
    'Sebze yemekleri' => '🥦',
    'Bakliyat yemekleri' => '🥘',
    'Makarnalar' => '🍝',
    'Pilavlar' => '🍚',
    'Kahvaltılıklar' => '🍳',
    'Hamur işleri' => '🥐',
    'Salatalar' => '🥗',
    'Mezeler' => '🥙',
    'Tatlılar' => '🍮',
    'Kek ve kurabiyeler' => '🍰',
    'İçecekler' => '🥤',
    'Dünya mutfağı' => '🌮',
    'Diyet ve sağlıklı tarifler' => '🥗',
    'Pratik tarifler' => '⏱️',
    'Meyve' => '🍎',
    'Sebze' => '🥕',
    'Tahıl' => '🥣',
    'Et' => '🍖',
    'Balık' => '🐟',
    'Baklagil' => '🥘',
    'Yumurta' => '🍳',
    'Süt ürünü' => '🥛',
    'Kahvaltı' => '🥞',
    'Tatlı' => '🍮',
    'İçecek' => '🥤',
    'Fırın' => '🥐',
    'Makarna' => '🍝',
    'Çorba' => '🍲',
    _ => '🍽️',
  };
}

/// Pastel zemin üzerinde renkli emoji (referanstaki 3B ikon görünümü).
class EmojiBadge extends StatelessWidget {
  const EmojiBadge(this.emoji, {super.key, this.size = 40, this.background, this.radius});
  final String emoji;
  final double size;
  final Color? background;
  final double? radius;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: background == null
            ? null
            : BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius ?? size * 0.32)),
        child: Text(emoji,
            textScaler: TextScaler.noScaling,
            style: TextStyle(fontSize: size * (background == null ? 0.82 : 0.56), height: 1.1)),
      );
}

// ---------------------------------------------------------------------------
// Çizimler
// ---------------------------------------------------------------------------

const _skin = Color(0xFFFFD9C2);
const _skinShade = Color(0xFFF6C3A6);
const _hair = Color(0xFF6B3E2E);
const _cheek = Color(0x66FF8FB1);
const _ink = Color(0xFF4A2B3A);

Path _heart(Offset c, double s) {
  final p = Path();
  p.moveTo(c.dx, c.dy + s * 0.35);
  p.cubicTo(c.dx - s * 0.9, c.dy - s * 0.25, c.dx - s * 0.45, c.dy - s * 0.85, c.dx, c.dy - s * 0.4);
  p.cubicTo(c.dx + s * 0.45, c.dy - s * 0.85, c.dx + s * 0.9, c.dy - s * 0.25, c.dx, c.dy + s * 0.35);
  return p;
}

void _closedEye(Canvas c, Offset o, double w, Paint p) {
  c.drawArc(Rect.fromCenter(center: o, width: w, height: w * 0.7), math.pi * 0.1, math.pi * 0.8, false, p);
}

/// Bebek yüzü avatarı (çocuk kartları ve profil listesi).
class BabyFaceAvatar extends StatelessWidget {
  const BabyFaceAvatar({super.key, this.size = 48, this.girl = true, this.background = const Color(0xFFFFE3EF)});
  final double size;
  final bool girl;
  final Color background;
  @override
  Widget build(BuildContext context) => SizedBox.square(
      dimension: size, child: CustomPaint(painter: _BabyFacePainter(girl: girl, background: background)));
}

class _BabyFacePainter extends CustomPainter {
  _BabyFacePainter({required this.girl, required this.background});
  final bool girl;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);
    canvas.drawCircle(center, s / 2, Paint()..color = background);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: s / 2)));
    final face = Offset(s * 0.5, s * 0.56);
    final r = s * 0.3;
    // Kulaklar
    final skin = Paint()..color = _skin;
    canvas.drawCircle(face.translate(-r * 0.98, r * 0.05), r * 0.2, Paint()..color = _skinShade);
    canvas.drawCircle(face.translate(r * 0.98, r * 0.05), r * 0.2, Paint()..color = _skinShade);
    // Gövde (tulum)
    canvas.drawOval(Rect.fromCenter(center: Offset(s * 0.5, s * 1.02), width: s * 0.78, height: s * 0.5),
        Paint()..color = girl ? const Color(0xFFF7A8C9) : const Color(0xFFA9C8F5));
    canvas.drawCircle(face, r, skin);
    // Saç perçemi
    final hair = Paint()..color = _hair;
    final tuft = Path()
      ..moveTo(face.dx - r * 0.25, face.dy - r * 0.92)
      ..quadraticBezierTo(face.dx, face.dy - r * 1.45, face.dx + r * 0.3, face.dy - r * 1.0)
      ..quadraticBezierTo(face.dx + r * 0.05, face.dy - r * 1.05, face.dx + r * 0.08, face.dy - r * 0.82)
      ..close();
    canvas.drawPath(tuft, hair);
    canvas.drawArc(Rect.fromCircle(center: face, radius: r), math.pi * 1.15, math.pi * 0.7, false,
        Paint()..color = _hair..style = PaintingStyle.stroke..strokeWidth = r * 0.16..strokeCap = StrokeCap.round);
    // Gözler, yanaklar, gülümseme
    final eye = Paint()..color = _ink;
    canvas.drawOval(Rect.fromCenter(center: face.translate(-r * 0.36, -r * 0.05), width: r * 0.17, height: r * 0.24), eye);
    canvas.drawOval(Rect.fromCenter(center: face.translate(r * 0.36, -r * 0.05), width: r * 0.17, height: r * 0.24), eye);
    canvas.drawCircle(face.translate(-r * 0.58, r * 0.28), r * 0.16, Paint()..color = _cheek);
    canvas.drawCircle(face.translate(r * 0.58, r * 0.28), r * 0.16, Paint()..color = _cheek);
    canvas.drawArc(Rect.fromCenter(center: face.translate(0, r * 0.25), width: r * 0.5, height: r * 0.36),
        math.pi * 0.15, math.pi * 0.7, false,
        Paint()..color = _ink..style = PaintingStyle.stroke..strokeWidth = r * 0.08..strokeCap = StrokeCap.round);
    if (girl) {
      final bow = Paint()..color = const Color(0xFFF0449B);
      final b = face.translate(r * 0.62, -r * 0.78);
      canvas.drawPath(Path()
        ..moveTo(b.dx, b.dy)..lineTo(b.dx - r * 0.34, b.dy - r * 0.2)..lineTo(b.dx - r * 0.34, b.dy + r * 0.2)..close(), bow);
      canvas.drawPath(Path()
        ..moveTo(b.dx, b.dy)..lineTo(b.dx + r * 0.34, b.dy - r * 0.2)..lineTo(b.dx + r * 0.34, b.dy + r * 0.2)..close(), bow);
      canvas.drawCircle(b, r * 0.1, Paint()..color = const Color(0xFFC2186B));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BabyFacePainter old) => old.girl != girl || old.background != background;
}

/// Ana sayfa karşılama kartındaki anne ve bebek çizimi.
class MotherBabyArt extends StatelessWidget {
  const MotherBabyArt({super.key, this.width = 130, this.height = 120});
  final double width, height;
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: width, height: height, child: CustomPaint(painter: _MotherBabyPainter()));
}

class _MotherBabyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawCircle(Offset(w * 0.58, h * 0.52), h * 0.46, Paint()..color = const Color(0xFFFFD3E6));
    final heart = Paint()..color = const Color(0xFFF77DB4);
    canvas.drawPath(_heart(Offset(w * 0.12, h * 0.22), h * 0.11), heart);
    canvas.drawPath(_heart(Offset(w * 0.24, h * 0.08), h * 0.07), Paint()..color = const Color(0xFFFFA9CF));
    canvas.drawPath(_heart(Offset(w * 0.93, h * 0.2), h * 0.08), Paint()..color = const Color(0xFFFFA9CF));

    final mHead = Offset(w * 0.64, h * 0.34);
    final r = h * 0.17;
    // Anne: saç (arka), omuzlar, yüz
    final hair = Paint()..color = _hair;
    canvas.drawPath(Path()
      ..moveTo(mHead.dx - r * 1.05, mHead.dy)
      ..quadraticBezierTo(mHead.dx - r * 1.2, mHead.dy - r * 1.35, mHead.dx + r * 0.2, mHead.dy - r * 1.15)
      ..quadraticBezierTo(mHead.dx + r * 1.35, mHead.dy - r * 0.9, mHead.dx + r * 1.15, mHead.dy + r * 0.6)
      ..quadraticBezierTo(mHead.dx + r * 1.5, mHead.dy + r * 1.9, mHead.dx + r * 0.9, mHead.dy + r * 2.3)
      ..lineTo(mHead.dx - r * 1.0, mHead.dy + r * 1.6)
      ..close(), hair);
    canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(w * 0.36, h * 0.66, w * 0.6, h * 0.42),
            topLeft: Radius.circular(h * 0.2), topRight: Radius.circular(h * 0.2)),
        Paint()..color = const Color(0xFFF0449B));
    canvas.drawRect(Rect.fromCenter(center: mHead.translate(0, r * 1.15), width: r * 0.6, height: r * 0.6),
        Paint()..color = _skinShade);
    canvas.drawCircle(mHead, r, Paint()..color = _skin);
    // Perçem
    canvas.drawPath(Path()
      ..moveTo(mHead.dx - r * 1.0, mHead.dy - r * 0.1)
      ..quadraticBezierTo(mHead.dx - r * 0.6, mHead.dy - r * 1.25, mHead.dx + r * 0.9, mHead.dy - r * 0.55)
      ..quadraticBezierTo(mHead.dx + r * 0.1, mHead.dy - r * 0.6, mHead.dx - r * 1.0, mHead.dy - r * 0.1)
      ..close(), hair);
    final line = Paint()..color = _ink..style = PaintingStyle.stroke..strokeWidth = r * 0.1..strokeCap = StrokeCap.round;
    _closedEye(canvas, mHead.translate(-r * 0.38, r * 0.05), r * 0.32, line);
    _closedEye(canvas, mHead.translate(r * 0.3, r * 0.05), r * 0.32, line);
    canvas.drawCircle(mHead.translate(-r * 0.55, r * 0.38), r * 0.16, Paint()..color = _cheek);
    canvas.drawCircle(mHead.translate(r * 0.5, r * 0.38), r * 0.16, Paint()..color = _cheek);
    canvas.drawArc(Rect.fromCenter(center: mHead.translate(-r * 0.04, r * 0.42), width: r * 0.42, height: r * 0.3),
        math.pi * 0.15, math.pi * 0.7, false, line);

    // Bebek: battaniye, yüz, kol
    final bHead = Offset(w * 0.44, h * 0.68);
    final br = h * 0.13;
    canvas.drawOval(Rect.fromCenter(center: bHead.translate(br * 0.9, br * 1.1), width: br * 3.4, height: br * 2.2),
        Paint()..color = const Color(0xFFFFF4FA));
    canvas.drawCircle(bHead, br, Paint()..color = _skin);
    canvas.drawPath(Path()
      ..moveTo(bHead.dx - br * 0.2, bHead.dy - br * 0.95)
      ..quadraticBezierTo(bHead.dx + br * 0.1, bHead.dy - br * 1.5, bHead.dx + br * 0.35, bHead.dy - br * 1.0)
      ..close(), hair);
    final bl = Paint()..color = _ink..style = PaintingStyle.stroke..strokeWidth = br * 0.11..strokeCap = StrokeCap.round;
    _closedEye(canvas, bHead.translate(-br * 0.35, 0), br * 0.32, bl);
    _closedEye(canvas, bHead.translate(br * 0.35, 0), br * 0.32, bl);
    canvas.drawCircle(bHead.translate(-br * 0.55, br * 0.35), br * 0.18, Paint()..color = _cheek);
    canvas.drawCircle(bHead.translate(br * 0.55, br * 0.35), br * 0.18, Paint()..color = _cheek);
    // Annenin kolu bebeği sarıyor
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: bHead.translate(br * 1.2, br * 1.35), width: br * 3.0, height: br * 0.75),
            Radius.circular(br * 0.4)),
        Paint()..color = _skin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gebelik kartındaki hamile kadın çizimi.
class PregnantArt extends StatelessWidget {
  const PregnantArt({super.key, this.width = 110, this.height = 130});
  final double width, height;
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: width, height: height, child: CustomPaint(painter: _PregnantPainter()));
}

class _PregnantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawPath(_heart(Offset(w * 0.15, h * 0.2), h * 0.09), Paint()..color = const Color(0xFFFFA9CF));
    canvas.drawPath(_heart(Offset(w * 0.88, h * 0.32), h * 0.07), Paint()..color = const Color(0xFFF77DB4));
    final head = Offset(w * 0.5, h * 0.2);
    final r = h * 0.11;
    final hair = Paint()..color = _hair;
    // Uzun saç
    canvas.drawPath(Path()
      ..moveTo(head.dx - r * 1.1, head.dy)
      ..quadraticBezierTo(head.dx - r * 1.1, head.dy - r * 1.3, head.dx, head.dy - r * 1.15)
      ..quadraticBezierTo(head.dx + r * 1.2, head.dy - r * 1.1, head.dx + r * 1.1, head.dy + r * 0.4)
      ..quadraticBezierTo(head.dx + r * 1.4, head.dy + r * 2.4, head.dx + r * 0.6, head.dy + r * 3.0)
      ..lineTo(head.dx - r * 1.2, head.dy + r * 2.6)
      ..quadraticBezierTo(head.dx - r * 1.5, head.dy + r * 1.4, head.dx - r * 1.1, head.dy)
      ..close(), hair);
    // Elbise ve karın
    final dress = Paint()..color = const Color(0xFFF7A8C9);
    canvas.drawPath(Path()
      ..moveTo(w * 0.36, h * 0.38)
      ..lineTo(w * 0.64, h * 0.38)
      ..quadraticBezierTo(w * 0.72, h * 0.6, w * 0.76, h * 0.98)
      ..lineTo(w * 0.24, h * 0.98)
      ..quadraticBezierTo(w * 0.28, h * 0.6, w * 0.36, h * 0.38)
      ..close(), dress);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.6, h * 0.66), width: w * 0.46, height: h * 0.3),
        Paint()..color = const Color(0xFFF48DB9));
    // Eller karın üzerinde
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.56, h * 0.62), width: w * 0.16, height: h * 0.07), Paint()..color = _skin);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.64, h * 0.72), width: w * 0.16, height: h * 0.07), Paint()..color = _skin);
    canvas.drawPath(_heart(Offset(w * 0.68, h * 0.6), h * 0.05), Paint()..color = Colors.white.withValues(alpha: 0.85));
    // Boyun ve yüz
    canvas.drawRect(Rect.fromCenter(center: head.translate(0, r * 1.2), width: r * 0.55, height: r * 0.7), Paint()..color = _skinShade);
    canvas.drawCircle(head, r, Paint()..color = _skin);
    canvas.drawPath(Path()
      ..moveTo(head.dx - r, head.dy - r * 0.1)
      ..quadraticBezierTo(head.dx - r * 0.3, head.dy - r * 1.3, head.dx + r, head.dy - r * 0.3)
      ..quadraticBezierTo(head.dx, head.dy - r * 0.55, head.dx - r, head.dy - r * 0.1)
      ..close(), hair);
    final line = Paint()..color = _ink..style = PaintingStyle.stroke..strokeWidth = r * 0.12..strokeCap = StrokeCap.round;
    _closedEye(canvas, head.translate(-r * 0.38, r * 0.1), r * 0.34, line);
    _closedEye(canvas, head.translate(r * 0.38, r * 0.1), r * 0.34, line);
    canvas.drawCircle(head.translate(-r * 0.55, r * 0.45), r * 0.17, Paint()..color = _cheek);
    canvas.drawCircle(head.translate(r * 0.55, r * 0.45), r * 0.17, Paint()..color = _cheek);
    canvas.drawArc(Rect.fromCenter(center: head.translate(0, r * 0.45), width: r * 0.45, height: r * 0.32),
        math.pi * 0.15, math.pi * 0.7, false, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kadınlar ekranındaki "Bugünkü Notun" kartı için kadın portresi.
class WomanPortraitArt extends StatelessWidget {
  const WomanPortraitArt({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: _WomanPainter()));
}

class _WomanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    canvas.drawCircle(c, s / 2, Paint()..color = const Color(0xFFFFE3EF));
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: s / 2)));
    final head = Offset(s * 0.5, s * 0.48);
    final r = s * 0.2;
    final hair = Paint()..color = _hair;
    canvas.drawCircle(head.translate(0, -r * 1.05), r * 0.45, hair); // topuz
    canvas.drawCircle(head.translate(0, -r * 0.1), r * 1.12, hair);
    canvas.drawOval(Rect.fromCenter(center: Offset(s * 0.5, s * 1.0), width: s * 0.8, height: s * 0.5),
        Paint()..color = const Color(0xFFB98BF0));
    canvas.drawRect(Rect.fromCenter(center: head.translate(0, r * 1.15), width: r * 0.6, height: r * 0.8), Paint()..color = _skinShade);
    canvas.drawCircle(head, r, Paint()..color = _skin);
    final line = Paint()..color = _ink..style = PaintingStyle.stroke..strokeWidth = r * 0.12..strokeCap = StrokeCap.round;
    _closedEye(canvas, head.translate(-r * 0.38, r * 0.05), r * 0.34, line);
    _closedEye(canvas, head.translate(r * 0.38, r * 0.05), r * 0.34, line);
    canvas.drawCircle(head.translate(-r * 0.55, r * 0.42), r * 0.17, Paint()..color = _cheek);
    canvas.drawCircle(head.translate(r * 0.55, r * 0.42), r * 0.17, Paint()..color = _cheek);
    canvas.drawArc(Rect.fromCenter(center: head.translate(0, r * 0.45), width: r * 0.45, height: r * 0.3),
        math.pi * 0.15, math.pi * 0.7, false, line);
    // Çiçek
    final f = head.translate(r * 0.95, -r * 0.7);
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      canvas.drawCircle(f + Offset(math.cos(a), math.sin(a)) * r * 0.22, r * 0.18, Paint()..color = const Color(0xFFF77DB4));
    }
    canvas.drawCircle(f, r * 0.13, Paint()..color = const Color(0xFFFFD54F));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
