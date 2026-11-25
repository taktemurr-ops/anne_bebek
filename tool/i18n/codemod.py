"""Çok dillilik için kod dönüşümü.
1) material/widgets/cupertino importlarında Text'i gizler, i18n/text.dart ekler.
2) Metin alan String parametrelerini t('...') ile sarar.
Tekrar çalıştırılabilir (idempotent)."""
import re, glob, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LIB = os.path.join(ROOT, 'lib')
PARAMS = ('labelText|hintText|helperText|tooltip|helpText|errorText|prefixText|suffixText|'
          'semanticLabel|barrierLabel|confirmText|cancelText|fieldLabelText|fieldHintText|'
          'applicationName|applicationLegalese|message')
STR = r"""'(?:[^'\\\n]|\\.)*'"""
param_re = re.compile(r'\b(' + PARAMS + r')(\s*:\s*)(' + STR + r')')
tab_re = re.compile(r'\b(Tab\([^()]*?\btext\s*:\s*)(' + STR + r')')
imp_re = re.compile(r"""import 'package:flutter/(material|widgets|cupertino)\.dart'( (?:show|hide) [^;]+)?;""")

def rel(path, target):
    return os.path.relpath(os.path.join(LIB, target), os.path.dirname(path)).replace(os.sep, '/')

changed = 0
for path in glob.glob(os.path.join(LIB, '**', '*.dart'), recursive=True):
    if '/lib/i18n/' in path:
        continue
    src = open(path, encoding='utf-8').read()
    orig = src
    uses_flutter = False
    def fix_imp(m):
        global uses_flutter
        lib, combinator = m.group(1), m.group(2) or ''
        if combinator.strip().startswith('show'):
            return m.group(0)  # yalnız belirli adlar; Text yoksa dokunma
        if 'Text' in re.findall(r'\b\w+\b', combinator):
            return m.group(0)
        hide = combinator.strip()
        new = f" hide Text{', ' + hide[5:] if hide.startswith('hide ') else ''}"
        return f"import 'package:flutter/{lib}.dart'{new};"
    src2 = imp_re.sub(fix_imp, src)
    if src2 != src or "hide Text" in src2:
        src = src2
        imp_text = f"import '{rel(path, 'i18n/text.dart')}';"
        if imp_text not in src:
            # İlk importtan sonra ekle.
            m = re.search(r"^import [^\n]+;\n", src, re.M)
            src = src[:m.end()] + imp_text + '\n' + src[m.end():]
    # Parametre sarma
    def wrap(m):
        return f"{m.group(1)}{m.group(2)}t({m.group(3)})"
    src = param_re.sub(wrap, src)
    src = tab_re.sub(lambda m: f"{m.group(1)}t({m.group(2)})", src)
    if 't(' in src and re.search(r'\bt\(\'', src):
        imp_t = f"import '{rel(path, 'i18n/i18n.dart')}' show t;"
        if imp_t not in src and f"import '{rel(path, 'i18n/i18n.dart')}';" not in src:
            m = re.search(r"^import [^\n]+;\n", src, re.M)
            src = src[:m.end()] + imp_t + '\n' + src[m.end():]
    if src != orig:
        open(path, 'w', encoding='utf-8').write(src)
        changed += 1
print('changed', changed)
