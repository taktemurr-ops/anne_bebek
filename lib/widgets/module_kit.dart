import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/phone_launcher.dart';
import 'reference_widgets.dart';

const kitMor = Color(0xFF764A72);

/// Boşluklu bölüm başlığı.
class KitHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? action;
  final VoidCallback? onAction;
  const KitHeader(this.title, this.icon, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: PastelSectionHeader(icon: icon, title: title, action: action, onAction: onAction));
}

/// Renkli bilgi kartı.
class KitNote extends StatelessWidget {
  final String? title;
  final String text;
  final Color color;
  const KitNote(this.text, {super.key, this.title, this.color = const Color(0xFFFFF4FA)});
  @override
  Widget build(BuildContext context) => PastelCard(color: color, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[
          Text(title!, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
          const SizedBox(height: 4),
        ],
        Text(text, style: const TextStyle(fontSize: 13)),
      ]));
}

/// Madde işaretli liste (metinler çevrilir).
class KitBullets extends StatelessWidget {
  final List<String> items;
  final double fontSize;
  const KitBullets(this.items, {super.key, this.fontSize = 13});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final i in items)
          Padding(padding: const EdgeInsets.only(bottom: 6),
              child: Text('• ${t(i)}', style: TextStyle(fontSize: fontSize))),
      ]);
}

/// Küçük gri dipnot.
class KitFootnote extends StatelessWidget {
  final String text;
  const KitFootnote(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: const TextStyle(fontSize: 11.5, color: Colors.black54)));
}

void kitSnack(BuildContext context, String text) {
  final m = ScaffoldMessenger.maybeOf(context);
  m?..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text)));
}

void kitSaveFailed(BuildContext context) =>
    kitSnack(context, 'Kayıt cihazda saklanamadı. Lütfen tekrar deneyin.');

/// Onay penceresi; evet ise true.
Future<bool> kitConfirm(BuildContext context, String title, String body, {String yes = 'Sil'}) async =>
    await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title), content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(yes)),
      ])) ==
    true;

/// Gün seçici (bugünden ileri gidilmez).
Future<DateTime?> kitPickDay(BuildContext context, {DateTime? initial, DateTime? first, DateTime? last, String? help}) {
  final now = DateTime.now();
  final l = last ?? now;
  var i = initial ?? now;
  if (i.isAfter(l)) i = l;
  final f = first ?? DateTime(2000);
  if (i.isBefore(f)) i = f;
  return showDatePicker(context: context, initialDate: i, firstDate: f, lastDate: l,
      helpText: help == null ? null : t(help));
}

/// Telefonun arama ekranını açan büyük düğme.
class KitCallButton extends StatelessWidget {
  final String number;
  final String label;
  final Color color;
  const KitCallButton(this.number, this.label, {super.key, this.color = const Color(0xFFD32F2F)});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton.icon(
        key: Key('ara_$number'),
        style: FilledButton.styleFrom(backgroundColor: color, minimumSize: const Size.fromHeight(48)),
        onPressed: () async {
          var ok = false;
          try { ok = await PhoneLauncher.call(number); } catch (_) {}
          if (!ok && context.mounted) kitSnack(context, t('Arama açılamadı. Numarayı elle çevir: {0}').replaceAll('{0}', number));
        },
        icon: const Icon(Icons.call),
        label: Text('$number · ${t(label)}'),
      ));
}
