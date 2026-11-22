// Supabase Edge Function (Deno): mağaza aboneliklerini sunucuda doğrular.
// Uygulama SUBSCRIPTION_API_URL = https://<proje>.supabase.co/functions/v1/subscription
//   GET  /status  -> { tier, active, expires_at }
//   POST /verify  -> { platform: 'google'|'apple', product_id, verification_data }
// Gerekli gizli değerler (supabase secrets set ...):
//   GOOGLE_SERVICE_ACCOUNT_JSON  Play Console'a bağlı servis hesabı JSON'u
//   ANDROID_PACKAGE_NAME          ör. com.annebebek.app
//   APPLE_ISSUER_ID, APPLE_KEY_ID, APPLE_PRIVATE_KEY (p8 içeriği), APPLE_BUNDLE_ID
//   PRODUCT_TIERS (isteğe bağlı) {"premium_monthly":"premium","family_monthly":"family"}
// SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY Supabase tarafından verilir.
// Uygulamaya hiçbir gizli anahtar konmaz; ücretli hak yalnızca bu doğrulamayla açılır.
import { importPKCS8, SignJWT, decodeJwt } from 'npm:jose@5';

type Json = Record<string, unknown>;
const json = (status: number, data: Json) => new Response(JSON.stringify(data), {
  status, headers: { 'Content-Type': 'application/json; charset=utf-8' },
});

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const ANON = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const SERVICE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

function tierFor(productId: string): 'premium' | 'family' {
  try {
    const map = JSON.parse(Deno.env.get('PRODUCT_TIERS') ?? '{}') as Record<string, string>;
    if (map[productId] === 'family' || map[productId] === 'premium') return map[productId] as 'premium' | 'family';
  } catch { /* varsayılana düş */ }
  return productId.toLowerCase().includes('family') || productId.toLowerCase().includes('aile') ? 'family' : 'premium';
}

async function db(path: string, init: RequestInit = {}) {
  return await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...init,
    headers: {
      apikey: SERVICE, Authorization: `Bearer ${SERVICE}`, 'Content-Type': 'application/json',
      ...(init.headers ?? {}),
    },
  });
}

// ---------------- Google Play ----------------
async function googleAccessToken(): Promise<string> {
  const sa = JSON.parse(Deno.env.get('GOOGLE_SERVICE_ACCOUNT_JSON') ?? '{}');
  if (!sa.client_email || !sa.private_key) throw new Error('google-not-configured');
  const key = await importPKCS8(sa.private_key, 'RS256');
  const now = Math.floor(Date.now() / 1000);
  const assertion = await new SignJWT({ scope: 'https://www.googleapis.com/auth/androidpublisher' })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .setIssuer(sa.client_email).setAudience('https://oauth2.googleapis.com/token')
    .setIssuedAt(now).setExpirationTime(now + 3000).sign(key);
  const r = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion }),
  });
  if (!r.ok) throw new Error('google-auth');
  return (await r.json()).access_token as string;
}

interface Verified { productId: string; status: string; expiresAt: string | null; ref: string; accountId?: string }

async function verifyGoogle(purchaseToken: string): Promise<Verified> {
  const pkg = Deno.env.get('ANDROID_PACKAGE_NAME');
  if (!pkg) throw new Error('google-not-configured');
  const token = await googleAccessToken();
  const r = await fetch(`https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(pkg)}/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`,
    { headers: { Authorization: `Bearer ${token}` } });
  if (!r.ok) throw new Error('google-invalid');
  const p = await r.json();
  const item = (p.lineItems ?? [])[0] ?? {};
  const state = String(p.subscriptionState ?? '');
  const status = state.endsWith('_ACTIVE') ? 'active'
    : state.endsWith('_IN_GRACE_PERIOD') ? 'grace'
    : state.endsWith('_CANCELED') ? 'canceled'
    : state.endsWith('_PENDING') ? 'pending'
    : 'expired';
  return {
    productId: String(item.productId ?? ''), status, expiresAt: item.expiryTime ?? null,
    ref: purchaseToken, accountId: p.externalAccountIdentifiers?.obfuscatedExternalAccountId,
  };
}

// ---------------- App Store ----------------
async function appleJwt(): Promise<string> {
  const issuer = Deno.env.get('APPLE_ISSUER_ID'), kid = Deno.env.get('APPLE_KEY_ID');
  const pem = Deno.env.get('APPLE_PRIVATE_KEY'), bid = Deno.env.get('APPLE_BUNDLE_ID');
  if (!issuer || !kid || !pem || !bid) throw new Error('apple-not-configured');
  const key = await importPKCS8(pem, 'ES256');
  const now = Math.floor(Date.now() / 1000);
  return await new SignJWT({ bid })
    .setProtectedHeader({ alg: 'ES256', kid, typ: 'JWT' })
    .setIssuer(issuer).setAudience('appstoreconnect-v1')
    .setIssuedAt(now).setExpirationTime(now + 1800).sign(key);
}

