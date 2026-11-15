-- Paket 28. Execute AFTER both forum setup scripts in Supabase SQL Editor.
-- Never embed a service_role key or moderator credentials in Flutter.
create extension if not exists pgcrypto;

create table if not exists public.forum_moderators (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.forum_moderators enable row level security;
revoke all on public.forum_moderators from anon, authenticated;
-- Add moderators manually as project owner in SQL Editor:
-- insert into public.forum_moderators(user_id) values ('YOUR-AUTH-USER-UUID');

create table if not exists public.forum_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  forum text not null check (forum in ('baby','women')),
  content_kind text not null check (content_kind in ('post','reply')),
  content_id uuid not null,
  reason text not null check (char_length(btrim(reason)) between 3 and 200),
  status text not null default 'pending' check (status in ('pending','dismissed','removed')),
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  unique(reporter_id, forum, content_kind, content_id)
);
create index if not exists forum_reports_status_idx on public.forum_reports(status,created_at);
alter table public.forum_reports enable row level security;
revoke all on public.forum_reports from anon, authenticated;
grant select, insert on public.forum_reports to authenticated;

-- Private moderator membership: evaluated by SECURITY DEFINER, not readable by users.
create or replace function public.is_forum_moderator()
returns boolean language sql stable security definer
set search_path = '' as $$
  select exists(select 1 from public.forum_moderators where user_id = (select auth.uid()));
$$;
revoke all on function public.is_forum_moderator() from public, anon;
grant execute on function public.is_forum_moderator() to authenticated;

create policy "forum_reports_insert_self" on public.forum_reports for insert to authenticated
  with check (reporter_id = (select auth.uid()) and status = 'pending'
    and reviewed_by is null and reviewed_at is null);
create policy "forum_reports_read_moderator" on public.forum_reports for select to authenticated
  using ((select public.is_forum_moderator()));

-- Validate that the reported object exists, and that it isn't the reporter's own.
create or replace function public.validate_forum_report()
returns trigger language plpgsql security definer set search_path = '' as $$
declare owner_id uuid;
begin
  if new.forum = 'baby' and new.content_kind = 'post' then
    select author_id into owner_id from public.baby_forum_posts where id = new.content_id;
  elsif new.forum = 'baby' and new.content_kind = 'reply' then
    select author_id into owner_id from public.baby_forum_replies where id = new.content_id;
  elsif new.forum = 'women' and new.content_kind = 'post' then
    select author_id into owner_id from public.women_forum_posts where id = new.content_id;
  elsif new.forum = 'women' and new.content_kind = 'reply' then
    select author_id into owner_id from public.women_forum_replies where id = new.content_id;
  end if;
  if owner_id is null then raise exception 'İçerik bulunamadı'; end if;
  if owner_id = (select auth.uid()) then raise exception 'Kendi içeriğiniz şikâyet edilemez'; end if;
  return new;
end;
$$;
drop trigger if exists forum_reports_validate on public.forum_reports;
create trigger forum_reports_validate before insert on public.forum_reports
for each row execute function public.validate_forum_report();

-- Atomic decision. No direct UPDATE or DELETE permissions for users.
create or replace function public.moderate_forum_report(report_id uuid, decision text)
returns void language plpgsql security definer set search_path = '' as $$
declare r public.forum_reports%rowtype;
begin
  if not public.is_forum_moderator() then raise exception 'Moderatör yetkisi gerekli'; end if;
  if decision not in ('dismissed','removed') then raise exception 'Geçersiz karar'; end if;
  select * into r from public.forum_reports where id = report_id for update;
  if not found then raise exception 'Şikâyet bulunamadı'; end if;
  if r.status <> 'pending' then raise exception 'Şikâyet daha önce incelendi'; end if;
  if decision = 'removed' then
    if r.forum = 'baby' and r.content_kind = 'post' then
      delete from public.baby_forum_posts where id = r.content_id;
    elsif r.forum = 'baby' and r.content_kind = 'reply' then
      delete from public.baby_forum_replies where id = r.content_id;
    elsif r.forum = 'women' and r.content_kind = 'post' then
      delete from public.women_forum_posts where id = r.content_id;
    elsif r.forum = 'women' and r.content_kind = 'reply' then
      delete from public.women_forum_replies where id = r.content_id;
    end if;
  end if;
  update public.forum_reports set status = decision,
    reviewed_by = (select auth.uid()), reviewed_at = now() where id = report_id;
end;
$$;
revoke all on function public.moderate_forum_report(uuid,text) from public, anon;
grant execute on function public.moderate_forum_report(uuid,text) to authenticated;

-- In-app notifications for replies to a user's forum topic.
create table if not exists public.forum_notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references auth.users(id) on delete cascade,
  forum text not null check (forum in ('baby','women')),
  post_id uuid not null,
  kind text not null default 'reply' check (kind = 'reply'),
  created_at timestamptz not null default now(),
  read_at timestamptz
);
create index if not exists forum_notifications_owner_idx on public.forum_notifications(recipient_id,created_at desc);
alter table public.forum_notifications enable row level security;
revoke all on public.forum_notifications from anon, authenticated;
grant select, update(read_at) on public.forum_notifications to authenticated;
create policy "forum_notifications_read_self" on public.forum_notifications
  for select to authenticated using (recipient_id = (select auth.uid()));
create policy "forum_notifications_mark_read_self" on public.forum_notifications
  for update to authenticated using (recipient_id = (select auth.uid()))
  with check (recipient_id = (select auth.uid()));

create or replace function public.notify_forum_reply()
returns trigger language plpgsql security definer set search_path = '' as $$
declare owner_id uuid; forum_name text;
begin
  if tg_table_name = 'baby_forum_replies' then
    select author_id into owner_id from public.baby_forum_posts where id = new.post_id;
    forum_name := 'baby';
  else
    select author_id into owner_id from public.women_forum_posts where id = new.post_id;
    forum_name := 'women';
  end if;
  if owner_id is not null and owner_id <> new.author_id then
    insert into public.forum_notifications(recipient_id,forum,post_id)
      values(owner_id,forum_name,new.post_id);
  end if;
  return new;
end;
$$;
drop trigger if exists baby_reply_notify on public.baby_forum_replies;
create trigger baby_reply_notify after insert on public.baby_forum_replies
  for each row execute function public.notify_forum_reply();
drop trigger if exists women_reply_notify on public.women_forum_replies;
create trigger women_reply_notify after insert on public.women_forum_replies
  for each row execute function public.notify_forum_reply();

-- Operational requirements before public release: server-side per-user/IP rate limiting,
-- abuse prevention, retention/deletion policy, privacy/legal review, audit trail,
-- email/push delivery infrastructure, and live RLS/integration testing.
