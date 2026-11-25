import 'package:flutter/material.dart' hide Text;
import '../i18n/text.dart';

import 'pastel_design.dart';

/// Sunucu bağlantısı gerektiren ve henüz açılmamış özellikler için ekran.
///
/// Özellik menüde görünür; açıldığında çalışıyormuş gibi davranmak yerine
/// "Yakında" olduğunu açıkça söyler.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                      color: PastelPalette.softPink, shape: BoxShape.circle),
                  child: Icon(icon, size: 56, color: PastelPalette.primary),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: PastelPalette.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Yakında',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 14),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900, color: PastelPalette.text)),
                const SizedBox(height: 10),
                Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 14),
                const Text(
                  'Bu özellik çevrim içi hizmet gerektiriyor ve bir sonraki güncellemelerle açılacak. '
                  'Uygulamadaki diğer tüm kayıtların cihazında güvenle saklanmaya devam ediyor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
              ]),
            ),
          ),
        ),
      );
}
