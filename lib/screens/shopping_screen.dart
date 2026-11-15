import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../widgets/ui.dart';
import 'product_catalog_page.dart';
import 'smart_shopping_page.dart';
import 'weekly_meal_planner_page.dart';
import 'backup_page.dart';

class ShoppingScreen extends StatelessWidget {
  final AppStore store;
  const ShoppingScreen({super.key, required this.store});
  Future<void> add(BuildContext context) async {
    final item = await askText(context, 'Alışveriş listesine ekle', hint: 'Ürün adı');
    if (item == null || item.isEmpty) return;
    await store.addShopping(item);
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    sectionTitle('Alışveriş Listem 🛍️'),
    FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ProductCatalogPage())), icon: const Icon(Icons.storefront_outlined), label: const Text('Ürün kataloğu ve karşılaştırma')),
    const SizedBox(height: 10),
    OutlinedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
        builder: (_) => const SmartShoppingPage())),
      icon: const Icon(Icons.auto_awesome_outlined),
      label: const Text('Akıllı alışveriş, stok ve bütçe merkezi'),
    ),
    OutlinedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
        builder: (_) => const WeeklyMealPlannerPage())),
      icon: const Icon(Icons.calendar_month_outlined),
      label: const Text('Haftalık yemek planlayıcı'),
    ),
    TextButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
        builder: (_) => const BackupPage())),
      icon: const Icon(Icons.backup_outlined),
      label: const Text('Alışveriş ve diğer kayıtları yedekle'),
    ),
    const SizedBox(height: 10),
    FilledButton.icon(onPressed: () => add(context), icon: const Icon(Icons.add), label: const Text('Ürün ekle')),
    const SizedBox(height: 12),
    for (var i = 0; i < store.shopping.length; i++) Card(child: ListTile(
      leading: const Icon(Icons.shopping_basket_outlined, color: purple), title: Text(store.shopping[i]),
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => store.deleteShopping(i)),
    )),
    const SizedBox(height: 12),
    const Text('Ürün türleri kataloğu ve özellik karşılaştırması eklendi. Gerçek fiyat, stok, satıcı ve ödeme entegrasyonu henüz bulunmuyor.', style: TextStyle(color: Colors.black54)),
  ]);
}
