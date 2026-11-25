"""Regenerates lib/data/general_recipe_catalog.dart.

- Normalises categories to the 18 categories requested in Paket 39.
- Removes title duplicates ("(Alternatif tarif N)", "(ev usulü)") and
  near-duplicates (same category, same steps, >=75% same ingredients).
- Applies detailed rewrites from rewrites/*.json (id -> full recipe).
- Marks recipes whose steps are only generic template sentences as
  detailed: false, so the app can say so instead of pretending.
"""
import collections, json, glob, re, sys

SRC, OUT, REWRITES = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(SRC, encoding='utf-8').read()

def q(r, key):
    return re.search(key + r': "([^"]*)"', r).group(1)

def strs(block):
    return [x.replace('\\"', '"') for x in re.findall(r'"((?:[^"\\]|\\.)*)"', block)]

recs = []
for r in re.findall(r'GeneralRecipe\((.*?)\),\n', s, re.S):
    recs.append(dict(
        id=q(r, 'id'), title=q(r, 'title'), cat=q(r, 'category'),
        ing=strs(re.search(r'ingredients: \[(.*?)\]', r, re.S).group(1)),
        steps=strs(re.search(r'steps: \[(.*?)\]', r, re.S).group(1)),
        minutes=int(re.search(r'minutes: (\d+)', r).group(1))))

step_count = collections.Counter(x for r in recs for x in r['steps'])
template_steps = {k for k, v in step_count.items() if v >= 10}

def has(t, *words):
    t = t.lower()
    return any(w in t for w in words)

WORLD = ('pizza', 'kiş', 'crumble', 'polenta', 'kuskus', 'lazanya', 'risotto', 'köri',
         'curry', 'taco', 'burrito', 'noodle', 'wok', 'sushi', 'falafel', 'gnocchi',
         'tortilla', 'fajita', 'ratatouille', 'guacamole', 'paella', 'teriyaki')
DIET = ('kinoa', 'chia', 'karabuğday', 'light', 'fit ', 'diyet')

def category(r):
    c, t = r['cat'], r['title'].lower()
    if has(t, *WORLD) and c not in ('İçecekler',):
        return 'Dünya mutfağı'
    if (re.search(r'\bkek\b', t) or has(t, 'kurabiye', 'muffin', 'muzlu ekmek')) and c not in ('Çorbalar',):
        return 'Kek ve kurabiyeler'
    simple = {
        'Çorbalar': 'Çorbalar', 'Salatalar': 'Salatalar', 'Mezeler': 'Mezeler',
        'Pilavlar': 'Pilavlar', 'Makarnalar': 'Makarnalar', 'İçecekler': 'İçecekler',
        'Kahvaltı': 'Kahvaltılıklar', 'Tatlılar': 'Tatlılar', 'Tatlı': 'Tatlılar',
        'Hamur işleri': 'Hamur işleri', 'Hamur İşleri': 'Hamur işleri',
        'Sebze yemekleri': 'Sebze yemekleri', 'Sebze Yemekleri': 'Sebze yemekleri',
        'Zeytinyağlılar': 'Sebze yemekleri', 'Garnitürler': 'Sebze yemekleri',
        'Baklagiller': 'Bakliyat yemekleri', 'Bakliyatlar': 'Bakliyat yemekleri',
        'Bakliyat yemekleri': 'Bakliyat yemekleri',
        'Et yemekleri': 'Et yemekleri', 'Et Yemekleri': 'Et yemekleri', 'Et': 'Et yemekleri',
        'Tavuk yemekleri': 'Tavuk yemekleri', 'Tavuk Yemekleri': 'Tavuk yemekleri',
        'Tavuk': 'Tavuk yemekleri',
        'Balık yemekleri': 'Balık ve deniz ürünleri', 'Balık Yemekleri': 'Balık ve deniz ürünleri',
        'Balık': 'Balık ve deniz ürünleri', 'Deniz Ürünleri': 'Balık ve deniz ürünleri',
        'Balık ve deniz ürünleri': 'Balık ve deniz ürünleri',
    }
    if c in simple:
        if simple[c] in ('Salatalar', 'Kahvaltılıklar') and has(t, *DIET):
            return 'Diyet ve sağlıklı tarifler'
        return simple[c]
    if c in ('Makarna ve tahıl', 'Pilav ve makarna'):
        if has(t, 'makarna', 'erişte', 'şehriye') and not has(t, 'pilav'):
            return 'Makarnalar'
        if has(t, *DIET):
            return 'Diyet ve sağlıklı tarifler'
        return 'Pilavlar'
    if c in ('Atıştırmalık', 'Atıştırmalıklar'):
        if has(t, 'yulaf', 'nohut', 'sebze', 'yoğurt', 'karnabahar', 'kabak'):
            return 'Diyet ve sağlıklı tarifler'
        return 'Pratik tarifler'
    if c in ('Fırın', 'Fırın yemekleri', 'Fırın Yemekleri', 'Ana Yemekler', 'Ana yemekler', 'Et ve tavuk'):
        if has(t, 'börek', 'poğaça'):
            return 'Hamur işleri'
        if has(t, 'tavuk', 'hindi'):
            return 'Tavuk yemekleri'
        if has(t, 'balık', 'somon', 'levrek'):
            return 'Balık ve deniz ürünleri'
        if has(t, 'kıyma', 'köfte', 'etli', 'et '):
            return 'Et yemekleri'
        return 'Sebze yemekleri'
    raise SystemExit('unmapped category: %s (%s)' % (c, r['title']))

