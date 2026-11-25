import 'package:flutter/material.dart' hide Text;

import 'i18n.dart';
import 'text.dart';

/// Dil seçim penceresi; seçilen dil kaydedilir ve uygulama yeniden çizilir.
Future<void> showLanguagePicker(BuildContext context) async {
  final code = await showDialog<String>(context: context, builder: (ctx) => SimpleDialog(
    title: const Text('Dil seçin'),
    children: [
      for (final l in appLanguages) SimpleDialogOption(
        key: Key('dil_${l.code}'),
        onPressed: () => Navigator.pop(ctx, l.code),
        child: Row(children: [
          Icon(l.code == I18n.language.value ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFF764A72), size: 20),
          const SizedBox(width: 12),
          // Dil adı her dilde kendi yazımıyla gösterilir; çevrilmez.
          Expanded(child: Text(l.name)),
        ])),
    ]));
  if (code != null) await I18n.set(code);
}

/// Ayarlar listesinde kullanılan satır.
class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});
  @override
  Widget build(BuildContext context) => ListTile(
    key: const Key('dil_secimi'),
    leading: const Icon(Icons.language_rounded, color: Color(0xFF764A72)),
    title: const Text('Dil'),
    subtitle: Text(I18n.current.name),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: () => showLanguagePicker(context),
  );
}

/// Kompakt düğme (ör. açılış ekranının köşesi).
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});
  @override
  Widget build(BuildContext context) => TextButton.icon(
    key: const Key('dil_dugme'),
    onPressed: () => showLanguagePicker(context),
    icon: const Icon(Icons.language_rounded, size: 18),
    label: Text(I18n.current.name),
  );
}
