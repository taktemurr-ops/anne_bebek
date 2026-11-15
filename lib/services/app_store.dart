import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_data.dart';
import 'secure_health_store.dart';

class AppStore extends ChangeNotifier {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  BabyProfile? baby;
  List<BabyEntry> entries = [];
  List<String> shopping = ['Bebek bezi', 'Islak mendil'];
  bool ready = false;

  Future<void> load() async {
    try {
      final babyJson = await SecureHealthStore.read('baby_v2');
      if (babyJson != null) baby = BabyProfile.fromJson(Map<String, dynamic>.from(jsonDecode(babyJson) as Map));
      final entriesJson = await SecureHealthStore.read('entries_v2');
      if (entriesJson != null) entries = (jsonDecode(entriesJson) as List).map((e) => BabyEntry.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      final shoppingJson = await _prefs.getString('shopping_v2');
      if (shoppingJson != null) shopping = (jsonDecode(shoppingJson) as List).cast<String>();
    } catch (e) {
      debugPrint('Yerel veri okuma hatası: $e');
    } finally {
      ready = true;
      notifyListeners();
    }
  }

  Future<void> saveBaby(BabyProfile value) async {
    baby = value;
    notifyListeners();
    await SecureHealthStore.write('baby_v2', jsonEncode(value.toJson()));
  }

  Future<void> addEntry(String category, String note) async {
    final now = DateTime.now();
    entries = [BabyEntry(id: now.microsecondsSinceEpoch.toString(), category: category, note: note, createdAt: now), ...entries];
    notifyListeners();
    await _saveEntries();
  }

  Future<void> deleteEntry(String id) async {
    entries = entries.where((e) => e.id != id).toList();
    notifyListeners();
    await _saveEntries();
  }

  Future<void> _saveEntries() => SecureHealthStore.write('entries_v2', jsonEncode(entries.map((e) => e.toJson()).toList()));

  Future<void> addShopping(String item) async {
    shopping = [...shopping, item];
    notifyListeners();
    await _saveShopping();
  }

  Future<void> deleteShopping(int index) async {
    shopping = [...shopping]..removeAt(index);
    notifyListeners();
    await _saveShopping();
  }

  Future<void> _saveShopping() => _prefs.setString('shopping_v2', jsonEncode(shopping));
}
