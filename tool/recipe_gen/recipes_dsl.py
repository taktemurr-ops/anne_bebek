"""Compact helper to write detailed recipes and dump them to rewrites/*.json."""
import json, os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'rewrites')


# Ölçüsüz yazılmış yaygın malzemelere standart miktar verilir.
QTY = {'Tuz':'1 tatlı kaşığı tuz','Tuz, karabiber':'1 tatlı kaşığı tuz, yarım çay kaşığı karabiber','Tuz, kimyon':'1 tatlı kaşığı tuz, 1 çay kaşığı kimyon',
'Parmesan':'3 yemek kaşığı rendelenmiş parmesan','Maydanoz':'Yarım demet maydanoz','Pul biber':'1 çay kaşığı pul biber','Tuz, pul biber':'1 tatlı kaşığı tuz, 1 çay kaşığı pul biber',
'Tuz, kekik':'1 tatlı kaşığı tuz, 1 çay kaşığı kekik','Dereotu':'Yarım demet dereotu','Fesleğen':'1 avuç fesleğen yaprağı','Karabiber, muskat':'Yarım çay kaşığı karabiber, 1 tutam muskat',
'Tarçın':'1 çay kaşığı tarçın','Dereotu, karabiber':'Yarım demet dereotu, 1 tutam karabiber','Tuz, nane':'1 tatlı kaşığı tuz, 1 çay kaşığı kuru nane','Tuz, sumak':'1 tatlı kaşığı tuz, 1 tatlı kaşığı sumak',
'Tuz, karabiber, muskat':'1 tatlı kaşığı tuz, yarım çay kaşığı karabiber, 1 tutam muskat','Tuz, muskat':'1 tatlı kaşığı tuz, 1 tutam muskat','Tuz, nar taneleri':'1 tatlı kaşığı tuz, 3 yemek kaşığı nar tanesi',
'Tuz, dereotu':'1 tatlı kaşığı tuz, yarım demet dereotu','Birkaç dal maydanoz':'4–5 dal maydanoz','Birkaç dal dereotu':'4–5 dal dereotu','Birkaç dal nane':'4–5 dal nane','Birkaç yaprak marul':'3–4 yaprak marul',
'Üzeri için çörek otu ve susam':'Üzeri için 1 tatlı kaşığı çörek otu ve 1 tatlı kaşığı susam','Üzeri için mantar, biber, zeytin':'Üzeri için 4 mantar, 1 biber, 8 zeytin',
'Üzeri için Antep fıstığı veya hindistan cevizi':'Üzeri için 2 yemek kaşığı Antep fıstığı veya hindistan cevizi','Üzeri için zeytinyağı ve pul biber':'Üzeri için 1 yemek kaşığı zeytinyağı ve 1 çay kaşığı pul biber'}

def R(id, title, category, servings, prep, cook, difficulty, oven, ingredients, steps, tips, serving, storage):
    ingredients = [QTY.get(i, i) for i in ingredients]
    assert len(steps) >= 4, title
    assert len(ingredients) >= 3, title
    return dict(id=id, title=title, category=category, servings=servings, prepMinutes=prep,
                cookMinutes=cook, difficulty=difficulty, ovenCelsius=oven, ingredients=ingredients,
                steps=steps, tips=tips, serving=serving, storage=storage)


def _low(t):
    return t.replace('I', 'ı').replace('İ', 'i').lower()


def dump(name, recipes, drops=()):
    mine = {r['id'] for r in recipes}
    existing = set()
    for line in open(os.path.join(HERE, 'existing_titles.txt')).read().split('\n'):
        if '\t' in line:
            rid, title = line.split('\t', 1)
            if rid not in mine:
                existing.add(title)
    if name.startswith('n'):
        clash = [r['title'] for r in recipes if _low(r['title']) in existing]
        assert not clash, clash
        titles = [_low(r['title']) for r in recipes]
        assert len(titles) == len(set(titles)), 'duplicate title in batch'
    ids = [r['id'] for r in recipes]
    assert len(ids) == len(set(ids)), 'duplicate id'
    json.dump(recipes, open(os.path.join(OUT, name + '.json'), 'w', encoding='utf-8'),
              ensure_ascii=False, indent=0)
    if drops:
        path = os.path.join(OUT, 'drop.txt')
        existing = set(open(path).read().split()) if os.path.exists(path) else set()
        with open(path, 'a') as f:
            for d in drops:
                if d not in existing:
                    f.write(d + '\n')
    print(name, len(recipes), 'drops', len(drops))
