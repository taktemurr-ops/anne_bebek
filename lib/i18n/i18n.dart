import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gen/strings.dart';

/// Uygulama dilleri. Kaynak dil Türkçedir; çeviriler Türkçe metin anahtarıyla
/// tutulur (bkz. tool/i18n). Bulunamayan metin Türkçe gösterilir.
class AppLanguage {
  final String code;
  final String name; // kendi dilinde
  final bool rtl;
  const AppLanguage(this.code, this.name, {this.rtl = false});
}

const appLanguages = <AppLanguage>[
  AppLanguage('tr', 'Türkçe'),
  AppLanguage('en', 'English'),
  AppLanguage('ar', 'العربية', rtl: true),
  AppLanguage('de', 'Deutsch'),
  AppLanguage('fr', 'Français'),
  AppLanguage('es', 'Español'),
  AppLanguage('ru', 'Русский'),
  AppLanguage('pt', 'Português'),
  AppLanguage('fa', 'فارسی', rtl: true),
  AppLanguage('id', 'Bahasa Indonesia'),
];

class I18n {
  static const prefsKey = 'app_language_v1';

  /// Seçili dil kodu; değişince uygulama yeniden çizilir.
  static final ValueNotifier<String> language = ValueNotifier('tr');

  static Map<String, String> _exact = const {};
  /// (desen, hedef metin, kaynak metindeki yer tutucu sırası). Sıra, kaynakta
  /// {1} … {0} gibi karışık sırada yazılmış şablonların doğru eşlenmesi içindir.
  static List<(RegExp, String, List<int>)> _templates = const [];

  /// Kayıtlı dili yükler; yoksa cihaz dilini (destekleniyorsa) kullanır.
  static Future<void> load() async {
    String? code;
    try {
      code = (await SharedPreferences.getInstance()).getString(prefsKey);
    } catch (_) {}
    code ??= PlatformDispatcher.instance.locale.languageCode;
    _apply(appLanguages.any((l) => l.code == code) ? code : 'tr');
  }

  static Future<void> set(String code) async {
    if (!appLanguages.any((l) => l.code == code)) return;
    _apply(code);
    try {
      await (await SharedPreferences.getInstance()).setString(prefsKey, code);
    } catch (_) {}
  }

  static bool get hasChosen => _chosen;
  static bool _chosen = false;
  static Future<bool> wasChosen() async {
    try {
      _chosen = (await SharedPreferences.getInstance()).getString(prefsKey) != null;
    } catch (_) {}
    return _chosen;
  }

  @visibleForTesting
  static void setForTest(String code, {Map<String, String>? exact}) {
    _apply(code);
    if (exact != null) {
      _exact = exact;
      _templates = [
        for (final e in exact.entries)
          if (e.key.contains('{0}')) (_templateRegExp(e.key), e.value, templateOrder(e.key)),
      ];
    }
  }

  static void _apply(String code) {
    final table = translationTables[code];
    _exact = table ?? const {};
    _templates = [
      for (final e in _exact.entries)
        if (e.key.contains('{0}')) (_templateRegExp(e.key), e.value, templateOrder(e.key)),
    ];
    language.value = code;
  }

  /// Kaynak şablondaki yer tutucuların görünme sırasıyla numaraları.
  @visibleForTesting
  static List<int> templateOrder(String tpl) =>
      [for (final m in RegExp(r'\{(\d+)\}').allMatches(tpl)) int.parse(m.group(1)!)];

  static RegExp _templateRegExp(String tpl) {
    final parts = tpl.split(RegExp(r'\{\d+\}'));
    final buf = StringBuffer('^');
    for (var i = 0; i < parts.length; i++) {
      buf.write(RegExp.escape(parts[i]));
      if (i < parts.length - 1) buf.write(r'([\s\S]+?)');
    }
    buf.write(r'$');
    return RegExp(buf.toString());
  }

  static AppLanguage get current =>
      appLanguages.firstWhere((l) => l.code == language.value, orElse: () => appLanguages.first);

  static Locale get locale => Locale(language.value);

  /// Türkçe metnin seçili dildeki karşılığı.
  static String tr(String text) {
    if (language.value == 'tr' || text.isEmpty) return text;
    final exact = _exact[text];
    if (exact != null) return exact;
    for (final (re, target, order) in _templates) {
      final m = re.firstMatch(text);
      if (m == null) continue;
      var out = target;
      for (var i = 1; i <= m.groupCount; i++) {
        final g = m.group(i)!;
        final index = i - 1 < order.length ? order[i - 1] : i - 1;
        out = out.replaceAll('{$index}', _exact[g] ?? g);
      }
      return out;
    }
    return text;
  }
}

/// Kısayol: `t('Kaydet')`.
String t(String text) => I18n.tr(text);
