import 'dart:convert';

/// A server-verification snapshot, NOT a receipt validator or a checkout flow.
class PremiumEntitlement {
  final String productId;
  final DateTime? expiresAt;
  final bool verifiedByServer;

  const PremiumEntitlement({required this.productId,
    this.expiresAt, this.verifiedByServer = false});

  bool isActive(DateTime now) => verifiedByServer &&
      productId.trim().isNotEmpty &&
      (expiresAt == null || expiresAt!.isAfter(now));

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'expiresAt': expiresAt?.toIso8601String(),
    'verifiedByServer': verifiedByServer,
  };

  factory PremiumEntitlement.fromJson(Map<String, dynamic> data) {
    final productId = data['productId'];
    final expires = data['expiresAt'];
    final verified = data['verifiedByServer'];
    if (productId is! String || productId.trim().isEmpty ||
        productId.length > 120 || (expires != null && expires is! String) ||
        verified is! bool) {
      throw const FormatException('Geçersiz premium yetkisi');
    }
    final expiresAt = expires == null ? null : DateTime.tryParse(expires as String);
    if (expires != null && expiresAt == null) {
      throw const FormatException('Geçersiz premium bitiş tarihi');
    }
    return PremiumEntitlement(productId: productId,
      expiresAt: expiresAt, verifiedByServer: verified);
  }
}

String encodePremiumEntitlement(PremiumEntitlement entitlement) =>
    jsonEncode(entitlement.toJson());

PremiumEntitlement? decodePremiumEntitlement(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final decoded = jsonDecode(raw);
  if (decoded is! Map || decoded.keys.any((key) => key is! String)) {
    throw const FormatException('Geçersiz premium kaydı');
  }
  return PremiumEntitlement.fromJson(Map<String, dynamic>.from(decoded));
}
