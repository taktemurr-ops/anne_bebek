import 'package:flutter/material.dart';

/// Kayıt diyaloglarında kullanılan controller'ları güvenle kapatır.
///
/// `await showDialog(...)` diyalog `pop` edildiği anda döner; ancak diyalog
/// kapanma animasyonu süresince içindeki `TextField`'lar hâlâ çizilir. Bu
/// sırada controller'lar `dispose` edilirse Flutter
/// `'_dependents.isEmpty': is not true` veya
/// "TextEditingController was used after being disposed" hatası verir ve
/// kırmızı ekran oluşur (Paket 39 §8).
///
/// Bu yardımcılar diyalog rotasının animasyonu tamamen bittiğinde
/// (`ModalRoute.completed`) controller'ları kapatır.
Future<T?> showDialogAndDispose<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required List<ChangeNotifier> disposables,
  bool barrierDismissible = true,
}) async {
  ModalRoute<dynamic>? route;
  try {
    final result = await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        route = ModalRoute.of(dialogContext);
        return builder(dialogContext);
      },
    );
    await _waitForRoute(route);
    return result;
  } finally {
    _disposeAll(disposables);
  }
}

/// [showDialogAndDispose] ile aynı korumayı alt sayfalar için sağlar.
Future<T?> showModalBottomSheetAndDispose<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required List<ChangeNotifier> disposables,
  bool isScrollControlled = false,
  bool showDragHandle = false,
  bool useSafeArea = false,
}) async {
  ModalRoute<dynamic>? route;
  try {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      builder: (sheetContext) {
        route = ModalRoute.of(sheetContext);
        return builder(sheetContext);
      },
    );
    await _waitForRoute(route);
    return result;
  } finally {
    _disposeAll(disposables);
  }
}

Future<void> _waitForRoute(ModalRoute<dynamic>? route) async {
  if (route == null) return;
  try {
    await route.completed;
  } catch (_) {
    // Rota hata ile tamamlansa bile controller'lar kapatılmalı.
  }
}

void _disposeAll(List<ChangeNotifier> disposables) {
  for (final item in disposables) {
    item.dispose();
  }
}
