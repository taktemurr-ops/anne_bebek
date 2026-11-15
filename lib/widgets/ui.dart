import 'package:flutter/material.dart';
const purple = Color(0xFF75466F);
const pink = Color(0xFFF3D5EB);

Widget sectionTitle(String text) => Padding(
  padding: const EdgeInsets.only(top: 18, bottom: 12),
  child: Text(text, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: purple)),
);

Widget categoryCard(String title, IconData icon, Color color, VoidCallback onTap) => InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(22),
  child: Container(
    constraints: const BoxConstraints(minHeight: 120),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: purple, size: 36),
      const SizedBox(height: 12),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(color: purple, fontWeight: FontWeight.bold)),
    ]),
  ),
);

Future<String?> askText(BuildContext context, String title, {String? hint}) async {
  String value = '';
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextFormField(
        autofocus: true,
        onChanged: (text) => value = text,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.of(dialogContext).pop(value.trim()), child: const Text('Kaydet')),
      ],
    ),
  );
}
