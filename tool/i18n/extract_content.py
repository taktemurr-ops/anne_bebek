"""İçerik metinlerini (ansiklopedi, rehberler, tarifler, isimler…) çıkarır →
tool/i18n/content_source.json. Ekran metinleri extract.py ile ayrıca çıkarılır.
Ekranlar bu metinleri gölge Text/t() üzerinden gösterdiği için çeviri tablosu
aynı kaynak cümleyle eşleşir."""
import json, os, re, sys
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FILES = [
    'lib/data/encyclopedia/model.dart', 'lib/data/encyclopedia/baby.dart', 'lib/data/encyclopedia/child.dart',
    'lib/data/encyclopedia/pregnancy.dart', 'lib/data/encyclopedia/mother.dart', 'lib/data/encyclopedia/life.dart',
    'lib/data/encyclopedia/more.dart',
    'lib/services/pregnancy_week_guide.dart', 'lib/data/monthly_baby_guide.dart', 'lib/data/monthly_age_content.dart',
    'lib/data/baby_care_guidance.dart', 'lib/data/age_guides.dart', 'lib/data/baby_nutrition.dart',
    'lib/data/women_lifestyle_content.dart', 'lib/services/offline_assistant.dart',
    'lib/services/baby_activity_catalog.dart', 'lib/services/turkey_vaccine_schedule.dart',
    'lib/services/today_insights.dart', 'lib/services/pregnancy_timeline.dart',
    'lib/services/my_health.dart', 'lib/services/fever_log.dart', 'lib/services/mom_tools.dart',
    'lib/services/sound_synth.dart', 'lib/data/shopping_needs.dart', 'lib/data/product_catalog.dart',
    'lib/services/product_catalog.dart', 'lib/data/recipe_meta.dart',
]
GROUPS = {
    'recipes': ['lib/data/general_recipe_catalog.dart', 'lib/data/baby_recipe_catalog.dart'],
    'names': ['lib/data/baby_names.dart'],
}
LIT = re.compile(r"'((?:[^'\\\n]|\\.)*)'|\"((?:[^\"\\\n]|\\.)*)\"")

def strings(path):
    s = open(os.path.join(ROOT, path), encoding='utf-8').read()
    if path.endswith('baby_names.dart'):   # isimler çevrilmez; yalnız anlam ve köken
        out = []
        for m in re.finditer(r"BabyName\('[^']*', '\w', '([^']*)', '([^']*)'\)", s):
            out += [m.group(1), m.group(2)]
        return out
    s = re.sub(r'^\s*(import|export|part)\b.*$', '', s, flags=re.M)
    s = re.sub(r'^\s*//.*$', '', s, flags=re.M)
    s = re.sub(r"'[ \t]*\n[ \t]*'", '', s)   # bitişik dize birleştirme
    s = re.sub(r'"[ \t]*\n[ \t]*"', '', s)
    out = []
    for m in LIT.finditer(s):
        v = m.group(1) if m.group(1) is not None else m.group(2)
        v = v.replace("\\'", "'").replace('\\"', '"').replace('\\n', '\n').replace('\\$', '$')
        if '$' in v: continue
        if not re.search(r'[A-Za-zÇĞİÖŞÜçğıöşü]', v): continue
        if re.fullmatch(r'[a-z0-9_\-]+', v): continue          # kimlik
        if re.fullmatch(r'[A-Za-zÇĞİÖŞÜçğıöşü]{1,3}-\d+', v): continue
        if v[0].islower() and len(v.split()) <= 4 and not v.rstrip().endswith(('.', '!', '?')): continue  # arama anahtarı
        if '\\' in v or v in ('RIFF', 'WAVE', 'I', 'İ', 'ı') or v.startswith(')'): continue  # düzenli ifade / teknik
        out.append(v)
    return out

def main(groups):
    res, seen = [], set()
    files = list(FILES) if 'base' in groups else []
    for g in groups:
        files += GROUPS.get(g, [])
    for f in files:
        for v in strings(f):
            if v not in seen: seen.add(v); res.append(v)
    json.dump(res, open(os.path.join(ROOT, 'tool', 'i18n', 'content_source.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
    print(len(res), 'içerik metni', sum(map(len, res)), 'karakter')

if __name__ == '__main__':
    main(sys.argv[1:] or ['base'])
