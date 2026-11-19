/// GP-12: Explicit release gates; do not infer success from a commit alone.
class ReleaseReadiness {
  final bool flutterAnalyzePassed;
  final bool unitTestsPassed;
  final bool androidBuildPassed;
  final bool androidDeviceTestsPassed;
  final bool iosBuildPassed;
  final bool iosDeviceTestsPassed;
  final bool privacyReviewPassed;
  final bool storeMetadataReady;
  final bool signingConfigured;

  const ReleaseReadiness({
    this.flutterAnalyzePassed = false,
    this.unitTestsPassed = false,
    this.androidBuildPassed = false,
    this.androidDeviceTestsPassed = false,
    this.iosBuildPassed = false,
    this.iosDeviceTestsPassed = false,
    this.privacyReviewPassed = false,
    this.storeMetadataReady = false,
    this.signingConfigured = false,
  });

  bool get isReady => missingGates.isEmpty;

  List<String> get missingGates => [
    if (!flutterAnalyzePassed) 'Flutter analyze',
    if (!unitTestsPassed) 'Birim testleri',
    if (!androidBuildPassed) 'Android derlemesi',
    if (!androidDeviceTestsPassed) 'Android cihaz testleri',
    if (!iosBuildPassed) 'iOS derlemesi',
    if (!iosDeviceTestsPassed) 'iOS cihaz testleri',
    if (!privacyReviewPassed) 'Gizlilik değerlendirmesi',
    if (!storeMetadataReady) 'Mağaza açıklamaları ve görselleri',
    if (!signingConfigured) 'İmzalama ve yayın kimlikleri',
  ];
}