async function verifyApple(transactionId: string): Promise<Verified> {
  const jwt = await appleJwt();
  for (const host of ['https://api.storekit.itunes.apple.com', 'https://api.storekit-sandbox.itunes.apple.com']) {
    const r = await fetch(`${host}/inApps/v1/subscriptions/${encodeURIComponent(transactionId)}`,
      { headers: { Authorization: `Bearer ${jwt}` } });
    if (r.status === 404) continue;
    if (!r.ok) throw new Error('apple-invalid');
    const body = await r.json();
    let best: Verified | null = null;
    for (const group of body.data ?? []) {
      for (const last of group.lastTransactions ?? []) {
        // Yanıt Apple'dan, kimliği doğrulanmış TLS bağlantısıyla alınır.
        const tx = decodeJwt(String(last.signedTransactionInfo ?? '')) as Json;
        if (tx.bundleId !== Deno.env.get('APPLE_BUNDLE_ID')) continue;
        const code = Number(last.status);
        const status = code === 1 ? 'active' : code === 4 ? 'grace' : code === 5 ? 'revoked' : 'expired';
        const expiresAt = typeof tx.expiresDate === 'number' ? new Date(tx.expiresDate).toISOString() : null;
        const v: Verified = { productId: String(tx.productId ?? ''), status, expiresAt, ref: String(tx.originalTransactionId ?? transactionId) };
        if (!best || (v.expiresAt ?? '') > (best.expiresAt ?? '')) best = v;
      }
    }
    if (best) return best;
  }
  throw new Error('apple-invalid');
}

async function store(userId: string, platform: string, v: Verified) {
  const key = `${platform}:${v.ref}`;
  const existing = await db(`premium_subscriptions?purchase_key=eq.${encodeURIComponent(key)}&select=user_id`);
  const rows = existing.ok ? await existing.json() : [];
  if (rows.length && rows[0].user_id !== userId) throw new Error('owned-by-other');
  const r = await db('premium_subscriptions?on_conflict=purchase_key', {
    method: 'POST', headers: { Prefer: 'resolution=merge-duplicates' },
    body: JSON.stringify({
      purchase_key: key, user_id: userId, platform, product_id: v.productId, tier: tierFor(v.productId),
      status: v.status, expires_at: v.expiresAt, verification_ref: v.ref, updated_at: new Date().toISOString(),
    }),
  });
  if (!r.ok) throw new Error('db');
}

function activeRow(rows: Json[]): Json | undefined {
  const now = new Date().toISOString();
  return rows.find((r) => ['active', 'grace', 'canceled'].includes(String(r.status)) && String(r.expires_at ?? '') > now);
}

Deno.serve(async (req) => {
  if (!SUPABASE_URL || !ANON || !SERVICE) return json(503, { error: 'Abonelik servisi yapılandırılmadı.' });
  const auth = req.headers.get('Authorization') ?? '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : '';
  if (!token) return json(401, { error: 'Giriş yapmanız gerekiyor.' });
  const u = await fetch(`${SUPABASE_URL}/auth/v1/user`, { headers: { apikey: ANON, Authorization: `Bearer ${token}` } });
  if (!u.ok) return json(401, { error: 'Oturum geçersiz.' });
  const userId = String((await u.json()).id ?? '');
  if (!userId) return json(401, { error: 'Oturum geçersiz.' });
  const path = new URL(req.url).pathname;

  try {
    if (req.method === 'GET' && path.endsWith('/status')) {
      const r = await db(`premium_subscriptions?user_id=eq.${userId}&select=*&order=expires_at.desc.nullslast`);
      let rows: Json[] = r.ok ? await r.json() : [];
      let best = activeRow(rows);
      // Süresi dolmuş görünen kayıt yenilenmiş olabilir: mağazadan tekrar sor.
      if (!best && rows.length) {
        const latest = rows[0];
        try {
          const v = latest.platform === 'google'
            ? await verifyGoogle(String(latest.verification_ref))
            : await verifyApple(String(latest.verification_ref));
          await store(userId, String(latest.platform), v);
          const again = await db(`premium_subscriptions?user_id=eq.${userId}&select=*&order=expires_at.desc.nullslast`);
          rows = again.ok ? await again.json() : rows;
          best = activeRow(rows);
        } catch { /* mağaza erişilemezse ücretsiz kabul edilir */ }
      }
      return json(200, best
        ? { tier: best.tier, active: true, expires_at: best.expires_at }
        : { tier: 'free', active: false, expires_at: null });
    }

    if (req.method === 'POST' && path.endsWith('/verify')) {
      let body: Json;
      try { body = await req.json(); } catch { return json(400, { error: 'Geçersiz istek.' }); }
      const platform = body.platform, data = body.verification_data, productId = body.product_id;
      if ((platform !== 'google' && platform !== 'apple') || typeof data !== 'string' || data.length < 8 || data.length > 4096
          || typeof productId !== 'string' || productId.length > 120) {
        return json(400, { error: 'Geçersiz satın alma bilgisi.' });
      }
      const v = platform === 'google' ? await verifyGoogle(data) : await verifyApple(data);
      if (v.productId !== productId) return json(400, { error: 'Ürün eşleşmedi.' });
      if (platform === 'google' && v.accountId && v.accountId !== userId) return json(403, { error: 'Satın alma başka bir hesaba ait.' });
      await store(userId, platform, v);
      const ok = ['active', 'grace', 'canceled'].includes(v.status) && (v.expiresAt ?? '') > new Date().toISOString();
      return json(200, ok
        ? { tier: tierFor(v.productId), active: true, expires_at: v.expiresAt }
        : { tier: 'free', active: false, expires_at: v.expiresAt });
    }
    return json(404, { error: 'Bulunamadı.' });
  } catch (e) {
    const m = e instanceof Error ? e.message : '';
    if (m === 'owned-by-other') return json(403, { error: 'Satın alma başka bir hesaba ait.' });
    if (m.endsWith('not-configured')) return json(503, { error: 'Mağaza doğrulaması yapılandırılmadı.' });
    if (m.endsWith('invalid')) return json(400, { error: 'Satın alma doğrulanamadı.' });
    return json(502, { error: 'Doğrulama şu an yapılamıyor.' });
  }
});
