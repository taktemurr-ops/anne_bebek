#!/usr/bin/env python3
"""Yayın kapısı: kanıt yoksa başarılı sonucu vermez."""
from pathlib import Path
import json,sys
r=Path(__file__).resolve().parents[1]
evidence=r/'release_evidence'
checks={
 'flutter_analyze_pass':evidence/'flutter_analyze_pass.txt',
 'flutter_test_pass':evidence/'flutter_test_pass.txt',
 'android_device_test_pass':evidence/'android_device_test_pass.txt',
 'supabase_integration_pass':evidence/'supabase_integration_pass.txt',
 'ai_security_test_pass':evidence/'ai_security_test_pass.txt',
 'store_payments_test_pass':evidence/'store_payments_test_pass.txt',
 'content_editorial_signoff':evidence/'content_editorial_signoff.txt',
 'privacy_security_signoff':evidence/'privacy_security_signoff.txt',
}
status={k:(v.exists() and v.read_text(encoding='utf8').strip()=='PASS') for k,v in checks.items()}
print(json.dumps({'release_ready':all(status.values()),'checks':status},ensure_ascii=False,indent=2))
sys.exit(0 if all(status.values()) else 1)
