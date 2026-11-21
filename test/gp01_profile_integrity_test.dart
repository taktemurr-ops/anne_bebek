import 'package:anne_bebek/screens/child_profiles_page.dart';
import 'package:anne_bebek/services/child_care_plans.dart';
import 'package:anne_bebek/services/child_profiles.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
  });

  testWidgets('GP-01: saglik planli cocuk profili silinmez', (tester) async {
    final child = ChildProfile(
      id: 'care-child',
      name: 'Deneme',
      birthDate: DateTime(2025, 8, 26),
    );
    final care = ChildCareItem(
      id: 'care-1',
      childId: child.id,
      category: 'Aşı',
      title: 'Doktor randevusu',
      note: 'Deneme',
      date: DateTime(2026, 11, 16),
      completed: false,
    );
    await SecureHealthStore.write(
      'child_profiles_directory_v58', encodeChildProfiles([child]),
    );
    await SecureHealthStore.write(
      'child_care_plan_v96', encodeChildCareItems([care]),
    );

    await tester.pumpWidget(const MaterialApp(home: ChildProfilesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Deneme'), findsOneWidget);
    await tester.tap(find.byTooltip('Profil işlemleri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profili sil'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Veri kaybını önlemek için profil silinmedi'),
        findsOneWidget);
    expect(
      decodeChildProfiles(
        await SecureHealthStore.read('child_profiles_directory_v58'),
      ),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });
}
