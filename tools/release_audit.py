"""Kaynak dosyası mevcudiyet kontrolü; derleme veya canlı test değildir."""
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
required = [
    'lib/main.dart', 'lib/screens/release_check_page.dart',
    'lib/screens/integration_status_page.dart',
    'lib/screens/baby_online_forum_page.dart',
    'lib/screens/women_online_forum_page.dart',
    'lib/screens/admin_dashboard_page.dart',
    'lib/screens/ai_assistant_page.dart',
    'lib/services/subscription_service.dart',
    'BABY_FORUM_SUPABASE_SETUP.sql', 'WOMEN_FORUM_SUPABASE_SETUP.sql',
    'FORUM_MODERATION_SETUP.sql', 'ADMIN_DASHBOARD_SETUP.sql',
    'PAKET_32_FINAL_DURUM_RAPORU.md',
]
missing = [item for item in required if not (root / item).is_file()]
main = (root / 'lib/main.dart').read_text(encoding='utf-8')
release = (root / 'lib/screens/release_check_page.dart').read_text(encoding='utf-8')
if 'ReleaseCheckPage()' not in main:
    missing.append('main.dart → ReleaseCheckPage bağlantısı')
if 'IntegrationStatusPage()' not in release:
    missing.append('release_check_page.dart → IntegrationStatusPage bağlantısı')
for item in required:
    print(('EKSİK' if item in missing else 'VAR'), item)
for item in missing:
    if item not in required:
        print('EKSİK', item)
print('Not: Bu kontrol uygulamanın çalıştığını kanıtlamaz.')
sys.exit(1 if missing else 0)
