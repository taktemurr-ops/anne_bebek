#!/usr/bin/env python3
"""Statik kaynak envanteri. Flutter derlemesi veya runtime testi değildir."""
from pathlib import Path
import re, json, sys
root=Path(__file__).resolve().parents[1]
screens=list((root/'lib/screens').glob('*.dart'))
imports=[]
for f in (root/'lib').rglob('*.dart'):
 text=f.read_text(encoding='utf-8')
 for imp in re.findall(r"import\s+['\"]([^'\"]+)['\"]",text):
  if imp.startswith('package:') or imp.startswith('dart:'): continue
  target=(f.parent/imp).resolve()
  if not target.exists(): imports.append({'file':str(f.relative_to(root)),'import':imp})
recipes=(root/'lib/data/general_recipe_catalog.dart').read_text(encoding='utf-8')
ids=re.findall(r'GeneralRecipe\(id: ["\']([^"\']+)',recipes)
dups=sorted({x for x in ids if ids.count(x)>1})
result={'screens':len(screens),'dart_files':len(list((root/'lib').rglob('*.dart'))),'recipe_records':len(ids),'duplicate_recipe_ids':dups,'missing_relative_imports':imports,'limitations':['No Flutter compile','No device tests','No server tests','No medical editorial review']}
print(json.dumps(result,ensure_ascii=False,indent=2))
sys.exit(1 if imports or dups else 0)
