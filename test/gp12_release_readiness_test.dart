import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/release_readiness.dart';

void main() {
  test('GP-12 release is blocked by default', () {
    final gates = ReleaseReadiness();
    expect(gates.isReady, isFalse);
    expect(gates.missingGates, contains('iOS cihaz testleri'));
    expect(gates.missingGates, contains('Gizlilik değerlendirmesi'));
  });
  test('GP-12 release requires every gate', () {
    final gates = ReleaseReadiness(flutterAnalyzePassed: true,
      unitTestsPassed: true, androidBuildPassed: true,
      androidDeviceTestsPassed: true, iosBuildPassed: true,
      iosDeviceTestsPassed: true, privacyReviewPassed: true,
      storeMetadataReady: true, signingConfigured: true);
    expect(gates.isReady, isTrue);
    expect(gates.missingGates, isEmpty);
  });
  test('GP-12 signing failure blocks otherwise ready release', () {
    final gates = ReleaseReadiness(flutterAnalyzePassed: true,
      unitTestsPassed: true, androidBuildPassed: true,
      androidDeviceTestsPassed: true, iosBuildPassed: true,
      iosDeviceTestsPassed: true, privacyReviewPassed: true,
      storeMetadataReady: true);
    expect(gates.isReady, isFalse);
    expect(gates.missingGates, contains('İmzalama ve yayın kimlikleri'));
  });
}
