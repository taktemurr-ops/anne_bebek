import 'forum_safety_service.dart';

/// Read-only administrative summary. The SQL RPC checks auth.uid() against
/// private admin membership; UI visibility is never an authorization boundary.
class AdminDashboardService {
  static Future<Map<String, dynamic>> summary() async {
    final result = await ForumSafetyService.request('POST',
      'rpc/admin_dashboard_summary', body: <String, dynamic>{});
    if (result is! Map) throw const FormatException('Geçersiz yönetim yanıtı');
    return Map<String, dynamic>.from(result);
  }
}
