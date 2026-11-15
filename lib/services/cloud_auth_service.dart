import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_health_store.dart';

/// Supabase Auth (GoTrue) integration. Requires a real project URL and public
/// anon key supplied at build time. Never embed a service-role key in an app.
class CloudAuthService {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const storageKey = 'cloud_auth_session_v1';
  static bool get configured => url.startsWith('https://') && anonKey.isNotEmpty;
  static Uri endpoint(String path) => Uri.parse('${url.replaceAll(RegExp(r'/$'), '')}/auth/v1/$path');
  static Map<String, String> get headers => {'apikey': anonKey, 'Content-Type': 'application/json'};

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> payload) async {
    if (!configured) throw StateError('Bulut üyelik sistemi henüz yapılandırılmadı.');
    final response = await http.post(endpoint(path), headers: headers, body: jsonEncode(payload)).timeout(const Duration(seconds: 20));
    final parsed = jsonDecode(response.body);
    final data = parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(_friendlyError(data));
    }
    return data;
  }

  static String _friendlyError(Map<String, dynamic> data) {
    final message = (data['msg'] ?? data['error_description'] ?? data['message'] ?? data['error'] ?? 'İşlem tamamlanamadı.').toString();
    return message.length > 220 ? message.substring(0, 220) : message;
  }

  static Future<Map<String, dynamic>> register(String email, String password) async {
    final result = await _post('signup', {'email': email.trim(), 'password': password});
    await _saveIfAuthenticated(result);
    return result;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _post('token?grant_type=password', {'email': email.trim(), 'password': password});
    await _saveIfAuthenticated(result);
    return result;
  }

  static Future<void> resetPassword(String email) async {
    await _post('recover', {'email': email.trim()});
  }

  static Future<void> _saveIfAuthenticated(Map<String, dynamic> data) async {
    if (data['access_token'] is String && data['refresh_token'] is String) {
      await SecureHealthStore.write(storageKey, jsonEncode(data));
    }
  }

  static Future<Map<String, dynamic>?> currentSession() async {
    final raw = await SecureHealthStore.read(storageKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  static Future<Map<String, dynamic>?> refreshSession() async {
    final session = await currentSession();
    if (session == null) return null;
    final refresh = session['refresh_token'];
    if (refresh is! String) return null;
    final result = await _post('token?grant_type=refresh_token', {'refresh_token': refresh});
    await _saveIfAuthenticated(result);
    return result;
  }

  static Future<void> logout() async {
    final session = await currentSession();
    try {
      if (configured && session?['access_token'] is String) {
        await http.post(endpoint('logout'), headers: {...headers, 'Authorization': 'Bearer ${session!['access_token']}'}).timeout(const Duration(seconds: 10));
      }
    } finally {
      await SecureHealthStore.delete(storageKey);
    }
  }
}
