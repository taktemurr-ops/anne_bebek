import 'package:flutter/material.dart';

/// Tüm modüllerde ortak kullanılan, sade pastel tasarım renkleri.
abstract final class PastelPalette {
  static const background = Color(0xFFFFF7FC);
  static const surface = Color(0xFFFFFCFF);
  static const primary = Color(0xFFE94791);
  static const lavender = Color(0xFFEFE4FF);
  static const softPink = Color(0xFFFFE3F0);
  static const text = Color(0xFF48235F);
  static const divider = Color(0xFFF2E5F0);
}

/// Yeni modüller için tek tip geri tuşu ve rahat okunabilir başlık.
class PastelModuleScaffold extends StatelessWidget {
  const PastelModuleScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  tooltip: 'Geri dön',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: actions,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Text(subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      );
}

/// Uzun menü listeleri yerine tek sütun, büyük dokunma alanı.
class PastelActionTile extends StatelessWidget {
  const PastelActionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          leading: CircleAvatar(
            backgroundColor: PastelPalette.softPink,
            foregroundColor: PastelPalette.text,
            child: Icon(icon),
          ),
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      );
}