def base_title(t):
    return re.sub(r'\s*\((alternatif tarif \d+|ev usulü)\)\s*$', '', t.lower()).strip()

UNITS = ['su bardağı', 'yemek kaşığı', 'tatlı kaşığı', 'çay kaşığı', 'çay bardağı', 'yarım',
         'orta boy', 'küçük', 'büyük', 'adet', 'demet', 'avuç', 'diş', 'dilim', 'g ', 'ml',
         'kg', 'tutam', 'paket', 'kutu']

def norm_ing(x):
    x = re.sub(r'[\d,./½¼]+', '', x.lower())
    for w in UNITS:
        x = x.replace(w, ' ')
    return ' '.join(x.split())

rewrites = {}
for path in sorted(glob.glob(REWRITES + '/*.json')):
    for item in json.load(open(path, encoding='utf-8')):
        rewrites[item['id']] = item

import os
drop_ids = set(open(REWRITES + '/drop.txt').read().split()) if os.path.exists(REWRITES + '/drop.txt') else set()
kept, seen, dropped = [], set(), collections.Counter()
# Yakın kopya karşılaştırması tüm önceki KAYNAK tariflere göre yapılır;
# böylece bir tarif çıkarılınca kopyaları zincirleme geri gelmez.
prior = []
for r in recs:
    prior_now = list(prior)
    prior.append(r)
    if r['id'] in drop_ids:
        dropped['single-ingredient variant'] += 1
        continue
    if r['id'] in rewrites:
        kept.append(dict(r, rewrite=rewrites[r['id']]))
        seen.add(base_title(rewrites[r['id']].get('title', r['title'])))
        continue
    b = base_title(r['title'])
    if b in seen:
        dropped['title'] += 1
        continue
    ingredients = set(map(norm_ing, r['ing']))
    near = False
    for k in prior_now:
        if k['cat'] != r['cat']:
            continue
        other = set(map(norm_ing, k['ing']))
        if ingredients and other and len(ingredients & other) / len(ingredients | other) >= 0.75 \
                and r['steps'] == k['steps']:
            near = True
            break
    if near:
        dropped['near'] += 1
        continue
    seen.add(b)
    kept.append(r)

# New recipes (ids not in the source catalogue).
known = {r['id'] for r in recs}
for rid, item in rewrites.items():
    if rid not in known:
        kept.append(dict(id=rid, title=item['title'], cat=item['category'], ing=[], steps=[],
                         minutes=0, rewrite=item))

def dart(sv):
    return '"' + sv.replace('\\', '\\\\').replace('"', '\\"').replace('$', '\\$') + '"'

def dlist(xs):
    return '[' + ', '.join(dart(x) for x in xs) + ']'

titles_seen = collections.Counter(base_title(r['rewrite'].get('title', r['title']) if 'rewrite' in r else r['title']) for r in kept)
dups = [t for t, n in titles_seen.items() if n > 1]
if dups:
    raise SystemExit('duplicate titles: %s' % dups)

lines = []
counts = collections.Counter()
for r in kept:
    if 'rewrite' in r:
        w = r['rewrite']
        cat = w.get('category') or category(r)
        args = [
            'id: %s' % dart(r['id']), 'title: %s' % dart(w.get('title', r['title'])),
            'category: %s' % dart(cat), 'ingredients: %s' % dlist(w['ingredients']),
            'steps: %s' % dlist(w['steps']),
            'minutes: %d' % (w['prepMinutes'] + w['cookMinutes']),
            'servings: %d' % w['servings'], 'prepMinutes: %d' % w['prepMinutes'],
            'cookMinutes: %d' % w['cookMinutes'], 'difficulty: %s' % dart(w['difficulty']),
        ]
        if w.get('ovenCelsius'):
            args.append('ovenCelsius: %d' % w['ovenCelsius'])
        args += ['tips: %s' % dlist(w['tips']), 'serving: %s' % dart(w['serving']),
                 'storage: %s' % dart(w['storage'])]
    else:
        cat = category(r)
        detailed = not all(x in template_steps for x in r['steps'])
        args = ['id: %s' % dart(r['id']), 'title: %s' % dart(r['title']),
                'category: %s' % dart(cat), 'ingredients: %s' % dlist(r['ing']),
                'steps: %s' % dlist(r['steps']), 'minutes: %d' % r['minutes']]
        if not detailed:
            args.append('detailed: false')
    counts[cat] += 1
    lines.append('  GeneralRecipe(%s),' % ', '.join(args))

header = open(OUT + '.header', encoding='utf-8').read() if False else None
with open(OUT, 'w', encoding='utf-8') as f:
    f.write(open(sys.argv[4], encoding='utf-8').read())
    f.write('const generalRecipes = <GeneralRecipe>[\n')
    f.write('\n'.join(lines))
    f.write('\n];\n')

print('source', len(recs), 'kept', len(kept), 'dropped', dict(dropped),
      'rewrites', len(rewrites), 'not detailed',
      sum(1 for r in kept if 'rewrite' not in r and all(x in template_steps for x in r['steps'])))
for c, n in sorted(counts.items()):
    print(' ', c, n)
