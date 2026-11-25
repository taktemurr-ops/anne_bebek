import 'package:anne_bebek/screens/membership_page.dart';
import 'package:anne_bebek/services/affiliate.dart';
import 'package:anne_bebek/services/store_billing.dart';
import 'package:anne_bebek/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iş birliği bağlantısı güvenli oluşturulur', () {
    const tpl = 'https://ornek-magaza.com/ara?q={q}&ref=annebebek';
    expect(Affiliate.urlFor('Bebek bezi & mendil', template: tpl),
        'https://ornek-magaza.com/ara?q=Bebek+bezi+%26+mendil&ref=annebebek');
    expect(Affiliate.urlFor('x', template: 'http://guvensiz.com/?q={q}'), isNull);
    expect(Affiliate.urlFor('x', template: 'https://yer-tutucu-yok.com/'), isNull);
    expect(Affiliate.urlFor('   ', template: tpl), isNull);
    expect(Affiliate.configured, isFalse);
  });

  test('yapılandırma yokken satın alma kapalı', () {
    expect(SubscriptionService.configured, isFalse);
    expect(StoreBilling.configured, isFalse);
  });

  testWidgets('üyelik sayfası ücretsiz ve premium avantajları gösterir', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MembershipPage()));
    await tester.pumpAndSettle();
    expect(find.text('Ücretsiz'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text(freeFeatures.first), findsOneWidget);
    expect(find.text(premiumFeatures.first), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('mağaza sürümünde etkinleşir'), 200);
    expect(find.textContaining('mağaza sürümünde etkinleşir'), findsOneWidget);
  });
}
