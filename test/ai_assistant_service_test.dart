import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/ai_assistant_service.dart';

void main() {
  test('Kısa sorular reddedilir', () async {
    await expectLater(AiAssistantService.ask('a'), throwsArgumentError);
  });
  test('Aşırı uzun sorular reddedilir', () async {
    await expectLater(AiAssistantService.ask('x' * 1201), throwsArgumentError);
  });
}
