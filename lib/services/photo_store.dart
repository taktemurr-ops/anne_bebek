import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Anı defteri fotoğrafları. Fotoğraflar uygulamanın özel klasöründe tutulur
/// (başka uygulamalar erişemez, galeriye eklenmez). Yedek dosyasına girmez;
/// "Verilerimi sil" ile birlikte silinir.
class PhotoStore {
  static const folder = 'memories';

  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/$folder');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  /// Kameradan ya da galeriden seçer, küçültüp klasöre kopyalar.
  /// Dosya adını döndürür; vazgeçilirse null.
  static Future<String?> pick({required bool camera}) async {
    final x = await ImagePicker().pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery, maxWidth: 1600, maxHeight: 1600, imageQuality: 85);
    if (x == null) return null;
    final dir = await _dir();
    final name = 'm_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(x.path).copy('${dir.path}/$name');
    return name;
  }

  static Future<String> pathOf(String name) async => '${(await _dir()).path}/$name';

  static Future<String> dirPath() async => (await _dir()).path;

  static Future<void> deleteFile(String name) async {
    if (name.contains('/') || name.contains('..')) return;
    final f = File(await pathOf(name));
    if (await f.exists()) await f.delete();
  }

  static Future<void> deleteAll() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/$folder');
    if (await d.exists()) await d.delete(recursive: true);
  }
}
