"""Arayüz metinlerini çıkarır → tool/i18n/source.json (Türkçe kaynak listesi).
Enterpolasyonlar {0}, {1} yer tutucularına dönüştürülür."""
import re, glob, os, json
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SKIP_FILES = ('smart_shopping_page.dart', 'pregnancy_week_guide.dart', 'offline_assistant.dart',
              'guide_content.dart', 'monthly_baby_guide.dart', 'age_guides.dart', 'baby_activity_catalog.dart',
              'recipe_art.dart')
LIT = re.compile(r"""(?<![A-Za-z0-9_$])'((?:[^'\\\n]|\\.|\$\{(?:[^{}]|\{[^{}]*\})*\})*)'""")

SEQ = re.compile(LIT.pattern + r'(?:\s*' + LIT.pattern + r')*')

def template(s):
    n = [0]
    def rep(_):
        r = '{%d}' % n[0]; n[0] += 1; return r
    s = re.sub(r'\$\{(?:[^{}]|\{[^{}]*\})*\}', rep, s)
    s = re.sub(r'\$[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*', rep, s)
    return s.replace("\\'", "'").replace('\\n', '\n').replace('\\$', '$')

def wanted(v):
    if not re.search(r'[A-Za-zÇĞİÖŞÜçğıöşü]', v): return False
    if re.fullmatch(r"[a-z0-9_./:\-]+", v): return False
    if v.startswith(('package:', 'dart:', 'http', 'data:', '@')): return False
    if re.fullmatch(r'[A-Z0-9_]+', v): return False
    letters = re.sub(r'\{\d+\}', '', v)
    if not re.search(r'[A-Za-zÇĞİÖŞÜçğıöşü]{2}', letters): return False
    return True

def main():
    found = {}
    for f in sorted(glob.glob(os.path.join(ROOT, 'lib', '**', '*.dart'), recursive=True)):
        rel = os.path.relpath(f, ROOT)
        if '/data/' in rel or rel.endswith('_catalog.dart') or os.path.basename(f) in SKIP_FILES or ('/i18n/' in rel and not rel.endswith('language_picker.dart')):
            continue
        src = open(f, encoding='utf-8').read()
        # Yorumları at
        src = re.sub(r'^\s*//.*$', '', src, flags=re.M)
        for m in SEQ.finditer(src):
            ctx = src[max(0, m.start() - 40):m.start()]
            if re.search(r"(Key|getString|setString|read|write|storageKey|prefsKey|ValueKey|import|export)\(?\s*$", ctx):
                continue
            joined = ''.join(x.group(1) for x in LIT.finditer(m.group(0)))
            v = template(joined)
            if '${' in v or v.count('{') != v.count('}'):
                continue
            if wanted(v):
                found.setdefault(v, rel)
    out = os.path.join(ROOT, 'tool', 'i18n', 'source.json')
    json.dump(sorted(found), open(out, 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
    print(len(found), 'metin')

if __name__ == '__main__':
    main()
