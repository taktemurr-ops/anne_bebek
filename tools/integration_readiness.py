#!/usr/bin/env python3
"""Harici servislerin kurulum belgelerini denetler; canlı bağlantı testi değildir."""
from pathlib import Path
import json
r=Path(__file__).resolve().parents[1]
items={
 'cloud_auth': ['CLOUD_AUTH_SETUP.md'],
 'baby_forum': ['BABY_FORUM_SUPABASE_SETUP.sql'],
 'women_forum': ['WOMEN_FORUM_SUPABASE_SETUP.sql'],
 'moderation': ['FORUM_MODERATION_SETUP.sql'],
 'admin': ['ADMIN_DASHBOARD_SETUP.sql'],
 'ai_function': ['supabase/functions/anne-bebek-ai/index.ts'],
 'subscription': ['lib/services/subscription_service.dart'],
}
print(json.dumps({k:{'source_files_present':all((r/f).exists() for f in fs),'live_verified':False} for k,fs in items.items()},ensure_ascii=False,indent=2))
