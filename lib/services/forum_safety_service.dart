import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cloud_auth_service.dart';

/// Shared reporting, moderation and inbox API. Server RLS is authoritative.
class ForumSafetyService {
  static Future<dynamic> request(String method, String table,
      {Map<String, String>? query, Map<String, dynamic>? body}) async {
    if (!CloudAuthService.configured) throw StateError('Bulut bağlantısı yapılandırılmadı.');
    var session = await CloudAuthService.currentSession();
    if (session == null) throw StateError('Önce hesabınıza giriş yapın.');
    final expiry = session['expires_at'];
    if (expiry is int && expiry <= DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60) {
      session = await CloudAuthService.refreshSession();
    }
    final token = session?['access_token'];
    if (token is! String || token.isEmpty) throw StateError('Oturum geçersiz.');
    final uri = Uri.parse('${CloudAuthService.url.replaceAll(RegExp(r'/$'), '')}/rest/v1/$table')
        .replace(queryParameters: query);
    final headers = {'apikey': CloudAuthService.anonKey,
      'Authorization': 'Bearer $token', 'Content-Type': 'application/json',
      'Prefer': 'return=representation'};
    late http.Response response;
    if (method == 'GET') {
      response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
    } else if (method == 'POST') {
      response = await http.post(uri, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 20));
    } else if (method == 'PATCH') {
      response = await http.patch(uri, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 20));
    } else { throw ArgumentError('Desteklenmeyen işlem'); }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('İşlem başarısız (${response.statusCode}).');
    }
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  static Future<void> report({required String forum, required String kind,
      required String contentId, required String reason}) async {
    if (!['baby', 'women'].contains(forum) || !['post', 'reply'].contains(kind)) {
      throw ArgumentError('Geçersiz bildirim türü');
    }
    await request('POST', 'forum_reports', body: {
      'forum': forum, 'content_kind': kind, 'content_id': contentId,
      'reason': reason.trim(),
    });
  }

  static Future<List<Map<String, dynamic>>> notifications() async {
    final result = await request('GET', 'forum_notifications', query: {
      'select': 'id,forum,post_id,kind,created_at,read_at',
      'order': 'created_at.desc', 'limit': '100',
    }) as List<dynamic>;
    return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> markRead(String id) async {
    await request('PATCH', 'forum_notifications', query: {'id': 'eq.$id'},
      body: {'read_at': DateTime.now().toUtc().toIso8601String()});
  }

  static Future<List<Map<String, dynamic>>> pendingReports() async {
    final result = await request('GET', 'forum_reports', query: {
      'select': 'id,forum,content_kind,content_id,reason,status,created_at',
      'status': 'eq.pending', 'order': 'created_at.asc', 'limit': '100',
    }) as List<dynamic>;
    return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> resolveReport(String id, String status) async {
    if (!['dismissed', 'removed'].contains(status)) throw ArgumentError('Geçersiz karar');
    await request('POST', 'rpc/moderate_forum_report', body: {
      'report_id': id, 'decision': status,
    });
  }
}
