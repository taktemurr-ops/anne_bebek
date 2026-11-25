/// İş birliği (affiliate) alışveriş bağlantıları.
/// Derleme ayarı: --dart-define=AFFILIATE_SEARCH_URL=https://...{q}...
///                --dart-define=AFFILIATE_PARTNER=MağazaAdı
/// Ayarlanmazsa uygulamada satın alma bağlantısı gösterilmez.
class Affiliate {
  static const searchTemplate = String.fromEnvironment('AFFILIATE_SEARCH_URL');
  static const partner = String.fromEnvironment('AFFILIATE_PARTNER');

  static bool isValidTemplate(String template) =>
      template.startsWith('https://') && template.contains('{q}') && template.length < 500;

  static bool get configured => isValidTemplate(searchTemplate) && partner.trim().isNotEmpty;

  /// Ürün adını şablondaki {q} yerine güvenli biçimde yerleştirir.
  static String? urlFor(String query, {String? template}) {
    final tpl = template ?? searchTemplate;
    final q = query.trim();
    if (!isValidTemplate(tpl) || q.isEmpty) return null;
    return tpl.replaceAll('{q}', Uri.encodeQueryComponent(q));
  }
}
