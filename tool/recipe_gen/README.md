# Tarif kataloğu üretimi

`lib/data/general_recipe_catalog.dart` ve `lib/data/baby_recipe_catalog.dart` bu klasördeki
araçlarla üretilir; elle düzenlemeyin.

- `batches/*.py` — elle yazılmış tarifler (her biri `rewrites/*.json` üretir).
- `rewrites/drop.txt` — çıkarılan tek-malzeme varyantları.
- `gen_catalog.py` — kaynak katalog + yeniden yazımlar + yeni tarifler → genel katalog.
- `baby_data.py`, `gen_baby.py` — bebek tarifleri.

```
cd tool/recipe_gen
for b in batches/*.py; do python3 "$b"; done
python3 gen_catalog.py original_catalog.dart ../../lib/data/general_recipe_catalog.dart rewrites catalog_header.dart
python3 gen_baby.py original_baby_catalog.dart ../../lib/data/baby_recipe_catalog.dart
```
