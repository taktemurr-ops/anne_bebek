import '../utils/ai_request_guard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cloud_auth_service.dart';

/// Sends only the text the user explicitly submits. Never ship AI provider keys
/// in Flutter binaries. The Edge Function must enforce authorization and quotas.
class AiAssistantService {
  static bool get configured => CloudAuthService.configured;

  static Future<String> ask(String question) async {
    final text = AiRequestGuard.maskContactDetails(question.trim());
    if (text.runes.length < 3 || text.runes.length > 1200) {
      throw ArgumentError('Sorunuz 3–1200 karakter arasında olmalıdır.');
    }
    if (!configured) throw StateError('AI sunucusu henüz yapılandırılmadı.');
    var session = await CloudAuthService.currentSession();
    if (session?['access_token'] is! String) {
      throw StateError('AI asistanını kullanmak için hesabınıza giriş yapın.');
    }
    final expiresAt = session?['expires_at'];
    if (expiresAt is num && expiresAt <= DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60) {
      session = await CloudAuthService.refreshSession();
    }
    final token = session?['access_token'];
    if (token is! String || token.isEmpty) throw StateError('Oturumunuzu yenileyip tekrar deneyin.');
    final uri = Uri.parse('${CloudAuthService.url.replaceAll(RegExp(r'/$'), '')}/functions/v1/anne-bebek-ai');
    final response = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      'apikey': CloudAuthService.anonKey,
      'Authorization': 'Bearer $token',
    }, body: jsonEncode({'question': text})).timeout(const Duration(seconds: 35));
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      payload = decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      throw StateError('Sunucudan geçerli yanıt alınamadı.');
    }
    if (response.statusCode != 200) {
      throw StateError((payload['error'] ?? 'AI yanıtı alınamadı (${response.statusCode}).').toString());
    }
    final answer = payload['answer'];
    if (answer is! String || answer.trim().isEmpty) throw StateError('Boş AI yanıtı alındı.');
    return answer.trim();
  }
}
