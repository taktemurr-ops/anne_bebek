import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/who_lms_math.dart';
import 'package:anne_bebek/services/child_profiles.dart';

void main() {
  test('CDC WHO 9 month boy reference example z score', () {
    final z = lmsZScore(9.7, const LmsParameters(-0.1600954, 9.476500305, 0.11218624));
    expect(z, closeTo(0.207, 0.002));
    expect(normalPercentile(z), closeTo(58.2, 0.4));
  });
  test('invalid parameters are rejected', () {
    expect(lmsZScore(-1, const LmsParameters(1, 9, 0.1)), isNull);
    expect(lmsZScore(9, const LmsParameters(1, 9, 0)), isNull);
    expect(normalPercentile(null), isNull);
  });
  test('older profiles preserve backward compatibility', () {
    final child = ChildProfile.fromJson({'id':'a','name':'Ada','birthDate':'2025-01-01T00:00:00.000'});
    expect(child.sex, 'unknown');
    expect(ChildProfile.fromJson(child.toJson()).sex, 'unknown');
  });
}
