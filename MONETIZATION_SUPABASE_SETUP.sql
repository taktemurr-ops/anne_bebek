-- Para kazanma altyapısı (abonelik doğrulama + iş birliği tıklama sayımı).
-- ADMIN_DASHBOARD_SETUP.sql'den SONRA, Supabase proje sahibi olarak çalıştırın.
-- service_role anahtarı yalnızca Edge Function içinde kullanılır; uygulamaya konmaz.

-- 1) Mağazadan doğrulanmış abonelikler. Satır yalnızca "subscription" Edge
--    Function'ı (service_role) tarafından yazılır; kullanıcı yalnızca kendi
--    satırlarını okuyabilir.
create table if not exists public.premium_subscriptions (
  purchase_key text primary key,              -- 'google:<purchaseToken>' veya 'apple:<originalTransactionId>'
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text not null check (platform in ('google', 'apple')),
  product_id text not null check (char_length(product_id) between 1 and 120),
  tier text not null check (tier in ('premium', 'family')),
  status text not null check (status in ('active', 'grace', 'canceled', 'expired', 'revoked', 'pending')),
  expires_at timestamptz,
  verification_ref text not null,             -- Google purchaseToken ya da Apple originalTransactionId
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists premium_subscriptions_user_idx on public.premium_subscriptions(user_id, expires_at desc);
alter table public.premium_subscriptions enable row level security;
revoke all on public.premium_subscriptions from anon, authenticated;
grant select on public.premium_subscriptions to authenticated;
drop policy if exists premium_subscriptions_own on public.premium_subscriptions;
create policy premium_subscriptions_own on public.premium_subscriptions
  for select to authenticated using (user_id = (select auth.uid()));

-- 2) İş birliği (affiliate) bağlantı tıklamaları: kişisel veri tutulmaz,
--    yalnızca ürün kimliği, iş ortağı ve gün.
create table if not exists public.affiliate_clicks (
  id bigint generated always as identity primary key,
  product_id text not null check (char_length(product_id) between 1 and 40),
  partner text not null check (char_length(partner) between 1 and 40),
  clicked_on date not null default current_date
);
create index if not exists affiliate_clicks_day_idx on public.affiliate_clicks(clicked_on);
alter table public.affiliate_clicks enable row level security;
revoke all on public.affiliate_clicks from anon, authenticated;

create or replace function public.log_affiliate_click(p_product_id text, p_partner text)
returns void language plpgsql security definer
set search_path = '' as $$
begin
  if p_product_id is null or p_partner is null
     or char_length(p_product_id) not between 1 and 40
     or char_length(p_partner) not between 1 and 40 then
    raise exception 'Geçersiz tıklama' using errcode = '22023';
  end if;
  insert into public.affiliate_clicks(product_id, partner) values (p_product_id, p_partner);
end;
$$;
revoke all on function public.log_affiliate_click(text, text) from public;
grant execute on function public.log_affiliate_click(text, text) to anon, authenticated;

-- 3) Yönetici gelir özeti: yalnızca toplu sayılar; kişi bilgisi yok.
create or replace function public.admin_revenue_summary()
returns jsonb language plpgsql stable security definer
set search_path = '' as $$
begin
  if not public.is_app_administrator() then
    raise exception 'Yönetici yetkisi gerekli' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'active_premium', (select count(distinct user_id) from public.premium_subscriptions
                        where tier = 'premium' and status in ('active', 'grace', 'canceled') and expires_at > now()),
    'active_family', (select count(distinct user_id) from public.premium_subscriptions
                        where tier = 'family' and status in ('active', 'grace', 'canceled') and expires_at > now()),
    'new_subscriptions_30d', (select count(*) from public.premium_subscriptions
                        where created_at > now() - interval '30 days'),
    'canceled_active', (select count(*) from public.premium_subscriptions
                        where status = 'canceled' and expires_at > now()),
    'by_product', coalesce((select jsonb_object_agg(product_id, c) from (
                        select product_id, count(*) c from public.premium_subscriptions
                        where status in ('active', 'grace', 'canceled') and expires_at > now()
                        group by product_id) x), '{}'::jsonb),
    'affiliate_clicks_30d', (select count(*) from public.affiliate_clicks
                        where clicked_on > current_date - 30),
    'affiliate_by_partner', coalesce((select jsonb_object_agg(partner, c) from (
                        select partner, count(*) c from public.affiliate_clicks
                        where clicked_on > current_date - 30 group by partner) y), '{}'::jsonb)
  );
end;
$$;
revoke all on function public.admin_revenue_summary() from public, anon;
grant execute on function public.admin_revenue_summary() to authenticated;
