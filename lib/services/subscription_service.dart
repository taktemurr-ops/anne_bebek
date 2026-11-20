import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cloud_auth_service.dart';

/// Server-authoritative subscription state. Never grant paid access from a
/// local flag, product selection, or unverified store callback.
class SubscriptionService {
  static const verificationUrl = String.fromEnvironment('SUBSCRIPTION_API_URL');
  static const androidMonthly = String.fromEnvironment('ANDROID_PREMIUM_MONTHLY_ID');
  static const iosMonthly = String.fromEnvironment('IOS_PREMIUM_MONTHLY_ID');
  static const androidFamily = String.fromEnvironment('ANDROID_FAMILY_MONTHLY_ID');
  static const iosFamily = String.fromEnvironment('IOS_FAMILY_MONTHLY_ID');

  static bool get configured => verificationUrl.startsWith('https://') &&
      CloudAuthService.configured;

  static Future<SubscriptionStatus> fetchStatus() async {
    if (!configured) return const SubscriptionStatus(tier: 'free', configured: false);
    var session = await CloudAuthService.currentSession();
    if (session == null) return const SubscriptionStatus(tier: 'free', configured: true);
    var token = session['access_token'];
    if (token is! String || token.isEmpty) {
      return const SubscriptionStatus(tier: 'free', configured: true);
    }
    var response = await http.get(
      Uri.parse('$verificationUrl/status'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) {
      session = await CloudAuthService.refreshSession();
      token = session?['access_token'];
      if (token is! String) throw StateError('Oturum süresi doldu.');
      response = await http.get(Uri.parse('$verificationUrl/status'),
          headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 15));
    }
    if (response.statusCode != 200) {
      throw StateError('Abonelik durumu alınamadı (${response.statusCode}).');
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) throw const FormatException('Geçersiz abonelik yanıtı');
    return SubscriptionStatus.fromServerPayload(body, DateTime.now());
  }
}

class SubscriptionStatus {
  final String tier;
  final bool configured;
  final DateTime? expiresAt;
  const SubscriptionStatus({required this.tier, required this.configured, this.expiresAt});
  /// Fail closed on malformed, expired, or incomplete paid entitlement responses.
  /// A paid tier without a valid expiration is not considered verified.
  factory SubscriptionStatus.fromServerPayload(
      Map<String, dynamic> body, DateTime now) {
    final tier = body['tier'];
    final active = body['active'];
    final rawExpiry = body['expires_at'];
    if (tier is! String || active is! bool ||
        (rawExpiry != null && rawExpiry is! String)) {
      throw const FormatException('Geçersiz abonelik yanıtı');
    }
    final expiry = rawExpiry is String ? DateTime.tryParse(rawExpiry) : null;
    if (rawExpiry != null && expiry == null) {
      throw const FormatException('Geçersiz abonelik bitiş tarihi');
    }
    final paidTier = tier == 'premium' || tier == 'family';
    final verified = paidTier && active && expiry != null &&
        expiry.isAfter(now);
    return SubscriptionStatus(
      tier: verified ? tier : 'free',
      configured: true,
      expiresAt: expiry,
    );
  }

  bool get isPremium => tier == 'premium' || tier == 'family';
  bool get isFamily => tier == 'family';
  String get label => switch (tier) {
    'premium' => 'Premium',
    'family' => 'Premium Aile',
    _ => 'Ücretsiz',
  };
}
