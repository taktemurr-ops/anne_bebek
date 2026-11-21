import 'package:flutter/material.dart' as m;
import 'package:flutter/widgets.dart';

import 'i18n.dart';

/// Flutter `Text` yerine kullanılır: Türkçe kaynak metni çizim anında seçili
/// dile çevirir. `import 'package:flutter/material.dart' hide Text;` ile
/// birlikte içe aktarılır; böylece mevcut `Text('...')` kullanımları
/// değiştirilmeden çok dilli olur.
class Text extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final TextDirection? textDirection;
  const Text(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow,
      this.softWrap, this.textScaler, this.semanticsLabel, this.textDirection});

  @override
  Widget build(BuildContext context) => m.Text(I18n.tr(data), style: style, textAlign: textAlign,
      maxLines: maxLines, overflow: overflow, softWrap: softWrap, textScaler: textScaler,
      semanticsLabel: semanticsLabel == null ? null : I18n.tr(semanticsLabel!), textDirection: textDirection);
}
