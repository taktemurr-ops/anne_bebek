"""Çevirileri derler: tool/i18n/<dil>/*.tsv (kimlik<TAB>çeviri) →
lib/i18n/gen/strings*.dart. Kimlik = Türkçe kaynağın sha1'inin ilk 8 hanesi.
Kullanım: python3 tool/i18n/build.py           (derle)
          python3 tool/i18n/build.py show A B  (kaynak satırları A..B, kimlikle)
          python3 tool/i18n/build.py missing en (eksik kimlikleri listele)"""
import json, os, sys, glob, hashlib, re
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HERE = os.path.join(ROOT, 'tool', 'i18n')
LANGS = ['en', 'ar', 'de', 'fr', 'es', 'ru', 'pt', 'fa', 'id']

def hid(s): return hashlib.sha1(s.encode('utf-8')).hexdigest()[:8]

def sources():
    out = []
    for name in ('source.json', 'content_source.json'):
        p = os.path.join(HERE, name)
        if os.path.exists(p):
            out += json.load(open(p, encoding='utf-8'))
    seen = set(); res = []
    for s in out:
        if s not in seen: seen.add(s); res.append(s)
    return res

def load(lang):
    m = {}
    for f in sorted(glob.glob(os.path.join(HERE, lang, '*.tsv'))):
        for line in open(f, encoding='utf-8'):
            line = line.rstrip('\n')
            if not line.strip() or '\t' not in line: continue
            k, v = line.split('\t', 1)
            m[k.strip()] = v.replace('\\n', '\n')
    return m

def esc(s): return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$').replace('\n', '\\n')

def build():
    src = sources(); by = {hid(s): s for s in src}
    tables = []
    os.makedirs(os.path.join(ROOT, 'lib', 'i18n', 'gen'), exist_ok=True)
    for lang in LANGS:
        tr = load(lang); entries = []; bad = 0
        for k, v in tr.items():
            s = by.get(k)
            if s is None: continue
            if sorted(re.findall(r'\{\d+\}', s)) != sorted(re.findall(r'\{\d+\}', v)):
                bad += 1; continue
            entries.append((s, v))
        if not entries: continue
        body = ''.join(f"  '{esc(s)}': '{esc(v)}',\n" for s, v in sorted(entries))
        open(os.path.join(ROOT, 'lib', 'i18n', 'gen', f'strings_{lang}.dart'), 'w', encoding='utf-8').write(
            f"// Oluşturulan dosya: tool/i18n/build.py. Elle düzenlemeyin.\n"
            f"// ignore_for_file: lines_longer_than_80_chars\nconst Map<String, String> strings{lang.capitalize()} = {{\n{body}}};\n")
        tables.append(lang)
        print(f'{lang}: {len(entries)}/{len(src)} ({100*len(entries)//max(1,len(src))}%)' + (f', yer tutucu hatası {bad}' if bad else ''))
    imports = ''.join(f"import 'strings_{l}.dart';\n" for l in tables)
    body = ''.join(f"  '{l}': strings{l.capitalize()},\n" for l in tables)
    open(os.path.join(ROOT, 'lib', 'i18n', 'gen', 'strings.dart'), 'w', encoding='utf-8').write(
        f"// Oluşturulan dosya: tool/i18n/build.py. Elle düzenlemeyin.\n{imports}\n"
        f"const Map<String, Map<String, String>> translationTables = {{\n{body}}};\n")

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'show':
        src = sources(); a, b = int(sys.argv[2]), int(sys.argv[3])
        for s in src[a:b]:
            print(hid(s) + '\t' + s.replace('\n', '\\n'))
    elif len(sys.argv) > 1 and sys.argv[1] == 'missing':
        src = sources(); have = load(sys.argv[2])
        miss = [s for s in src if hid(s) not in have]
        print(len(miss), 'eksik')
        for s in miss[: int(sys.argv[3]) if len(sys.argv) > 3 else 50]:
            print(hid(s) + '\t' + s.replace('\n', '\\n'))
    else:
        build()
