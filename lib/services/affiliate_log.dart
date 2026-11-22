import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cloud_auth_service.dart';

/// Bağlantı tıklamasını kişisel veri olmadan sayar (yalnızca ürün ve iş ortağı).
class AffiliateLog {
  static Future<void> click(String productId, String partner) async {
    if (!CloudAuthService.configured) return;
    try {
      await http.post(
        Uri.parse('${CloudAuthService.url.replaceAll(RegExp(r'/$'), '')}/rest/v1/rpc/log_affiliate_click'),
        headers: {'apikey': CloudAuthService.anonKey, 'Authorization': 'Bearer ${CloudAuthService.anonKey}', 'Content-Type': 'application/json'},
        body: jsonEncode({'p_product_id': productId, 'p_partner': partner}),
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Sayım başarısız olsa da bağlantı açılır.
    }
  }
}
