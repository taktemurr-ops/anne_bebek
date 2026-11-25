"""Analizörün bildirdiği 'sabit ifadede metot çağrısı' hatalarında, hatayı
kapsayan en yakın `const` anahtar sözcüğünü kaldırır. Hata kalmayana kadar
tekrarlar."""
import re, subprocess, os, collections
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CODES = ('const_eval_method_invocation', 'non_constant_list_element', 'const_with_non_constant_argument',
         'non_constant_map_value', 'const_initialized_with_non_constant_value', 'invalid_constant',
         'non_constant_default_value', 'const_constructor_param_type_mismatch', 'const_eval_throws_exception')
OPEN = {'(': ')', '[': ']', '{': '}'}

def match_close(s, i):
    stack = [s[i]]; j = i + 1; q = None
    while j < len(s):
        c = s[j]
        if q:
            if c == '\\': j += 2; continue
            if c == q: q = None
        elif c in "'\"": q = c
        elif c in OPEN: stack.append(c)
        elif c in ')]}':
            stack.pop()
            if not stack: return j
        j += 1
    return len(s)

def remove_enclosing_const(src, off):
    for m in reversed(list(re.finditer(r'\bconst\s+', src[:off]))):
        k = m.end()
        while k < len(src) and src[k] not in '([{;': k += 1
        if k >= len(src) or src[k] == ';': continue
        if match_close(src, k) >= off:
            return src[:m.start()] + src[m.end():]
    return None

for it in range(12):
    out = subprocess.run(['dart', 'analyze', 'lib'], cwd=ROOT, capture_output=True, text=True,
                         env={**os.environ, 'PATH': '/opt/dartpkg/bin:' + os.environ['PATH']}).stdout
    errs = collections.defaultdict(list)
    for line in out.splitlines():
        m = re.match(r'\s*error - (.+?):(\d+):(\d+) - .* - (\w+)$', line)
        if m and m.group(4) in CODES:
            errs[m.group(1)].append((int(m.group(2)), int(m.group(3))))
    if not errs:
        print('temiz, tur', it); break
    n = 0
    for f, locs in errs.items():
        path = os.path.join(ROOT, 'lib', f)
        src = open(path, encoding='utf-8').read()
        lines = src.split('\n')
        offs = sorted({sum(len(l) + 1 for l in lines[:ln - 1]) + col - 1 for ln, col in locs}, reverse=True)
        for off in offs:
            new = remove_enclosing_const(src, off)
            if new is not None:
                src = new; n += 1
        open(path, 'w', encoding='utf-8').write(src)
    print('tur', it, 'kaldırılan const', n)
