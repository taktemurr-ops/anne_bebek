import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory implementation of the secure-storage platform channel for unit tests.
/// Production encryption and platform code are not replaced or disabled.
void installSecureStorageMock() {
  final values = <String, String>{};
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    final key = args['key'] as String?;
    switch (call.method) {
      case 'read':
        return values[key];
      case 'write':
        values[key!] = args['value'] as String;
        return null;
      case 'delete':
        values.remove(key);
        return null;
      case 'deleteAll':
        values.clear();
        return null;
      case 'readAll':
        return Map<String, String>.from(values);
      case 'containsKey':
        return values.containsKey(key);
      default:
        throw MissingPluginException('Unexpected secure storage method: ${call.method}');
    }
  });
}
