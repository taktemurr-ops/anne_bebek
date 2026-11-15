-- Package 31: run AFTER BABY_FORUM_SUPABASE_SETUP.sql,
-- WOMEN_FORUM_SUPABASE_SETUP.sql and FORUM_MODERATION_SETUP.sql.
-- Execute as the Supabase project owner. Do NOT embed service_role keys in apps.
create table if not exists public.app_administrators (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.app_administrators enable row level security;
revoke all on public.app_administrators from anon, authenticated;

-- Provision trusted administrators manually in the Supabase SQL editor:
-- insert into public.app_administrators(user_id) values ('EXISTING-AUTH-USER-UUID');

create or replace function public.is_app_administrator()
returns boolean language sql stable security definer
set search_path = '' as $$
  select (select auth.uid()) is not null and exists (
    select 1 from public.app_administrators a
    where a.user_id = (select auth.uid())
  );
$$;
revoke all on function public.is_app_administrator() from public, anon;
grant execute on function public.is_app_administrator() to authenticated;

-- Administrators also qualify for existing forum moderation actions.
create or replace function public.is_forum_moderator()
returns boolean language sql stable security definer
set search_path = '' as $$
  select (select auth.uid()) is not null and (
    exists(select 1 from public.forum_moderators where user_id = (select auth.uid()))
    or public.is_app_administrator()
  );
$$;
revoke all on function public.is_forum_moderator() from public, anon;
grant execute on function public.is_forum_moderator() to authenticated;

-- No individual email addresses, health records, or private profile data.
-- An unauthorized caller receives an exception, not a partial dashboard.
create or replace function public.admin_dashboard_summary()
returns jsonb language plpgsql stable security definer
set search_path = '' as $$
begin
  if not public.is_app_administrator() then
    raise exception 'Yönetici yetkisi gerekli' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'users', (select count(*) from auth.users),
    'baby_posts', (select count(*) from public.baby_forum_posts),
    'women_posts', (select count(*) from public.women_forum_posts),
    'baby_replies', (select count(*) from public.baby_forum_replies),
    'women_replies', (select count(*) from public.women_forum_replies),
    'pending_reports', (select count(*) from public.forum_reports where status = 'pending')
  );
end;
$$;
revoke all on function public.admin_dashboard_summary() from public, anon;
grant execute on function public.admin_dashboard_summary() to authenticated;
