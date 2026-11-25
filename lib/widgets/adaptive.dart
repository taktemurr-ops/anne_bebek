import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Telefon, katlanabilir ve tablet ekranlarında ortak düzen kuralları.
///
/// * Çok geniş ekranlarda (yatay tablet, masaüstü) içerik okunabilir bir
///   genişlikte ortalanır; kenarlar uygulamanın arka plan rengiyle dolar.
/// * Sistem yazı boyutu çok büyük seçildiğinde metinler okunur kalır ama
///   düzeni bozacak kadar büyümez (en çok 1,3 kat).
/// * Izgaralar sütun sayısını ekran genişliğine göre seçer; kutular sabit
///   yükseklikte kalır, böylece tablette dev kutular, küçük telefonda
///   taşan yazılar oluşmaz.
class Breakpoints {
  const Breakpoints._();

  /// Bu genişlik ve üstünde içerik ortalanır.
  static const double frameMaxWidth = 1000;

  /// 600 dp ve üstü tablet sayılır (Material yönergesi).
  static const double tablet = 600;

  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.3;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= tablet;
}

/// MaterialApp.builder için: her ekranı saran ortak çerçeve.
class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({super.key, required this.child, this.background});

  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scaled = mq.copyWith(
      textScaler: mq.textScaler.clamp(
          minScaleFactor: Breakpoints.minTextScale,
          maxScaleFactor: Breakpoints.maxTextScale),
    );
    final width = mq.size.width;
    if (width <= Breakpoints.frameMaxWidth) {
      return MediaQuery(data: scaled, child: child);
    }
    // Geniş ekran: içerik ortada; MediaQuery de bu genişliği bildirir ki
    // ekranlar kendi hesaplarını doğru genişliğe göre yapsın.
    const w = Breakpoints.frameMaxWidth;
    final side = (width - w) / 2;
    final framed = scaled.copyWith(
      size: Size(w, mq.size.height),
      padding: scaled.padding.copyWith(
          left: math.max(0, scaled.padding.left - side),
          right: math.max(0, scaled.padding.right - side)),
      viewPadding: scaled.viewPadding.copyWith(
          left: math.max(0, scaled.viewPadding.left - side),
          right: math.max(0, scaled.viewPadding.right - side)),
    );
    return ColoredBox(
      color: background ?? Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: w,
          child: MediaQuery(data: framed, child: ClipRect(child: child)),
        ),
      ),
    );
  }
}

/// Verilen genişliğe kaç sütun sığar.
int adaptiveColumns(double width,
    {required double minTileWidth, double spacing = 10, int min = 1, int max = 6}) {
  if (!width.isFinite || width <= 0) return min;
  final n = ((width + spacing) / (minTileWidth + spacing)).floor();
  return n.clamp(min, max);
}

/// Genişliğe göre sütun sayısını seçen, kaydırılmayan ızgara
/// (bir liste içinde kullanılır).
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    required this.minTileWidth,
    required this.tileHeight,
    this.spacing = 10,
    this.minColumns = 1,
    this.maxColumns = 6,
  });

  final List<Widget> children;

  /// Bir kutunun en az genişliği; bundan darsa sütun sayısı azalır.
  final double minTileWidth;

  /// Normal yazı boyutundaki kutu yüksekliği; büyük yazıda orantılı artar.
  final double tileHeight;
  final double spacing;
  final int minColumns, maxColumns;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return LayoutBuilder(builder: (context, c) {
      final cols = adaptiveColumns(c.maxWidth,
          minTileWidth: minTileWidth,
          spacing: spacing,
          min: minColumns,
          max: math.max(minColumns, math.min(maxColumns, children.length)));
      return GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          mainAxisExtent: tileHeight * math.max(1.0, scale),
        ),
        children: children,
      );
    });
  }
}
