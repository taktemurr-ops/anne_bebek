import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cloud_auth_service.dart';

/// Supabase PostgREST women forum; server-side RLS is mandatory (see SQL setup).
class WomenForumService {
  static Uri _uri(String table, [Map<String, String>? query]) => Uri.parse(
    '${CloudAuthService.url.replaceAll(RegExp(r'/$'), '')}/rest/v1/$table',
  ).replace(queryParameters: query);

  static Future<String> _token() async {
    if (!CloudAuthService.configured) throw StateError('Çevrim içi forum henüz yapılandırılmadı.');
    var session = await CloudAuthService.currentSession();
    if (session == null) throw StateError('Forum için önce bulut hesabınıza giriş yapın.');
    final expiresAt = session['expires_at'];
    if (expiresAt is int && expiresAt <= DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60) {
      session = await CloudAuthService.refreshSession();
    }
    final token = session?['access_token'];
    if (token is! String || token.isEmpty) throw StateError('Oturum geçersiz. Yeniden giriş yapın.');
    return token;
  }

  static Future<dynamic> _request(String method, String table,
      {Map<String, String>? query, Map<String, dynamic>? body}) async {
    final token = await _token();
    final headers = {
      'apikey': CloudAuthService.anonKey,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };
    final uri = _uri(table, query);
    late http.Response response;
    if (method == 'GET') {
      response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
    } else if (method == 'POST') {
      response = await http.post(uri, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 20));
    } else if (method == 'DELETE') {
      response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 20));
    } else {
      throw ArgumentError('Unsupported method');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Forum işlemi başarısız (${response.statusCode}). ${response.body.length > 180 ? response.body.substring(0, 180) : response.body}');
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  static Future<List<Map<String, dynamic>>> posts() async {
    final result = await _request('GET', 'women_forum_posts', query: {
      'select': 'id,author_id,title,body,category,created_at',
      'order': 'created_at.desc', 'limit': '100',
    }) as List<dynamic>;
    return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<List<Map<String, dynamic>>> replies(String postId) async {
    final result = await _request('GET', 'women_forum_replies', query: {
      'select': 'id,post_id,author_id,body,created_at',
      'post_id': 'eq.$postId', 'order': 'created_at.asc', 'limit': '200',
    }) as List<dynamic>;
    return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> createPost(String title, String body, String category) async {
    await _request('POST', 'women_forum_posts', body: {
      'title': title.trim(), 'body': body.trim(), 'category': category,
    });
  }

  static Future<void> createReply(String postId, String body) async {
    await _request('POST', 'women_forum_replies', body: {
      'post_id': postId, 'body': body.trim(),
    });
  }

  static Future<void> deletePost(String postId) async {
    await _request('DELETE', 'women_forum_posts', query: {'id': 'eq.$postId'});
  }

  static Future<String?> currentUserId() async {
    final session = await CloudAuthService.currentSession();
    final user = session?['user'];
    return user is Map ? user['id']?.toString() : null;
  }
}
