# Anne & Bebek — bütünleşik proje kaynak paketi

Bu paket, daha önce birleştirilen `lib`, `android`, `ios`, `test` ve `pubspec.yaml` kaynaklarını içerir.

## Ekrandaki Git uyarısının çözümü

`LF will be replaced by CRLF` bir Flutter derleme hatası değildir. Git'in Windows satır sonu dönüşümü uyarısıdır.
`build/` ve `.dart_tool/` otomatik üretilen klasörlerdir; Git'e eklenmemelidir.

1. Proje köküne bu paketin `.gitignore` ve `.gitattributes` dosyalarını kopyalayın.
2. Proje kökünde PowerShell açın ve `powershell -ExecutionPolicy Bypass -File .\GIT_DUZELT.ps1` komutunu çalıştırın.
3. `git status --short` ile değişiklikleri kontrol edin; ardından commit/push yapın.

**Önemli:** `git rm --cached` yalnızca Git takip listesinden kaldırır; yerel dosyaları silmez.
Android `local.properties` makineye özel olduğu için paketten çıkarılmıştır; Flutter/Android Studio yerelde oluşturabilir.

## Doğrulama

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Bu komutlar burada çalıştırılmadı. Uygulamanın tüm özelliklerinin tamamlandığı veya yayın için hazır olduğu doğrulanmış değildir.
Mağaza yayını için ayrıca gerçek applicationId, release imzası ve cihaz testleri gereklidir.
