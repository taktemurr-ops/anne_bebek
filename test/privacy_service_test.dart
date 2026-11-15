import 'support/secure_storage_mock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anne_bebek/services/privacy_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(installSecureStorageMock);
  test('registered local records are deleted, unrelated settings remain', () async {
    SharedPreferences.setMockInitialValues({
      'bebekAdi': 'Deneme',
      'olaylar': '[]',
      'unrelated_setting': 'keep',
    });
    final count = await PrivacyService.deleteLocalRecords();
    final prefs = await SharedPreferences.getInstance();
    expect(count, greaterThanOrEqualTo(2));
    expect(prefs.getString('bebekAdi'), isNull);
    expect(prefs.getString('olaylar'), isNull);
    expect(prefs.getString('unrelated_setting'), 'keep');
  });
}
