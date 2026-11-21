import re, sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from baby_data import BASE, NEW

SRC, OUT = sys.argv[1], sys.argv[2]
src = open(SRC, encoding='utf-8').read()
KEEP = {'ozgun001', 'ozgun002', 'ozgun003', 'ozgun006', 'ozgun013', 'ozgun014', 'ozgun020'}
ozgun = [o for o in re.findall(r"  BabyRecipe\(id: 'ozgun\d+'.*?\]\),\n", src, re.S)
         if re.search(r"id: '(ozgun\d+)'", o).group(1) in KEEP]
assert len(ozgun) == len(KEEP), len(ozgun)

def q(v):
    return "'" + v.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"

def ql(xs):
    return '[' + ', '.join(q(x) for x in xs) + ']'

def rec(d):
    parts = ["id: %s" % q(d['id']), "title: %s" % q(d['title']), "age: %s" % q(d['age']),
             "category: %s" % q(d['category']), "ingredient: %s" % q(d['ingredient']),
             "vegetable: %s" % q(d['vegetable']), "ingredients: %s" % ql(d['ingredients']),
             "steps: %s" % ql(d['steps'])]
    if d.get('variants'):
        parts.append("variants: %s" % ql(d['variants']))
    if d.get('tips'):
        parts.append("tips: %s" % ql(d['tips']))
    if d.get('storage'):
        parts.append("storage: %s" % q(d['storage']))
    return '  BabyRecipe(%s),\n' % ', '.join(parts)

header = '''// Bebek tarifleri kataloğu (Paket 39 §4).
// Araçla üretilir. Her kayıt bağımsız bir tariftir; "variants" aynı tarifte
// kullanılabilecek sebze/meyve seçenekleridir ve ayrı tarif sayılmaz.
// Önceki sürümdeki 300 "varyasyon" (30 yöntem x 10 sebze) bu yapıya
// dönüştürülmüştür.

/// Paket 39'da istenen yaş grupları.
const babyAgeGroups = <String>['6–8 ay', '9–11 ay', '12–18 ay', '18–24 ay', '24–36 ay', '36–72 ay'];

class BabyRecipe {
  final String id, title, age, category, ingredient, vegetable;
  final List<String> ingredients, steps;

  /// Aynı tarifte kullanılabilecek sebze/meyve seçenekleri.
  final List<String> variants;
  final List<String> tips;
  final String? storage;

  const BabyRecipe({
    required this.id,
    required this.title,
    required this.age,
    required this.category,
    required this.ingredient,
    required this.vegetable,
    required this.ingredients,
    required this.steps,
    this.variants = const [],
    this.tips = const [],
    this.storage,
  });

  /// Önerilen en küçük yaş (ay).
  int get minMonths => int.tryParse(age.replaceAll('+', '').trim()) ?? 6;

  /// [babyAgeGroups] içindeki grup.
  String get ageGroup {
    final m = minMonths;
    if (m <= 8) return babyAgeGroups[0];
    if (m <= 11) return babyAgeGroups[1];
    if (m < 18) return babyAgeGroups[2];
    if (m < 24) return babyAgeGroups[3];
    if (m < 36) return babyAgeGroups[4];
    return babyAgeGroups[5];
  }

  /// Verilen aydaki çocuk için uygun mu (en küçük yaş sınırına göre).
  bool suitableFor(int months) => months >= minMonths;
}

/// Eski "bXXvYY" varyasyon kimliklerini yeni tarif kimliğine çevirir
/// (kayıtlı favoriler kaybolmasın diye).
String babyRecipeIdFor(String id) {
  final m = RegExp(r'^(b\\d\\d)v\\d\\d$').firstMatch(id);
  return m == null ? id : '${m.group(1)}v00';
}

const babyRecipes = <BabyRecipe>[
'''
body = ''.join(rec(d) for d in BASE) + ''.join(ozgun) + ''.join(rec(d) for d in NEW)
open(OUT, 'w', encoding='utf-8').write(header + body + '];\n')
ids = [d['id'] for d in BASE + NEW]
assert len(ids) == len(set(ids))
print('base', len(BASE), 'ozgun', len(ozgun), 'new', len(NEW), 'total', len(BASE) + len(ozgun) + len(NEW),
      'combos', sum(max(1, len(d.get('variants', []))) for d in BASE))
