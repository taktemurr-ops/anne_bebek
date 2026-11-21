import 'dart:async';
import 'package:anne_bebek/utils/privacy_log_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _capture(void Function() body) {
  final lines = <String>[];
  runZoned(body, zoneSpecification: ZoneSpecification(
    print: (self, parent, zone, line) => lines.add(line)));
  return lines;
}

void main() {
  test('yayın sürümünde hata günlüğe yazılmaz', () {
    final lines = _capture(() => logSafeError('Kayıt', const FormatException(
        '{"kilo":"7.2","not":"anne@example.com"}'), releaseMode: true));
    expect(lines, isEmpty);
  });

  test('geliştirmede iletişim bilgisi maskelenir ve mesaj kısaltılır', () {
    final lines = _capture(() => logSafeError('Kayıt',
        StateError('iletisim anne@example.com ${'x' * 300}'), releaseMode: false));
    expect(lines, hasLength(1));
    expect(lines.single, contains('[email]'));
    expect(lines.single, isNot(contains('anne@example.com')));
    expect(lines.single.length, lessThan(200));
  });
}
